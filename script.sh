#!/usr/bin/bash

echo 'Starting script...'

domain=$1

echo '[+] Finding subdomains for' $domain
echo

subfinder -silent -d $domain > raw_result.txt 

echo '[-] Subfinder done'
echo

echo '[+] Domains recognition for' $domain
echo

findomain --quiet -t $domain >> raw_result.txt

echo '[-] Find domain done'
echo

cat raw_result.txt | sort -u > results

sed -i '/^$/d' results

rm raw_result.txt

echo
for i in $(cat results); do
    if ping -c 1 $i &> /dev/null; then
        echo $i >> targets
    fi
done

rm results

echo '[+] Checking for alive domains'
echo

# FAZER 2 LISTAS, UMA PRO NUCLEI E OUTRA PRO NMAP, O NUCLEI PRECISA DO PROTOCOLO HTTP, O NMAP NÃO
httpx --list targets | awk '{print $1}'

echo "[*] Total domains found in $domain: $(wc -l targets | awk '{print $1}')"
echo


echo "[+] Starting nmap banner scan"

while read aux; do
    nmap --append-output -oN nmap_output -sS -p 80 $aux | tee
done < targets

while read aux; do
    nuclei -u $aux >> nuclei_output | tee
done < targets


echo "[-] Nmap banner scan done, see the results at banners"


echo 'Done'
fasfa