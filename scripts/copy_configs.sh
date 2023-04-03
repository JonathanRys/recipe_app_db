#!/bin/bash

source /root/scripts/env_$ENV.sh

# Encrypt with
# gpg --batch --yes --passphrase <password> --output $file.gpg -c $file

# decrypt encrypted files
for file in /vagrant/config/*; do
    if [ -f "$file" ]; then
        file_name="${file/\/vagrant\/config/}"
        script_dest="${file_name//__//}"
        if [[ $file == *.gpg ]]; then
            # decrypt encrypted files
            decrypted_file="${script_dest//.gpg/}"
            gpg --decrypt $file --pinentry-mode loopback --passphrase $DECRYPT_PASSWORD > $decrypted_file
        else
            cp $file $script_dest
            chmod -R 644 $script_dest
        fi
    fi
done
