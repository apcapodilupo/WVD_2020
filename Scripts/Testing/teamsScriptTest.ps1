
Param(
  [string] $storageAccountName,
  [string] $ResourceGroupName,
  [string] $administratorAccountUsername,
  [string] $administratorAccountPassword,
  [string] $subscriptionID
  )


##create share name
#$shareName = $storageAccountName+'.file.core.windows.net'
#$connectionString = '\\' + $storageAccountName + '.file.core.windows.net\userprofiles'
############Files#################################################################################################################
#
###Install FSLOGIX Agent
##sets execution policy to 'bypass' and installs chocolatey package manager
#Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/apcapodilupo/WVD_2020/main/Scripts/install.ps1'))
#
#
##installs fslogix apps 
#choco install fslogix -yes --ignore-checksums
#
#sleep 10
#
##configure fslogix profile containers
#
##create profiles key
#New-Item 'HKLM:\Software\FSLogix\Profiles' -Force 
#sleep 10
#
##create enabled value
#New-ITEMPROPERTY 'HKLM:\Software\FSLogix\Profiles' -Name Enabled -Value 1
#sleep 10
#
#
##removes any local profiles that are found
#New-ITEMPROPERTY 'HKLM:\Software\FSLogix\Profiles' -Name DeleteLocalProfileWhenVHDShouldApply -Value 1
#sleep 10
#
##set  connection string
#New-ITEMPROPERTY 'HKLM:\Software\FSLogix\Profiles' -Name VHDLocations -PropertyType String -Value $connectionString
#sleep 10
#
##set to vhdx
#New-ITEMPROPERTY 'HKLM:\Software\FSLogix\Profiles' -Name VolumeType -PropertyType String -Value "vhdx"
#
#sleep 10



#Installs Teams

##Create required registry entry
#reg add "HKLM\SOFTWARE\Microsoft\Teams" /v IsWVDEnvironment /t REG_DWORD /d 1 /f
#
##VisualC++ Source x64
#$VisualCSource = "https://aka.ms/vs/16/release/vc_redist.x64.exe"
#
##Remote Desktop WebRTC Redirector Service Source
#$RDWRedirectorSource = "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE4AQBt"
#
##Teams Source x64
#$TeamsSource = "https://statics.teams.cdn.office.net/production-windows-x64/1.3.00.21759/Teams_windows_x64.msi"
#
##Download Location
#$location = "D:\"
#$locationRDWR = "D:\MsRdcWebRTCSvc_HostSetup_1.0.2006.11001_x64.msi"
#$locationvcc = "D:\vc_redist.x64.exe"
#$locationteamsdownload = "C:\"
#$locationteams = "C:\Teams_windows_x64.msi"
#
#Set-ExecutionPolicy Unrestricted -force
#
##Download Remote Desktop WebRTC Redirector Service Source
#Invoke-WebRequest -Uri $RDWRedirectorSource -OutFile $locationRDWR
#Start-Process -FilePath "$locationRDWR" /quiet
#
##Download VisualC++ x64
#Start-BitsTransfer -Source $VisualCSource -Destination $location
#Start-Process -FilePath "$locationvcc" /quiet
#
##Download Teams Source x64
#Start-BitsTransfer -Source $TeamsSource -Destination $locationteamsdownload
#
##Run this following command to install Teams
#msiexec /i $locationteams /l*v teams_install.log ALLUSERS=1 ALLUSER=1