#!/bin/bash

export GIT_SSL_NO_VERIFY=1 
git config --global http.sslVerify false


RSA_REQ=./easyrsa
GITFILE=.git


install_easyrsa(){
    echo "yes" | $RSA_REQ init-pki
    echo 'easyrsa-ca' | $RSA_REQ build-ca nopass
    echo 'Start build Server Cert'
    echo 'yes' | $RSA_REQ build-server-full easyrsa-server nopass
    openssl verify -CAfile pki/ca.crt pki/issued/easyrsa-server.crt
    echo '' | $RSA_REQ gen-req easyrsa-client nopass
    echo 'yes' | $RSA_REQ sign-req client easyrsa-client
    openssl verify -CAfile pki/ca.crt pki/issued/easyrsa-client.crt
    clear
    printf "All Done"
    echo ''
}

download_easyrsa(){
    git init
    git remote add origin https://github.com/OpenVPN/easy-rsa.git
    git config core.sparsecheckout true
    echo "easyrsa3" >> .git/info/sparse-checkout
    git pull origin master
    mv easyrsa3/* .
    rm -rf easyrsa3
}

if [ -f "$RSA_REQ" ]; then
    echo "Found $RSA_REQ"
    install_easyrsa
    #if user do not download easyrsa
else
    if [ -d "$GITFILE" ]; then
        rm -rf $GITFILE
    fi
    download_easyrsa
    install_easyrsa
fi
