#!/bin/bash
# A script to make all targets
set -x

CODE_DIR=$1
SW_OUTPUT_DIR=$2
MESSAGE_LOG_DIR=$3

CUSTOMER_CONFIG_FILE=customer_config.h
MATCH_STRING=#endif
COMPILER_DEF_DEFAULT_FILE=src/compiler.def

#code fix
find ${CODE_DIR} -name '*.sh' -o -name '*.exe' -o -name '*.EXE' -o -name '*.bat' -o -name '*.BAT' | xargs -I{} chmod +x {};

if [ ! -f ${CODE_DIR}/${CUSTOMER_CONFIG_FILE} ]; then
echo "No file ${CODE_DIR}/${CUSTOMER_CONFIG_FILE}.";
exit 1;
fi;

if [ ! -f target.txt ]; then
echo "No target.";
exit 2;
fi;

#get target list
cat target.txt | grep ^# -v > /tmp/target_clean.txt
cd ${CODE_DIR};
while read line
do           
#revert and clean code
svn revert ${CUSTOMER_CONFIG_FILE}
svn revert ${COMPILER_DEF_DEFAULT_FILE}
svn st | grep prj/lib/crypto/auth.lib -v | grep ^? | awk {'print $2'} | xargs -I{} rm {}
svn st --no-ignore | grep ^I | awk {'print $2'} | xargs -I{} rm {}

TARGET_CREATE_SW=$(echo $line | awk '{print $1 }')
if [ ! -f prj/bin/$TARGET_CREATE_SW ]; then
exit 3;
fi;

TARGET_COMPILER_DEF=$(echo $line | awk '{print $2 }')
if [ -f src/$TARGET_COMPILER_DEF ]; then
cp src/$TARGET_COMPILER_DEF $COMPILER_DEF_DEFAULT_FILE;
else
exit 3;
fi;

echo $line | awk '{for (i=3; i<=NF; i++) print $i }' | grep ^-D | cut -c 3- | awk '{print "#define ", $0}' | sed 's/=/\ /g' >> ${CUSTOMER_CONFIG_FILE}

make -C prj/App product_7z > $MESSAGE_LOG_DIR/make_$(date +%Y_%m_%d_%H%M%S).log 2>&1;
if [ $? != 0 ]; then
cd ..;
exit 4;
fi;

#create SW
cd prj/bin;
./${TARGET_CREATE_SW};
#output
mkdir -p $SW_OUTPUT_DIR/$TARGET_CREATE_SW/
cp product_* $SW_OUTPUT_DIR/$TARGET_CREATE_SW/
cp Ali_update* $SW_OUTPUT_DIR/$TARGET_CREATE_SW/
cd ../../

done </tmp/target_clean.txt

cd ..;
exit 0;
