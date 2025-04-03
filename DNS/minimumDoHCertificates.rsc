# Import minimum cerificates to have several DOHs servers working
# by xdenb43 | tested on hap ac lite tc/hap ax3, RoS 7.17+

#CloudFlare
/tool fetch https://cacerts.digicert.com/DigiCertGlobalRootG2.crt.pem
/certificate import file-name=DigiCertGlobalRootG2.crt.pem passphrase=""
#/ip dns set allow-remote-requests=yes use-doh-server=https://cloudflare-dns.com/dns-query verify-doh-cert=yes
#secure https://secure.cloudflare-dns.com/dns-query

#Quad9
/tool/fetch url=https://cacerts.digicert.com/DigiCertGlobalG3TLSECCSHA3842020CA1-2.crt.pem
/certificate/import file-name=DigiCertGlobalG3TLSECCSHA3842020CA1-2.crt.pem
#/ip dns set allow-remote-requests=yes use-doh-server=https://dns.quad9.net/dns-query verify-doh-cert=yes

#Google
/tool fetch url=https://i.pki.goog/r1.pem
/tool fetch url=https://i.pki.goog/r2.pem
/tool fetch url=https://i.pki.goog/r3.pem
/tool fetch url=https://i.pki.goog/r4.pem
/tool fetch url=https://i.pki.goog/gsr4.pem
/certificate/import file-name=r1.pem
/certificate/import file-name=r2.pem
/certificate/import file-name=r3.pem
/certificate/import file-name=r4.pem
/certificate/import file-name=gsr4.pem
#/ip dns set allow-remote-requests=yes use-doh-server=https://dns.google/dns-query verify-doh-cert=yes

#COMSS - rename .crt to .pem!!!
#/tool/fetch url=https://www.tbs-x509.com/USERTrustRSACertificationAuthority.crt dst-path=USERTrustRSACertificationAuthority.crt.pem
/tool/fetch url=https://www.tbs-x509.com/USERTrustRSACertificationAuthority.crt
/certificate/import file-name=USERTrustRSACertificationAuthority.crt
#/ip dns set allow-remote-requests=yes use-doh-server=https://dns.comss.one/mikrotik verify-doh-cert=yes	


#big list ~ 2Mb
#/tool fetch url=https://curl.se/ca/cacert.pem
#/certificate import file-name=cacert.pem passphrase=""
