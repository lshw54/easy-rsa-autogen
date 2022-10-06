#!/bin/bash

export GIT_SSL_NO_VERIFY=1
git config --global http.sslVerify false

RSA_REQ=./easyrsa
GITFILE=.git

if [ -f "$RSA_REQ" ]; then
    echo "Found $RSA_REQ"
    echo "Pending to gen the CA"
    sleep 0.5
    echo "yes" | $RSA_REQ init-pki
    sleep 0.5
    echo 'Start build CA'
    echo 'easyrsa-ca' | $RSA_REQ build-ca nopass
    sleep 0.5
    echo 'Start build Server Cert'
    sleep 0.5
    echo 'yes' | $RSA_REQ build-server-full easyrsa-server nopass
    openssl verify -CAfile pki/ca.crt pki/issued/easyrsa-server.crt
    sleep 0.5
    echo 'Start build Client Cert'
    sleep 0.5
    echo '' | $RSA_REQ gen-req easyrsa-client nopass
    echo 'yes' | $RSA_REQ sign-req client easyrsa-client
    openssl verify -CAfile pki/ca.crt pki/issued/easyrsa-client.crt
    sleep 0.5
    clear
    sleep 0.5
    printf "All Done"
    echo ''
    #if user do not download easyrsa
else
    if [ -d "$GITFILE" ]; then
        rm -rf $GITFILE
    fi
    sleep 0.5
    echo 'Downloading the easyrsa'
    sleep 0.5
    git init
    git remote add origin https://github.com/OpenVPN/easy-rsa.git
    git config core.sparsecheckout true
    echo "easyrsa3" >> .git/info/sparse-checkout
    git pull origin master
    mv easyrsa3/* .
    rm -rf easyrsa3
    echo "Pending to gen the CA"
    sleep 0.5
    $RSA_REQ init-pki
    sleep 0.5
    echo 'Start build CA'
    echo 'easyrsa-ca' | $RSA_REQ build-ca nopass
    sleep 0.5
    echo 'Start build Server Cert'
    sleep 0.5
    echo 'yes' | $RSA_REQ build-server-full easyrsa-server nopass
    openssl verify -CAfile pki/ca.crt pki/issued/easyrsa-server.crt
    sleep 0.5
    echo 'Start build Client Cert'
    sleep 0.5
    echo '' | $RSA_REQ gen-req easyrsa-client nopass
    echo 'yes' | $RSA_REQ sign-req client easyrsa-client
    openssl verify -CAfile pki/ca.crt pki/issued/easyrsa-client.crt
    sleep 0.5
    clear
    sleep 0.5
    printf "All Done"
    echo ''
fi
