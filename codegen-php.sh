#!/bin/bash
specUri="$1"
IFS=/ read scheme empty host docs section version remainder <<<$specUri
api=${section#*_}
directory="ezze-siftuz/${api,,}-${version,,}"
user="gisevevokoru"
repository="ezze-siftuz-${api,,}-${version,,}"
data=$(
    printf '{
        "specURL" : "%s",
        "options" : {
            "variableNamingConvention" : "camelCase",
            "invokerPackage" : "EzzeSiftuz\\\\%s%s",
            "gitUserId" : "%s",
            "gitRepoId" : "%s",
            "artifactVersion" : "v1.0"
        },
        "lang" : "php",
        "type" : "CLIENT",
        "codegenVersion" : "V3"
    }' \
    $specUri $api ${version^} $user $repository
)
mkdir -p "$directory"
pushd "$directory"
zipFile="../$api-$version.zip"
if [[ ! -d ".git" ]]; then
    read -sp "Go to Github now and create the repository $user/$repository. Then press Enter."
    git clone "https://$user@github.com/$user/$repository.git" ./ \
    && git config user.name gisevevokoru \
    && git config user.email g+isevevokoru@commodea.com
else
    git pull --rebase origin master
fi
curl \
    --request POST \
    --header 'content-type: application/json' \
    --data "$data" \
    --output "$zipFile" \
    https://generator3.swagger.io/api/generate \
&& unzip "$zipFile" \
&& rsync --archive --delete-after SwaggerClient-php/* "./" \
&& rm -r "$zipFile" SwaggerClient-php/
git add -A \
&& git commit -m "Rebuild from $specUri" \
&& git push --set-upstream origin master
popd
