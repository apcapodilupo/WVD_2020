Param(
  [string] $storageAccountName,
  [string] $ResourceGroupName,
  [string] $administratorAccountUsername,
  [string] $administratorAccountPassword,
  [string] $SubscriptionId
  )
 


$MyLastExitCode = $LastExitCode

#create directory for log file
New-Item -ItemType "directory" -Path C:\DeploymentLogs

#create Log File
New-Item C:\DeploymentLogs\log.txt
Set-Content C:\DeploymentLogs\log.txt "Starting Script. exit code is: $MyLastExitCode"
Set-Content C:\DeploymentLogs\log.txt "exit code is: $MyLastExitCode"

#set execution policy
Set-Content C:\DeploymentLogs\log.txt "Setting Execution policy. exit code is: $MyLastExitCode"
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -force

#enable TLS 1.2 
Set-Content C:\DeploymentLogs\log.txt "Enabling TLS. exit code is: $MyLastExitCode"
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord
sleep 5

Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord
sleep 5

#Install NuGet Modules
Set-Content C:\DeploymentLogs\log.txt "Downloading modules. exit code is: $MyLastExitCode"
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name PowerShellGet -Force -AllowClobber
sleep 5

#install AZ modules
Install-Module -Name Az -force -AllowClobber
sleep 30

Import-Module Az.Accounts -force 
sleep 30

#Download StgAcct Script
Set-Content C:\DeploymentLogs\log.txt "downloading JoinStorageAccount Script. exit code is: $MyLastExitCode"
$Url = 'https://github.com/apcapodilupo/WVD_2020/blob/main/Scripts/JoinStorageAccount.zip?raw=true' 
Invoke-WebRequest -Uri $Url -OutFile "C:\JoinStorageAccount.zip"
Expand-Archive -Path "C:\JoinStorageAccount.zip" -DestinationPath "C:\JoinStorageAccount" -Force 

#create share name
$shareName = $storageAccountName+'.file.core.windows.net'
$connectionString = '\\' + $storageAccountName + '.file.core.windows.net\userprofiles'
###########Files#################################################################################################################

Set-Content C:\DeploymentLogs\log.txt "installing FSLogix. exit code is: $MyLastExitCode"
##Install FSLOGIX Agent
#sets execution policy to 'bypass' and installs chocolatey package manager
#Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/apcapodilupo/WVD_2020/main/Scripts/install.ps1'))


#installs fslogix apps 
choco install fslogix -yes --ignore-checksums

sleep 10


#configure fslogix profile containers

Set-Content C:\DeploymentLogs\log.txt "Setting FSLogix Registry Keys. exit code is: $MyLastExitCode"
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

Set-Content C:\DeploymentLogs\log.txt "Script Complete. exit code is: $MyLastExitCode"



