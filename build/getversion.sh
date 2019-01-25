VERSION_TYPE=$1

set -exu pipefail

# Fetch the tags because normally Jenkins will not do that...
git fetch -t

projectversion=`git describe --tags --long --match 'release_*'`

BASE_VERSION=${projectversion%%-*}
BASE_VERSION=${BASE_VERSION##*release_}

GITHASH=${projectversion##*-g}
BUILD_VERSION=$BASE_VERSION"-SNAPSHOT-"$GITHASH

if [ $VERSION_TYPE = BASE ]; then
    echo -n $BASE_VERSION
else
    echo -n $BUILD_VERSION
fi