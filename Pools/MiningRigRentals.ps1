﻿using module ..\Include.psm1
using module ..\MiningRigRentals.psm1

param(
    [PSCustomObject]$Wallets,
    [PSCustomObject]$Params,
    [alias("WorkerName")]
    [String]$Worker, 
    [TimeSpan]$StatSpan,
    [String]$DataWindow = "average-2",
    [Bool]$InfoOnly = $false,
    [Bool]$AllowZero = $false,
    [String]$StatAverage = "Minute_10",
    [String]$User = "",
    [String]$API_Key = "",
    [String]$API_Secret = "",
    [String]$UseWorkerName = "",
    [String]$ExcludeWorkerName = "",
    [Bool]$EnableMining = $false,
    [Bool]$EnableAutoCreate = $false,
    [Bool]$EnableAutoUpdate = $false,
    [Bool]$EnableAutoExtend = $false,
    [Bool]$EnableAutoPrice = $false,
    [Bool]$EnableMinimumPrice = $false,
    [Bool]$EnableUpdateTitle = $false,
    [Bool]$EnableUpdateDescription = $false,
    [Bool]$EnableUpdatePriceModifier = $false,
    [Bool]$EnablePowerDrawAddOnly = $false,
    [String]$AutoCreateAlgorithm = "",
    [String]$AutoCreateMinProfitPercent = "50",
    [String]$AutoCreateMinCPUProfitBTC = "0.00001",
    [String]$AutoCreateMaxMinHours = "24",
    [String]$AutoExtendTargetPercent = "100",
    [String]$AutoExtendMaximumPercent = "30",
    [String]$AutoBonusExtendForHours = "0",
    [String]$AutoBonusExtendByHours = "0",
    [String]$AutoUpdateMinPriceChangePercent = "3",
    [String]$AutoPriceModifierPercent = "0",
    [String]$PriceBTC = "0",
    [String]$PriceFactor = "2.0",
    [String]$PowerDrawFactor = "1.0",
    [String]$PriceCurrencies = "BTC",
    [String]$MinHours = "3",
    [String]$MaxHours = "168",
    [String]$Title = "",
    [String]$Description = ""
)

$Name = Get-Item $MyInvocation.MyCommand.Path | Select-Object -ExpandProperty BaseName

$Pool_Fee = 3

if ($InfoOnly) {
    [PSCustomObject]@{
        Algorithm     = ""
        CoinName      = ""
        CoinSymbol    = ""
        Currency      = "BTC"
        Price         = 0
        StablePrice   = 0
        MarginOfError = 0
        Protocol      = "stratum+tcp"
        PoolFee       = $Pool_Fee
        Name          = $Name
        Penalty       = 0
        PenaltyFactor = 1
        Disabled      = $false
        HasMinerExclusions = $false
        Price_Bias    = 0.0
        Price_Unbias  = 0.0
        Wallet        = $Wallets.BTC
        Worker        = $Worker
        Email         = $Email
    }
    return
}

if (-not $API_Key -or -not $API_Secret) {return}

$Workers     = @($Session.Config.DeviceModel | Where-Object {$Session.Config.Devices.$_.Worker} | Foreach-Object {$Session.Config.Devices.$_.Worker} | Select-Object -Unique) + $Worker | Select-Object -Unique

$UseWorkerName_Array     = @($UseWorkerName   -split "[,; ]+" | Where-Object {$_} | Select-Object -Unique)
$ExcludeWorkerName_Array = @($ExcludeWorkerName -split "[,; ]+" | Where-Object {$_} | Select-Object -Unique)

if ($UseWorkerName_Array.Count -or $ExcludeWorkerName_Array.Count) {
    $Workers = $Workers.Where({($UseWorkerName_Array.Count -eq 0 -or $UseWorkerName_Array -contains $_) -and ($ExcludeWorkerName_Array.Count -eq 0 -or $ExcludeWorkerName_Array -notcontains $_)})
}

if (-not $Workers.Count) {return}

$AllRigs_Request = Get-MiningRigRentalRigs -key $API_Key -secret $API_Secret -workers $Workers

$Pool_Request = [PSCustomObject]@{}

if (-not ($Pool_Request = Get-MiningRigRentalAlgos)) {return}

Set-MiningRigRentalConfigDefault -Workers $Workers > $null

$Devices_Benchmarking = @($API.MinersNeedingBenchmark | Select-Object -ExpandProperty DeviceName | Select-Object -Unique)
if ($Session.MRRBenchmarkStatus -eq $null) {$Session.MRRBenchmarkStatus = @{}}

if ($AllRigs_Request) {

    [hashtable]$Pool_RegionsTable = @{}

    $Pool_AllHosts = Get-MiningRigRentalServers

    $Pool_AllHosts.Foreach({$Pool_RegionsTable[$_.region] = Get-Region "$($_.region -replace "^eu-")"})

    $Workers_Devices = @{}
    $Workers_Models  = @{}
    $Devices_Rented  = @()

    foreach ($Worker1 in $Workers) {

        if (-not ($Rigs_Request = $AllRigs_Request | Where-Object description -match "\[$($Worker1)\]")) {continue}

        $Rigs_DeviceModels = @($Session.Config.Devices.PSObject.Properties | Where-Object {$_.Value.Worker -eq $Worker1} | Select-Object -ExpandProperty Name | Select-Object -Unique)
        $Rigs_Devices = $Global:DeviceCache.Devices.Where({($_.Model -notmatch "-" -and (($Worker1 -eq $Worker -and $_.Type -eq "Gpu") -or ($Worker1 -ne $Worker -and $_.Model -in $Rigs_DeviceModels)))})
        $Workers_Devices[$Worker1] = @($Rigs_Devices | Select-Object -ExpandProperty Name -Unique)
        $Workers_Models[$Worker1]  = @($Rigs_Devices | Select-Object -ExpandProperty Model -Unique)

        if (($Rigs_Request | Where-Object {$_.status.status -eq "rented" -or $_.status.rented} | Measure-Object).Count) {
            $Devices_Rented = @($Devices_Rented + $Workers_Devices[$Worker1] | Select-Object -Unique | Sort-Object)
        }

        if (-not $Session.MRRBenchmarkStatus.ContainsKey($Worker1)) {$Session.MRRBenchmarkStatus[$Worker1] = $false}
    }

    foreach ($Worker1 in $Workers) {

        if (-not ($Rigs_Request = $AllRigs_Request | Where-Object description -match "\[$($Worker1)\]")) {continue}

        if (($Rigs_Request | Where-Object {$_.status.status -eq "rented" -or $_.status.rented} | Measure-Object).Count) {
            if ($Disable_Rigs = $Rigs_Request | Where-Object {$_.status.status -ne "rented" -and -not $_.status.rented -and $_.available_status -eq "available"} | Select-Object -ExpandProperty id | Sort-Object) {
                Invoke-MiningRigRentalRequest "/rig/$($Disable_Rigs -join ';')" $API_Key $API_Secret -params @{"status"="disabled"} -method "PUT" > $null
                $Rigs_Request | Where-Object {$Disable_Rigs -contains $_.id} | Foreach-Object {$_.available_status="disabled"}
                $Disable_Rigs | Foreach-Object {Set-MiningRigRentalStatus $_ -Stop}
            }
        } else {
            $Valid_Rigs = @()

            if ((Compare-Object $Devices_Benchmarking $Workers_Devices[$Worker1] -ExcludeDifferent -IncludeEqual | Measure-Object).Count) {
                $Session.MRRBenchmarkStatus[$Worker1] = $true
            } elseif ($Session.MRRBenchmarkStatus[$Worker1]) {
                $API.UpdateMRR = $true
                $Session.MRRBenchmarkStatus[$Worker1] = $false
            } else {
                $DeviceAlgorithm        = @($Workers_Models[$Worker1] | Where-Object {$Session.Config.Devices.$_.Algorithm.Count} | Foreach-Object {$Session.Config.Devices.$_.Algorithm} | Select-Object -Unique)
                $DeviceExcludeAlgorithm = @($Workers_Models[$Worker1] | Where-Object {$Session.Config.Devices.$_.ExcludeAlgorithm.Count} | Foreach-Object {$Session.Config.Devices.$_.ExcludeAlgorithm} | Select-Object -Unique)

                $Rigs_Request | Select-Object id,type | Foreach-Object {
                    $Pool_Algorithm_Norm = Get-MiningRigRentalAlgorithm $_.type
                    if ((Get-Yes $Session.Config.Algorithms.$Pool_Algorithm_Norm.MRREnable) -and -not (
                        ($Session.Config.Algorithm.Count -and $Session.Config.Algorithm -inotcontains $Pool_Algorithm_Norm) -or
                        ($Session.Config.ExcludeAlgorithm.Count -and $Session.Config.ExcludeAlgorithm -icontains $Pool_Algorithm_Norm) -or
                        ($Session.Config.Pools.$Name.Algorithm.Count -and $Session.Config.Pools.$Name.Algorithm -inotcontains $Pool_Algorithm_Norm) -or
                        ($Session.Config.Pools.$Name.ExcludeAlgorithm.Count -and $Session.Config.Pools.$Name.ExcludeAlgorithm -icontains $Pool_Algorithm_Norm) -or
                        (Compare-Object $Devices_Rented $Workers_Devices[$Worker1] -ExcludeDifferent -IncludeEqual | Measure-Object).Count -or
                        ($DeviceAlgorithm.Count -and $DeviceAlgorithm -inotcontains $Pool_Algorithm_Norm) -or
                        ($DeviceExcludeAlgorithm.Count -and $DeviceExcludeAlgorithm -icontains $Pool_Algorithm_Norm)
                        )) {$Valid_Rigs += $_.id}
                }
            }

            if ($Enable_Rigs = $Rigs_Request | Where-Object {$_.available_status -ne "available" -and $Valid_Rigs -contains $_.id} | Select-Object -ExpandProperty id | Sort-Object) {
                Invoke-MiningRigRentalRequest "/rig/$($Enable_Rigs -join ';')" $API_Key $API_Secret -params @{"status"="available"} -method "PUT" > $null
                $Rigs_Request | Where-Object {$Enable_Rigs -contains $_.id} | Foreach-Object {$_.available_status="available"}
            }
            if ($Disable_Rigs = $Rigs_Request | Where-Object {$_.available_status -eq "available" -and $Valid_Rigs -notcontains $_.id} | Select-Object -ExpandProperty id | Sort-Object) {
                Invoke-MiningRigRentalRequest "/rig/$($Disable_Rigs -join ';')" $API_Key $API_Secret -params @{"status"="disabled"} -method "PUT" > $null
                $Rigs_Request | Where-Object {$Disable_Rigs -contains $_.id} | Foreach-Object {$_.available_status="disabled"}
            }
            $Rigs_Request | Foreach-Object {Set-MiningRigRentalStatus $_.id -Stop}
        }

        if (-not ($Rigs_Ids = $Rigs_Request | Where-Object {$_.available_status -eq "available"} | Select-Object -ExpandProperty id | Sort-Object)) {continue}

        $RigInfo_Request = Get-MiningRigInfo -id $Rigs_Ids -key $API_Key -secret $API_Secret
        if (-not $RigInfo_Request) {
            Write-Log -Level Warn "Pool API ($Name) rig $Worker1 info request has failed. "
            return
        }

        $Rigs_Request | Where-Object {$_.available_status -eq "available"} | ForEach-Object {
            $Pool_RigId = $_.id
            $Pool_Algorithm = $_.type
            $Pool_Algorithm_Norm = Get-MiningRigRentalAlgorithm $_.type
            $Pool_CoinSymbol = Get-MiningRigRentalCoin $_.type

            if ($false) {
                $Pool_Price_Data = ($Pool_Request | Where-Object name -eq $Pool_Algorithm).stats.prices.last_10 #suggested_price
                $Divisor = Get-MiningRigRentalsDivisor $Pool_Price_Data.unit
                $Pool_Price = $Pool_Price_Data.amount
            } else {
                $Divisor = Get-MiningRigRentalsDivisor $_.price.type
                $Pool_Price = $_.price.BTC.price
            }

            if (-not $InfoOnly) {
                $Stat = Set-Stat -Name "$($Name)_$($Pool_Algorithm_Norm)_Profit" -Value ([Double]$Pool_Price / $Divisor) -Duration $StatSpan -ChangeDetection $false -Quiet
            }

            $Pool_Rig = $RigInfo_Request | Where-Object {$_.rigid -eq $Pool_RigId -and $_.port -ne "error"}

            if ($Pool_Rig) {
                $Pool_Price = $Stat.$StatAverage
                $Pool_Currency = "BTC"
                if ($_.status.status -eq "rented" -or $_.status.rented) {
                    try {
                        $Pool_RigRental = Invoke-MiningRigRentalRequest "/rental" $API_Key $API_Secret -params (@{type="owner";"rig"=$Pool_RigId;history=$false;limit=1}) -Cache $([double]$_.status.hours*3600)
                        if ($Rig_RentalPrice = [Double]$Pool_RigRental.rentals.price.advertised / 1e6) {
                            $Pool_Price = $Rig_RentalPrice
                            if ($Pool_RigRental.rentals.price.currency -ne "BTC") {
                                $Pool_Currency = $Pool_RigRental.rentals.price.currency
                                $Pool_Price *= $_.price.BTC.price/$_.price."$($Pool_RigRental.rentals.price.currency)".price
                            }
                        }
                    } catch {if ($Error.Count){$Error.RemoveAt(0)}}
                }

                $Pool_RigEnable = if ($_.status.status -eq "rented" -or $_.status.rented) {Set-MiningRigRentalStatus $Pool_RigId -Status $_.poolstatus}

                if (($_.status.status -eq "rented" -or $_.status.rented) -and (Get-Yes $EnableAutoExtend) -and ([double]$_.status.hours -lt 0.25) -and -not (Get-MiningRigRentalStatus $Pool_RigId).extend) {
                    try {
                        $Rental_Result = Invoke-MiningRigRentalRequest "/rental/$($_.rental_id)" $API_Key $API_Secret -method "GET" -Timeout 60
                        $Rental_AdvHashrate = [double]$Rental_Result.hashrate.advertised.hash * (ConvertFrom-Hash "1$($Rental_Result.hashrate.advertised.type)")
                        $Rental_AvgHashrate = [double]$Rental_Result.hashrate.average.hash * (ConvertFrom-Hash "1$($Rental_Result.hashrate.average.type)")
                        if ($Rental_AvgHashrate -and $Rental_AdvHashrate -and $Rental_AvgHashrate -lt $Rental_AdvHashrate) {
                            $MRRConfig = Get-ConfigContent "MRR"
                            if ($MRRConfig -eq $null) {$MRRConfig = [PSCustomObject]@{}}
                            $AutoExtendTargetPercent_Value = if ($MRRConfig.$Worker1.AutoExtendTargetPercent -ne $null -and $MRRConfig.$Worker1.AutoExtendTargetPercent -ne "") {$MRRConfig.$Worker1.AutoExtendTargetPercent} else {$AutoExtendTargetPercent}
                            $AutoExtendTargetPercent_Value = [Double]("$($AutoExtendTargetPercent_Value)" -replace ",","." -replace "[^0-9\.]+") / 100
                            $AutoExtendMaximumPercent_Value = if ($MRRConfig.$Worker1.AutoExtendMaximumPercent -ne $null -and $MRRConfig.$Worker1.AutoExtendMaximumPercent -ne "") {$MRRConfig.$Worker1.AutoExtendMaximumPercent} else {$AutoExtendMaximumPercent}
                            $AutoExtendMaximumPercent_Value = [Double]("$($AutoExtendMaximumPercent_Value)" -replace ",","." -replace "[^0-9\.]+") / 100

                            $ExtendBy = ([double]$Rental_Result.length + [double]$Rental_Result.extended) * ($AutoExtendTargetPercent_Value * $Rental_AdvHashrate / $Rental_AvgHashrate - 1)
                            if ($AutoExtendMaximumPercent_Value -gt 0) {
                                $ExtendBy = [Math]::Min([double]$Rental_Result.length * $AutoExtendMaximumPercent_Value,$ExtendBy)
                            }
                            $ExtendBy = [Math]::Round($ExtendBy,2)
                            if ($ExtendBy -ge (1/6)) {
                                $Extend_Result = Invoke-MiningRigRentalRequest "/rig/$Pool_RigId/extend" $API_Key $API_Secret -params @{"hours"=$ExtendBy} -method "PUT" -Timeout 60
                                if ($Extend_Result.success) {
                                    Write-Log -Level Info "Extended MRR rental #$($_.rental_id) for $Pool_Algorithm_Norm on $Worker1 for $ExtendBy hours."
                                    Set-MiningRigRentalStatus $Pool_RigId -Extend > $null
                                }
                            }
                        }
                    } catch {
                        if ($Error.Count){$Error.RemoveAt(0)}
                        Write-Log -Level Warn "Unable to get rental #$($_.rental_id) from MRR: $($_.Exception.Message)"
                    }
                }

                if ($_.status.status -eq "rented" -or $_.status.rented -or $_.poolstatus -eq "online" -or $EnableMining) {

                    $Pool_FailOver = if ($Pool_AltRegions = Get-Region2 $Pool_RegionsTable."$($_.region)") {$Pool_AllHosts | Where-Object {$_.name -ne $Pool_Rig.server} | Sort-Object -Descending {$ix = $Pool_AltRegions.IndexOf($Pool_RegionsTable."$($_.region)");[int]($ix -ge 0)*(100-$ix)},{$_.region -match "^$($Pool_Rig.server.SubString(0,2))"},{100-$_.id} | Select-Object -First 2}
                    if (-not $Pool_Failover) {$Pool_FailOver = @($Pool_AllHosts | Where-Object {$_.name -ne $Pool_Rig.server -and $_.region -match "^us"} | Select-Object -First 1) + @($Pool_AllHosts | Where-Object {$_.name -ne $Pool_Rig.server -and $_.region -match "^eu"} | Select-Object -First 1)}
                    $Pool_FailOver += $Pool_AllHosts | Where-Object {$_.name -ne $Pool_Rig.server -and $Pool_FailOver -notcontains $_} | Select-Object -First 1

                    $Miner_Server = $Pool_Rig.server
                    $Miner_Port   = $Pool_Rig.port
                
                    #BEGIN temporary fixes

                    #
                    # hardcoded fixes due to MRR stratum or API failures
                    #

                    if (($Pool_Algorithm_Norm -eq "X25x" -or $Pool_Algorithm_Norm -eq "MTP") -and $Miner_Server -match "^eu-01") {
                        $Miner_Server = ($Pool_Failover | Select-Object -First 1).name
                        $Miner_Port   = 3333
                        $Pool_Failover = $Pool_Failover | Select-Object -Skip 1
                    }

                    if ($Pool_Algorithm_Norm -eq "Cuckaroo29") {$Miner_Port = 3322}

                    $Pool_SSL = $Pool_Algorithm_Norm -eq "EquihashR25x5"

                    #END temporary fixes
                    
                    $Rigs_Model = if ($Worker1 -ne $Worker) {"$(($Session.Config.DeviceModel | Where-Object {$Session.Config.Devices.$_.Worker -eq $Worker1} | Sort-Object | Select-Object -Unique) -join '-')"} elseif ($Global:DeviceCache.DeviceNames.CPU -ne $null) {"GPU"}

                    [PSCustomObject]@{
                        Algorithm     = "$Pool_Algorithm_Norm$(if ($Rigs_Model) {"-$Rigs_Model"})"
					    Algorithm0    = $Pool_Algorithm_Norm
                        CoinName      = if ($_.status.status -eq "rented" -or $_.status.rented) {try {$ts=[timespan]::fromhours($_.status.hours);"{0:00}h{1:00}m{2:00}s" -f [Math]::Floor($ts.TotalHours),$ts.Minutes,$ts.Seconds}catch{if ($Error.Count){$Error.RemoveAt(0)};"$($_.status.hours)h"}} else {""}
                        CoinSymbol    = $Pool_CoinSymbol
                        Currency      = $Pool_Currency
                        Price         = $Pool_Price
                        StablePrice   = $Stat.Week
                        MarginOfError = $Stat.Week_Fluctuation
                        Protocol      = "stratum+$(if ($Pool_SSL) {"ssl"} else {"tcp"})"
                        Host          = $Miner_Server
                        Port          = $Miner_Port
                        User          = "$($User)$(if (@("ProgPowZ") -icontains $Pool_Algorithm_Norm) {"*"} else {"."})$($Pool_RigId)"
                        Pass          = "x"
                        Region        = $Pool_RegionsTable."$($_.region)"
                        SSL           = $Pool_SSL
                        Updated       = $Stat.Updated
                        PoolFee       = $Pool_Fee
                        Exclusive     = ($_.status.status -eq "rented" -or $_.status.rented) -and $Pool_RigEnable
                        Idle          = if (($_.status.status -eq "rented" -or $_.status.rented) -and $Pool_RigEnable) {$false} else {-not $EnableMining}
                        Failover      = @($Pool_Failover | Select-Object -ExpandProperty name | Foreach-Object {
                            [PSCustomObject]@{
                                Protocol = "stratum+tcp"
                                Host     = $_
                                Port     = if ($Miner_Port -match "^33\d\d$") {$Miner_Port} else {3333}
                                User     = "$($User).$($Pool_RigId)"
                                Pass     = "x"
                            }
                        })
                        EthMode       = if ($Pool_Rig.port -in @(3322,3333,3344) -and $Pool_Algorithm_Norm -match "^(Ethash|ProgPow|KawPow)") {"qtminer"} else {$null}
                        Name          = $Name
                        Penalty       = 0
                        PenaltyFactor = 1
					    Disabled      = $false
					    HasMinerExclusions = $false
					    Price_Bias    = 0.0
					    Price_Unbias  = 0.0
                        Wallet        = $Wallets.BTC
                        Worker        = $Worker1
                        Email         = $Email
                    }
                }

                if (-not $Pool_RigEnable) {
                    if (-not (Invoke-PingStratum -Server $Pool_Rig.server -Port $Pool_Rig.port -User "$($User).$($Pool_RigId)" -Pass "x" -Worker $Worker1 -Method $(if ($Pool_Rig.port -in @(3322,3333,3344)) {"EthProxy"} else {"Stratum"}) -WaitForResponse ($_.status.status -eq "rented" -or $_.status.rented))) {
                        $Pool_Failover | Select-Object -ExpandProperty name | Foreach-Object {if (Invoke-PingStratum -Server $_ -Port $Pool_Rig.port -User "$($User).$($Pool_RigId)" -Pass "x" -Worker $Worker1 -Method $(if ($Pool_Rig.port -eq 3322 -or $Pool_Rig.port -eq 3333 -or $Pool_Rig.port -eq 3344) {"EthProxy"} else {"Stratum"}) -WaitForResponse ($_.status.status -eq "rented" -or $_.status.rented)) {return}}
                    }
                }
            }
        }
    }

    Remove-Variable "Workers_Devices"
    Remove-Variable "Devices_Rented"
}

#
# we will check for auto operations every hour but not at startup
#
if (-not $InfoOnly -and (-not $API.DownloadList -or -not $API.DownloadList.Count) -and -not $Session.IsDonationRun -and $Session.RoundCounter -and ($API.UpdateMRR -or -not $Session.MRRlastautoperation -or $Session.MRRlastautoperation -lt (Get-Date).AddHours(-1))) {

    if ($API.UpdateMRR) {$API.UpdateMRR = $false}

    $RigDivisors = @("h","kh","mh","gh","th") | Foreach-Object {[PSCustomObject]@{type=$_;value=(ConvertFrom-Hash "1$_")}}
    $RigServer  = $null
    $RigCreated = 0
    $RigsToUpdate = @()
    $RigMinProfit = 0.00001

    #
    # 1. gather config per workername
    #

    if ($MRRConfig -eq $null) {
        $MRRConfig = Get-ConfigContent "MRR"
        if ($MRRConfig -eq $null) {$MRRConfig = [PSCustomObject]@{}}
    }

    foreach ($RigName in $Workers) {

        if ($MRRConfig.$RigName -eq $null) {$MRRConfig | Add-Member $RigName ([PSCustomObject]@{}) -Force}
            
        foreach ($fld in @("EnableAutoCreate","EnableAutoUpdate","EnableAutoPrice","EnableMinimumPrice","EnableUpdateTitle","EnableUpdateDescription","EnableUpdatePriceModifier","EnablePowerDrawAddOnly")) {
            #boolean
            try {
                $val = if ($MRRConfig.$RigName.$fld -ne $null -and $MRRConfig.$RigName.$fld -ne "") {Get-Yes $MRRConfig.$RigName.$fld} else {Get-Variable $fld -ValueOnly -ErrorAction Ignore}
                $MRRConfig.$RigName | Add-Member $fld $val -Force
            } catch {
                if ($Error.Count){$Error.RemoveAt(0)}
                Write-Log -Level Warn "Error in MiningRigRentals parameter `"$fld`" in pools.config.txt or mrr.config.txt"
            }
        }

        $AutoCreateMinProfitBTC = "-1"

        foreach ($fld in @("AutoCreateMinProfitPercent","AutoCreateMinProfitBTC","AutoCreateMinCPUProfitBTC","AutoCreateMaxMinHours","AutoExtendTargetPercent","AutoExtendMaximumPercent","AutoBonusExtendForHours","AutoBonusExtendByHours","AutoUpdateMinPriceChangePercent","AutoPriceModifierPercent","PriceBTC","PriceFactor","PowerDrawFactor","MinHours","MaxHours")) {
            #double
            try {
                $val = if ($MRRConfig.$RigName.$fld -ne $null -and $MRRConfig.$RigName.$fld -ne "") {$MRRConfig.$RigName.$fld} else {Get-Variable -Name $fld -ValueOnly -ErrorAction Ignore}
                $val = "$($val)" -replace ",","." -replace "[^0-9\.\-]+"
                $MRRConfig.$RigName | Add-Member $fld ([Double]$(if ($val.Length -le 1) {$val -replace "[^0-9]"} else {$val[0] + "$($val.Substring(1) -replace "[^0-9\.]")"})) -Force
            } catch {
                if ($Error.Count){$Error.RemoveAt(0)}
                Write-Log -Level Warn "Error in MiningRigRentals parameter `"$fld`" in pools.config.txt or mrr.config.txt"
            }
        }

        foreach ($fld in @("PriceCurrencies","AutoCreateAlgorithm")) {
            #array
            try {
                $val = if ($MRRConfig.$RigName.$fld -ne $null -and $MRRConfig.$RigName.$fld -ne "") {$MRRConfig.$RigName.$fld} else {Get-Variable -Name $fld -ValueOnly -ErrorAction Ignore}
                if ($fld -match "Algorithm") {
                    $val = @($val -split "[,; ]+" | Where-Object {$_} | Foreach-Object {Get-Algorithm $_} | Select-Object -Unique)
                } else {
                    $val = @($val -split "[,; ]+" | Where-Object {$_} | Select-Object)
                }
                $MRRConfig.$RigName | Add-Member $fld $val -Force
            } catch {
                if ($Error.Count){$Error.RemoveAt(0)}
                Write-Log -Level Warn "Error in MiningRigRentals parameter `"$fld`" in pools.config.txt or mrr.config.txt"
            }
        }

        foreach ($fld in @("Title","Description")) {
            #string
            try {
                $val = if ($MRRConfig.$RigName.$fld -ne $null -and $MRRConfig.$RigName.$fld -ne "") {$MRRConfig.$RigName.$fld} else {Get-Variable $fld -ValueOnly -ErrorAction Ignore}
                $val = "$($val)".Trim()
                $MRRConfig.$RigName | Add-Member $fld $val -Force
            } catch {
                if ($Error.Count){$Error.RemoveAt(0)}
                Write-Log -Level Warn "Error in MiningRigRentals parameter `"$fld`" in pools.config.txt or mrr.config.txt"
            }
        }

        if ($MRRConfig.$RigName.MinHours -lt 3) {$MRRConfig.$RigName.MinHours = 3}
        if ($MRRConfig.$RigName.MaxHours -lt $MRRConfig.$RigName.MinHours) {$MRRConfig.$RigName.MaxHours = $MRRConfig.$RigName.MinHours}
        if ($MRRConfig.$RigName.AutoCreateMaxMinHours -lt 3) {$MRRConfig.$RigName.AutoCreateMaxMinHours = 3}
    }

    #
    # 2. Auto extend rented rigs, if bonus applicable
    #

    $RentalIDs = @($AllRigs_Request.Where({($_.status.status -eq "rented" -or $_.status.rented) -and $_.description -match "\[$($Workers -join "|")\]" -and (([regex]"\[[\w\-]+\]").Matches($_.description).Value | Select-Object -Unique | Measure-Object).Count -eq 1}) | Select-Object -ExpandProperty rental_id)
    
    if ($RentalIDs) {
        $Rental_Result = Invoke-MiningRigRentalRequest "/rental/$($RentalIDs -join ";")" $API_Key $API_Secret -method "GET" -Timeout 60
        foreach ($RigName in $Workers) {
            if (-not $MRRConfig.$RigName.AutoBonusExtendForHours -or -not $MRRConfig.$RigName.AutoBonusExtendByHours) {continue}
            $Rental_Result | Where-Object {$_.rig.description -match "\[$RigName\]"} | Foreach-Object {
                $ExtendBy = [Math]::Floor([double]$_.length/$MRRConfig.$RigName.AutoBonusExtendForHours) * $MRRConfig.$RigName.AutoBonusExtendByHours - [double]$_.extended
                if ($ExtendBy -gt 0) {
                    try {                    
                        $Extend_Result = Invoke-MiningRigRentalRequest "/rig/$($_.rig.id)/extend" $API_Key $API_Secret -params @{"hours"=$ExtendBy} -method "PUT" -Timeout 60
                        if ($Extend_Result.success) {
                            Write-Log -Level Info "Extended MRR rental #$($_.id) for $(Get-MiningRigRentalAlgorithm $_.rig.type) on $($RigName) for $ExtendBy bonus-hours."
                        }
                    } catch {
                        if ($Error.Count){$Error.RemoveAt(0)}
                        Write-Log -Level Warn "Unable to extend MRR rental #$($_.id) $(Get-MiningRigRentalAlgorithm $_.rig.type) on $($RigName) for $ExtendBy bonus-hours: $($_.Exception.Message)"
                    }
                }
            }
        }
    }

    #
    # 3. Auto create/update rigs
    #

    $MaxAPICalls = 40

    $RigGPUModels = $Session.Config.DeviceModel.Where({$_ -ne "CPU"})

    $RigPools = [hashtable]@{}
    if ($AllRigs_Request) {
        try {
            (Invoke-MiningRigRentalRequest "/rig/$(@($AllRigs_Request | Select-Object -ExpandProperty id) -join ";")/pool" $API_Key $API_Secret -Timeout 60) | Foreach-Object {$RigPools[[int]$_.rigid] = $_.pools}
        } catch {
            if ($Error.Count){$Error.RemoveAt(0)}
            Write-Log -Level Warn "Unable to get MRR pools: $($_.Exception.Message)"
        }
    }

    $PoolsData = Get-MiningRigRentalsPoolsData

    foreach($RigRunMode in @("create","update")) {

        foreach ($RigName in $Workers) {

            Write-Log -Level Info "Start $($RigRunMode) MRR rigs on $($RigName)"

            if ($RigRunMode -eq "create" -and $RigCreated -ge $MaxAPICalls) {break}

            if (($RigRunMode -eq "create" -and $MRRConfig.$RigName.EnableAutoCreate) -or ($RigRunMode -eq "update" -and $MRRConfig.$RigName.EnableAutoUpdate)) {
                try {
                    $RigModels           = @($Session.Config.Devices.PSObject.Properties | Where-Object {$_.Value.Worker -eq $RigName} | Foreach-Object {$_.Name} | Select-Object -Unique)
                    $RigDevice           = $Global:DeviceCache.Devices.Where({($_.Model -notmatch "-" -and (($RigName -eq $Worker -and $_.Type -eq "Gpu") -or ($RigName -ne $Worker -and $_.Model -in $RigModels)))})
                    $RigDeviceStat       = Get-Stat -Name "Profit-$(@($RigDevice | Select-Object -ExpandProperty Name -Unique | Sort-Object) -join "-")"
                    $RigDeviceRevenue24h = $RigDeviceStat.Day
                    $RigDevicePowerDraw  = $RigDeviceStat.PowerDraw_Average

                    $CurrentlyBenchmarking = @($API.MinersNeedingBenchmark | Foreach-Object {[PSCustomObject]@{Algorithm="$($_.HashRates.PSObject.Properties.Name | Select-Object -First 1)";DeviceModel=$_.DeviceModel}} | Where-Object {$_.Algorithm -notmatch "-"} | Select-Object)

                    $RigType ="$($RigDevice | Select-Object -ExpandProperty Type -Unique)".ToUpper()

                    if ($MRRConfig.$RigName.AutoCreateMinProfitBTC -lt 0) {
                        $MRRConfig.$RigName.AutoCreateMinProfitBTC = if ($RigType -eq "CPU") {$MRRConfig.$RigName.AutoCreateMinCPUProfitBTC} else {0}
                    }

                    $RigSubst = @{
                        "RigID"      = "$(Get-MiningRigRentalsRigID $RigName)"
                        "Type"       = $RigType
                        "TypeCPU"    = "$(if ($RigType -eq "CPU") {"CPU"})"
                        "TypeGPU"    = "$(if ($RigType -eq "GPU") {"GPU"})"
                        "Workername" = $RigName
                    }
                    
                    if ($RigDeviceRevenue24h -and $RigDeviceStat.Duration) {
                        if ($RigDeviceStat.Duration -lt [timespan]::FromHours(3)) {throw "your rig must run for at least 3 hours be accurate"}
                        $RigModels         = @($RigDevice | Select-Object -ExpandProperty Model -Unique | Sort-Object)
                        $RigAlreadyCreated = @($AllRigs_Request.Where({$_.description -match "\[$RigName\]" -and ($RigRunMode -eq "create" -or (([regex]"\[[\w\-]+\]").Matches($_.description).Value | Select-Object -Unique | Measure-Object).Count -eq 1)}))
                        $RigProfitBTCLimit = [Math]::Max($RigDeviceRevenue24h * [Math]::Min($MRRConfig.$RigName.AutoCreateMinProfitPercent,100)/100,$MRRConfig.$RigName.AutoCreateMinProfitBTC)
                        $RigModifier       = [Math]::Max(-30,[Math]::Min(30,$MRRConfig.$RigName.AutoPriceModifierPercent))

                        $DeviceAlgorithm        = @($RigModels | Where-Object {$Session.Config.Devices.$_.Algorithm.Count} | Foreach-Object {$Session.Config.Devices.$_.Algorithm} | Select-Object -Unique)
                        $DeviceExcludeAlgorithm = @($RigModels | Where-Object {$Session.Config.Devices.$_.ExcludeAlgorithm.Count} | Foreach-Object {$Session.Config.Devices.$_.ExcludeAlgorithm} | Select-Object -Unique)

                        $Pool_Request.Where({($RigRunMode -eq "create" -and $RigAlreadyCreated.type -notcontains $_.name) -or ($RigRunMode -eq "update" -and $RigAlreadyCreated.type -contains $_.name)}).Foreach({
                            $Algorithm_Norm  = Get-MiningRigRentalAlgorithm $_.name
                            $RigPower   = 0
                            $RigSpeed   = 0
                            $RigRevenue = 0

                            if ((Get-Yes $Session.Config.Algorithms.$Algorithm_Norm.MRREnable) -and -not (
                                    ($Session.Config.Algorithm.Count -and $Session.Config.Algorithm -inotcontains $Algorithm_Norm) -or
                                    ($Session.Config.ExcludeAlgorithm.Count -and $Session.Config.ExcludeAlgorithm -icontains $Algorithm_Norm) -or
                                    ($Session.Config.Pools.$Name.Algorithm.Count -and $Session.Config.Pools.$Name.Algorithm -inotcontains $Algorithm_Norm) -or
                                    ($Session.Config.Pools.$Name.ExcludeAlgorithm.Count -and $Session.Config.Pools.$Name.ExcludeAlgorithm -icontains $Algorithm_Norm) -or
                                    ($DeviceAlgorithm.Count -and $DeviceAlgorithm -inotcontains $Algorithm_Norm) -or
                                    ($DeviceExcludeAlgorithm.Count -and $DeviceExcludeAlgorithm -icontains $Algorithm_Norm)
                                ) -and (-not $CurrentlyBenchmarking.Count -or -not $CurrentlyBenchmarking.Where({$_.Algorithm -eq $Algorithm_Norm -and $RigModels -contains $_.DeviceModel}).Count)) {
                                foreach ($Model in $RigModels) {
                                    $RigPowerAdd   = 0
                                    $RigSpeedAdd   = 0
                                    $RigRevenueAdd = 0
                                    $Global:ActiveMiners.Where({$_.Speed -ne $null -and "$($_.Algorithm | Select-Object -First 1)" -eq $Algorithm_Norm -and $_.DeviceModel -eq $Model}).Foreach({
                                        $ThisSpeed = $_.Speed[0] * (1 - $_.DevFee."$($_.Algorithm[0])" / 100)
                                        if ($ThisSpeed -gt $RigSpeedAdd) {
                                            $RigPowerAdd   = $_.PowerDraw
                                            $RigSpeedAdd   = $ThisSpeed
                                            $RigRevenueAdd = $_.Profit + $(if ($Session.Config.UsePowerPrice -and $_.Profit_Cost -ne $null -and $_.Profit_Cost -gt 0) {$_.Profit_Cost})
                                        }
                                    })
                                    $RigPower   += $RigPowerAdd
                                    $RigSpeed   += $RigSpeedAdd
                                    $RigRevenue += $RigRevenueAdd
                                }
                            }

                            $SuggestedPrice = if ($_.suggested_price.unit) {[Double]$_.suggested_price.amount / (ConvertFrom-Hash "1$($_.suggested_price.unit -replace "\*.+$")")} else {0}
                            $IsHandleRig    = ($RigRunMode -eq "update") -or ($MRRConfig.$RigName.AutoCreateAlgorithm -contains $Algorithm_Norm)

                            $RigPowerDiff   = 0
                            $RigMinPrice    = 0
                            $RigPrice       = 0

                            if ($RigSpeed -gt 0) {
                                $RigPowerDiff   = if ($Session.Config.UsePowerPrice -and $RigPower -gt 0 -and $RigDevicePowerDraw -gt 0) {($RigPower - $RigDevicePowerDraw) * 24/1000 * $Session.PowerPriceBTC * $MRRConfig.$RigName.PowerDrawFactor} else {0}
                                if ($RigPowerDiff -lt 0 -and $MRRConfig.$RigName.EnablePowerDrawAddOnly) {$RigPowerDiff = 0}
                                $RigMinPrice    = [Math]::Max($RigDeviceRevenue24h * $MRRConfig.$RigName.PriceFactor + $RigPowerDiff,$RigDeviceRevenue24h) / $RigSpeed
                                $RigPrice       = if ($MRRConfig.$RigName.PriceBTC -gt 0) {$MRRConfig.$RigName.PriceBTC / $RigSpeed} else {$RigMinPrice}
       
                                if (($RigRevenue -lt 5*$RigDeviceRevenue24h) -and ($IsHandleRig -or $RigRevenue -ge $RigProfitBTCLimit -or $RigMinPrice -lt $SuggestedPrice)) {

                                    #Write-Log -Level Warn "$RigRunMode $RigName $($_.name): Profit=$($RigRevenue) > $($RigProfitBTCLimit) $(if ($RigRevenue -gt $RigProfitBTCLimit) {"YES!!"} else {"no   "}), MinPrice=$($RigMinPrice) / $($RigMinPriceNew) => $($RigDevicePowerDraw) vs. $($RigPower), Sugg=$($SuggestedPrice), Speed=$($RigSpeed), MinHours=$($RigMinHours)"

                                    $RigMinPrice = [Math]::Max($RigPrice,$RigMinPrice)

                                    $PriceDivisor = 0
                                    while($PriceDivisor -lt $RigDivisors.Count -and $RigMinPrice -lt 1e-3) {
                                        $RigMinPrice *= 1000
                                        $RigPrice    *= 1000
                                        $PriceDivisor++
                                    }
                                    $RigMinPrice = [Decimal][Math]::Round($RigMinPrice,12)
                                    $RigPrice    = [Decimal][Math]::Round($RigPrice,12)

                                    $HashDivisor = 0
                                    while ($HashDivisor -lt $RigDivisors.Count -and $RigSpeed -gt 1000) {
                                        $RigSpeed /= 1000
                                        $HashDivisor++
                                    }

                                    if ($RigSpeed -lt 1) {$RigSpeed = [Math]::Floor($RigSpeed*100)/100}
                                    elseif ($RigSpeed -lt 100) {$RigSpeed = [Math]::Floor($RigSpeed*10)/10}
                                    else {$RigSpeed = [Math]::Floor($RigSpeed)}

                                    $Multiply = $RigDivisors[$HashDivisor].value / $RigDivisors[$PriceDivisor].value

                                    $RigMinHours = if ($RigMinPrice -eq 0 -or ($RigMinPrice * $RigSpeed * $MRRConfig.$RigName.MinHours * $Multiply / 24 -gt $RigMinProfit)) {$MRRConfig.$RigName.MinHours} else {[Math]::Ceiling($RigMinProfit*24/($RigMinPrice*$RigSpeed*$Multiply))}

                                    #Write-Log -Level Warn "$RigRunMode $RigName $($_.name): Multiply=$($Multiply), MinPrice=$($RigMinPrice), Sugg=$($SuggestedPrice), Speed=$($RigSpeed), MinHours=$($RigMinHours)"

                                    if ($IsHandleRig -or $RigMinHours -le $MRRConfig.$RigName.AutoCreateMaxMinHours) {

                                        $RigMaxHours             = [Math]::Max($MRRConfig.$RigName.MinHours,$MRRConfig.$RigName.MaxHours)
                                        $Algorithm_Norm_Mapped   = Get-MappedAlgorithm $Algorithm_Norm
                                        $RigSubst["Algorithm"]   = $Algorithm_Norm_Mapped
                                        $RigSubst["AlgorithmEx"] = if ($_.display -match "\(([^\)]+)\)$") {"$($Algorithm_Norm_Mapped)$(if (Get-Coin $Matches[1]) {"/$($Matches[1].ToUpper())"} elseif ($Matches[1] -ne $Algorithm_Norm_Mapped) {"/$($Matches[1])"})"} else {$Algorithm_Norm_Mapped}
                                        $RigSubst["CoinInfo"]    = if ($_.display -match "\(([^\)]+)\)$") {"$(if (Get-Coin $Matches[1]) {$Matches[1].ToUpper()} else {$Matches[1]})"} else {""}
                                        $RigSubst["Display"]     = $_.display
                                    
                                        if (-not $RigServer) {$RigServer = Get-MiningRigRentalServers -Region @(@($Session.Config.Region) + $Session.Config.DefaultPoolRegion.Where({$_ -ne $Session.Config.Region}) | Select-Object)}
                                        $CreateRig = if ($RigRunMode -eq "create") {
                                            @{
                                                type        = $_.name
                                                status	    = "disabled"
                                                server	    = $RigServer.name
                                                ndevices    = $RigDevice.Count
                                            }
                                        } else {
                                            @{
                                                ndevices    = $RigDevice.Count
                                            }
                                        }

                                        if ($RigRunMode -eq "create" -or $MRRConfig.$RigName.EnableUpdateTitle) {
                                            $CreateRig["name"] = Get-MiningRigRentalsSubst "$(if (-not $MRRConfig.$RigName.Title -or $MRRConfig.$RigName.Title -eq "%algorithm% mining") {"%algorithmex% mining with RainbowMiner rig %rigid%"} elseif ($MRRConfig.$RigName.Title -notmatch "%(algorithm|algorithmex|display)%") {"%algorithmex% $($MRRConfig.$RigName.Title)"} else {$MRRConfig.$RigName.Title})" -Subst $RigSubst
                                        }

                                        if ($RigRunMode -eq "create" -or $MRRConfig.$RigName.EnableUpdateDescription) {
                                            $CreateRig["description"] = Get-MiningRigRentalsSubst "$(if ($MRRConfig.$RigName.Description -notmatch "%workername%") {"$($MRRConfig.$RigName.Description)[$RigName]"} elseif ($MRRConfig.$RigName.Description -notmatch "\[%workername%\]") {$MRRConfig.$RigName.Description -replace "%workername%","[$RigName]"} else {$MRRConfig.$RigName.Description})" -Subst $RigSubst
                                        }

                                        $CreateRig["price"] = @{
                                            btc = @{
                                                price       = $RigPrice
                                                autoprice   = $MRRConfig.$RigName.EnableAutoPrice
                                                minimum	    = if ($MRRConfig.$RigName.EnableMinimumPrice) {$RigMinPrice} else {0}
                                            }
                                            ltc = @{
                                                enabled     = $MRRConfig.$RigName.PriceCurrencies -contains "LTC"
                                                autoprice   = $true
                                            }
                                            eth = @{
                                                enabled     = $MRRConfig.$RigName.PriceCurrencies -contains "ETH"
                                                autoprice   = $true
                                            }
                                            dash = @{
                                                enabled     = $MRRConfig.$RigName.PriceCurrencies -contains "DASH"
                                                autoprice   = $true
                                            }
                                            bch = @{
                                                enabled     = $MRRConfig.$RigName.PriceCurrencies -contains "BCH"
                                                autoprice   = $true
                                            }
                                            type = $RigDivisors[$PriceDivisor].type
                                        }

                                        $CreateRig["hash"] = @{
                                            hash = $RigSpeed
                                            type = $RigDivisors[$HashDivisor].type
                                        }

                                        $CreateRig["minhours"] = $RigMinHours
                                        $CreateRig["maxhours"] = $RigMaxHours

                                        if ($RigRunMode -eq "create" -or $EnableUpdatePriceModifier) {
                                            $CreateRig["price"]["btc"]["modifier"] = if ($Session.Config.Algorithms.$Algorithm_Norm.MRRPriceModifierPercent -ne $null) {$Session.Config.Algorithms.$Algorithm_Norm.MRRPriceModifierPercent} else {$RigModifier}
                                            $CreateRig["price"]["btc"]["modifier"] = "$(if ($CreateRig["price"]["btc"]["modifier"] -gt 0) {"+"})$($CreateRig["price"]["btc"]["modifier"])"
                                        }
                            
                                        $RigPool = $PoolsData | Where-Object {$_.Algorithm -eq $Algorithm_Norm} | Sort-Object -Descending {$_.Region -eq $Session.Config.Region}, {$ix = $Session.Config.DefaultPoolRegion.IndexOf($_.Region);[int]($ix -ge 0)*(100-$ix)} | Select-Object -First 1
                                        if ($RigRunMode -eq "create") {
                                            try {
                                                $Result = Invoke-MiningRigRentalRequest "/rig" $API_Key $API_Secret -params $CreateRig -method "PUT" -Timeout 60
                                                if ($Result.id) {
                                                    Write-Log -Level Info "Created MRR rig #$($Result.id) $($Algorithm_Norm) [$($RigName)]: hash=$($CreateRig.hash.hash)$($CreateRig.hash.type), minimum=$($RigMinPrice)/$($RigDivisors[$PriceDivisor].type)/day, minhours=$($CreateRig.minhours)"
                                                    if ($RigPool) {
                                                        try {
                                                            $Result = Invoke-MiningRigRentalRequest "/rig/$($Result.id)/pool" $API_Key $API_Secret -params @{host=$RigPool.Host;port=$RigPool.Port;user=$RigPool.User;pass=$RigPool.pass} -method "PUT" -Timeout 60
                                                            if ($Result.success) {
                                                                $RigCreated++
                                                                Write-Log -Level Info "Update pools of MRR rig #$($Result.id) $($Algorithm_Norm) [$($RigName)]: $($RigPool.Host)"
                                                            }
                                                        } catch {
                                                            if ($Error.Count){$Error.RemoveAt(0)}
                                                            Write-Log -Level Warn "Unable to add pools to MRR $($Algorithm_Norm) rig for $($RigName): $($_.Exception.Message)"
                                                        }
                                                    }
                                                }
                                            } catch {
                                                if ($Error.Count){$Error.RemoveAt(0)}
                                                Write-Log -Level Warn "Unable to create MRR $($Algorithm_Norm) rig for $($RigName): $($_.Exception.Message)"
                                            }
                                            $RigCreated++
                                            if ($RigCreated -ge $MaxAPICalls) {return}

                                        } elseif ($RigRunMode -eq "update") {

                                            $RigMRRid = $_.name
                                            $RigAlreadyCreated.Where({$_.type -eq $RigMRRid -and $_.price.BTC.autoprice}).Foreach({
                                                $RigHashCurrent     = [double]$_.hashrate.advertised.hash * $(ConvertFrom-Hash "1$($_.hashrate.advertised.type)")
                                                $RigMinPriceCurrent = [double]$_.price.BTC.minimum / $(ConvertFrom-Hash "1$($_.price.type)")

                                                if ( (-not $RigMinPriceCurrent) -or
                                                     ([decimal]($RigSpeed*$RigDivisors[$HashDivisor].value) -ne [decimal]$RigHashCurrent) -or
                                                     ([Math]::Abs($RigMinPrice / $RigDivisors[$PriceDivisor].value / $RigMinPriceCurrent - 1) -gt ($MRRConfig.$RigName.AutoUpdateMinPriceChangePercent / 100)) -or
                                                     ($_.ndevices -ne $CreateRig.ndevices) -or 
                                                     ($MRRConfig.$RigName.EnableUpdateTitle -and $_.name -ne $CreateRig.name) -or
                                                     ($MRRConfig.$RigName.EnableUpdateDescription -and $_.description -ne $CreateRig.description) -or
                                                     ($CreateRig.price.btc.modifier -ne $null -and $_.price.BTC.modifier -ne $CreateRig.price.btc.modifier) -or
                                                     ($RigServer -and ($_.region -ne $RigServer.region))
                                                ) {
                                                    $CreateRig["id"] = $_.id
                                                    if ($_.region -ne $RigServer.region) {$CreateRig["server"] = $RigServer.name}
                                                    $RigUpdated = $false
                                                    if ($MRRConfig.$RigName.EnableUpdateDescription -and $_.description -ne $CreateRig.description) {
                                                        if ($RigCreated -lt $MaxAPICalls) {
                                                            $RigUpdated = $true
                                                            try {
                                                                $Result = Invoke-MiningRigRentalRequest "/rig/$($_.id)" $API_Key $API_Secret -params $CreateRig -method "PUT" -Timeout 60
                                                            } catch {
                                                                if ($Error.Count){$Error.RemoveAt(0)}
                                                                Write-Log -Level Warn "Unable to update MRR rig #$($_.id) $($Algorithm_Norm) [$($RigName)]: $($_.Exception.Message)"
                                                            }
                                                            $RigCreated++
                                                        }
                                                    } else {
                                                        $RigUpdated = $true
                                                        $RigsToUpdate += $CreateRig
                                                    }
                                                    if ($RigUpdated) {
                                                        Write-Log -Level Info "Update MRR rig #$($_.id) $($Algorithm_Norm) [$($RigName)]: hash=$($CreateRig.hash.hash)$($CreateRig.hash.type), minimum=$($RigMinPrice)/$($RigDivisors[$PriceDivisor].type)/day, minhours=$($CreateRig.minhours), ndevices=$($CreateRig.ndevices), modifier=$($CreateRig.price.btc.modifier), region=$($RigServer.region)"
                                                    }
                                                }

                                                if ($RigPool -and $RigCreated -lt $MaxAPICalls) {
                                                    $RigPoolCurrent = $RigPools[[int]$_.id] | Where-Object {$_.user -match "mrx$" -or $_.pass -match "^mrx"} | Select-Object -First 1
                                                    if ((-not $RigPoolCurrent -and ($RigPools[[int]$_.id] | Measure-Object).Count -lt 5) -or ($RigPoolCurrent -and ($RigPoolCurrent.host -ne $RigPool.Host -or $RigPoolCurrent.user -ne $RigPool.User -or $RigPoolCurrent.pass -ne $RigPool.Pass))) {
                                                        try {
                                                            $RigPriority = [int]$(if ($RigPoolCurrent) {
                                                                $RigPoolCurrent.priority
                                                            } else {
                                                                foreach($i in 0..4) {
                                                                    if (-not ($RigPools[[int]$_.id] | Where-Object {$_.priority -eq $i})) {
                                                                        $i
                                                                        break
                                                                    }
                                                                }
                                                            })
                                                            $Result = Invoke-MiningRigRentalRequest "/rig/$($_.id)/pool/$($RigPriority)" $API_Key $API_Secret -params @{host=$RigPool.Host;port=$RigPool.Port;user=$RigPool.User;pass=$RigPool.pass} -method "PUT" -Timeout 60
                                                            if ($Result.success) {
                                                                $RigCreated++
                                                                Write-Log -Level Info "Update pools of MRR rig #$($_.id) $($Algorithm_Norm) [$($RigName)]: $($RigPool.Host)"
                                                            }
                                                        } catch {
                                                            if ($Error.Count){$Error.RemoveAt(0)}
                                                            Write-Log -Level Warn "Unable to update pools MRR rig #$($_.id) $($Algorithm_Norm) [$($RigName)]: $($_.Exception.Message)"
                                                        }                                                        
                                                    }
                                                }
                                            })
                                        }
                                    }
                                }
                            }
                        })
                    }
                } catch {
                    if ($Error.Count){$Error.RemoveAt(0)}
                    Write-Log -Level Warn "Unable to $($RigRunMode) MRR rigs for $($RigName): $($_.Exception.Message)"
                }
            }
        }
    }

    if ($RigsToUpdate.Count) {

        try {
            $Result = Invoke-MiningRigRentalRequest "/rig/batch" $API_Key $API_Secret -params @{"rigs"=$RigsToUpdate} -method "PUT" -Timeout 60
        } catch {
            if ($Error.Count){$Error.RemoveAt(0)}
            Write-Log -Level Warn "Unable to update MRR: $($_.Exception.Message)"
        }

    }

    $Session.MRRlastautoperation = Get-Date    
}