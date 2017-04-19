#! /bin/bash

# libreria di appoggio
. ./installLib.sh

QUEUEMETRICS="/usr/local/queuemetrics/tomcat/webapps/queuemetrics"
CPROPSQM="$QUEUEMETRICS/WEB-INF/configuration.properties"

rv $CPROPSQM layout.splash "<h2><img src=\"./img/icons_silk/delete.png\"> Warning: The Espresso installation failed! Please <a href=\"http://queuemetrics.com/espresso_failure.jsp?pkg=$@\" target=\"_blank\">click here to resolve</a>.</h2>"

cat <<"EOF"

          _____                       __ 
         / ___/___ _ ___   ___  ___  / /_
        / /__ / _ `// _ \ / _ \/ _ \/ __/
        \___/ \_,_//_//_//_//_/\___/\__/ 
                                         
   _____             ___ _                      
  / ___/___   ___   / _/(_)___ _ __ __ ____ ___ 
 / /__ / _ \ / _ \ / _// // _ `// // // __// -_)
 \___/ \___//_//_//_/ /_/ \_, / \_,_//_/   \__/ 
                         /___/                  
                         
                !!! W A R N I N G !!!
     !!!  C A N N O T   C O N F I G U R E !!!
===================================================
The QueueMetrics package is installed successfully, 
but we have not been able to detect your system's 
configuration.

Please install the database manually by issuing:

cd /usr/local/queuemetrics/tomcat/webapps/queuemetrics/WEB-INF/README/
./installDb.sh

and configure QM manually as written on the manual.
===================================================
EOF
