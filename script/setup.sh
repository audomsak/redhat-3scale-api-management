#!/bin/sh

echo "ATTENTION!! Please make sure that you already prepared AWS S3 Bucket and credential to access AWS."
echo
echo "This simple script is about to install following components:"
echo "1. Red Hat 3Scale API Management"
echo "2. Red Hat Single Sign-On"
echo "3. A Demo Application"
echo

read -p "OCP Cluster Domain e.g. apps.cluster-k9blx.opentlc.com: " OCP_DOMAIN

echo "\nFollowing inputs will be used for set up 3Scale API Management by using AWS S3 as a storage."
read -p "AWS Access Key ID: " AWS_ACCESS_KEY_ID
read -p "AWS Secret Access Key: " AWS_SECRET_ACCESS_KEY
read -p "AWS S3 Bucket Name i.e. my3ScaleBucket: " AWS_BUCKET
read -p "AWS S3's Region i.e. ap-southeast-1: " AWS_REGION
echo
echo "------------------------------------------------------------------------------------------------------------------------------"
echo

# #Install 3Scale API Management from Operator Hub
threeScaleProject="3scale"
echo "Creating ${threeScaleProject} project and installing 3Scale API Management\n"

oc new-project ${threeScaleProject} --display-name="Red Hat 3Scale API Management" --description="Red Hat 3Scale API Management"
oc apply -f ../manifest/3scale/3scale-operator-group.yml -n ${threeScaleProject}
oc apply -f ../manifest/3scale/3scale-subscription.yml -n ${threeScaleProject}
echo
echo "Waiting for 3Scale Operator to be available..."

available="False"
while [[ $available != "True" ]]; do
  sleep 5
  available=$(oc get -n ${threeScaleProject} operators.operators.coreos.com 3scale-operator.3scale -o jsonpath='{.status.components.refs[?(@.apiVersion=="apps/v1")].conditions[?(@.type=="Available")].status}')
done;

echo "3Scale Operator is now available!!!"
echo

oc create secret generic aws-auth --from-literal=AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
--from-literal=AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
--from-literal=AWS_BUCKET=${AWS_BUCKET} \
--from-literal=AWS_REGION=${AWS_REGION} \
-n ${threeScaleProject}

sed "s/OCP_DOMAIN/${OCP_DOMAIN}/g" ../manifest/3scale/api-manager.yml | oc apply -f- -n ${threeScaleProject}

echo "Waiting for 3Scale API Manager to be available..."

available="False"
while [[ $available != "True" ]]; do
  sleep 5
  available=$(oc get -n ${threeScaleProject} apimanagers.apps.3scale.net apimanager -o jsonpath='{.status.conditions[?(@.type=="Available")].status}')
done;

echo "3Scale API Manager is now available!!!"
echo
echo "------------------------------------------------------------------------------------------------------------------------------"
echo

#Install Single Sign-On from Operator Hub
ssoProject="sso"
echo "Creating ${ssoProject} project and installing Single Sign-On...\n"

oc new-project ${ssoProject} --display-name="Red Hat Single Sign-On" --description="Red Hat Single Sign-On"
oc apply -f ../manifest/sso/sso-operator-group.yml -n ${ssoProject}
oc apply -f ../manifest/sso/sso-subscription.yml -n ${ssoProject}

echo "Waiting for SSO Operator to be available..."
available="False"
while [[ $available != "True" ]]; do
  sleep 5
  available=$(oc get -n ${ssoProject} operators.operators.coreos.com rhsso-operator.${ssoProject} -o jsonpath='{.status.components.refs[?(@.apiVersion=="apps/v1")].conditions[?(@.type=="Available")].status}')
done;
echo "SSO Operator is now available!!!"
echo

oc apply -f ../manifest/sso/keycloak.yml -n ${ssoProject}
oc apply -f ../manifest/sso/realm.yml -n ${ssoProject}
oc apply -f ../manifest/sso/user.yml -n ${ssoProject}

echo "Waiting for SSO instance to be available..."
available="False"
while [[ $available != "true" ]]; do
  sleep 5
  available=$(oc get -n ${ssoProject} keycloaks.keycloak.org keycloak -o jsonpath='{.status.ready}')
done;
echo "SSO instance is now available!!!"
echo
echo "------------------------------------------------------------------------------------------------------------------------------"
echo

# Get 3Scale and SSO credentials and URLs
threeScaleAdminUser=$(oc get secret system-seed -n ${threeScaleProject} --template={{.data.ADMIN_USER}} | base64 -d)
threeScaleAdminPassword=$(oc get secret system-seed -n ${threeScaleProject} --template={{.data.ADMIN_PASSWORD}} | base64 -d)
threeScaleRouteUrl=$(oc get $(oc get route -l zync.3scale.net/route-to=system-provider -o name -n ${threeScaleProject}) -o jsonpath='{.spec.host}' -n ${threeScaleProject})

ssoAdminUser=$(oc -n ${ssoProject} get secret credential-keycloak --template={{.data.ADMIN_USERNAME}} | base64 -d)
ssoAdminPassword=$(oc -n ${ssoProject} get secret credential-keycloak --template={{.data.ADMIN_PASSWORD}} | base64 -d)
ssoRouteUrl=$(oc get route keycloak -o jsonpath='{.spec.host}' -n ${ssoProject})

# Add the RHSSO certificate chain to the 3scale API Management certificate chain.
# This step is necessary because the 3scale API Management Zync pod does not trust the self-signed certificates of RHSSO.
# Export RHSSO Cert.
echo "Adding the RHSSO certificate chain to the 3scale API Management (Zync pod) certificate chain..."
echo -n | openssl s_client -connect "${ssoRouteUrl}:443" -servername "${ssoRouteUrl}" -showcerts | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > customCA.pem
# Export Zync Cert.
zync_pod=$(oc -n ${threeScaleProject} get pods -l threescale_component_element=zync-que -o name)
oc -n "${threeScaleProject}" exec "${zync_pod}" --  cat /etc/pki/tls/cert.pem > zync.pem
# Add RHSSO cert to Zync's cert chain
cat customCA.pem >> zync.pem
oc -n "${threeScaleProject}" create configmap zync-new-ca-bundle --from-file=./zync.pem
oc -n "${threeScaleProject}" set volume dc/zync-que --add --name=zync-new-ca-bundle \
  --mount-path /etc/pki/tls/zync/zync.pem \
  --sub-path zync.pem \
  --source='{"configMap":{"name":"zync-new-ca-bundle","items":[{"key":"zync.pem","path":"zync.pem"}]}}' \
&& oc -n "${threeScaleProject}" set env dc/zync-que SSL_CERT_FILE=/etc/pki/tls/zync/zync.pem
rm zync.pem customCA.pem

echo "------------------------------------------------------------------------------------------------------------------------------"
echo
# #Install a demo application

#echo "Creating library-system project and installing demo application...\n"
#oc new-project library-system --display-name="Library System Application Demo" --description="Library System Application Demo"
#oc apply -f ../manifest/demo-application/book-api.yml
#oc apply -f ../manifest/demo-application/book-frontend.yml

echo "Creating demo project and installing demo application...\n"
oc new-project demo --display-name="Application Demo" --description="Application Demo"
oc apply -f ../manifest/demo-application/demo-applications.yml

echo "------------------------------------------------------------------------------------------------------------------------------"
echo
echo "=============================================================================================================================="
echo "URLs and credentials"
echo "=============================================================================================================================="
echo "3Scale Web Console URL: https://${threeScaleRouteUrl}"
echo "3Scale Admin Username: ${threeScaleAdminUser}"
echo "3Scale Admin Password: ${threeScaleAdminPassword}"
echo
echo "SSO Web Console URL: https://${ssoRouteUrl}"
echo "SSO Admin Username: ${ssoAdminUser}"
echo "SSO Admin Password: ${ssoAdminPassword}"
echo "=============================================================================================================================="
echo
