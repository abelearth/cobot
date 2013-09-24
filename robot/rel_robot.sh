#!/bin/bash
# A script to fetch newest tag from svn repo
# exis code:
# 	0 - release SW successfully
#	11 - get code error 
#	12 - no newer code
set -x

SVN_SERVER=svn://192.168.0.1
REPO_NAME=xxx/tags
CODE_DIR=code
SW_OUTPUT_DIR=release
LOG_DIR=log
RELEASE_LOG=$LOG_DIR/release.log
SVN_USER=xxxxx
SVN_PASSWORD=xxxxx

get_latest_dir(){
	local DIR_LIST;
	local DIR_SVN_INFO="/tmp/dir_svn_info.txt";

	DIR_LIST=$(svn list $1 --username $SVN_USER --password $SVN_PASSWORD);

	if [ "$DIR_LIST"X == "X" ]; then
		echo "No directoty in target $1 !";
	return 1;
	fi;

	if [ -f $DIR_SVN_INFO ]; then
		rm $DIR_SVN_INFO;
	fi;

	for tag in ${DIR_LIST}
	do
		svn info $1/${tag} --username $SVN_USER --password $SVN_PASSWORD >> $DIR_SVN_INFO; 
	done;

	NEWEST_REV=$(grep "Last Changed Rev:" $DIR_SVN_INFO | sort -r | head -n 1);
	if [ "$NEWEST_REV" == "$(tail -1 $RELEASE_LOG)" ]; then
		echo "SW has alreay released on newest code!";
	return 2;
	fi;

	LATEST_TAG=$(grep "$(echo $NEWEST_REV)" $DIR_SVN_INFO -B9 | grep ^URL: | sed -n 's/^URL: //p');
	return 0;
}

#S0 prepare
export LANG=en_US.UTF-8
export RUN_MODE=ROBOT
mkdir -p $LOG_DIR 

################################################################################
#S1: get latest tag by revision
get_latest_dir ${SVN_SERVER}/${REPO_NAME};
RETURN_VAL=$?
if [ $RETURN_VAL != 0 ]; then
exit $((10 + $RETURN_VAL));
fi;

echo $LATEST_TAG;

################################################################################
#S2: check out source code
if [ -d ${CODE_DIR} ]; then
rm ${CODE_DIR} -R
fi;
svn co $LATEST_TAG ${CODE_DIR} --username $SVN_USER --password $SVN_PASSWORD;
RETURN_VAL=$?
if [ $RETURN_VAL != 0 ]; then
exit $((20 + $RETURN_VAL));
fi;

################################################################################
#S3: make
SW_OUTPUT_DIR=$SW_OUTPUT_DIR/$(basename $LATEST_TAG)
mkdir -p $SW_OUTPUT_DIR
./make_sw.sh $(pwd)/$CODE_DIR $(pwd)/$SW_OUTPUT_DIR $(pwd)/$LOG_DIR
RETURN_VAL=$?
if [ $RETURN_VAL != 0 ]; then
exit $((30 + $RETURN_VAL));
fi;

################################################################################
#S4: release

################################################################################
#S5: notify 
echo notify

################################################################################
#S6: log 
echo ""
echo "$(date)" >> $RELEASE_LOG; 
echo "$LATEST_TAG" >> $RELEASE_LOG;
echo "$NEWEST_REV" >> $RELEASE_LOG;
