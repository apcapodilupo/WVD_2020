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

#create Log File and error log file
New-Item C:\DeploymentLogs\log.txt
New-Item C:\DeploymentLogs\errors.txt
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

#Install Nuget Modules
try{
  Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
  Add-Content C:\DeploymentLogs\log.txt "Installing Nuget Modules. exit code is: $LASTEXITCODE"
  sleep 10
}
catch{
    Add-Content C:\DeploymentLogs\log.txt "Error occurred downloading NuGet Modules with exit code: $LASTEXITCODE."
}



#install PSGet modules
try{
    Add-Content C:\DeploymentLogs\log.txt "Installing powershellGet Modules. exit code is: $LASTEXITCODE"
    Install-Module -Name PowerShellGet -Force -AllowClobber
    sleep 10

}
catch{
    Add-Content C:\DeploymentLogs\log.txt "Error occurred downloading PSGet with exit code: $LASTEXITCODE"
}



#install AZ modules
try{
 Install-Module -Name Az -force -AllowClobber
 Add-Content C:\DeploymentLogs\log.txt "Installing AZ Modules. exit code is: $LASTEXITCODE"
 sleep 10
}
catch{
    Add-Content C:\DeploymentLogs\log.txt "Error occurred downloading az Modules with exit code: $LASTEXITCODE"
}


#install AZAccounts modules
try{

    Add-Content C:\DeploymentLogs\log.txt "Importing AZ.Accounts module. exit code is: $LASTEXITCODE"
    Import-Module Az.Accounts -force 
    sleep 10

}
catch{
    Add-Content C:\DeploymentLogs\log.txt "Error occurred Importing azAccounts Modules with exit code: $LASTEXITCODE"
}


#download storage account script
try{

    Add-Content C:\DeploymentLogs\log.txt "downloading storageAccountScript. exit code is: $LASTEXITCODE"
    $Url = 'https://github.com/apcapodilupo/WVD_2020/blob/main/Scripts/JoinStorageAccount.zip?raw=true' 
    Invoke-WebRequest -Uri $Url -OutFile "C:\JoinStorageAccount.zip"
    sleep 5
    Expand-Archive -Path "C:\JoinStorageAccount.zip" -DestinationPath "C:\JoinStorageAccount" -Force 

}
catch{
     Add-Content C:\DeploymentLogs\log.txt "Error downloading and expanding storage account script. exit code is: $LASTEXITCODE"
}

#create share name for fslogix
$shareName = $storageAccountName+'.file.core.windows.net'
$connectionString = '\\' + $storageAccountName + '.file.core.windows.net\userprofiles'

#Install Chocolatey
try{
    Add-Content C:\DeploymentLogs\log.txt "Installing chocolatey. exit code is: $LASTEXITCODE"
    sleep 5
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/apcapodilupo/WVD_2020/main/Scripts/install.ps1'))
}
catch{
     Add-Content C:\DeploymentLogs\log.txt "Error downloading chocolatey package manager. exit code is: $LASTEXITCODE"
}

#install fslogix apps
try{ 
    Add-Content C:\DeploymentLogs\log.txt "Installing FSLogix. exit code is: $LASTEXITCODE"
    choco install fslogix -yes --ignore-checksums
    sleep 5
}
catch{
    Add-Content C:\DeploymentLogs\log.txt "Error downloading FSLogix agent. exit code is: $LASTEXITCODE"
}


#configure fslogix profile containers
Add-Content C:\DeploymentLogs\log.txt "Setting FSLogix Registry Keys. exit code is: $LASTEXITCODE"

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
sleep 05


if($LASTEXITCODE -ne 0){

    Add-Content C:\DeploymentLogs\log.txt "Execution finished with non-zero exit code of: $LASTEXITCODE. Please check the error log."
    Add-Content C:\DeploymentLogs\error.txt $Error
    exit 0
}

Add-Content C:\DeploymentLogs\log.txt "Execution complete. Final exit code is: $LASTEXITCODE"
Add-Content C:\DeploymentLogs\error.txt $Error
exit 0






