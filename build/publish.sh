set -exu pipefail


pushToDockerRegistry() {
  sourceTag=$1
  targetTag=$2
  targetUrl=$3

  docker tag ${sourceTag} ${targetUrl}/${targetTag}
  docker push ${targetUrl}/${targetTag}
}

echo "Publishing to Docker registry"

docker login $ARTIFACTORY_DOCKER_URL -u $ARTIFACTORY_USR -p $ARTIFACTORY_PSW
cd $WORKSPACE

docker build -t terminal-anywhere-switch:${BUILD_VERSION} -f Dockerfile .

pushToDockerRegistry terminal-anywhere-switch:${BUILD_VERSION} ccv/terminal-anywhere-switch:${BUILD_VERSION} $ARTIFACTORY_DOCKER_URL
pushToDockerRegistry terminal-anywhere-switch:${BUILD_VERSION} ccv/terminal-anywhere-switch:${BUILD_VERSION} $NEXUS_DOCKER_URL
pushToDockerRegistry terminal-anywhere-switch:${BUILD_VERSION} ccv/terminal-anywhere-switch:latest-dev $NEXUS_DOCKER_URL
