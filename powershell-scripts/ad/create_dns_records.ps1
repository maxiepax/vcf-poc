function add-aptr {
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [string] $a,
        [Parameter(Mandatory=$true, Position=1)]
        [string] $ip
    )
 
    $split = $ip.Split(".")
    $oct1 = $split[0]
    $oct2 = $split[1]
    $oct3 = $split[2]
    $oct4 = $split[3]
 
Add-DnsServerResourceRecordA -Computername $ad -ZoneName $zone -Name $a -IPv4Address $ip
Add-DnsServerResourceRecordPtr -Computername $ad -AgeRecord -Name $oct4 -ZoneName "$oct3.$oct2.$oct1.in-addr.arpa" -PtrDomainName "$a.$zone"
 
}
 
#inputs
$ad = "sfo-dc01.rainpole.io"
$zone = "rainpole.io"
 
# add reverse zones
Add-DnsServerPrimaryZone -Computername $ad -NetworkID "172.16.11.0/24" -ReplicationScope "Forest"
Add-DnsServerPrimaryZone -Computername $ad -NetworkID "172.16.21.0/24" -ReplicationScope "Forest"
Add-DnsServerPrimaryZone -Computername $ad -NetworkID "172.16.31.0/24" -ReplicationScope "Forest"
Add-DnsServerPrimaryZone -Computername $ad -NetworkID "172.16.41.0/24" -ReplicationScope "Forest"
Add-DnsServerPrimaryZone -Computername $ad -NetworkID "192.168.11.0/24" -ReplicationScope "Forest"
Add-DnsServerPrimaryZone -Computername $ad -NetworkID "192.168.31.0/24" -ReplicationScope "Forest"
 
#ca
add-aptr -a "sfo-ca01.sfo" -ip "172.16.11.4"
 
#smtp
 
#A/PTR records for NTP
#Primary AZ
add-aptr -a "ntp01.sfo" -ip "172.16.11.4"
add-aptr -a "ntp02.sfo" -ip "172.16.11.5"
 
#Secondary AZ
#A/PTR records for NTP
add-aptr -a "ntp01.lax" -ip "172.16.11.4"
add-aptr -a "ntp02.lax" -ip "172.16.11.5"
 
#A records for NTP
#Primary AZ
Add-DnsServerResourceRecordA -Computername $ad -ZoneName "rainpole.io" -Name "ntp.sfo" -IPv4Address "172.16.11.4"
Add-DnsServerResourceRecordA -Computername $ad -ZoneName "rainpole.io" -Name "ntp.sfo" -IPv4Address "172.16.11.5"
#Secondary AZ
Add-DnsServerResourceRecordA -Computername $ad -ZoneName "rainpole.io" -Name "ntp.lax" -IPv4Address "172.16.21.4"
Add-DnsServerResourceRecordA -Computername $ad -ZoneName "rainpole.io" -Name "ntp.lax" -IPv4Address "172.16.21.5"
 
 
#A/PTR records for backup
add-aptr -a "sddc-backup" -ip "172.16.11.40"
 
#A/PTR records for Cloud Builder
add-aptr -a "sfo-cb01.sfo" -ip "172.16.11.60"
 
#A/PTR records for sfo-m01-vc01
add-aptr -a "sfo-m01-vc01.sfo" -ip "172.16.11.62"
 
 
#A/PTR records for sfo01-m01-esx hosts
add-aptr -a "sfo01-m01-esx01.sfo" -ip "172.16.11.101"
add-aptr -a "sfo01-m01-esx02.sfo" -ip "172.16.11.102"
add-aptr -a "sfo01-m01-esx03.sfo" -ip "172.16.11.103"
add-aptr -a "sfo01-m01-esx04" -ip "172.16.11.104"
 
#A/PTR records for sfo02-m01-esx hosts
add-aptr -a "sfo02-m01-esx01.sfo" -ip "172.16.21.101"
add-aptr -a "sfo02-m01-esx02.sfo" -ip "172.16.21.102"
add-aptr -a "sfo02-m01-esx03.sfo" -ip "172.16.21.103"
add-aptr -a "sfo03-m01-esx04.sfo" -ip "172.16.21.104"
 
#A/PTR records for sfo-m01-nsx
add-aptr -a "sfo-m01-nsx01.sfo" -ip "172.16.11.65"
add-aptr -a "sfo-m01-nsx01a.sfo" -ip "172.16.11.66"
add-aptr -a "sfo-m01-nsx01b.sfo" -ip "172.16.11.67"
add-aptr -a "sfo-m01-nsx01c.sfo" -ip "172.16.11.68"
 
#A/PTR records for sfo-m01-nsx-gm
add-aptr -a "sfo-m01-nsx01-gm.sfo" -ip "172.16.11.85"
add-aptr -a "sfo-m01-nsx01a-gm.sfo" -ip "172.16.11.86"
add-aptr -a "sfo-m01-nsx01b-gm.sfo" -ip "172.16.11.87"
add-aptr -a "sfo-m01-nsx01c-gm.sfo" -ip "172.16.11.88"
 
#A/PTR records for sfo-m01-nsx edge nodes
add-aptr -a "sfo-m01-en01.sfo" -ip "172.16.11.69"
add-aptr -a "sfo-m01-en02.sfo" -ip "172.16.11.70"
 
#A/PTR records for sfo-m01 vSAN Witness
add-aptr -a "sfo-m01-cl01-vsw01.sfo" -ip "172.17.11.201"
 
#A/PTR records for sfo-w01-vc01
add-aptr -a "sfo-w01-vc01.sfo" -ip "172.16.11.64"
 
#A/PTR records for sfo01-m01-esx hosts
add-aptr -a "sfo01-w01-esx01.sfo" -ip "172.16.31.101"
add-aptr -a "sfo01-w01-esx02.sfo" -ip "172.16.31.102"
add-aptr -a "sfo01-w01-esx03.sfo" -ip "172.16.31.103"
add-aptr -a "sfo01-w01-esx04.sfo" -ip "172.16.31.104"
 
#A/PTR records for sfo02-m01-esx hosts
add-aptr -a "sfo02-w01-esx01.sfo" -ip "172.16.41.101"
add-aptr -a "sfo02-w01-esx02.sfo" -ip "172.16.41.102"
add-aptr -a "sfo02-w01-esx03.sfo" -ip "172.16.41.103"
add-aptr -a "sfo03-w01-esx04.sfo" -ip "172.16.41.104"
 
#A/PTR records for sfo-w01-nsx
add-aptr -a "sfo-w01-nsx01.sfo" -ip "172.16.11.75"
add-aptr -a "sfo-w01-nsx01a.sfo" -ip "172.16.11.76"
add-aptr -a "sfo-w01-nsx01b.sfo" -ip "172.16.11.77"
add-aptr -a "sfo-w01-nsx01c.sfo" -ip "172.16.11.78"
 
#A/PTR records for sfo-w01-nsx-gm
add-aptr -a "sfo-w01-nsx01-gm.sfo" -ip "172.16.11.95"
add-aptr -a "sfo-w01-nsx01a-gm.sfo" -ip "172.16.11.96"
add-aptr -a "sfo-w01-nsx01b-gm.sfo" -ip "172.16.11.97"
add-aptr -a "sfo-w01-nsx01c-gm.sfo" -ip "172.16.11.98"
 
#A/PTR records for sfo-w01-nsx edge nodes
add-aptr -a "sfo-w01-en01.sfo" -ip "172.16.31.69"
add-aptr -a "sfo-w01-en02.sfo" -ip "172.16.31.70"
 
#A/PTR records for sfo-w01 vSAN Witness
add-aptr -a "sfo-w01-cl01-vsw01.sfo" -ip "172.17.11.211"
 
 
#A/PTR records for xint-vrslcm
add-aptr -a "xint-vrslcm01" -ip "192.168.11.20"
 
#A/PTR records for Clustered WSA1
add-aptr -a "xint-wsa01" -ip "192.168.11.60"
add-aptr -a "xint-wsa01a" -ip "192.168.11.61"
add-aptr -a "xint-wsa01b" -ip "192.168.11.62"
add-aptr -a "xint-wsa01c" -ip "192.168.11.63"
 
#A/PTR records for Standalone WSA1
add-aptr -a "sfo-wsa01.sfo" -ip "192.168.31.60"
 
#A/PTR records for vRealize Log insight
add-aptr -a "sfo-vrli01.sfo" -ip "192.168.31.10"
add-aptr -a "sfo-vrli01a.sfo" -ip "192.168.31.11"
add-aptr -a "sfo-vrli01b.sfo" -ip "192.168.31.12"
add-aptr -a "sfo-vrli01c.sfo" -ip "192.168.31.13"
 
#A/PTR records for vRealize Operations
add-aptr -a "xint-vrops01" -ip "192.168.11.30"
add-aptr -a "xint-vrops01a" -ip "192.168.11.31"
add-aptr -a "xint-vrops01b" -ip "192.168.11.32"
add-aptr -a "xint-vrops01c" -ip "192.168.11.33"
add-aptr -a "sfo-vropsc01a.sfo" -ip "192.168.31.31"
add-aptr -a "sfo-vropsc01b.sfo" -ip "192.168.31.32"
 
#A/PTR records for vRealize Automation
add-aptr -a "xint-vra01" -ip "192.168.11.50"
add-aptr -a "xint-vra01a" -ip "192.168.11.51"
add-aptr -a "xint-vra01b" -ip "192.168.11.52"
add-aptr -a "xint-vra01c" -ip "192.168.11.53"
 
#A/PTR records for vSphere Replication m01
add-aptr -a "sfo-m01-vrms01.sfo" -ip "172.16.11.123"
add-aptr -a "sfo-m01-srm01.sfo" -ip "172.16.11.124"
 
#A/PTR records for vSphere Replication w01
add-aptr -a "sfo-w01-vrms01.sfo" -ip "172.16.31.123"
add-aptr -a "sfo-w01-srm01.sfo" -ip "172.16.31.124"
