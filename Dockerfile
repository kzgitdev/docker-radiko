ARG UBUNTU_TAG=20.04

FROM ubuntu:$UBUNTU_TAG

ARG USERNAME=myname
ARG UID=1001
ENV USERNAME=$USERNAME
ENV UID=${UID}
ENV DEBIAN_FRONTEND=noninteractive

## intalling package
## NOTICE xmllint package dose not install using apt-get command.
## Another way using snapd package for using snap command.
RUN apt-get update && \
    apt-get install -y tzdata curl libxml2-utils ffmpeg ffmpeg libmp3lame0 perl

## set the timezone Asia/Tokyo
## and add user
RUN /bin/rm /etc/localtime && \
    /bin/ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    useradd --create-home --shell /bin/bash --uid $UID $USERNAME && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean

## copy radish.sh
COPY --chown=$USERNAME:$USERNAME rec_radiko.sh /tmp/rec_radiko.sh
RUN chmod +x /tmp/*.sh && mkdir /home/$USERNAME/rec-radiko && chown -R $USERNAME:$USERNAME /home/$USERNAME/rec-radiko

USER $USERNAME
WORKDIR /tmp
ENTRYPOINT ["/tmp/rec_radiko.sh"]
