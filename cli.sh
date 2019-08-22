#!/usr/bin/env zsh


HOST="$1"
if [ -z "$HOST" ];then
    cat README.md | sed -n '/Cli Usage/,//p'
    exit 1
fi
shift
DAYS=15
if [ "$1" = "--days" ]; then
    DAYS="$2"
    shift 2
fi
set -eu

scriptDir="$(dirname "$(test -L "$0" && readlink -nf "$0" || echo "$0")")"
leftDays="$("$scriptDir/index-cli.js" $HOST)"

# echo "HOST:$HOST"
# echo "DAYS:$DAYS"
# echo "curlOpts:$@"
msg="[$(date +"%Y-%m-%dT%H:%M:%S%z")] Checking uedsky.com: Expires in $leftDays days"
if [[ "$leftDays" -lt "$DAYS" ]]; then
    if [[ $# -gt 0 ]]; then
        curlOpts=()
        for arg in "$@"; do
            arg="${arg/\$CHECK_CERT_HOST/$HOST}"
            arg="${arg/\$CHECK_CERT_DAYS/$leftDays}"
            curlOpts+=($arg)
        done
        echo -e "\n[$(date +"%Y-%m-%dT%H:%M:%S%z")] ${curlOpts[@]}" >> /tmp/check-cert-request.log
        curl -sq "${curlOpts[@]}" >> /tmp/check-cert-request.log 2>&1
        msg="$msg [notified]"
    fi
fi
echo $msg