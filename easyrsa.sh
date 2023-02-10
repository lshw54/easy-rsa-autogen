#!/usr/bin/env bash

export GIT_SSL_NO_VERIFY=1 
git config http.sslVerify false

RSA_REQ=./easyrsa
GITFILE=.gi

quick_generate_easyrsa(){
    echo "yes" | $RSA_REQ init-pki
    echo 'easyrsa-ca' | $RSA_REQ build-ca nopass
    echo 'Start build Server Cert'
    echo 'yes' | $RSA_REQ build-server-full easyrsa-server nopass
    openssl verify -CAfile pki/ca.crt pki/issued/easyrsa-server.crt
    echo '' | $RSA_REQ gen-req easyrsa-client nopass
    echo 'yes' | $RSA_REQ sign-req client easyrsa-client
    openssl verify -CAfile pki/ca.crt pki/issued/easyrsa-client.crt
    clear
    echo "All Done"
    echo ''
}

manuel_generate_prerequisites(){
    read -rp "Enter the root ca name (default: easyrsa): " root_ca_name
    input_name="${root_ca_name:-easyrsa}"

    read -rp "Enter the ca server name (default: easyrsa-server): " ca_server_name
    input_name="${ca_server_name:-easyrsa-server}"
    while [ "$ca_server_name" = "$root_ca_name" ]; do
        input_name="$root_ca_name-server"
        echo "ca_server_name cannot be the same as root_ca_name, using $ca_server_name instead."
    done

    read -rp "Enter the ca client name (default: easyrsa-client): " ca_client_name
    input_name="${ca_client_name:-easyrsa-client}"
    while [ "$ca_client_name" = "$root_ca_name" ] || [ "$ca_client_name" = "$ca_server_name" ]; do
        input_name="$root_ca_name-client"
        echo "ca_client_name cannot be the same as root_ca_name or ca_server_name, using $ca_client_name instead."
    done
}

manuel_generate_easyrsa(){
    echo "yes" | $RSA_REQ init-pki
    echo $root_ca_name | $RSA_REQ build-ca nopass
    echo 'Start build Server Cert'
    echo 'yes' | $RSA_REQ build-server-full $ca_server_name nopass
    openssl verify -CAfile pki/ca.crt pki/issued/$ca_server_name.crt
    echo '' | $RSA_REQ gen-req $ca_client_name nopass
    echo 'yes' | $RSA_REQ sign-req client $ca_client_name
    openssl verify -CAfile pki/ca.crt pki/issued/$ca_client_name.crt
    clear
    echo "All Done"
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

# Set the number of tries
tries=5
# Counter for the number of tries
counter=0
menu(){
    clear
    echo "-----------------------------------------------------------------------------------"
    echo "$script_brand"
    echo -e "-----------------------------------------------------------------------------------\n"
    echo "1. Quick Generate"
    echo "2. Manuel Generate"
    echo "3. Download EasyRSA Only"
    echo "4. Exit"
    read -rp "Choose the option [1-3]: " choice

    case $choice in
        1) 
            if [ -f "$RSA_REQ" ]; then
                echo "Found $RSA_REQ"
                quick_generate_easyrsa
            else
                if [ -d "$GITFILE" ]; then
                    rm -rf $GITFILE
                fi
                download_easyrsa
                quick_generate_easyrsa
            fi
            ;;
        2) 
            manuel_generate_prerequisites
            # Perform actions based on the input name
            if [ -f "$RSA_REQ" ]; then
                echo "Found $RSA_REQ"
                manuel_generate_easyrsa
            else
                if [ -d "$GITFILE" ]; then
                    rm -rf $GITFILE
                fi
                download_easyrsa
                manuel_generate_easyrsa
            fi
            ;;
        3)
            if [ -f "$RSA_REQ" ]; then
                echo "Found $RSA_REQ"
                #install_easyrsa
            else
                if [ -d "$GITFILE" ]; then
                    rm -rf $GITFILE
                fi
                download_easyrsa
                echo "Completed !!!"
                #install_easyrsa
            fi
            ;;
        4)
            clear
            echo "Exit"
            exit 0
            ;;
        *)
        counter=$((counter + 1))
        if [ "$counter" -ge "$tries" ]; then
            echo "You have repeatedly entered errors please check and re-run this script"
            exit 1
        fi
        echo "Invalid option. Please try again."
        sleep 0.3
            menu
    esac
}

script_brand=$(cat << EOF
  _____                ____  ____    _         _         _         ____            
 | ____|__ _ ___ _   _|  _ \/ ___|  / \       / \  _   _| |_ ___  / ___| ___ _ __  
 |  _| / _\` / __| | | | |_) \___ \ / _ \     / _ \| | | | __/ _ \| |  _ / _ \ '_ \ 
 | |__| (_| \__ \ |_| |  _ < ___) / ___ \   / ___ \ |_| | || (_) | |_| |  __/ | | |
 |_____\____|___/\___ |_| \_\____/_/   \_\ /_/   \_\____|\__\___/ \____|\___|_| |_|
                 |___/                                                             
EOF
)

menu
