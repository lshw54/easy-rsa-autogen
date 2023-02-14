# easy-rsa-autogen
This is a bash script for generating certificates with EasyRSA. It has a menu with three options: Quick Generate, Manuel Generate, and Download EasyRSA Only.

- Quick Generate: generates server and client certificates with default names.
- Manuel Generate: prompts the user for the names of the root CA, the CA server, and the CA client and generates the certificates.
- Download EasyRSA Only: downloads the EasyRSA script without generating any certificates.

## How to use
To use this script, you can run the following commands in a terminal:
```bash
mkdir -p autogen && cd autogen
wget -N --no-check-certificate -q -O easyrsa.sh "https://raw.githubusercontent.com/lshw54/easy-rsa-autogen/main/easyrsa.sh" && chmod +x easyrsa.sh && bash easyrsa.sh
```
## More information about easy-rsa

[Official Documentation](https://github.com/OpenVPN/easy-rsa.git)