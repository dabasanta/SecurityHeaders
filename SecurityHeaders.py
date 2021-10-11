#!/usr/bin/env python3

# @author: Danilo Basanta
# @author-linkedin: https://www.linkedin.com/in/danilobasanta/
# @author-github: https://github.com/dabasanta

import argparse
import sys
import requests
from requests.exceptions import Timeout


def checkHeaders(w):
    if 'Strict-Transport-Security' in w:
        print("HSTS is enabled!")
    else:
        print("HSTS is not enabled!")

    if 'Content-Security-Policy' in w:
        print("CSP is enabled!")
    else:
        print("CSP is not enabled!")

    if 'X-Frame-Options' in w:
        print("X-Frame-Options is enabled!")
    else:
        print("X-Frame-Options is not enabled!")

    if 'X-Content-Type-Options' in w:
        print("X-Content-Type-Options is enabled!")
    else:
        print("X-Content-Type-Options is not enabled!")

    if 'Referrer-Policy' in w:
        print("Referrer-Policy is enabled!")
    else:
        print("Referrer-Policy is not enabled!")

    if 'Permissions-Policy' in w:
        print("Permissions-Policy is enabled!")
    else:
        print("Permissions-Policy is not enabled!")


def checkURL(url):
    import re
    regex = re.compile(
        r'^https?://'  # http:// or https://
        r'(?:(?:[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?\.)+[A-Z]{2,6}\.?|'  # domain...
        r'localhost|'  # localhost...
        r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})'  # ...or ip
        r'(?::\d+)?'  # optional port
        r'(?:/?|[/?]\S+)$', re.IGNORECASE)

    if url is not None and regex.search(url):
        return 1
    else:
        return 0


def banner():
    print("""
    ███████╗███████╗ ██████╗██╗   ██╗██████╗ ██╗████████╗██╗   ██╗
    ██╔════╝██╔════╝██╔════╝██║   ██║██╔══██╗██║╚══██╔══╝╚██╗ ██╔╝
    ███████╗█████╗  ██║     ██║   ██║██████╔╝██║   ██║    ╚████╔╝ 
    ╚════██║██╔══╝  ██║     ██║   ██║██╔══██╗██║   ██║     ╚██╔╝  
    ███████║███████╗╚██████╗╚██████╔╝██║  ██║██║   ██║      ██║   
    ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝   ╚═╝      ╚═╝   

    ██╗  ██╗███████╗ █████╗ ██████╗ ███████╗██████╗ ███████╗
    ██║  ██║██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔════╝
    ███████║█████╗  ███████║██║  ██║█████╗  ██████╔╝███████╗
    ██╔══██║██╔══╝  ██╔══██║██║  ██║██╔══╝  ██╔══██╗╚════██║
    ██║  ██║███████╗██║  ██║██████╔╝███████╗██║  ██║███████║
    ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝
    
    For: Testing security headers missing on authenticated responses
    """)


if __name__ == '__main__':
    banner()
    src_name = argparse._sys.argv[0]
    parser = argparse.ArgumentParser(usage='''
    python %s URL {-jwt eyJraWQiOi...} 

    Security Headers checks if a recommended security header is missing from serer response.

    Use -h or --help flag to get help
    ''' % src_name)
    parser.add_argument("URL", help='Url to check', type=str)
    parser.add_argument('-jwt', help='Bearer JWT token', type=str)
    arguments = parser.parse_args()

    if arguments.URL is None:
        parser.error('URL is missing.')
    else:
        if checkURL(arguments.URL):
            if arguments.jwt:
                try:
                    headers_dict = {"Authorization": "Bearer %s" % arguments.jwt}
                    headers = requests.get(arguments.URL, headers=headers_dict)
                    Headers = headers.headers
                    checkHeaders(str(Headers))
                except Timeout:
                    print("Error Timeout")
                    sys.exit(1)
            else:
                try:
                    headers = requests.get(arguments.URL)
                    Headers = headers.headers
                    checkHeaders(str(Headers))
                except Timeout:
                    print("Error Timeout")
                    sys.exit(1)




