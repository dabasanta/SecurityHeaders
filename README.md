# Security Headers Checker
![](https://raw.githubusercontent.com/dabasanta/SecurityHeaders/main/Examples/logo.png)

This script can make authenticated Bearer requests against a Web Service to check interesting headers in the responses, you can make a GET request to a URL or URI API to get authenticated responses.

#Dependencies
- requests==2.26.0


## Usage
```bash
Usage: 
    python ./SecurityHeaders.py URL {-jwt eyJraWQiOi...} 

    Security Headers checks if a recommended security header is missing from responses.

    Use -h or --help flag to get help
```
*Example*
```bash
./SecurityHeaders.py https://www.google.com/

OR

./SecurityHeaders.py https://api.localhost.com/offers/get -jwt eyJhbGciOiJSU0EtT0FFUCIsImVuYyI6IkEyNTZHQ00ifQ... 
```
Make sure of specify the communication schema, **HTTP** or **HTTPS**

![](https://raw.githubusercontent.com/dabasanta/SecurityHeaders/main/Examples/output.png)

## Checks
The script bases its functionality from [SecurityHeaders](https://securityheaders.com/) project.

- __Content-Security-Policy:__ Content Security Policy is an effective measure to protect your site from XSS attacks. By whitelisting sources of approved content, you can prevent the browser from loading malicious assets.

- __X-Frame-Options:__ X-Frame-Options tells the browser whether you want to allow your site to be framed or not. By preventing a browser from framing your site you can defend against attacks like clickjacking. Recommended value "_X-Frame-Options: SAMEORIGIN_".

- __X-Content-Type-Options:__ X-Content-Type-Options stops a browser from trying to MIME-sniff the content type and forces it to stick with the declared content-type. The only valid value for this header is "_X-Content-Type-Options: nosniff_".

- __Referrer-Policy:__ Referrer Policy is a new header that allows a site to control how much information the browser includes with navigations away from a document and should be set by all sites.

- __Permissions-Policy:__ Permissions Policy is a new header that allows a site to control which features and APIs can be used in the browser.
