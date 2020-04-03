#!/bin/bash

if [ -z "$(which curl)" ]; then 
	printf 'Need curl\n';
	exit 1;
fi

mkdir -p files
pushd files
curl -OL https://github.com/sgidevnet/sgug-rse/releases/download/v0.0.4beta/sgug-rse-srpms-0.0.4beta.tar.gz
tar -xvf sgug-rse-srpms*.tar.gz
mv SRPMS/{gcc-9.2.0-1.sgugbeta.src.rpm,binutils-2.23.2-24.sgugbeta.src.rpm} .
rm -rf SRPMS
popd