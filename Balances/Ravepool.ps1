﻿param(
    $Config
)

$Name = Get-Item $MyInvocation.MyCommand.Path | Select-Object -ExpandProperty BaseName

$Pools_Data = @(
    [PSCustomObject]@{symbol = "XGM";   port = 3333; fee = 1.0; rpc = "grimm"; region = @("us")}
)

$Pools_Data | Where-Object {$Config.Pools.$Name.Wallets."$($_.symbol)" -and (-not $Config.ExcludeCoinsymbolBalances.Count -or $Config.ExcludeCoinsymbolBalances -notcontains "$($_.symbol)")} | Foreach-Object {
    $Pool_Currency = $_.symbol
    $Pool_RpcPath  = $_.rpc

    $Request = [PSCustomObject]@{}

    try {
        $Request = Invoke-RestMethodAsync "https://$($Pool_RpcPath)-api.ravepool.com/v2/workerStats?address=$($Config.Pools.$Name.Wallets."$($_.symbol)")" -delay 100 -cycletime ($Config.BalanceUpdateMinutes*60) -timeout 15
        if (-not $Request.result) {
            Write-Log -Level Info "Pool Balance API ($Name) for $($Pool_Currency) returned nothing. "
        } else {
            $Confirmed_Balance = $Request.confirmedBalance / 1e8
            $Pending_Balance   = $Request.unconfirmedBalance / 1e8
            [PSCustomObject]@{
                Caption     = "$($Name) ($Pool_Currency)"
				BaseName    = $Name
                Currency    = $Pool_Currency
                Balance     = [Decimal]$Confirmed_Balance
                Pending     = [Decimal]$Pending_Balance
                Total       = [Decimal]$Confirmed_Balance + [Decimal]$Pending_Balance
                Paid        = [Decimal]($Request.totalPaid / 1e8)
                Payouts     = @()
                LastUpdated = (Get-Date).ToUniversalTime()
            }
        }
    }
    catch {
        if ($Error.Count){$Error.RemoveAt(0)}
        Write-Log -Level Verbose "Pool Balance API ($Name) for $($Pool_Currency) has failed. "
    }
}