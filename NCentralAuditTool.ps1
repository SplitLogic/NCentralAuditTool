$JWT = ""
$ServerFQDN = ""
New-NCentralConnection -ServerFQDN $ServerFQDN -JWT $JWT
$SubFunction1={
    Get-NCCustomerList | Select-Object CustomerName,CustomerID | Format-Table
    $CustomerID = Read-Host "Please input the customer number:"
    Write-Host "Please Wait..." -ForegroundColor Green
    $Devices = Get-NCDeviceList -customerID $CustomerID
    $List = @()
    $today = Get-Date
    $imports = import-csv "C:\Temp\Procs.csv"
    foreach ($Device in $Devices){        
        #Create rows for list and select device by ID
        $Row = "" | Select-Object ID,Site,Name,Class,OS,Manufacturer,Model,Serial,Processor,RAM,Storage1,Storage2,Storage3,Storage4,Age
        $ID = $Device.DeviceID
        $Device = Get-NCDeviceObject -DeviceID $ID
        #Return ID
        $row.ID = $ID        
        #Return Customer name
        $customername = $device.customer
        $row.Site = $customername.customername
        $customername = $customername.customername
        #Return Computer Name
        $Row.Name = $device.longname
        #Return Device Class
        $Class = $device.deviceclass
        $Class = $class -replace ' - Windows',''
        $Class = $class -replace 'Workstations','Desktop'
        $Class = $class -replace 'Servers','Server'
        $Row.Class = $Class
        #Return OS
        $OS = $device.os
        $row.OS = $OS.reportedos
        #Return Manufacturer and Model and Serial
        $CS = $device.computersystem
        $row.Manufacturer = $CS.Manufacturer
        $row.Model = $CS.Model
        $row.Serial = $CS.serialnumber
        #Return processor name
        $processor = $Device.processor
        $processor = $processor.name
        $processor = $processor -replace '          ',''
        $processor = $processor -replace '\(TM\)',''
        $processor = $processor -replace '\(R\)',''
        $row.processor = $processor
        $processor = $processor -replace 'Intel ',''
        $processor = $processor -replace 'AMD ',''
        $processor = $processor -replace 'CPU ',''
        $Age = "Not in DB"
        foreach ($import in $imports) {
            $name = $import.Name
            if ($processor.contains($name)) {
                Try{
                $Age = New-TimeSpan -start $import.released -end ($today)
                $age = $Age.Days / 365
                $age = [math]::Round($Age,1)
                }
                Catch{}
            }
            else{}
        }
        $row.Age = $Age
        #RAM Calculation
        $Memory = $device.memory
        $RAM = 0
        $memory | ForEach-Object {$RAM += $_.capacity}
        $row.RAM = $RAM /1GB
        #Get Storage
        $drives = $device.physicaldrive
        Foreach ($Drive in $Drives){
            switch ($drive.ItemId){
                'physicaldrive.0'{
                $Drive1 = $drive.capacity
                $Drive1 = [math]::round($Drive1/1GB,2)
                $Storage1 = $drive1.ToString() + "GB" + " " + $drive.modelnumber
                $row.Storage1 = $Storage1
            }
                'physicaldrive.1'{
                $Drive2 = $drive.capacity
                $Drive2 = [math]::round($Drive2/1GB,2)
                $Storage2 = $drive2.ToString() + "GB" + " " + $drive.modelnumber
                $row.Storage2 = $Storage2
            }
                'physicaldrive.2'{
                $Drive3 = $drive.capacity
                $Drive3 = [math]::round($Drive3/1GB,2)
                $Storage3 = $drive3.ToString() + "GB" + " " + $drive.modelnumber
                $row.Storage3 = $Storage3
            }
                'physicaldrive.3'{
                $Drive4 = $drive.capacity
                $Drive4 = [math]::round($Drive4/1GB,2)
                $Storage4 = $drive4.ToString() + "GB" + " " + $drive.modelnumber
                $row.Storage4 = $Storage4
            }
                $null{}
            }    
        } 
        #Append Table
        $List += $Row       
    }
    $FilePath = "C:\Temp\$customername-DeviceAudit.csv"
    if (Test-Path $Filepath = $True) {
        $list | Export-Csv -notypeinformation $FilePath
        Import-Csv (Get-ChildItem $Filepath) | Sort-Object -Unique ID | Export-Csv $Filepath -NoClobber -NoTypeInformation
        Write-Host "Sorted audit has been saved to C:\Temp\$customername-DeviceAudit.csv" -ForegroundColor Blue
        Remove-Item $Filepath
        }
    if (Test-Path $Filepath = $False) {
    Write-Host "Unable to delete previous file. Please delete and rerun this tool"
    }
    Import-CSV $
    $Excel = New-Object -ComObject Excel.Application
    $Workbook = $Excel.Workbooks.Open($FilePath)
    $excel.visible = $true
    Write-Host "That should now be open in Excel for you"
}
$SubFunction2={
    $DevicesNotReady = @()
    Get-NCCustomerList | Select-Object CustomerName,CustomerID | Format-Table
    $CustomerID = Read-Host "Please input the customer number:"
    Write-Host "Please Wait..." -ForegroundColor Green
        $Devices = Get-NCDeviceList -customerID $CustomerID
        Foreach ($device in $Devices){
            $ID = $Device.DeviceID
            $CustomerName = $Device.customername
            $Device = Get-NCDeviceObject -DeviceID $ID
            $Row = "" | Select-Object CustomerName,Device,'Windows 11 Ready Status'
            $device.customername
            $Row.CustomerName = $customername
            $Row.Device = $device.longname
            $PropertyList = Get-NCDevicePropertyList -DeviceID $id
            $status = $propertylist.'Windows 11 Ready'
            $State = "No Data"
            if ($device.deviceclass -eq "Servers"){
                $State = "Server"
            }
            Else{
                if ($status -eq 'Not Ready'){
                    $state = "Not Ready"
                }
                elseif ($status -eq 'Ready'){
                    $state = "Windows 11 Ready"
                }
                elseif ($status = 'Already Windows 11'){
                    $state =  "Already Windows 11"
                }
                else{
                    $state = "No Data"
                }
            }
            $row.'Windows 11 Ready Status' = $state
            $row.device
            $DevicesNotReady += $Row
        }
    $DevicesNotReady | Format-Table
    $ExportCSV = Read-Host "Do you want to export to CSV? Y/N"
    switch($ExportCSV){
        'y' {
            Write-Host "The file has been exported to C:\Temp\$name-W11Reayness.csv" -ForegroundColor Blue
            $FilePath = "C:\Temp\$name-W11Readyness.csv"
            $DevicesNotReady| Export-Csv -notypeinformation $FilePath
            Import-Csv (Get-ChildItem $Filepath) | Sort-Object -Unique ID | Export-Csv $Filepath -NoClobber -NoTypeInformation
            $Excel = New-Object -ComObject Excel.Application
            $Workbook = $Excel.Workbooks.Open($FilePath)
            Write-Host "That should now be open in Excel for you"
            Read-host -prompt "Press any key to continue"
        }
        'n' {
            Read-host -prompt "Press any key to continue"
        }
    }
}
$SubFunction3={
    Get-NCCustomerList | Select-Object CustomerName,CustomerID | Format-Table
    $CustomerID = Read-Host "Please input the customer number:"
    $name = 
    Write-Host "Please Wait..." -ForegroundColor Green
    $Devices = Get-NCDeviceList -customerID $CustomerID
    $List = @()
    Foreach ($device in $Devices){
        $name = $device.customer
        $ID = $Device.DeviceID
        $Device = Get-NCDeviceObject -DeviceID $ID
        $Row = "" | Select-Object Device,'KFM Status - Current User'
        $Row.Device = $device.longname
        $PropertyList = Get-NCDevicePropertyList -DeviceID $id
        $status = $propertylist.'KFM Status - Current User'
        if ($status -eq $null){
            $status = "Not Applicable to this Device"
        }
        elseif ($status -eq ''){
            $status = "Not Enabled for the Current User"
        }
        else {
            $status = "KFM Enabled"
        }
        $row.'KFM Status - Current User' = $status
        $List += $Row
    }
    $list | Format-Table
    Write-Host "Please note that these results are only up to date with the records in N-Central" -ForegroundColor Green
    Write-Host "For best results please run the automation policy to update this property first" -ForegroundColor Green
    $ExportCSV = Read-Host "Do you want to export to CSV? Y/N"
    switch($ExportCSV){
        'y' {
            $list | Export-Csv -notypeinformation $FilePath
            Import-Csv (Get-ChildItem $Filepath) | Sort-Object -Unique ID | Export-Csv $Filepath -NoClobber -NoTypeInformation
            Write-Host "The file has been exported to C:\Temp\$name-KFMStatus.csv" -ForegroundColor Blue
            $FilePath = "C:\Temp\$name-KFMStatus.csv"
            $Excel = New-Object -ComObject Excel.Application
            $Workbook = $Excel.Workbooks.Open($FilePath)
            Write-Host "That should now be open in Excel for you"
            Read-host -prompt "Press any key to continue"
        }
        'n' {
            Read-host -prompt "Press any key to continue"
        }
    }
}
$SubFunction4={
    Get-NCCustomerList | Select-Object CustomerName,CustomerID | Format-Table
    $CustomerID = Read-Host "Please input the customer number:"
    $ActiveIssues = Get-NCActiveIssuesList -CustomerID $CustomerID | Select-Object Devicename,Servicename,notifstate,customername
    $FormattedIssues = @()
    Foreach ($issue in $ActiveIssues){
        $row = ''| Select-Object DeviceName,Service,State
        $row.devicename = $issue.devicename
        $row.service = $issue.servicename
        switch ($issue.notifstate) {
            4 {$row.state = "Warning"}
            5 {$row.State = "Error"}
            6 {$row.state = "Misconfigured"}
            7 {$row.state = "Currently Offline"}
            }
        $FormattedIssues += $row
        }
    $FormattedIssues | Format-Table
    Read-Host -Prompt "Press any key to continue"
}
$SubFunction5={
    Get-NCCustomerList | Select-Object CustomerName,CustomerID | Format-Table
    $CustomerID = Read-Host "Please input the customer number:"
    Get-NCDeviceList -CustomerID $CustomerID |Select-Object deviceid,longname,deviceclass,agentversion | Format-Table
    $DeviceID = Read-Host "Please input the Device ID:"
    Get-NCDeviceStatus -DeviceID $DeviceID | Select-Object devicename,modulename,statestatus,transitiontime | Format-Table
    Read-Host -Prompt "Press any key to continue"
    Return
}
$InstallModuleFunction={
    if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
        if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
            $CommandLine = "Install-Module -Name PS-NCentral | Return"
            Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
            Return
           }
          }
}
$ProcessorListTool={  
    $PLTSubFunction1={
        if (Test-Path -Path C:\Temp\Procs.csv){
            Write-Host "YAY Procs.csv Exists"
            $Master = Import-Csv C:\Temp\Procs.csv
        }
        else {
            Write-Host "I cant find it, where is it?"
            Write-Host "I'll just make a new one..."
            $Row = "" | Select-Object Name,Codename,Cores,Clock,Socket,Process,L3Cache,TDP,Released
            $Row.Name = ""
            $row.Codename = ""
            $Row.Cores = ""
            $Row.Clock = ""
            $Row.Socket = ""
            $Row.Process = ""
            $row.L3Cache = ""
            $row.TDP = ""
            $row.Released = ""
            $row | Export-csv C:\Temp\Procs.csv
            Write-Host "Done with that... Moving On"
            $Master = Import-Csv C:\Temp\Procs.csv
        }
        #Specify the URLS to pull table data for
        $urls = @('https://www.techpowerup.com/cpu-specs/?released=2022&sort=name',
        'https://www.techpowerup.com/cpu-specs/?released=2021&sort=name',
        'https://www.techpowerup.com/cpu-specs/?released=2020&sort=name',
        'https://www.techpowerup.com/cpu-specs/?released=2019&sort=name',
        'https://www.techpowerup.com/cpu-specs/?released=2018&sort=name',
        'https://www.techpowerup.com/cpu-specs/?released=2017&sort=name',
        'https://www.techpowerup.com/cpu-specs/?released=2016&sort=name',
        'https://www.techpowerup.com/cpu-specs/?released=2015&sort=name',
        'https://www.techpowerup.com/cpu-specs/?released=2014&sort=name',
        'https://www.techpowerup.com/cpu-specs/?released=2013&sort=name',
        'https://www.techpowerup.com/cpu-specs/?released=2012&sort=name',
        'https://www.techpowerup.com/cpu-specs/?released=2011&sort=name',
        'https://www.techpowerup.com/cpu-specs/?released=2010&sort=name',
        'https://www.techpowerup.com/cpu-specs/?released=2009&sort=name',
        'https://www.techpowerup.com/cpu-specs/?released=2008&sort=name',
        'https://www.techpowerup.com/cpu-specs/?released=2007&sort=name',
        'https://www.techpowerup.com/cpu-specs/?released=2006&sort=name',
        'https://www.techpowerup.com/cpu-specs/?released=2005&sort=name')
        $allprocs = @()
        # Begin loop for each url
        Foreach ($url in $urls){
            # Grab required info from website
            $webSite = Invoke-WebRequest -Uri $url
            $content = $webSite.Content   
            # Create HTML file Object
            $HTML = New-Object -Com "HTMLFile"   
            # Write HTML content according to DOM Level2 
            $src = [System.Text.Encoding]::Unicode.GetBytes($content)
            $html.write($src)
            # Create Processor array
            $Processors = @()
            # Select all data withing the td html tag
            $TDS = $HTML.all.tags("td") | ForEach-Object InnerText
            # Set counters for switch and row loop
            $counter = 1
            $rowno = 0    
            # Create table from html tags while applying index to identify single record later
            ForEach ($TD in $TDS){ 
                $Row = "" | Select-Object Index,Name,Codename,Cores,Clock,Socket,Process,L3Cache,TDP,Released
                Switch ($counter){
                    1{
                        if ($td -like "*Edited*"){
                            $row.index ="1"
                        }
                        else {
                        $Row.name = $td
                        $Row.index = $rowno
                        $counter++
                        }
                    }
                    2{
                        $row.codename = $td
                        $Row.index = $rowno
                        $counter++
                    }
                    3{
                        $row.cores = $td
                        $Row.index = $rowno
                        $counter++
                    }
                    4{
                        $row.clock = $td
                        $Row.index = $rowno
                        $counter++
                    }
                    5{
                        $row.socket = $td
                        $Row.index = $rowno
                        $counter++
                    }
                    6{
                        $row.process = $td
                        $Row.index = $rowno
                        $counter++
                    }
                    7{
                        $row.L3Cache = $td
                        $Row.index = $rowno
                        $counter++
                    }
                    8{
                        $row.TDP = $td
                        $Row.index = $rowno
                        $counter++
                    }
                    9{
                        try {
                            $date = [datetime]::ParseExact(($td -replace '(th|st|nd|rd),'), 'MMM d yyyy', [cultureinfo]::InvariantCulture)
                        }
                        Catch {
                            Write-Host "These are not the dates you're looking for"
                            try{
                                $date = [DatetIme]$td
                            }
                            Catch{
                                Write-Host "That didnt work, this shits broken"
                            }
                        }
                        $row.released = $date
                        $Row.index = $rowno
                        $counter = 1
                        $rowno++
                    }
                }
                $Processors += $Row     
            }
            # Group Rows with same index
            $RowMasters = $processors | Group-Object Index | Where-Object count -gt 1
            $process = New-Object System.Collections.ArrayList
            # Apply rows to single row in array
            ForEach ($RowMaster in $RowMasters){
                $process.Add([pscustomobject]@{
                    Index=($rowmaster.Group.Index  | Select-Object -Unique) -as [int];
                    Name=$rowmaster.Group.Name | Select-Object -Unique
                    Codename=$rowmaster.Group.Codename| Select-Object -Unique
                    Cores=$rowmaster.Group.cores | Select-Object -Unique
                    Clock = $rowmaster.Group.clock | Select-Object -Unique
                    Socket= $rowmaster.Group.socket  | Select-Object -Unique
                    Process= $rowmaster.Group.process  | Select-Object -Unique
                    L3Cache= $rowmaster.Group.l3cache | Select-Object -Unique
                    TDP= $rowmaster.Group.tdp  | Select-Object -Unique
                    Released= $rowmaster.Group.released  | Select-Object -Unique })
                }
                # add only required information to allprocs master table if it doesnt already exist in the imported list    
            foreach ($processor in $process){
                if ($master.name -notcontains $processor.name){
                    Write-Host $processor.name"not in list"
                    $Row = "" | Select-Object Name,Codename,Cores,Clock,Socket,Process,L3Cache,TDP,Released
                    $Row.Name = $Processor.name
                    $row.Codename = $processor.Codename
                    $Row.Cores = $processor.Cores
                    $Row.Clock = $processor.Clock
                    $Row.Socket = $processor.Socket
                    $Row.Process = $processor.Process
                    $row.L3Cache = $processor.L3Cache
                    $row.TDP = $processor.TDP
                    $row.Released = $processor.Released
                    $allprocs += $row
                    Write-Host "Added"$processor.name"to the list"
                }
                else{
                    Write-Host $processor.name"already in the list"
                }
            }
            # Sleep to mitigate website detecting too many requests
            Start-Sleep 20s
        }
        $allprocs | Export-Csv C:\temp\procs.csv -NoTypeInformation -Append
        }
        $PLTSubFunction2={
            $processor = @()
            $proc = "" | Select-Object Index,Name,Codename,Cores,Clock,Socket,Process,L3Cache,TDP,Released
            $Proc.name = Read-Host "Processor Name e.g. Core i7 6700K" -ForegroundColor Green
            $Proc.name = Read-Host
            $proc.Codename = Read-Host "Processor Codename e.g. Haswell" -ForegroundColor Green
            $proc.cores = Read-Host "Processor Cores P/HT e.g. 4/8" -ForegroundColor Green
            $Proc.Clock = Read-Host "Processor Clock e.g. 2.4 Ghz" -ForegroundColor Green
            $Proc.Socket = Read-Host "Processor Socket e.g BGA 1499" -ForegroundColor Green
            $Proc.Process = Read-Host "Processor Process e.g. 10 nm" -ForegroundColor Green
            $Proc.L3Cache = Read-Host "Processor L3Cache e.g. 8 MB" -ForegroundColor Green
            $Proc.TDP = Read-Host "Processor TDP e.g. 80 W" -ForegroundColor Green
            $Proc.Released = Read-Host "Processor Released - Q2 2017 needs changing to 01/04/2017 format" -ForegroundColor Green
            $processor += $Proc
            $Processor | Export-Csv C:\temp\Procs.csv -NoTypeInformation -Append
            Write-Host "Processor added to list"
        }
        $ProcessorToolMain={
            function Show-PLTMenu{
                param ([string]$Title = 'ProcessorList')
                    Clear-Host
                    Write-Host "==================================================" -ForegroundColor Yellow
                    Write-Host "   _____                                          " -ForegroundColor Red
                    Write-Host "  |  __ \                                         " -ForegroundColor Red
                    Write-Host "  | |__) | __ ___   ___ ___  ___ ___  ___  _ __   " -ForegroundColor Red
                    Write-Host "  |  ___/ '__/ _ \ / __/ _ \/ __/ __|/ _ \| '__|  " -ForegroundColor Red
                    Write-Host "  | |   | | | (_) | (_|  __/\__ \__ \ (_) | |     " -ForegroundColor Red
                    Write-Host "  |_|   |_|  \___/ \___\___||___/___/\___/|_|     " -ForegroundColor Red
                    Write-Host "  | |    (_)   | |                                " -ForegroundColor Blue
                    Write-Host "  | |     _ ___| |_                               " -ForegroundColor Blue
                    Write-Host "  | |    | / __| __|                              " -ForegroundColor Blue      
                    Write-Host "  | |____| \__ \ |_                               " -ForegroundColor Blue                        
                    Write-Host "  |______|_|___/\__|_                             " -ForegroundColor Blue
                    Write-Host "  |__   __|        | |                            " -ForegroundColor Green
                    Write-Host "     | | ___   ___ | |                            " -ForegroundColor Green
                    Write-Host "     | |/ _ \ / _ \| |                            " -ForegroundColor Green
                    Write-Host "     | | (_) | (_) | |                            " -ForegroundColor Green
                    Write-Host "     |_|\___/ \___/|_|         Created By Tom Hyde" -ForegroundColor Green
                    Write-Host "==================================================" -ForegroundColor Yellow
                    Write-Host "=======================Menu=======================" -ForegroundColor Yellow
                    Write-Host
                    Write-Host "1: Update processor list from web"
                    Write-Host "2: Update Manually"			
                    Write-Host 
                    Write-Host "q: Go back to Main Menu"
                    Write-Host "==================================================" -ForegroundColor Yellow
                    }
                    do{
                        Show-PLTMenu
                        $Selection = Read-Host "Please Make a Selection"
                        switch ($Selection){
                            '1'{& $PLTSubFunction1}
                            '2'{& $PLTSubFunction2}
                            'q'{return}
                        }
                    }
                    until ($input -eq 'q')
            }
            & $ProcessorToolMain        
}
$AllCustomerTool={
    $ALTSubFunction1={
        Write-Host "Please Wait..." -ForegroundColor Green
        $CL = Get-NCCustomerList
        $List = @()
        $today = Get-Date
        $imports = import-csv "C:\Temp\Procs.csv"
        Foreach ($customer in $cl ){
            write-host $Customer.customername
            $customerID = $customer.CustomerID
            Write-Host "Please Wait..." -ForegroundColor Green
            $Devices = Get-NCDeviceList -customerID $CustomerID
            foreach ($Device in $Devices){        
                #Create rows for list and select device by ID
                $Row = "" | Select-Object ID,Site,Name,Class,OS,Manufacturer,Model,Serial,Processor,RAM,Storage1,Storage2,Storage3,Storage4,Age
                $ID = $Device.DeviceID
                $Device = Get-NCDeviceObject -DeviceID $ID
                #Return ID
                $row.ID = $ID        
                #Return Customer name
                $customername = $device.customer
                $row.Site = $customername.customername
                $customername = $customername.customername
                #Return Computer Name
                $Row.Name = $device.longname
                #Return Device Class
                $Class = $device.deviceclass
                $Class = $class -replace ' - Windows',''
                $Class = $class -replace 'Workstations','Desktop'
                $Class = $class -replace 'Servers','Server'
                $Row.Class = $Class
                #Return OS
                $OS = $device.os
                $row.OS = $OS.reportedos
                #Return Manufacturer and Model and Serial
                $CS = $device.computersystem
                $row.Manufacturer = $CS.Manufacturer
                $row.Model = $CS.Model
                $row.Serial = $CS.serialnumber
                #Return processor name
                $processor = $Device.processor
                $processor = $processor.name
                $processor = $processor -replace '          ',''
                $processor = $processor -replace '\(TM\)',''
                $processor = $processor -replace '\(R\)',''
                $row.processor = $processor
                $processor = $processor -replace 'Intel ',''
                $processor = $processor -replace 'AMD ',''
                $processor = $processor -replace 'CPU ',''
                $Age = "Not in DB"
                foreach ($import in $imports) {
                    $name = $import.Name
                    if ($processor.contains($name)) {
                        Try{
                        $Age = New-TimeSpan -start $import.released -end ($today)
                        $age = $Age.Days / 365
                        $age = [math]::Round($Age,1)
                        }
                        Catch{}
                    }
                    else{}
                }
                $row.Age = $Age
                #RAM Calculation
                $Memory = $device.memory
                $RAM = 0
                $memory | ForEach-Object {$RAM += $_.capacity}
                $row.RAM = $RAM /1GB
                #Get Storage
                $drives = $device.physicaldrive
                Foreach ($Drive in $Drives){
                    switch ($drive.ItemId){
                        'physicaldrive.0'{
                        $Drive1 = $drive.capacity
                        $Drive1 = [math]::round($Drive1/1GB,2)
                        $Storage1 = $drive1.ToString() + "GB" + " " + $drive.modelnumber
                        $row.Storage1 = $Storage1
                    }
                        'physicaldrive.1'{
                        $Drive2 = $drive.capacity
                        $Drive2 = [math]::round($Drive2/1GB,2)
                        $Storage2 = $drive2.ToString() + "GB" + " " + $drive.modelnumber
                        $row.Storage2 = $Storage2
                    }
                        'physicaldrive.2'{
                        $Drive3 = $drive.capacity
                        $Drive3 = [math]::round($Drive3/1GB,2)
                        $Storage3 = $drive3.ToString() + "GB" + " " + $drive.modelnumber
                        $row.Storage3 = $Storage3
                    }
                        'physicaldrive.3'{
                        $Drive4 = $drive.capacity
                        $Drive4 = [math]::round($Drive4/1GB,2)
                        $Storage4 = $drive4.ToString() + "GB" + " " + $drive.modelnumber
                        $row.Storage4 = $Storage4
                    }
                        $null{}
                    }    
                } 
                #Append Table
                $List += $Row       
            }
        }
        $FilePath = "C:\Temp\AllSite-DeviceAudit.csv"
        if (Test-Path $Filepath = $True) {
            Write-Host "Sorted audit has been saved to C:\Temp\AllSite-DeviceAudit.csv" -ForegroundColor Blue
            Remove-Item $Filepath
            $list | Export-Csv -notypeinformation $FilePath
            Import-Csv (Get-ChildItem $Filepath) | Sort-Object -Unique ID | Export-Csv $Filepath -NoClobber -NoTypeInformation
          }
        if (Test-Path $Filepath = $False) {
        Write-Host "Unable to delete previous file. Please delete and rerun this tool"
        }
        Import-CSV $FilePath
        $Excel = New-Object -ComObject Excel.Application
        $Workbook = $Excel.Workbooks.Open($FilePath)
        $excel.visible = $true
        Write-Host "That should now be open in Excel for you"
    }
    $ALTSubFunction2={  
        Write-Host "Please Wait..." -ForegroundColor Green
        $DevicesNotReady = @()
        $CL = Get-NCCustomerList | Select-Object CustomerName,CustomerID
        foreach ($customer in $cl){
            $CustomerID = $customer.customerid
            $Devices = Get-NCDeviceList -customerID $CustomerID
            Foreach ($device in $Devices){
                $ID = $Device.DeviceID
                $CustomerName = $Device.customername
                $Device = Get-NCDeviceObject -DeviceID $ID
                $Row = "" | Select-Object ID,CustomerName,Device,'Windows 11 Ready Status'
                $row.CustomerName = $CustomerName
                $row.ID = $ID
                $Row.Device = $device.longname
                $PropertyList = Get-NCDevicePropertyList -DeviceID $id
                $row.'Windows 11 Ready Status' = $propertylist.'Windows 11 Ready'
                $row.device
                $DevicesNotReady += $Row
            }
        }
        $DevicesNotReady | Format-Table
        $ExportCSV = Read-Host "Do you want to export to CSV? Y/N"
        switch($ExportCSV){
            'y' {
                $FilePath = "C:\Temp\AllCustomer-W11Readyness.csv"
                if (Test-Path $Filepath = $True) {
                Write-Host "Sorted audit has been saved to C:\Temp\AllSite-W11Readyness.csv" -ForegroundColor Blue
                Remove-Item $Filepath
                $list | Export-Csv -notypeinformation $FilePath
                Import-Csv (Get-ChildItem $Filepath) | Sort-Object -Unique ID | Export-Csv $Filepath -NoClobber -NoTypeInformation
                }
            }
            'n' {
                Read-host -prompt "Press any key to continue"
            }
        }     
    }
    $AllCustomerToolMain={
        function Show-ALTMenu{
            param ([string]$Title = 'ProcessorList')
                Clear-Host
                Write-Host "==================================================" -ForegroundColor Yellow
                Write-Host "  _   _         _____           _             _   " -ForegroundColor Red
                Write-Host " | \ | |       / ____|         | |           | |  " -ForegroundColor Red
                Write-Host " |  \| |______| |     ___ _ __ | |_ _ __ __ _| |  " -ForegroundColor Red
                Write-Host " | . `  |______| |    / _ \ '_ \| __| '__/ _`  | |  " -ForegroundColor Red
                Write-Host " | |\  |      | |___|  __/ | | | |_| | | (_| | |  " -ForegroundColor Red
                Write-Host " |_| \_|       \_____\___|_| |_|\__|_|  \__,_|_|  " -ForegroundColor Red
                Write-Host "     /\            | (_) |                        " -ForegroundColor Blue
                Write-Host "    /  \  _   _  __| |_| |_                       " -ForegroundColor Blue
                Write-Host "   / /\ \| | | |/ _` | | __|                      " -ForegroundColor Blue      
                Write-Host "  / ____ \ |_| | (_| | | |_                       " -ForegroundColor Blue                        
                Write-Host " /_/____\_\__,_|\__,_|_|\__|                      " -ForegroundColor Blue
                Write-Host "  |__   __|        | |                            " -ForegroundColor Green
                Write-Host "     | | ___   ___ | |                            " -ForegroundColor Green
                Write-Host "     | |/ _ \ / _ \| |                            " -ForegroundColor Green
                Write-Host "     | | (_) | (_) | |                            " -ForegroundColor Green
                Write-Host "     |_|\___/ \___/|_|         Created By Tom Hyde" -ForegroundColor Green
                Write-Host "==================================================" -ForegroundColor Yellow
                Write-Host "=======================Menu=======================" -ForegroundColor Yellow
                Write-Host
                Write-Host "1: All Customer Device Audit"
                Write-Host "2: All Customer Windows 11 Readyness"			
                Write-Host 
                Write-Host "q: Go back to Main Menu"
                Write-Host "==================================================" -ForegroundColor Yellow
                }
                do{
                    Show-ALTMenu
                    $Selection = Read-Host "Please Make a Selection"
                    switch ($Selection){
                        '1'{& $ALTSubFunction1}
                        '2'{& $ALTSubFunction2}
                        'q'{return}
                    }
                }
                until ($input -eq 'q')
        }
        & $AllCustomerToolMain
}
$MainFunction={
    function Show-Menu{
        param ([string]$Title = 'N-Central Audit Tool')
                Clear-Host
                Write-Host "==================================================" -ForegroundColor Yellow
                Write-Host "  _   _         _____           _             _   " -ForegroundColor Red
                Write-Host " | \ | |       / ____|         | |           | |  " -ForegroundColor Red
                Write-Host " |  \| |______| |     ___ _ __ | |_ _ __ __ _| |  " -ForegroundColor Red
                Write-Host " | . `  |______| |    / _ \ '_ \| __| '__/ _`  | |  " -ForegroundColor Red
                Write-Host " | |\  |      | |___|  __/ | | | |_| | | (_| | |  " -ForegroundColor Red
                Write-Host " |_| \_|       \_____\___|_| |_|\__|_|  \__,_|_|  " -ForegroundColor Red
                Write-Host "     /\            | (_) |                        " -ForegroundColor Blue
                Write-Host "    /  \  _   _  __| |_| |_                       " -ForegroundColor Blue
                Write-Host "   / /\ \| | | |/ _` | | __|                      " -ForegroundColor Blue      
                Write-Host "  / ____ \ |_| | (_| | | |_                       " -ForegroundColor Blue                        
                Write-Host " /_/____\_\__,_|\__,_|_|\__|                      " -ForegroundColor Blue
                Write-Host "  |__   __|        | |                            " -ForegroundColor Green
                Write-Host "     | | ___   ___ | |                            " -ForegroundColor Green
                Write-Host "     | |/ _ \ / _ \| |                            " -ForegroundColor Green
                Write-Host "     | | (_) | (_) | |                            " -ForegroundColor Green
                Write-Host "     |_|\___/ \___/|_|         Created By Tom Hyde" -ForegroundColor Green
                Write-Host "==================================================" -ForegroundColor Yellow
                Write-Host "=======================Menu=======================" -ForegroundColor Yellow
                Write-Host "1: Customer Device Audit"
                Write-Host "2: Windows 11 Readyness Check"
                Write-Host "3: KFM Enabled"
                Write-Host "4: Active Issues by Customer"
                Write-Host "5: Active Issues by Device"			
                Write-Host 
                Write-Host "A: All Customer Reports"
                Write-Host "i: Install PS-NCentral Module (Requires Admin)"
                Write-Host "p: Processor List Tool"
                Write-Host "q: Quit"
                Write-Host "==================================================" -ForegroundColor Yellow
              }
        do{
            Show-Menu
            $Selection = Read-Host "Please Make a Selection"
            switch ($Selection)
            {
                '1'{& $SubFunction1}
                '2'{& $SubFunction2}
                '3'{& $SubFunction3}
                '4'{& $SubFunction4}
                '5'{& $SubFunction5}
                'A'{& $AllCustomerTool}
                'i'{& $InstallModuleFunction}
                'p'{& $ProcessorListTool}
                'q'{return}
                }
            }
        until ($input -eq 'q')
    }
    & $MainFunction
