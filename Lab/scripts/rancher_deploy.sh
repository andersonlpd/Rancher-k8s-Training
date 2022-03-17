#! /bin/bash -x

# Generate random password
passwdfile="/tmp/.pass"
openssl rand -base64 14 > $passwdfile
admin_password=$(cat $passwdfile)

rancher_version=$1
k8s_version=$2
domain=$3
k8s_hosts=$4
jqimage="stedolan/jq"

# Pulling needed docker images

for image in $jqimage "rancher/rancher:${rancher_version}"; do
        until docker inspect $image > /dev/null 2>&1; do
                docker pull $image
                sleep 2
        done
done

# Running Rancher single-node container

docker run -d --name rancher --restart=unless-stopped -v /opt/rancher:/var/lib/rancher  -p 80:80 -p 443:443 rancher/rancher:${rancher_version}

# Check if the rancher docker is running
while true; do
        curl -sLk https://127.0.0.1/ping && break
        sleep 5
done

# Check if there's a bootstrap password in the log
RancherContainerID=$(docker ps | grep "rancher/rancher:${rancher_version}" | cut -d " " -f 1)
DefaultPassword=$(docker logs "$RancherContainerID" 2>&1 | grep "Bootstrap Password:" | sed -n 's/.*: \(.*\)$/\1/p')
if [ -z "$DefaultPassword" ]; then
        DefaultPassword="admin"
fi

# Get login information
while true; do
            LoginJson=$(curl -s "https://127.0.0.1/v3-public/localProviders/local?action=login" -H 'content-type: application/json' --data-binary '{"username":"admin","password":"'$DefaultPassword'"}' --insecure)
            LoginToken=$(echo $LoginJson | docker run --rm -i $jqimage -r .token)

            if [ "$LoginToken" != "null" ]; then
                    break
            else
                    sleep 5
            fi
done

# Change password for admin user
curl -s 'https://127.0.0.1/v3/users?action=changepassword' -H 'content-type: application/json' -H "Authorization: Bearer $LoginToken" --data-binary '{"currentPassword":"'$DefaultPassword'","newPassword":"'$admin_password'"}' --insecure

# Create API key and store API token
APIKey=$(curl -s 'https://127.0.0.1/v3/token' -H 'content-type: application/json' -H "Authorization: Bearer $LoginToken" --data-binary '{"type":"token","description":"automation"}' --insecure)
APIToken=$(echo $APIKey | docker run --rm -i $jqimage -r .token)

# Configure Rancher server-url
RancherServer="https://$domain"
curl -s 'https://127.0.0.1/v3/settings/server-url' -H 'content-type: application/json' -H "Authorization: Bearer $APIToken" -X PUT --data-binary '{"name":"server-url","value":"'$RancherServer'"}' --insecure

# Create Rancher cluster
### Need to add the option to disable NGINX ingress
ClusterResponse=$(curl -s 'https://127.0.0.1/v3/cluster' -H 'content-type: application/json' -H "Authorization: Bearer $APIToken" --data-binary '{"dockerRootDir":"/var/lib/docker","enableNetworkPolicy":false,"type":"cluster","rancherKubernetesEngineConfig":{"kubernetesVersion":"'$k8s_version'","addonJobTimeout":30,"ignoreDockerVersion":true,"sshAgentAuth":false,"type":"rancherKubernetesEngineConfig","authentication":{"type":"authnConfig","strategy":"x509"},"network":{"options":{"flannelBackendType":"vxlan"},"plugin":"canal","canalNetworkProvider":{"iface":"eth1"}},"ingress":{"type":"ingressConfig","provider":"nginx"},"monitoring":{"type":"monitoringConfig","provider":"metrics-server"},"services":{"type":"rkeConfigServices","kubeApi":{"podSecurityPolicy":false,"type":"kubeAPIService"},"etcd":{"creation":"12h","extraArgs":{"heartbeat-interval":500,"election-timeout":5000},"retention":"72h","snapshot":false,"type":"etcdService","backupConfig":{"enabled":true,"intervalHours":12,"retention":6,"type":"backupConfig"}}}},"localClusterAuthEndpoint":{"enabled":true,"type":"localClusterAuthEndpoint"},"name":"quickstart"}' --insecure)

# Extract clusterid
ClusterID=$(echo $ClusterResponse | docker run --rm -i $jqimage -r .id)

while true; do
        curl -sLk https://127.0.0.1/ping && break
        sleep 5
done

# Generate registration token
RegistrationCommand=$(curl -s 'https://127.0.0.1/v3/clusterregistrationtoken' -H 'content-type: application/json' -H "Authorization: Bearer $APIToken" --data-binary '{"type":"clusterRegistrationToken","clusterId":"'$ClusterID'"}' --insecure | docker run --rm -i $jqimage -r .nodeCommand)

RegistrationCommandComplete="${RegistrationCommand} --etcd --controlplane --worker"

# Installing kubernetes using Rancher registration command
for x in ${k8s_hosts//,/ }; do 
        ssh -i ~/.ssh/id_rsa adorigao@$x "${RegistrationCommandComplete}"; 
done