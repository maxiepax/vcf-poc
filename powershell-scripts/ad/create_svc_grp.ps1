function add-svcaccount {
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [string] $username,
        [Parameter(Mandatory=$true, Position=1)]
        [string] $password,
        [Parameter(Mandatory=$true, Position=2)]
        [string] $path
    )
    New-ADUser -Name $username -Accountpassword (ConvertTo-SecureString -AsPlainText $password -Force) -EmailAddress "$username@$es" -Enabled $true -GivenName "svc account" -Surname $username -PasswordNeverExpires $true -Path $path
}
 
function add-grp {
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [string] $groupname,
        [Parameter(Mandatory=$true, Position=1)]
        [string] $path
    )
    New-ADGroup -Name $groupname -SamAccountName $groupname -GroupCategory Security -GroupScope Global -DisplayName $groupname -Path $path
}
 
#email suffix
$es = "rainpole.io"
 
#Service Accounts
 
New-ADOrganizationalUnit -Name "sfo" -Path "dc=rainpole,dc=io"
New-ADOrganizationalUnit -Name "Security Groups" -Path "dc=rainpole,dc=io"
New-ADOrganizationalUnit -Name "Security Groups" -Path "ou=sfo,dc=rainpole,dc=io"
 
New-ADOrganizationalUnit -Name "Security Users" -Path "dc=rainpole,dc=io"
New-ADOrganizationalUnit -Name "Security Users" -Path "ou=sfo,dc=rainpole,dc=io"
 
#Parent
add-svcaccount -username "svc-wsacluster-ad" -password "VMware1!VMware1!" -path "OU=Security Users,DC=rainpole,DC=io"
add-svcaccount -username "svc-vrops-vra" -password "VMware1!VMware1!" -path "OU=Security Users,DC=rainpole,DC=io"
add-svcaccount -username "svc-vra-vrops" -password "VMware1!VMware1!" -path "OU=Security Users,DC=rainpole,DC=io"
 
 
#Child
add-svcaccount -username "svc-vcf-ca" -password "VMware1!VMware1!" -path "OU=Security Users,OU=sfo,DC=rainpole,DC=io"
add-svcaccount -username "svc-vsphere-ad" -password "VMware1!VMware1!" -path "OU=Security Users,OU=sfo,DC=rainpole,DC=io"
add-svcaccount -username "svc-wsa-ad" -password "VMware1!VMware1!" -path "OU=Security Users,OU=sfo,DC=rainpole,DC=io"
add-svcaccount -username "svc-vra-vsphere" -password "VMware1!VMware1!" -path "OU=Security Users,OU=sfo,DC=rainpole,DC=io"
add-svcaccount -username "svc-vra-nsx" -password "VMware1!VMware1!" -path "OU=Security Users,OU=sfo,DC=rainpole,DC=io"
add-svcaccount -username "svc-vra-vcf" -password "VMware1!VMware1!" -path "OU=Security Users,OU=sfo,DC=rainpole,DC=io"
add-svcaccount -username "svc-vro-vsphere" -password "VMware1!VMware1!" -path "OU=Security Users,OU=sfo,DC=rainpole,DC=io"
 
#Security Groups
 
#vRealize Suite Lifecycle Manager
add-grp -groupname "gg-vrslcm-admins" -path "OU=Security Groups,DC=rainpole,DC=io"
add-grp -groupname "gg-vrslcm-content-admins" -path "OU=Security Groups,DC=rainpole,DC=io"
add-grp -groupname "gg-vrslcm-content-developers" -path "OU=Security Groups,DC=rainpole,DC=io"
 
#Clustered Workspace One Access
add-grp -groupname "gg-wsacluster-admins" -path "OU=Security Groups,DC=rainpole,DC=io"
add-grp -groupname "gg-wsacluster-directory-admins" -path "OU=Security Groups,DC=rainpole,DC=io"
add-grp -groupname "gg-wsacluster-read-only" -path "OU=Security Groups,DC=rainpole,DC=io"
 
#Identity and Access Management for VMware Cloud Foundation
add-grp -groupname "gg-vcf-admins" -path "OU=Security Groups,OU=sfo,DC=rainpole,DC=io"
add-grp -groupname "gg-vcf-operators" -path "OU=Security Groups,OU=sfo,DC=rainpole,DC=io"
add-grp -groupname "gg-vcf-viewers" -path "OU=Security Groups,OU=sfo,DC=rainpole,DC=io"
add-grp -groupname "gg-vc-admins" -path "OU=Security Groups,OU=sfo,DC=rainpole,DC=io"
add-grp -groupname "gg-vc-read-only" -path "OU=Security Groups,OU=sfo,DC=rainpole,DC=io"
add-grp -groupname "gg-sso-admins" -path "OU=Security Groups,OU=sfo,DC=rainpole,DC=io"
add-grp -groupname "gg-nsx-enterprise-admins" -path "OU=Security Groups,OU=sfo,DC=rainpole,DC=io"
add-grp -groupname "gg-nsx-network-admins" -path "OU=Security Groups,OU=sfo,DC=rainpole,DC=io"
add-grp -groupname "gg-nsx-auditors" -path "OU=Security Groups,OU=sfo,DC=rainpole,DC=io"
add-grp -groupname "gg-wsa-admins" -path "OU=Security Groups,OU=sfo,DC=rainpole,DC=io"
add-grp -groupname "gg-wsa-directory-admins" -path "OU=Security Groups,OU=sfo,DC=rainpole,DC=io"
add-grp -groupname "gg-wsa-read-only" -path "OU=Security Groups,OU=sfo,DC=rainpole,DC=io"
 
#Intelligent Operations Management for VMware Cloud Foundation
add-grp -groupname "gg-vrops-admins" -path "OU=Security Groups,DC=rainpole,DC=io"
add-grp -groupname "gg-vrops-content-admins" -path "OU=Security Groups,DC=rainpole,DC=io"
add-grp -groupname "gg-vrops-read-only" -path "OU=Security Groups,DC=rainpole,DC=io"
 
 
#Intelligent Logging and Analyrics for VMware Cloud Foundation
add-grp -groupname "gg-vrli-admins" -path "OU=Security Groups,OU=sfo,DC=rainpole,DC=io"
add-grp -groupname "gg-vrli-users" -path "OU=Security Groups,OU=sfo,DC=rainpole,DC=io"
add-grp -groupname "gg-vrli-viewers" -path "OU=Security Groups,OU=sfo,DC=rainpole,DC=io"
 
#Private Cloud and Automation for VMware Cloud Foundation
add-grp -groupname "gg-vra-org-owners" -path "OU=Security Groups,DC=rainpole,DC=io"
add-grp -groupname "gg-vra-cloud-assembly-admins" -path "OU=Security Groups,DC=rainpole,DC=io"
add-grp -groupname "gg-vra-cloud-assembly-users" -path "OU=Security Groups,DC=rainpole,DC=io"
add-grp -groupname "gg-vra-cloud-assembly-viewers" -path "OU=Security Groups,DC=rainpole,DC=io"
add-grp -groupname "gg-vra-service-broker-admins" -path "OU=Security Groups,DC=rainpole,DC=io"
add-grp -groupname "gg-vra-service-broker-users" -path "OU=Security Groups,DC=rainpole,DC=io"
add-grp -groupname "gg-vra-service-broker-viewers" -path "OU=Security Groups,DC=rainpole,DC=io"
add-grp -groupname "gg-vra-orchestrator-admins" -path "OU=Security Groups,DC=rainpole,DC=io"
add-grp -groupname "gg-vra-orchestrator-designers" -path "OU=Security Groups,DC=rainpole,DC=io"
add-grp -groupname "gg-vra-orchestrator-viewers" -path "OU=Security Groups,DC=rainpole,DC=io"
add-grp -groupname "gg-vra-project-admins-sample" -path "OU=Security Groups,DC=rainpole,DC=io"
add-grp -groupname "gg-vra-project-users-sample" -path "OU=Security Groups,DC=rainpole,DC=io"
 
#Developer Ready Infrastructure using VMware Cloud Foundation
add-grp -groupname "gg-kub-admins" -path "OU=Security Groups,OU=sfo,DC=rainpole,DC=io"
add-grp -groupname "gg-kub-readonly" -path "OU=Security Groups,OU=sfo,DC=rainpole,DC=io"
