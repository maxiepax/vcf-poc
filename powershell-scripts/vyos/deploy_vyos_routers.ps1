#vmware specific
$vc = "sfo-w01-vc01.vmlab.se"
$vmw_username = ""
$vmw_password = ""
$vmw_vcenter = "sfo-w01-vc01.vmlab.se"
$vmw_esxi_host = "sfo01-w01-esx05.vmlab.se"
$vmw_datastore = "sfo-w01-sfo-w01-vc01-sfo-w01-cl01-vsan01"


#vyos specific
$vyos_location = "C:\Users\kjohansson\Downloads\vyos-rolling-latest.iso"
$vyos01_hostname = "sfo-vyos-r01"
$vyos01_eth0_pg = "packer-build-network"
$vyos01_eth0_ip  = "172.16.25.101"

$vyos02_hostname = "sfo-vyos-r02"
$vyos01_eth0     = "172.16.25.102"

#functions

function find_vyos {
    param ( 
        $Path
    )

    $test = Test-Path -Path $Path -PathType Leaf
    Write-Output $test

}


function download_vyos() {
    $dl = Read-Host "VYoS image not found, do you want me to download it? [Y/n]"
    if ($dl -eq 'y') {
        $vyos_location = Read-Host "Path to place VYoS Image:"
        Invoke-WebRequest -Uri https://s3-us.vyos.io/rolling/current/vyos-rolling-latest.iso -OutFile $vyos_location"\vyos-rolling-latest.iso"
        $vyos_location = $vyos_location+"\vyos-rolling-latest.iso"
        Write-Host "VYoS Image: $vyos_location"
    } else {
        Write-Host "aborting"
        $host.Exit()
    }
}

function connect_vcenter_or_host(){
    if (!$vmw_vcenter) { 
        Write-Host "Target is ESXi Host"
        $targethost = Connect-VIServer -Server $vmw_esxi_host -Username $vmw_username -Password $vmw_password
    } else {
        Write-Host "Target is vCenter"
        $targetvc = Connect-VIServer -Server $vmw_vcenter -Username $vmw_username -Password $vmw_password
        $targethost = Get-VMHost -Name $vmw_esxi_host
    }
}

Function Set-VMKeystrokes {
<#
    .NOTES
    ===========================================================================
        Created by:    William Lam
        Organization:  VMware
        Blog:          www.virtuallyghetto.com
        Twitter:       @lamw
    ===========================================================================
    .DESCRIPTION
        This function emulates keyboard entries to the vm console.
 
#>

    param(
        [Parameter(Mandatory=$true)][String]$VMName,
        [Parameter(Mandatory=$true)][String]$StringInput,
        [Parameter(Mandatory=$false)][Boolean]$ReturnCarriage,
        [Parameter(Mandatory=$false)][Boolean]$DebugOn
    )

    # Map subset of USB HID keyboard scancodes
    # https://gist.github.com/MightyPork/6da26e382a7ad91b5496ee55fdc73db2
    $hidCharacterMap = @{
        "a"="0x04";
        "b"="0x05";
        "c"="0x06";
        "d"="0x07";
        "e"="0x08";
        "f"="0x09";
        "g"="0x0a";
        "h"="0x0b";
        "i"="0x0c";
        "j"="0x0d";
        "k"="0x0e";
        "l"="0x0f";
        "m"="0x10";
        "n"="0x11";
        "o"="0x12";
        "p"="0x13";
        "q"="0x14";
        "r"="0x15";
        "s"="0x16";
        "t"="0x17";
        "u"="0x18";
        "v"="0x19";
        "w"="0x1a";
        "x"="0x1b";
        "y"="0x1c";
        "z"="0x1d";
        "1"="0x1e";
        "2"="0x1f";
        "3"="0x20";
        "4"="0x21";
        "5"="0x22";
        "6"="0x23";
        "7"="0x24";
        "8"="0x25";
        "9"="0x26";
        "0"="0x27";
        "!"="0x1e";
        "@"="0x1f";
        "#"="0x20";
        "$"="0x21";
        "%"="0x22";
        "^"="0x23";
        "&"="0x24";
        "*"="0x25";
        "("="0x26";
        ")"="0x27";
        "_"="0x2d";
        "+"="0x2e";
        "{"="0x2f";
        "}"="0x30";
        "|"="0x31";
        ":"="0x33";
        "`""="0x34";
        "~"="0x35";
        "<"="0x36";
        ">"="0x37";
        "?"="0x38";
        "-"="0x2d";
        "="="0x2e";
        "["="0x2f";
        "]"="0x30";
        "\"="0x31";
        "`;"="0x33";
        "`'"="0x34";
        ","="0x36";
        "."="0x37";
        "/"="0x38";
        " "="0x2c";
    }

    $vm = Get-View -ViewType VirtualMachine -Filter @{"Name"="^$($VMName)$"}

    # Verify we have a VM or fail
    if(!$vm) {
        Write-host "Unable to find VM $VMName"
        return
    }

    $hidCodesEvents = @()
    foreach($character in $StringInput.ToCharArray()) {
        # Check to see if we've mapped the character to HID code
        if($hidCharacterMap.ContainsKey([string]$character)) {
            $hidCode = $hidCharacterMap[[string]$character]

            $tmp = New-Object VMware.Vim.UsbScanCodeSpecKeyEvent

            # Add leftShift modifer for capital letters and/or special characters
            if( ($character -cmatch "[A-Z]") -or ($character -match "[!|@|#|$|%|^|&|(|)|_|+|{|}|||:|~|<|>|?|*]") ) {
                $modifer = New-Object Vmware.Vim.UsbScanCodeSpecModifierType
                $modifer.LeftShift = $true
                $tmp.Modifiers = $modifer
            }

            # Convert to expected HID code format
            $hidCodeHexToInt = [Convert]::ToInt64($hidCode,"16")
            $hidCodeValue = ($hidCodeHexToInt -shl 16) -bor 0007

            $tmp.UsbHidCode = $hidCodeValue
            $hidCodesEvents+=$tmp

            if($DebugOn) {
                Write-Host "Character: $character -> HIDCode: $hidCode -> HIDCodeValue: $hidCodeValue"
            }
        } else {
            Write-Host "The following character `"$character`" has not been mapped, you will need to manually process this character"
            break
        }
    }

    # Add return carriage to the end of the string input (useful for logins or executing commands)
    if($ReturnCarriage) {
        # Convert return carriage to HID code format
        $hidCodeHexToInt = [Convert]::ToInt64("0x28","16")
        $hidCodeValue = ($hidCodeHexToInt -shl 16) + 7

        $tmp = New-Object VMware.Vim.UsbScanCodeSpecKeyEvent
        $tmp.UsbHidCode = $hidCodeValue
        $hidCodesEvents+=$tmp
    }

    # Call API to send keystrokes to VM
    $spec = New-Object Vmware.Vim.UsbScanCodeSpec
    $spec.KeyEvents = $hidCodesEvents
    Write-Host "Sending `'$StringInput`' ...`n"
    $results = $vm.PutUsbScanCodes($spec)
}

Function New-VyOSInstallation {
<#
    .NOTES
    ===========================================================================
        Created by:    William Lam
        Organization:  VMware
        Blog:          www.virtuallyghetto.com
        Twitter:       @lamw
    ===========================================================================
    .DESCRIPTION
        This function automates the installation and configuration of VyOS from ISO
    .PARAMETER VMName
        The name of the VyOS VM
    .PARAMETER ManagementPassword
        The password to configure for the vyos user
    .EXAMPLE
        New-VyOSInstallation -VMName VyOS-Router -ManagementPassword VMware1!
#>
    param(
        [Parameter(Mandatory=$true)][String]$VMName,
        [Parameter(Mandatory=$true)][String]$ManagementPassword
    )

    # Login to console and install VyOS before starting configuration
    Set-VMKeystrokes -VMName $VMName -StringInput "vyos" -ReturnCarriage $true
    Set-VMKeystrokes -VMName $VMName -StringInput "vyos" -ReturnCarriage $true
    Set-VMKeystrokes -VMName $VMName -StringInput "install image" -ReturnCarriage $true
    Set-VMKeystrokes -VMName $VMName -StringInput "yes" -ReturnCarriage $true
    Start-Sleep -Seconds 5
    Set-VMKeystrokes -VMName $VMName -StringInput "Auto" -ReturnCarriage $true
    Start-Sleep -Seconds 1
    Set-VMKeystrokes -VMName $VMName -StringInput "sda" -ReturnCarriage $true
    Start-Sleep -Seconds 5
    Set-VMKeystrokes -VMName $VMName -StringInput "yes" -ReturnCarriage $true
    Start-Sleep -Seconds 5
    Set-VMKeystrokes -VMName $VMName -StringInput " " -ReturnCarriage $true
    Start-Sleep -Seconds 10
    Set-VMKeystrokes -VMName $VMName -StringInput "vyos-router" -ReturnCarriage $true
    Start-Sleep -Seconds 5
    Set-VMKeystrokes -VMName $VMName -StringInput " " -ReturnCarriage $true
    Start-Sleep -Seconds 10
    Set-VMKeystrokes -VMName $VMName -StringInput "$ManagementPassword" -ReturnCarriage $true
    Start-Sleep -Seconds 5
    Set-VMKeystrokes -VMName $VMName -StringInput "$ManagementPassword" -ReturnCarriage $true
    Start-Sleep -Seconds 5
    Set-VMKeystrokes -VMName $VMName -StringInput "sda" -ReturnCarriage $true
    Start-Sleep -Seconds 5
    Set-VMKeystrokes -VMName $VMName -StringInput "reboot" -ReturnCarriage $true
    Start-Sleep -Seconds 5
    Set-VMKeystrokes -VMName $VMName -StringInput "y" -ReturnCarriage $true
    Start-Sleep -Seconds 5
    Get-VM $VMName | Get-CDDrive | Set-CDDrive -Connected $false -Confirm:$false -ErrorAction Ignore -WarningAction Ignore | Out-Null

    Write-Host -ForegroundColor Green "VyOS has been installed, VM will reboot for changes to go into effect"
}

Function New-VyOSConfiguration {
<#
    .NOTES
    ===========================================================================
        Created by:    William Lam
        Organization:  VMware
        Blog:          www.virtuallyghetto.com
        Twitter:       @lamw
    ===========================================================================
    .DESCRIPTION
        This function automates the installation and configuration of VyOS from ISO
    .PARAMETER VMName
        The name of the VyOS VM
    .PARAMETER ManagementPassword
        The password to configure for the vyos user
    .PARAMETER ConfigFile
        The path to VyOS configuration file
    .PARAMETER ManagementAddress
        The IP Address of the OUTSIDE Interface (eth0)
    .PARAMETER ManagementGateway
        The Gateway Addrss of the OUTSIDE Interface (eth0)
    .PARAMETER ManagementDNSDomain
        The DNS Domain on the WAN network
    .PARAMETER ManagementDNSServer
        The DNS Server on the WAN Network
    .PARAMETER ManagementJumpHostIP
        The IP Address of Windows Jumphost that can be used to RDP into various VLANs
    .EXAMPLE
        New-VyOSConfiguration -VMName VyOS-Router -ConfigFile vyos.template -ManagementAddress 192.168.30.156/24 -ManagementGateway 192.168.30.1 -ManagementDNSDomain primp-industries.com -ManagementDNSServer 192.168.30.2 -ManagementJumpHostIP 192.168.30.199 -ManagementPassword VMware1!
#>
    param(
        [Parameter(Mandatory=$true)][String]$VMName,
        [Parameter(Mandatory=$true)][String]$ConfigFile,
        [Parameter(Mandatory=$true)][String]$ManagementAddress,
        [Parameter(Mandatory=$true)][String]$ManagementGateway,
        [Parameter(Mandatory=$true)][String]$ManagementDNSDomain,
        [Parameter(Mandatory=$true)][String]$ManagementDNSServer,
        [Parameter(Mandatory=$true)][String]$ManagementJumpHostIP,
        [Parameter(Mandatory=$true)][String]$ManagementPassword
    )

    # Login to console and install VyOS before starting configuration
    Set-VMKeystrokes -VMName $VMName -StringInput "vyos" -ReturnCarriage $true
    Set-VMKeystrokes -VMName $VMName -StringInput "$ManagementPassword" -ReturnCarriage $true

    foreach ($cmd in Get-Content -Path $ConfigFile | Where-Object { $_.Trim() -ne '' }) {
        if($cmd.Contains('[MANAGEMENT_ADDRESS]')) {
            $cmd = $cmd.replace('[MANAGEMENT_ADDRESS]',$ManagementAddress)
            if($Troubleshoot) {
                $cmd
            } else {
                Set-VMKeystrokes -VMName $VMName -StringInput $cmd -ReturnCarriage $true
                Start-Sleep -Seconds 1
            }
        } elseif($cmd.Contains('[MANAGEMENT_IP]')) {
            $ManagementAddress = $ManagementAddress.substring(0,$ManagementAddress.IndexOf('/'))
            $cmd = $cmd.replace('[MANAGEMENT_IP]',$ManagementAddress)
            if($Troubleshoot) {
                $cmd
            } else {
                Set-VMKeystrokes -VMName $VMName -StringInput $cmd -ReturnCarriage $true
                Start-Sleep -Seconds 1
            }
        } elseif($cmd.Contains('[MANAGEMENT_GATEWAY]')) {
            $cmd = $cmd.replace('[MANAGEMENT_GATEWAY]',$ManagementGateway)
            if($Troubleshoot) {
                $cmd
            } else {
                Set-VMKeystrokes -VMName $VMName -StringInput $cmd -ReturnCarriage $true
                Start-Sleep -Seconds 1
            }
        } elseif($cmd.Contains('[JUMPHOST_VM_IP]')) {
            $cmd = $cmd.replace('[JUMPHOST_VM_IP]',$ManagementJumpHostIP)
            if($Troubleshoot) {
                $cmd
            } else {
                Set-VMKeystrokes -VMName $VMName -StringInput $cmd -ReturnCarriage $true
                Start-Sleep -Seconds 1
            }
        } elseif($cmd.Contains('[MANAGEMENT_DNS_DOMAIN]')) {
            $cmd = $cmd.replace('[MANAGEMENT_DNS_DOMAIN]',$ManagementDNSDomain)
            $cmd = $cmd.replace('[MANAGEMENT_DNS_SERVER]',$ManagementDNSServer)
            if($Troubleshoot) {
                $cmd
            } else {
                Set-VMKeystrokes -VMName $VMName -StringInput $cmd -ReturnCarriage $true
                Start-Sleep -Seconds 1
            }
        } elseif($cmd.Contains('[MANAGEMENT_DNS_SERVER]')) {
            $cmd = $cmd.replace('[MANAGEMENT_DNS_SERVER]',$ManagementDNSServer)
            if($Troubleshoot) {
                $cmd
            } else {
                Set-VMKeystrokes -VMName $VMName -StringInput $cmd -ReturnCarriage $true
                Start-Sleep -Seconds 1
            }
        } else {
            if($Troubleshoot) {
                $cmd
            } else {
                Set-VMKeystrokes -VMName $VMName -StringInput $cmd -ReturnCarriage $true
                Start-Sleep -Seconds 1
            }
        }
    }


#runtime


if (-not(find_vyos -Path $vyos_location)) {
    Write-Host "Found VYoS Image"
} else {
    download_vyos($null)
}


#deploy VYoS routers.

#in case you have a self-signed certificate, disable certificate check.
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

#connect to vCenter or ESXi.
connect_vcenter_or_host($null)

#upload iso file to datastore
Copy-DatastoreItem -Item C:\Users\kjohansson\Downloads\vyos-rolling-latest.iso -Destination ds:\vyos-iso\vyos-rolling-latest.iso -Force

#create first VYoS
New-VM -Name $vyos01_hostname -ResourcePool $vmw_esxi_host -Datastore $vmw_datastore -NumCpu 1 -MemoryMB 512 -DiskGB 10 -NetworkName $vyos01_eth0_pg -CD -VMHost $vmw_esxi_host
New-AdvancedSetting -Entity $vyos01_hostname -Name ‘cdrom.showIsoLockWarning’ -Value ‘false’ -Confirm:$false
New-AdvancedSetting -Entity $vyos01_hostname -Name ‘msg.autoanswer’ -Value ‘true’ -Confirm:$false

#attach iso to VM
Get-VM -Name $vyos01_hostname | Get-CDDrive | Set-CDDrive -IsoPath "[$vmw_datastore] vyos-iso\vyos-rolling-latest.iso" -StartConnected $true -Confirm:$false

#start vm
Start-vm -vm $vyos01_hostname