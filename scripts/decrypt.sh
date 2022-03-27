#!usr/bin/sh

source env_$ENV.sh

for file in ../config/*.gpg; do
    new_file=`echo $file | tr '__' '/'`
    gpg --decrypt $file --pinentry-mode loopback --passphrase $ > $new_file
done
