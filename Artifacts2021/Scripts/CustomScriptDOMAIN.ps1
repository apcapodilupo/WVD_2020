Param(
  [string] $storageAccountName,
  [string] $ResourceGroupName,
  [string] $administratorAccountUsername,
  [string] $administratorAccountPassword,
  [string] $SubscriptionId,
  [string] $installTeams

  )
 
#set the code to 0 (this will change if there are errors.)
$LASTEXITCODE = 0

#create directory for log file
New-Item -ItemType "directory" -Path C:\DeploymentLogs
sleep 5

#create Log File
New-Item C:\DeploymentLogs\log.txt
sleep 5 

Set-Content C:\DeploymentLogs\log.txt "Starting Script. exit code is: $LASTEXITCODE"
sleep 5

#set execution policy
Set-Content C:\DeploymentLogs\log.txt "Setting Execution Policy. exit code is: $LASTEXITCODE"
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -force

Set-Content C:\DeploymentLogs\log.txt "Setting TLS. exit code is: $LASTEXITCODE"
#enable TLS 1.2 (required for Windows Server 2016)###############################################################################
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord
sleep 5

Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord
sleep 5
#################################################################################################################################


Set-Content C:\DeploymentLogs\log.txt "Installing Nuget Modules. exit code is: $LASTEXITCODE"
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name PowerShellGet -Force -AllowClobber
sleep 5

Set-Content C:\DeploymentLogs\log.txt "Installing AZ Modules. exit code is: $LASTEXITCODE"
#install AZ modules
Install-Module -Name Az -force -AllowClobber
sleep 30

Import-Module Az.Accounts -force 
sleep 30


Set-Content C:\DeploymentLogs\log.txt "downloading storageAccountScript. exit code is: $LASTEXITCODE"
$Url = 'https://github.com/apcapodilupo/WVD_2020/blob/main/Scripts/JoinStorageAccount.zip?raw=true' 
Invoke-WebRequest -Uri $Url -OutFile "C:\JoinStorageAccount.zip"
Expand-Archive -Path "C:\JoinStorageAccount.zip" -DestinationPath "C:\JoinStorageAccount" -Force 

#create share name
$shareName = $storageAccountName+'.file.core.windows.net'
$connectionString = '\\' + $storageAccountName + '.file.core.windows.net\userprofiles'
###########Files#################################################################################################################

Set-Content C:\DeploymentLogs\log.txt "Installing chocolatey. exit code is: $LASTEXITCODE"
##Install FSLOGIX Agent
#sets execution policy to 'bypass' and installs chocolatey package manager
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/apcapodilupo/WVD_2020/main/Scripts/install.ps1'))

Set-Content C:\DeploymentLogs\log.txt "Installing FSLogix. exit code is: $LASTEXITCODE"
#installs fslogix apps 
choco install fslogix -yes --ignore-checksums

sleep 10


#configure fslogix profile containers

Set-Content C:\DeploymentLogs\log.txt "Setting FSLOgix Registry Keys. exit code is: $LASTEXITCODE"

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

Set-Content C:\DeploymentLogs\log.txt "Setting Defender Exclusions for FSLogix. exit code is: $LASTEXITCODE"
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

    Set-Content C:\DeploymentLogs\log.txt "Installing Teams. exit code is: $LASTEXITCODE"


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


Set-Content C:\DeploymentLogs\log.txt "Execution complete. Final exit code is: $LASTEXITCODE"




