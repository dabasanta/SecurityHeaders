#!/usr/bin/env bash
#
# Script to check for misssing security http headers in non-authenticated webapps. Can pass an URL or file as argmument. If the argmument is a file, make sure the file is ASCII/text.
# You can pass a complete URI resource "http(s)://www.website.com/resource/id/here" or only hostname/DNS name, as appropriate.
#
# Note: if you're using a filename containing URLs to test, please don't let blank lines, this may affect script performance and make it too slow.
#
# @author: Danilo Basanta

help(){
echo ""
}

banner(){
echo ""
}

checkDependencies(){
  echo -e "\n"
  if which curl > /dev/null 2>&1 ; then
    cURLversion=$(curl -V | head -1 | awk '{print $1,$2}')
    echo "[+] $cURLversion. Installed."
  else
    echo "[-] Error: cURL couldn't found."
    exit 1
  fi
  echo -e "\n"
}

securityHeaders(){
  host="$1"
  curl -LIs --max-redirs 5 -X GET "$host" -o /tmp/curl.output 2>/dev/null
  echo -e "\n[*] Results for $host\n"
  cat /tmp/curl.output | cut -d : -f 1 | grep -Eiw 'Content-Security-Policy|X-Content-Type-Options|X-Frame-Options|X-XSS-Protection' | uniq
  echo $?
}

checkConn(){
  filename=$1
  long=$(wc -l $filename)
  ok=0

  for url in $(cat $filename) ; do
    if curl --output /dev/null --silent --head --fail "$url" ; then
      ok=$(($ok+1))
      securityHeaders "$url"
    fi
  done

  echo -e "\n\n[+] Done! $ok URL tested.\n\n"
}

checkArg(){
  if file $1 | grep -Eo "ASCII text" > /dev/null 2>&1 ; then
    checkConn $1
  else
    if curl --output /dev/null --silent --head --fail $1 ; then
      echo ""
    else
      echo "[-] Error while check URL, connection fail."
    fi
  fi
}

banner
checkDependencies
checkArg $1
