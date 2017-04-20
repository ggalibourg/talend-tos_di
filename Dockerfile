#FROM solfin/debian:jessie
FROM debian:jessie


# prepare ENV variables
ENV JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64

# Install everything
RUN \
# Surpress Upstart errors/warning
	dpkg-divert --local --rename --add /sbin/initctl && \
	ln -sf /bin/true /sbin/initctl && \
# Load all required packages (for unzip, bzip, java dependencies, etc ...)
	DEBIAN_FRONTEND=noninteractive apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get -y upgrade && \
	DEBIAN_FRONTEND=noninteractive apt-get install -qy --no-install-recommends \
		bzip2 \
		curl \
		less \
		net-tools \
		openjdk-7-jdk \
		unzip \
		vim-tiny \
		x11-apps \
		xauth \
		&& \
		true


ARG TOS_DI_VERS=5.6.3
ARG TOS_DI_FULLVERS=20160127_1448-V${TOS_DI_VERS}
ARG TOS_DI_FILE=TOS_DI-${TOS_DI_FULLVERS}.zip

ARG TOS_DI_CMD="curl --location https://downloads.sourceforge.net/project/talend-studio/Talend%20Open%20Studio/${TOS_DI_VERS}/${TOS_DI_FILE} --output /tmp/${TOS_DI_FILE}"
ARG TOS_DI_LOCALFILE="Dockerfile"
# or "${TOS_DI_FILE}" if TOS_DI_CMD is "true"

RUN ${TOS_DI_CMD}
COPY ${TOS_DI_LOCALFILE} /tmp/

RUN \
# install TOS
	mkdir /apps && \
	cd /apps && \
	unzip /tmp/${TOS_DI_FILE} && \
	ln -s TOS_DI-${TOS_DI_FULLVERS} TOS_DI && \
	true

ARG XULRUNNER_FILE=xulrunner-1.9.2.28pre.en-US.linux-x86_64.tar.bz2

ARG XULRUNNER_CMD="curl http://ftp.mozilla.org/pub/mozilla.org/xulrunner/nightly/2012/03/2012-03-02-03-32-11-mozilla-1.9.2/${XULRUNNER_FILE} --output /tmp/${XULRUNNER_FILE}"
ARG XULRUNNER_LOCALFILE="Dockerfile"

COPY ${XULRUNNER_LOCALFILE} /tmp/
RUN ${XULRUNNER_CMD}


RUN \
# install XUL
	mkdir -p /apps && \
	cd /apps && \
	tar xpvfj /tmp/${XULRUNNER_FILE} && \
# default home directory for workspace
	mkdir /home/talend && \
# perform some cleanup
	apt-get --purge autoremove -y && \
	apt-get clean && \
	apt-get autoclean && \
	rm -rf /var/lib/apt/lists/* /tmp/* && \
# add XUL path to TOS_DI
	sed \
		-e '$a-Dorg.eclipse.swt.browser.XULRunnerPath=/apps/xulrunner/' \
		-i /apps/TOS_DI/TOS_DI-linux-gtk-x86_64.ini && \
# create a better linux launcher from existing one
	cp -p /apps/TOS_DI/TOS_DI-linux-gtk-x86.sh /apps/TOS_DI/TOS_DI-linux.sh && \
	sed \
		-e 's/.\/TOS_DI/$(dirname $0)\/TOS_DI/' \
		-e 's/.\/Talend-Studio-/$(dirname $0)\/TOS_DI-/' \
		-i /apps/TOS_DI/TOS_DI-linux.sh  && \
	true

VOLUME ["/home/talend"]

COPY entrypoint.sh /

ENTRYPOINT [ "/entrypoint.sh" ]
