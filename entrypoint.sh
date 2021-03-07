#!/bin/sh
registration_url="https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPOSITORY}/actions/runners/registration-token"
echo "Requesting registration URL at '${registration_url}'"

payload=$(curl -sX POST -H "Accept: application/vnd.github.v3+json" -H "Authorization: Bearer ${GITHUB_PAT}" ${registration_url})
RUNNER_TOKEN=$(echo "$payload" | jq .token --raw-output)

echo "$(hostname) - ${RUNNER_TOKEN} - ${GITHUB_OWNER}/${GITHUB_REPOSITORY}"
./config.sh --name "$(hostname)" --token "${RUNNER_TOKEN}" --url https://github.com/${GITHUB_OWNER}/${GITHUB_REPOSITORY} --work /home/github/_work --unattended --replace

remove() {
    ./config.sh remove --unattended --token "${RUNNER_TOKEN}"
}

trap 'remove; exit 130' INT
trap 'remove; exit 143' TERM

./run.sh "$*" &

wait $!
