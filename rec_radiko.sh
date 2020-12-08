#!/bin/bash

LANG=ja_JP.utf8

pid=$$
date=`date '+%Y%m%d-%H%M'`

# outdir="."
outdir="/home/${USERNAME}/rec-radiko"

if [ $# -le 1 ]; then
  echo "usage : $0 channel_name duration(minuites) [outputdir] [prefix]"
  exit 1
fi

if [ $# -ge 2 ]; then
  channel=$1
  DURATION=`expr $2 \* 60`
fi
if [ $# -ge 3 ]; then
  outdir=$3
fi
PREFIX=${channel}
if [ $# -ge 4 ]; then
  PREFIX=$4
fi

####
# Define authorize key value (from http://radiko.jp/apps/js/playerCommon.js)
RADIKO_AUTHKEY_VALUE="bcd151073c03b352e1ef2fd66c32209da9ca0afa"


if [ -f auth1_fms_${pid} ]; then
  rm -f auth1_fms_${pid}
fi

#
# access auth1_fms
#
curl -s \
     --header "pragma: no-cache" \
     --header "X-Radiko-App: pc_html5" \
     --header "X-Radiko-App-Version: 0.0.1" \
     --header "X-Radiko-User: test-stream" \
     --header "X-Radiko-Device: pc" \
     --dump-header auth1_fms_${pid} \
     -o /dev/null \
     https://radiko.jp/v2/api/auth1

if [ $? -ne 0 ]; then
  echo "failed auth1 process"
  exit 1
fi

#
# get partial key
#
authtoken=`perl -ne 'print $1 if(/x-radiko-authtoken: ([\w-]+)/i)' auth1_fms_${pid}`
offset=`perl -ne 'print $1 if(/x-radiko-keyoffset: (\d+)/i)' auth1_fms_${pid}`
length=`perl -ne 'print $1 if(/x-radiko-keylength: (\d+)/i)' auth1_fms_${pid}`
partialkey=`echo "${RADIKO_AUTHKEY_VALUE}" | dd bs=1 "skip=${offset}" "count=${length}" 2> /dev/null | base64`

#echo "authtoken: ${authtoken} \noffset: ${offset} length: ${length} \npartialkey: $partialkey"

rm -f auth1_fms_${pid}

if [ -f auth2_fms_${pid} ]; then
  rm -f auth2_fms_${pid}
fi

#
# access auth2_fms
#
curl -s \
     --header "pragma: no-cache" \
     --header "X-Radiko-User: test-stream" \
     --header "X-Radiko-Device: pc" \
     --header "X-Radiko-AuthToken: ${authtoken}" \
     --header "X-Radiko-PartialKey: ${partialkey}" \
     -o auth2_fms_${pid} \
     https://radiko.jp/v2/api/auth2

if [ $? -ne 0 -o ! -f auth2_fms_${pid} ]; then
  echo "failed auth2 process"
  exit 1
fi

#echo "authentication success"
areaid=`perl -ne 'print $1 if(/^([^,]+),/i)' auth2_fms_${pid}`
#echo "areaid: $areaid"

rm -f auth2_fms_${pid}

#
# get stream-url
#

if [ -f ${channel}.xml ]; then
  rm -f ${channel}.xml
fi

curl -s "http://radiko.jp/v2/station/stream_smh_multi/${channel}.xml" -o ${channel}.xml
stream_url=`xmllint --xpath "/urls/url[@areafree='0'][1]/playlist_create_url/text()" ${channel}.xml`

rm -f ${channel}.xml

#
# ffmpeg
#
ffmpeg \
  -loglevel error \
  -fflags +discardcorrupt \
  -headers "X-Radiko-Authtoken: ${authtoken}" \
  -i "${stream_url}" \
  -acodec copy \
  -vn \
  -bsf:a aac_adtstoasc \
  -y \
  -t ${DURATION} \
  "/tmp/${channel}_${date}.m4a"

ffmpeg -loglevel quiet -y -i "/tmp/${channel}_${date}" -acodec libmp3lame0 -ab 128k "${outdir}/${PREFIX}_${date}.m4a"
mv /tmp/${channel}_${date}.m4a "${outdir}/${PREFIX}_${date}.m4a"
if [ $? = 0 ]; then
  rm -f "/tmp/${channel}_${date}.m4a"
fi
chown -R $USERNAME:$USERNAME "${outdir}/${channel}_${date}.m4a"
