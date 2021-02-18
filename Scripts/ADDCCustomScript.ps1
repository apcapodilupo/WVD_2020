Param(
  [string] $storageAccountName,
  [string] $ResourceGroupName,
  [string] $administratorAccountUsername,
  [string] $administratorAccountPassword,
  [string] $SubscriptionId
  )

#set the code to 0 (this will change if a non-zero is returned on any command.)
$LASTEXITCODE = 0

#create directory for log file
New-Item -ItemType "directory" -Path C:\DeploymentLogs
sleep 5

#create Log File
New-Item C:\DeploymentLogs\log.txt
sleep 5

#create initial log
Add-Content C:\DeploymentLogs\log.txt "Starting Script. exit code is: $LASTEXITCODE"
sleep 5

#set execution policy
Add-Content C:\DeploymentLogs\log.txt "Setting Execution Policy. exit code is: $LASTEXITCODE"
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -force

#enable TLS 1.2 (required for Windows Server 2016)###############################################################################
Add-Content C:\DeploymentLogs\log.txt "Setting TLS. exit code is: $LASTEXITCODE"
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord
sleep 5

Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord
sleep 5
#################################################################################################################################

Add-Content C:\DeploymentLogs\log.txt "Installing Nuget Modules. exit code is: $LASTEXITCODE"
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Add-Content C:\DeploymentLogs\log.txt "Installing powershellGet Modules. exit code is: $LASTEXITCODE"
Install-Module -Name PowerShellGet -Force -AllowClobber
sleep 5

#install AZ modules
Add-Content C:\DeploymentLogs\log.txt "Installing AZ Modules. exit code is: $LASTEXITCODE"
Install-Module -Name Az -force -AllowClobber
sleep 30

Add-Content C:\DeploymentLogs\log.txt "Importing AZ.Accounts module. exit code is: $LASTEXITCODE"
Import-Module Az.Accounts -force 
sleep 30

Add-Content C:\DeploymentLogs\log.txt "downloading storageAccountScript. exit code is: $LASTEXITCODE"
$Url = 'https://github.com/apcapodilupo/WVD_2020/blob/main/Scripts/JoinStorageAccount.zip?raw=true' 
Invoke-WebRequest -Uri $Url -OutFile "C:\JoinStorageAccount.zip"
Expand-Archive -Path "C:\JoinStorageAccount.zip" -DestinationPath "C:\JoinStorageAccount" -Force 

#create share name
$shareName = $storageAccountName+'.file.core.windows.net'
$connectionString = '\\' + $storageAccountName + '.file.core.windows.net\userprofiles'
###########Files#################################################################################################################

##Install FSLOGIX Agent
#sets execution policy to 'bypass' and installs chocolatey package manager
#Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Add-Content C:\DeploymentLogs\log.txt "Installing chocolatey. exit code is: $LASTEXITCODE"
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/apcapodilupo/WVD_2020/main/Scripts/install.ps1'))


#installs fslogix apps 
Add-Content C:\DeploymentLogs\log.txt "Installing FSLogix. exit code is: $LASTEXITCODE"
sleep 10

choco install fslogix -yes --ignore-checksums

sleep 10


#configure fslogix profile containers
Add-Content C:\DeploymentLogs\log.txt "Setting FSLogix Registry Keys. exit code is: $LASTEXITCODE"

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

Add-Content C:\DeploymentLogs\log.txt "Execution complete. Final exit code is: $LASTEXITCODE"





