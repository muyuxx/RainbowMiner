﻿using module ..\Include.psm1

param(
    [PSCustomObject]$Pools,
    [Bool]$InfoOnly
)

if (-not $IsWindows -and -not $IsLinux) {return}

if ($IsLinux) {
    $Path = ".\Bin\ANY-SRBMinerMulti\SRBMiner-MULTI"
    $Uri = "https://github.com/RainbowMiner/miner-binaries/releases/download/v0.4.7-srbminermulti/SRBMiner-Multi-0-4-7-Linux.tar.xz"
} else {
    $Path = ".\Bin\ANY-SRBMinerMulti\SRBMiner-MULTI.exe"
    $Uri = "https://github.com/RainbowMiner/miner-binaries/releases/download/v0.4.7-srbminermulti/SRBMiner-Multi-0-4-7-win64.zip"
}
$ManualUri = "https://bitcointalk.org/index.php?topic=5190081.0"
$Port = "349{0:d2}"
$DevFee = 0.85
$Version = "0.4.7"

if (-not $Global:DeviceCache.DevicesByTypes.AMD -and -not $Global:DeviceCache.DevicesByTypes.CPU -and -not $InfoOnly) {return} # No AMD nor CPU present in system

$Commands = [PSCustomObject[]]@(
    [PSCustomObject]@{MainAlgorithm = "cpupower"      ; Params = ""; Fee = 0.85;               Vendor = @("CPU")} #CPUpower
    [PSCustomObject]@{MainAlgorithm = "defyx"         ; Params = ""; Fee = 0.85;               Vendor = @("CPU")} #DefyX
    [PSCustomObject]@{MainAlgorithm = "m7mv2"         ; Params = ""; Fee = 0.00;               Vendor = @("CPU")} #m7m
    [PSCustomObject]@{MainAlgorithm = "minotaur"      ; Params = ""; Fee = 2.50;               Vendor = @("CPU")} #Minotaur/RING Coin
    [PSCustomObject]@{MainAlgorithm = "randomarq"     ; Params = "--randomx-use-1gb-pages"; Fee = 0.85; Vendor = @("CPU")} #RandomArq
    [PSCustomObject]@{MainAlgorithm = "randomepic"    ; Params = "--randomx-use-1gb-pages"; Fee = 0.85; Vendor = @("CPU")} #RandomEPIC
    [PSCustomObject]@{MainAlgorithm = "randomkeva"    ; Params = "--randomx-use-1gb-pages"; Fee = 0.85; Vendor = @("CPU")} #RandomKEVA
    [PSCustomObject]@{MainAlgorithm = "randomsfx"     ; Params = "--randomx-use-1gb-pages"; Fee = 0.85; Vendor = @("CPU")} #RandomSFX
    [PSCustomObject]@{MainAlgorithm = "randomwow"     ; Params = "--randomx-use-1gb-pages"; Fee = 0.85; Vendor = @("CPU")} #RandomWow
    [PSCustomObject]@{MainAlgorithm = "randomx"       ; Params = "--randomx-use-1gb-pages"; Fee = 0.85; Vendor = @("CPU")} #RandomX
    [PSCustomObject]@{MainAlgorithm = "randomxl"      ; Params = "--randomx-use-1gb-pages"; Fee = 0.85; Vendor = @("CPU")} #RandomXL
    [PSCustomObject]@{MainAlgorithm = "yescryptr16"   ; Params = ""; Fee = 0.85;               Vendor = @("CPU")} #yescryptr16
    [PSCustomObject]@{MainAlgorithm = "yescryptr32"   ; Params = ""; Fee = 0.85;               Vendor = @("CPU")} #yescryptr32
    [PSCustomObject]@{MainAlgorithm = "yescryptr8"    ; Params = ""; Fee = 0.85;               Vendor = @("CPU")} #yescryptr8
    [PSCustomObject]@{MainAlgorithm = "yespower"      ; Params = ""; Fee = 0.85;               Vendor = @("CPU")} #yespower
    [PSCustomObject]@{MainAlgorithm = "yespower2b"    ; Params = ""; Fee = 0.85;               Vendor = @("CPU")} #yespower2b
    [PSCustomObject]@{MainAlgorithm = "yespoweric"    ; Params = ""; Fee = 0.85;               Vendor = @("CPU")} #yespoweric
    [PSCustomObject]@{MainAlgorithm = "yespoweriots"  ; Params = ""; Fee = 0.85;               Vendor = @("CPU")} #yespoweriots
    [PSCustomObject]@{MainAlgorithm = "yespoweritc"   ; Params = ""; Fee = 0.00;               Vendor = @("CPU")} #yespoweritc
    [PSCustomObject]@{MainAlgorithm = "yespowerlitb"  ; Params = ""; Fee = 0.85;               Vendor = @("CPU")} #yespowerlitb
    [PSCustomObject]@{MainAlgorithm = "yespowerltncg" ; Params = ""; Fee = 0.85;               Vendor = @("CPU")} #yespowerltncg
    [PSCustomObject]@{MainAlgorithm = "yespowerr16"   ; Params = ""; Fee = 0.85;               Vendor = @("CPU")} #yespowerr16
    [PSCustomObject]@{MainAlgorithm = "yespowerres"   ; Params = ""; Fee = 0.85;               Vendor = @("CPU")} #yespowerRES
    [PSCustomObject]@{MainAlgorithm = "yespowersugar" ; Params = ""; Fee = 0.85;               Vendor = @("CPU")} #yespowersugar
    [PSCustomObject]@{MainAlgorithm = "yespowerurx"   ; Params = ""; Fee = 0.00;               Vendor = @("CPU")} #yespowerurx
    [PSCustomObject]@{MainAlgorithm = "bl2bsha3"      ; Params = ""; Fee = 0.85; MinMemGb = 2; Vendor = @("AMD","CPU")} #blake2b+sha3/HNS
    [PSCustomObject]@{MainAlgorithm = "blake2b"       ; Params = ""; Fee = 0.00; MinMemGb = 2; Vendor = @("AMD")} #blake2b
    #[PSCustomObject]@{MainAlgorithm = "blake2s"       ; Params = ""; Fee = 0.00; MinMemGb = 2; Vendor = @("AMD","CPU")} #blake2s
    [PSCustomObject]@{MainAlgorithm = "cryptonight_bbc"; Params = ""; Fee = 2.5;               Vendor = @("AMD","CPU")} #CryptonightCatalans
    [PSCustomObject]@{MainAlgorithm = "cryptonight_catalans"; Params = ""; Fee = 0.00;         Vendor = @("AMD","CPU")} #CryptonightCatalans
    [PSCustomObject]@{MainAlgorithm = "cryptonight_talleo";   Params = ""; Fee = 0.00;         Vendor = @("AMD","CPU")} #CryptonightTalleo
    [PSCustomObject]@{MainAlgorithm = "eaglesong"     ; Params = ""; Fee = 0.85; MinMemGb = 2; Vendor = @("AMD")} #eaglesong
    [PSCustomObject]@{MainAlgorithm = "ethash"        ; Params = "--enable-ethash-leak-fix"; Fee = 0.85; MinMemGb = 3; Vendor = @("AMD"); ExcludePoolName="^Nicehash"} #ethash
    [PSCustomObject]@{MainAlgorithm = "ubqhash"       ; Params = ""; Fee = 0.85; MinMemGb = 3; Vendor = @("AMD")} #ubqhash
    [PSCustomObject]@{MainAlgorithm = "k12"           ; Params = ""; Fee = 0.85; MinMemGb = 2; Vendor = @("AMD","CPU")} #kangaroo12/AEON from 2019-10-25
    [PSCustomObject]@{MainAlgorithm = "kadena"        ; Params = ""; Fee = 0.85; MinMemGb = 2; Vendor = @("AMD","CPU"); Coins = @("KDA")} #blake2s / Kadena
    [PSCustomObject]@{MainAlgorithm = "keccak"        ; Params = ""; Fee = 0.00; MinMemGb = 2; Vendor = @("AMD")} #keccak
    [PSCustomObject]@{MainAlgorithm = "mtp"           ; Params = ""; Fee = 0.00; MinMemGb = 6; Vendor = @("AMD")} #mtp
    [PSCustomObject]@{MainAlgorithm = "rainforestv2"  ; Params = ""; Fee = 0.85; MinMemGb = 2; Vendor = @("AMD")} #rainforestv2
    [PSCustomObject]@{MainAlgorithm = "tellor"        ; Params = ""; Fee = 0.85; MinMemGb = 2; Vendor = @("AMD","CPU"); ExcludePoolName = "^Hashpool"} #Tellor
    [PSCustomObject]@{MainAlgorithm = "yescrypt"      ; Params = ""; Fee = 0.85; MinMemGb = 2; Vendor = @("AMD")} #yescrypt
)

$Name = Get-Item $MyInvocation.MyCommand.Path | Select-Object -ExpandProperty BaseName

if ($InfoOnly) {
    [PSCustomObject]@{
        Type = @("AMD","CPU")
        Name      = $Name
        Path      = $Path
        Port      = $Miner_Port
        Uri       = $Uri
        DevFee    = $DevFee
        ManualUri = $ManualUri
        Commands  = $Commands
    }
    return
}

foreach ($Miner_Vendor in @("AMD","CPU")) {
    $Global:DeviceCache.DevicesByTypes.$Miner_Vendor | Select-Object Vendor, Model -Unique | ForEach-Object {
        $Miner_Model = $_.Model
        $Device = $Global:DeviceCache.DevicesByTypes.$Miner_Vendor.Where({$_.Model -eq $Miner_Model})

        $Commands.Where({$_.Vendor -icontains $Miner_Vendor}).ForEach({
            $First = $true
            $Algorithm = $_.MainAlgorithm
            $Algorithm_Norm_0 = Get-Algorithm $Algorithm

            if ($Miner_Vendor -eq "CPU") {
                $CPUThreads = if ($Session.Config.Miners."$Name-CPU-$Algorithm_Norm_0".Threads)  {$Session.Config.Miners."$Name-CPU-$Algorithm_Norm_0".Threads}  elseif ($Session.Config.Miners."$Name-CPU".Threads)  {$Session.Config.Miners."$Name-CPU".Threads}  elseif ($Session.Config.CPUMiningThreads)  {$Session.Config.CPUMiningThreads}
                $CPUAffinity= if ($Session.Config.Miners."$Name-CPU-$Algorithm_Norm_0".Affinity) {$Session.Config.Miners."$Name-CPU-$Algorithm_Norm_0".Affinity} elseif ($Session.Config.Miners."$Name-CPU".Affinity) {$Session.Config.Miners."$Name-CPU".Affinity} elseif ($Session.Config.CPUMiningAffinity) {$Session.Config.CPUMiningAffinity}

                $DeviceParams = "$(if ($CPUThreads){" --cpu-threads $CPUThreads"})$(if ($CPUAffinity){" --cpu-affinity $CPUAffinity"})"
            }

            $MinMemGB = if ($Algorithm_Norm_0 -match "^(Ethash|KawPow|ProgPow)") {if ($Pools.$Algorithm_Norm_0.EthDAGSize) {$Pools.$Algorithm_Norm_0.EthDAGSize} else {Get-EthDAGSize $Pools.$Algorithm_Norm_0.CoinSymbol}} else {$_.MinMemGB}
        
            $Miner_Device = $Device | Where-Object {$Miner_Vendor -eq "CPU" -or $_.OpenCL.GlobalMemsize -ge ($MinMemGb * 1gb - 0.25gb)}

            $All_Algorithms = if ($Miner_Vendor -eq "CPU") {@($Algorithm_Norm_0,"$($Algorithm_Norm_0)-$($Miner_Model)")} else {@($Algorithm_Norm_0,"$($Algorithm_Norm_0)-$($Miner_Model)","$($Algorithm_Norm_0)-GPU")}

		    foreach($Algorithm_Norm in $All_Algorithms) {
			    if ($Pools.$Algorithm_Norm.Host -and $Miner_Device -and (-not $_.Coins -or $_.Coins -icontains $Pools.$Algorithm_Norm.CoinSymbol) -and (-not $_.ExcludePoolName -or $Pools.$Algorithm_Norm.Name -notmatch $_.ExcludePoolName)) {
                    if ($First) {
				        $Miner_Port = $Port -f ($Miner_Device | Select-Object -First 1 -ExpandProperty Index)            
				    	$Miner_Name = (@($Name) + @($Miner_Device.Name | Sort-Object) | Select-Object) -join '-'
                        $DeviceIDsAll = $Miner_Device.Type_Vendor_Index -join ','
                        $DeviceIntensity = ($Miner_Device | % {"0"}) -join ','
                        $First = $false
                    }

                    $Miner_Protocol = Switch ($Pools.$Algorithm_Norm.EthMode) {
                        "ethproxy"         {"--esm 0"}
                        "minerproxy"       {"--esm 1"}
						"ethstratumnh"     {""}
						default            {""}
					}

                    $Pool_Port_Index = if ($Miner_Vendor -eq "CPU") {"CPU"} else {"GPU"}
				    $Pool_Port = if ($Pools.$Algorithm_Norm.Ports -ne $null -and $Pools.$Algorithm_Norm.Ports.$Pool_Port_Index) {$Pools.$Algorithm_Norm.Ports.$Pool_Port_Index} else {$Pools.$Algorithm_Norm.Port}

                    #--disable-extranonce-subscribe
                    #--extended-log --log-file Logs\$($_.MainAlgorithm)-$((get-date).toString("yyyyMMdd-HHmmss")).txt

				    [PSCustomObject]@{
					    Name           = $Miner_Name
					    DeviceName     = $Miner_Device.Name
					    DeviceModel    = $Miner_Model
					    Path           = $Path
					    Arguments      = "--algorithm $Algorithm --api-enable --api-port `$mport --api-rig-name $($Session.Config.Pools.$($Pools.$Algorithm_Norm.Name).Worker) $(if ($Miner_Protocol) {"$($Miner_Protocol) "})$(if ($Miner_Vendor -eq "CPU") {"--disable-gpu$DeviceParams"} else {"--gpu-id $DeviceIDsAll --gpu-intensity $DeviceIntensity --disable-cpu --max-no-share-sent 120"}) --pool $($Pools.$Algorithm_Norm.Host):$($Pool_Port) --wallet $($Pools.$Algorithm_Norm.User)$(if ($Pools.$Algorithm_Norm.Worker) {" --worker $($Pools.$Algorithm_Norm.Worker)"}) --password $($Pools.$Algorithm_Norm.Pass) --tls $(if ($Pools.$Algorithm_Norm.SSL) {"true"} else {"false"}) --nicehash $(if ($Pools.$Algorithm_Norm.Name -match 'NiceHash') {"true"} else {"false"}) --keepalive --retry-time 10 --disable-startup-monitor --disable-gpu-watchdog $($_.Params)"
					    HashRates      = [PSCustomObject]@{$Algorithm_Norm = $Global:StatsCache."$($Miner_Name)_$($Algorithm_Norm_0)_HashRate".Week}
					    API            = "SrbMiner"
					    Port           = $Miner_Port
					    Uri            = $Uri
                        FaultTolerance = $_.FaultTolerance
					    ExtendInterval = if ($_.ExtendInterval) {$_.ExtendInterval} elseif ($Miner_Vendor -eq "CPU") {2} else {$null}
                        Penalty        = 0
					    DevFee         = $_.Fee
					    ManualUri      = $ManualUri
					    EnvVars        = if ($Miner_Vendor -ne "CPU") {@("GPU_MAX_SINGLE_ALLOC_PERCENT=100","GPU_FORCE_64BIT_PTR=0")} else {$null}
                        Version        = $Version
                        PowerDraw      = 0
                        BaseName       = $Name
                        BaseAlgorithm  = $Algorithm_Norm_0
                        SetLDLIBRARYPATH = $false
				    }
			    }
		    }
        })
    }
}