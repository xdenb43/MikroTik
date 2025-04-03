# DNS Forwarders | by @xmrdenb43
# tested on hap ac lite tc/hap ax3, RoS 7.18.2+

/ip dns forwarders
add doh-servers=https://cloudflare-dns.com/dns-query name=CloudFlare
add doh-servers=https://secure.cloudflare-dns.com/dns-query name="CloudFlare Secure"
add comment="no DoH certificate verification" disabled=yes doh-servers=https://dns.quad9.net/dns-query name="Quad9 Default" verify-doh-cert=no
add doh-servers=https://dns.google/dns-query name=Google
add comment="no DoH certificate verification" dns-servers=dns.comss.one doh-servers=https://dns.comss.one/mikrotik name=Comss verify-doh-cert=no
add doh-servers=https://dns.google/dns-query,https://cloudflare-dns.com/dns-query name="CF & Google DOH"
add dns-servers=1.0.0.1,8.8.4.4,1.1.1.1,8.8.8.8 name="CF & Google IPv4" verify-doh-cert=no
