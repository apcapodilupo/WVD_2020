
Param(
  [string] $storageAccountName,
  [string] $ResourceGroupName,
  [string] $administratorAccountUsername,
  [string] $administratorAccountPassword,
  [string] $subscriptionID
  )

#set the code to 0 (this will change if a non-zero is returned on any command.)
$LASTEXITCODE = 0

#create directory for log file
New-Item -ItemType "directory" -Path C:\DeploymentLogs
sleep 5

#create Log File and error log file
New-Item C:\DeploymentLogs\log.txt
New-Item C:\DeploymentLogs\errorlog.txt
sleep 5

#create initial log
Add-Content C:\DeploymentLogs\log.txt "Starting Script. exit code is: $LASTEXITCODE"
sleep 5

#create share name for FSLogix
$shareName = $storageAccountName+'.file.core.windows.net'
$connectionString = '\\' + $storageAccountName + '.file.core.windows.net\userprofiles'


#Install Chocolatey
try{
    Add-Content C:\DeploymentLogs\log.txt "Installing chocolatey. exit code is: $LASTEXITCODE"
    sleep 5
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/apcapodilupo/WVD_2020/main/Scripts/install.ps1'))
}
catch{
     Add-Content C:\DeploymentLogs\log.txt "Error downloading chocolatey package manager. exit code is: $LASTEXITCODE. Please check the error log."
}


#install FSlogix
try{ 
    Add-Content C:\DeploymentLogs\log.txt "Installing FSLogix. exit code is: $LASTEXITCODE"
    choco install fslogix -yes --ignore-checksums
    sleep 5
}
catch{
    Add-Content C:\DeploymentLogs\log.txt "Error downloading FSLogix agent. exit code is: $LASTEXITCODE. Please check the error log."
}

sleep 5

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
    Add-Content C:\DeploymentLogs\errorlog.txt $Error
}
else{
    Add-Content C:\DeploymentLogs\log.txt "Execution complete! Final exit code is: $LASTEXITCODE"
    Add-Content C:\DeploymentLogs\errorlog.txt $Error

}




