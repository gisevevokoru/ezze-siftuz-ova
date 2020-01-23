#!/bin/bash
specUri="$1"
IFS=/ read scheme empty host api version remainder <<<$specUri
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
zipFile="$api-$version.zip"
mkdir -p "$directory"
git clone "https://$user@github.com/$user/$repository.git" "$directory"
curl \
    --request POST \
    --header 'content-type: application/json' \
    --data "$data" \
    --output "$zipFile" \
    https://generator3.swagger.io/api/generate \
&& unzip "$zipFile" \
&& rsync --archive --delete-after SwaggerClient-php/* "$directory/" \
&& rsync --archive .swagger-* "$directory/" \
&& rm -r "$zipFile" SwaggerClient-php/ .swagger-*
pushd "$directory"
if [[ ! -d ".git" ]]; then
    git init \
    && git config user.name gisevevokoru \
    && git config user.email g+isevevokoru@commodea.com \
    && git remote add origin "https://$user@github.com/$user/$repository.git" \
    && git push --set-upstream origin master
fi
git config user.name gisevevokoru \
&& git config user.email g+isevevokoru@commodea.com \
&& git pull --rebase
git add -A \
&& git commit -m "Rebuild from $specUri" \
&& git push
popd
