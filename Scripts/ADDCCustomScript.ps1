Param(
  [string] $storageAccountName,
  [string] $ResourceGroupName,
  [string] $administratorAccountUsername,
  [string] $administratorAccountPassword,
  [string] $SubscriptionId
  )
 
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -force

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name PowerShellGet -Force -AllowClobber
sleep 5

#install AZ modules
Install-Module -Name Az -force -AllowClobber
sleep 5

Import-Module Az.Accounts -force 
sleep 5


$Url = 'https://raw.githubusercontent.com/acapodilupo/WVD_Solution/master/WVD%20-%20July%20Updates/Scripts/JoinStorageAccount.zip'
Invoke-WebRequest -Uri $Url -OutFile "C:\JoinStorageAccount.zip"
Expand-Archive -Path "C:\JoinStorageAccount.zip" -DestinationPath "C:\JoinStorageAccount" -Force 

#create share name
$shareName = $storageAccountName+'.file.core.windows.net'
$connectionString = '\\' + $storageAccountName + '.file.core.windows.net\userprofiles'
###########Files#################################################################################################################

##Install FSLOGIX Agent
#sets execution policy to 'bypass' and installs chocolatey package manager
#Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/apcapodilupo/WVD_2020/main/Scripts/install.ps1?token=ARN6WUDF5HA6MBIYHY35STS7RXLJW'))

https://raw.githubusercontent.com/acapodilupo/WVD_Solution/master/DSC/chocolatey.0.10.15.nupkg

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




