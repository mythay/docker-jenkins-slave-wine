
FROM jenkinsci/jnlp-slave
MAINTAINER Minglei Hei <mythay@126.com>


USER root
# Change to use China mirror, to speed up the apt download speed for test
# RUN sed -i 's/deb.debian.org/mirrors.163.com/g' /etc/apt/sources.list 

# Install packages required for connecting against X Server
RUN apt-get update && apt-get install -y --no-install-recommends \
				xvfb \
				rxvt \
				xauth \
				x11vnc \
				x11-utils \
				x11-xserver-utils \
                curl \
                unzip \
                ca-certificates

# Install wine and related packages
RUN dpkg --add-architecture i386 \
		&& apt-get update \
		&& apt-get install -y --no-install-recommends \
				wine \
				winetricks \
		&& rm -rf /var/lib/apt/lists/*




# create or use the volume depending on how container is run
# ensure that server and client can access the cookie
RUN mkdir -p /Xauthority && chown -R jenkins:jenkins /Xauthority

# start x11vnc and expose its port
ENV DISPLAY :0.0
EXPOSE 5900
COPY *.sh /scripts/
RUN chmod +x /scripts/*.sh

# During startup we need to prepare connection to X11-Server container
USER jenkins
ENV HOME /home/jenkins
ENV WINEPREFIX /home/jenkins/.wine
ENV WINEARCH win32

RUN echo "alias winegui='wine explorer /desktop=DockerDesktop,1024x768'" > ~/.bash_aliases 

RUN wine wineboot --init \
		&& /scripts/waitonprocess.sh wineserver 

ENTRYPOINT ["/scripts/wine-entrypoint.sh"]