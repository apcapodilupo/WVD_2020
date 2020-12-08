Write-Output "This script will Configure the FSLogix agent to point to an existing storage account."

$StorageAccountName = Read-Host -Prompt "Enter the Storage Account name from your WVD deployment: "

$shareName = $storageAccountName+'.file.core.windows.net'
$connectionString = '\\' + $storageAccountName + '.file.core.windows.net\userprofiles'


Write-Output "Installing chocolatey package manager..."
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/apcapodilupo/WVD_2020/main/Scripts/install.ps1'))
Write-Output "Done."

#installs fslogix apps 
Write-Output "installing the fslogix agent..."
choco install fslogix -yes --ignore-checksums
sleep 05
Write-Output "Done."


Write-Output "creating FSlogix registry keys..."

#create profiles key
New-Item 'HKLM:\Software\FSLogix\Profiles' -Force 
sleep 05

#create enabled value
New-ITEMPROPERTY 'HKLM:\Software\FSLogix\Profiles' -Name Enabled -Value 1
sleep 05


#removes any local profiles that are found
New-ITEMPROPERTY 'HKLM:\Software\FSLogix\Profiles' -Name DeleteLocalProfileWhenVHDShouldApply -Value 1
sleep 05

#set  connection string
New-ITEMPROPERTY 'HKLM:\Software\FSLogix\Profiles' -Name VHDLocations -PropertyType String -Value $connectionString
sleep 05

#set to vhdx
New-ITEMPROPERTY 'HKLM:\Software\FSLogix\Profiles' -Name VolumeType -PropertyType String -Value "vhdx"

Write-Output "Done."

Write-Output "FSLogix is now configured to point to storage account: $StorageAccountName"




