#!/bin/bash

VERSION=19.06.2
ROOT=${PWD}
BASEBUILD=$ROOT/_BUILD_
BUILDDIR=$BASEBUILD/queuemetrics-espresso-$VERSION
BN=${BUILD_NUMBER-0}
TGZ=$BASEBUILD/queuemetrics-espresso-$VERSION.tar.gz
NOW=$BN-`date -u +%Y%m%d.%H%M`

# PREREQUISITIES
for BINARY in rpmbuild tree tar dos2unix
do
        which "${BINARY}" > /dev/null 2>&1
        if [ "${?}" != "0" ]
        then
                echo "You need "${BINARY}" to execute this script; aborting..."
                exit 1
        fi
done

echo "Now building QueueMetrics Espresso version $VERSION - $NOW"

rm -rf $BASEBUILD
mkdir -p $BUILDDIR/bin

# Builds RPM 
RPMDIR=$BASEBUILD/myRPMs
mkdir -p $RPMDIR/SOURCES
mkdir -p $RPMDIR/BUILD
mkdir -p $RPMDIR/SPECS
mkdir -p $RPMDIR/RPMS
mkdir -p $RPMDIR/RPMS/noarch
mkdir -p $RPMDIR/RPMS/i386
mkdir -p $RPMDIR/RPMS/x86_64
mkdir -p $RPMDIR/SRPMS

# Creates tar
cp -r ./queuemetrics-espresso/* $BUILDDIR
cd $BASEBUILD
tar zcf $TGZ queuemetrics-espresso-$VERSION
cd $ROOT
cp $TGZ $RPMDIR/SOURCES/espresso.tar.gz

ARCH=noarch
ABSRPM=`cd "$RPMDIR"; pwd`
FILE=$BASEBUILD/espresso_$ARCH.spec

cp ./queuemetrics-espresso.spec $FILE
sed -i -e "s/_VERSION_/$VERSION/g" $FILE
sed -i -e "s/_RELEASE_/$BN/g" $FILE
sed -i -e "s/_ARCH_/$ARCH/g" $FILE

rpmbuild -bb --target=$ARCH \
      --define="%_topdir $ABSRPM" \
      --define '_binary_payload       w9.gzdio' \
      --define '_binary_filedigest_algorithm  1' \
      --define '__jar_repack 0' \
      $FILE

tree -h $RPMDIR/RPMS




