# VPN Clients connection failover resolution | by @xdenb43
# tested on hap ac lite tc, RoS 7.18.2+
# based on recursive routing  and DNS FWD + mangle
#   
# VPNs clients configured:
#    wg-proton - Wireguard Proton
#    wg-bth - Mikrotik Back-To-Home
#    wg-warp - CloudFlare Warp
#
# External servers used to check internet availability:
#    77.88.8.1 - Yandex secondary DNS
#    77.88.8.2 - Yandex secure DNS
#    1.1.1.3   - CF Family DNS
#
# Cheat by @wiktorbgu MUST be used to have WG working
# https://gist.github.com/wiktorbgu/1f2dfe99837d8f2803483be95814d2e5

# Addresses
/ip address
add address=10.2.0.2/24 interface=wg-proton network=10.2.0.0
add address=172.16.0.2/24 interface=wg-warp network=172.16.0.0
add address=192.168.216.4/24 interface=wg-bth network=192.168.216.0

# Routing tables
# any_vpn_out - used for ANY vpn connection
# geo_vpn_out - used to bypass GEO check
/routing table
add disabled=no fib name=any_vpn_out
add disabled=no fib name=geo_vpn_out

# Routes with priorities
# Target Scope for recursive route MUST be greater than next hope route target scope value
/ip route
add comment="proton recursive routing" disabled=no distance=21 dst-address=0.0.0.0/0 gateway=77.88.8.1 routing-table=any_vpn_out scope=30 suppress-hw-offload=no \
    target-scope=11
add comment="proton recursive routing" disabled=no distance=20 dst-address=0.0.0.0/0 gateway=77.88.8.1 routing-table=geo_vpn_out scope=30 suppress-hw-offload=no \
    target-scope=11
add comment="warp recursive routing" disabled=no distance=20 dst-address=0.0.0.0/0 gateway=1.1.1.3 routing-table=any_vpn_out scope=30 suppress-hw-offload=no \
    target-scope=11
add comment="bth recursive routing" disabled=no distance=21 dst-address=0.0.0.0/0 gateway=77.88.8.2 routing-table=geo_vpn_out scope=30 suppress-hw-offload=no \
    target-scope=11
add comment="bth recursive routing" disabled=no distance=22 dst-address=0.0.0.0/0 gateway=77.88.8.2 routing-table=any_vpn_out scope=30 suppress-hw-offload=no \
    target-scope=11
add check-gateway=ping comment="proton monitor external ip" disabled=no distance=20 dst-address=77.88.8.1/32 gateway=10.2.0.1 routing-table=main scope=10 \
    suppress-hw-offload=no target-scope=10
add check-gateway=ping comment="bth monitor external ip" disabled=no distance=20 dst-address=77.88.8.2/32 gateway=192.168.216.1 routing-table=main scope=10 \
    suppress-hw-offload=no target-scope=10
add check-gateway=ping comment="warp monitor external ip" disabled=no distance=20 dst-address=1.1.1.3/32 gateway=172.16.0.1 routing-table=main scope=10 \
    suppress-hw-offload=no target-scope=10
