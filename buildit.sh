#!/bin/bash

# Latest Talend 5 version
export TOS_DI_VERS=5.6.3
export TOS_DI_FULLVERS=20160127_1448-V${TOS_DI_VERS}

# check dependencies and downloaded them if necessary
[ -e TOS_DI-${TOS_DI_FULLVERS}.zip ]                    || wget https://downloads.sourceforge.net/project/talend-studio/Talend%20Open%20Studio/${TOS_DI_VERS}/TOS_DI-${TOS_DI_FULLVERS}.zip
[ -e xulrunner-1.9.2.28pre.en-US.linux-x86_64.tar.bz2 ] || wget http://ftp.mozilla.org/pub/mozilla.org/xulrunner/nightly/2012/03/2012-03-02-03-32-11-mozilla-1.9.2/xulrunner-1.9.2.28pre.en-US.linux-x86_64.tar.bz2

# and now build the docker
# (remove all the --build-arg lines to download the TOS and XUL each time you rebuild)
docker build \
	--tag=solfin/talend-tos_di:5.6 \
	--build-arg TOS_DI_CMD="true" \
	--build-arg TOS_DI_LOCALFILE="TOS_DI-${TOS_DI_FULLVERS}.zip" \
	--build-arg XULRUNNER_CMD="true" \
	--build-arg XULRUNNER_LOCALFILE="xulrunner-1.9.2.28pre.en-US.linux-x86_64.tar.bz2" \
	.

