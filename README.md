# docker-radiko
docker image for recoding radiko free area

## Overview
radiko free area recording docker image and usage guid

## feature
The permission of the generated .m4a file is general user.


## Usage
0. edit .env file (edit USERNAME and UID)
1. build docker image using Dockerfile
2. run the docker image

{USERNAME}: currnet user name
{DOCKER_IMAGE_TAG_NAME}: to use docker image tag name
{STATION}: radiko channel name. TBS LFR FMJ ...
{MUNITES}: recording time. 30 60 120 ... 1 houre is 60
```
docker run --rm -v /home/{USERNAME}/rec-radiko:/home/{USERNAME}/rac-radiko -t {DOCKER_IMAGE_TAG_NAME} {STATION} {MUNITES}
```
3. Recording schedule using cron command 
sample
```
crontab -e
# 月[深夜:火]-土[深夜:日] LFR オールナイトニッポン(25:00-27:00)
# 2-7: 2:火, 3:水, 4:木, 5:金, 6:土, 7or1:月
0 1 * * 2-7 /usr/bin/docker run --rm -v /home/myname/rec-radiko:/home/myname/rec-radiko -t kaz/radiko:3.8 LFR 120
# 土[深夜:日] FMJ DJ太郎 SATURDAY NINGT VIBES(00:00-03:00)
0 0 * * 7 /usr/bin/docker run --rm -v /home/myname/rec-radiko:/home/myname/rec-radiko -t kaz/radiko:3.8 FMJ 180
```

## Reference document
https://gist.github.com/matchy2/3956266
https://github.com/uru2/radish
