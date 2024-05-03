#! /usr/bin/sh

localpath='./download'
mkdir $localpath
wget "https://mirbase.org/download/" -R '*.html,*.js,*.css' \
  --reject-regex '.*/images/.*' \
  -r -nH --cut-dirs=1 \
  -l 1 -P $localpath
  

mv $localpath/README/index.html.tmp $localpath/README.html

find $localpath -type f -name 'index.html.tmp' -delete ;
find $localpath -type d -empty -delete