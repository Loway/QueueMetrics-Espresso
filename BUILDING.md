# How to build

## Set up a build box

You will need a Centos 6 or 7 system.

    yum install rpm-build dos2unix git tree

## Building

Access the box as a non-root account.

    git clone https://github.com/Loway/QueueMetrics-Espresso.git
    cd QueueMetrics-Espresso/
    ./createRpm.sh

This will create the RPM, that you can the install as:

    yum localupdate -y ...../_BUILD_/myRPMs/RPMS/noarch/queuemetrics-espresso-0.0.0-0.noarch.rpm

That's all.

