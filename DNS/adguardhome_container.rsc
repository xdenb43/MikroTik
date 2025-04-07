# adguard home to container | by @xdenb43
# tested on hap ax3/RoS 7.17.2+

# enable containers, follow https://help.mikrotik.com/docs/spaces/ROS/pages/84901929/Container
/system/device-mode/update container=yes

# MAIN PART STARTS HERE
/interface veth
add address=192.168.254.5/24 gateway=192.168.254.1 name=ADGUARD-HOME

/interface bridge
add name=Bridge-Docker port-cost-mode=short
/interface bridge port
add bridge=Bridge-Docker interface=ADGUARD-HOME
/ip address
add address=192.168.254.1/24 interface=Bridge-Docker network=192.168.254.0

/ip firewall nat
add action=masquerade chain=srcnat comment=AdGuardHome src-address=192.168.254.5

# USB flash drive, FS ext4
/container config
set ram-high=200.0MiB registry-url=https://registry-1.docker.io tmpdir=/usb1/docker/pull

/container mounts
add dst=/opt/adguardhome/conf name=adguard_home_conf src=/usb1/docker_configs/adguard_home

/container
add cmd="-c /opt/adguardhome/conf/AdGuardHome.yaml -h 0.0.0.0 -w /opt/adguardhome/work" entrypoint=/opt/adguardhome/AdGuardHome interface=ADGUARD-HOME logging=yes mounts=\
    adguard_home_conf root-dir=/usb1/docker/adguard_home workdir=/opt/adguardhome/work remote-image=adguard/adguardhome:latest

/container/start [find where interface=ADGUARD-HOME]

# ADH available on http://192.168.254.5:300 , configure before use
# Choose one of the options below
# uncomment lines before copying to terminal

# OPTION 1
# Just set AGH ip as DNS server. 
# /!\ DNS FWD will work. 
# /!\ No device-related stats will be gathered (all dns requests are coming from mikrotik)
#/ip dns
#set allow-remote-requests=yes servers=192.168.254.5
#/ip firewall nat
#add action=redirect chain=dstnat comment="Incoming DNS redirect" dst-address-type=!local dst-port=53 in-interface-list=LAN protocol=udp
#add action=redirect chain=dstnat comment="Incoming DNS redirect" dst-address-type=!local dst-port=53 in-interface-list=LAN protocol=tcp


# OPTION 2
# Forward all DNS requests to ADH
# /!\ DNS FWD will NOT work
# /!\ WILL SHOW stats for every LAN device 
#/ip firewall nat
#add action=dst-nat chain=dstnat comment="local AdGuard udp -  NO NAT Loopback / local addresses only!" dst-port=53 in-interface-list=LAN protocol=udp src-address=\
#    192.168.88.0/24 to-addresses=192.168.254.5 to-ports=53
#add action=dst-nat chain=dstnat comment="local AdGuard tcp" dst-port=53 in-interface-list=LAN protocol=tcp src-address=192.168.88.0/24 to-addresses=192.168.254.5 to-ports=53
