﻿
Param(
  [string] $storageAccountName,
  [string] $ResourceGroupName,
  [string] $administratorAccountUsername,
  [string] $administratorAccountPassword,
  [string] $subscriptionID,
  [string] $installTeams
  )

#create share name
$shareName = $storageAccountName+'.file.core.windows.net'
$connectionString = '\\' + $storageAccountName + '.file.core.windows.net\userprofiles'
###########Files#################################################################################################################

##Install FSLOGIX Agent
#sets execution policy to 'bypass' and installs chocolatey package manager
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/apcapodilupo/WVD_2020/main/Scripts/install.ps1'))


#installs fslogix apps 
choco install fslogix -yes --ignore-checksums

sleep 10

#configure fslogix profile containers

#create profiles key
New-Item 'HKLM:\Software\FSLogix\Profiles' -Force 
sleep 10

#create enabled value
New-ITEMPROPERTY 'HKLM:\Software\FSLogix\Profiles' -Name Enabled -Value 1
sleep 10


#removes any local profiles that are found
New-ITEMPROPERTY 'HKLM:\Software\FSLogix\Profiles' -Name DeleteLocalProfileWhenVHDShouldApply -Value 1
sleep 10

#set  connection string
New-ITEMPROPERTY 'HKLM:\Software\FSLogix\Profiles' -Name VHDLocations -PropertyType String -Value $connectionString
sleep 10

#set to vhdx
New-ITEMPROPERTY 'HKLM:\Software\FSLogix\Profiles' -Name VolumeType -PropertyType String -Value "vhdx"

sleep 10

#enable GPU rendering###############################################################################################
New-ITEMPROPERTY 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name bEnumerateHWBeforeSW -Value 1
sleep 10

#sets AVC Encoding
New-ITEMPROPERTY 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name AVCHardwareEncodePreferred -Value 1
sleep 10

#Full Screen Rendering
New-ITEMPROPERTY 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name AVC444ModePreferred -Value 1
sleep 10
#####################################################################################################################


#Add Defender Exclusions for FSLogix
powershell -Command "Add-MpPreference -ExclusionPath 'C:\Program Files\FSLogix\Apps\frxdrv.sys’"
powershell -Command "Add-MpPreference -ExclusionPath 'C:\Program Files\FSLogix\Apps\frxdrvvt.sys’"
powershell -Command "Add-MpPreference -ExclusionPath 'C:\Program Files\FSLogix\Apps\frxccd.sys’"
powershell -Command "Add-MpPreference -ExclusionExtension '%TEMP%\*.VHD’"
powershell -Command "Add-MpPreference -ExclusionExtension '%TEMP%\*.VHDX’"
powershell -Command "Add-MpPreference -ExclusionExtension '%Windir%\*.VHD’"
powershell -Command "Add-MpPreference -ExclusionExtension '%Windir%\*.VHDX’"
powershell -Command "Add-MpPreference -ExclusionExtension '\\gcrwvduserprofiles.file.core.windows.net\userprofiles\*\*.*.VHDX’"
powershell -Command "Add-MpPreference -ExclusionExtension '\\gcrwvduserprofiles.file.core.windows.net\userprofiles\*\*.*.VHD’"
powershell -Command "Add-MpPreference -ExclusionProcess '%Program Files%\FSLogix\Apps\frxccd.exe’"
powershell -Command "Add-MpPreference -ExclusionProcess '%Program Files%\FSLogix\Apps\frxccds.exe’"
powershell -Command "Add-MpPreference -ExclusionProcess '%Program Files%\FSLogix\Apps\frxsvc.exe’"


if ($installTeams -eq 'Yes'){

    #create Teams folder in C drive
    New-Item -Path "c:\" -Name "Install" -ItemType "directory"

    # Add registry Key
    reg add "HKLM\SOFTWARE\Microsoft\Teams" /v IsWVDEnvironment /t REG_DWORD /d 1 /f
    sleep 5

    #Download C++ Runtime
    invoke-WebRequest -Uri https://aka.ms/vs/16/release/vc_redist.x64.exe -OutFile "C:\Install\vc_redist.x64.exe"
    sleep 5

    #Download RDCWEBRTCSvc
    invoke-WebRequest -Uri https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE4AQBt -OutFile "C:\Install\MsRdcWebRTCSvc_HostSetup_1.0.2006.11001_x64.msi"
    sleep 5

    #Download Teams 
    invoke-WebRequest -Uri https://statics.teams.cdn.office.net/production-windows-x64/1.3.00.13565/Teams_windows_x64.msi -OutFile "C:\Install\Teams_windows_x64.msi"
    sleep 5

    #Install C++ runtime
    Start-Process -FilePath C:\Install\vc_redist.x64.exe -ArgumentList '/q', '/norestart'
    sleep 5

    #Install Web Socket Redirector Service
    msiexec /i C:\Install\MsRdcWebRTCSvc_HostSetup_1.0.2006.11001_x64.msi /q /n
    sleep 5

    # Install Teams
    msiexec /i "C:\Install\Teams_windows_x64.msi" /l*v c:\Install\Teams.log ALLUSER=1 ALLUSERS=1 
    sleep 5

}

