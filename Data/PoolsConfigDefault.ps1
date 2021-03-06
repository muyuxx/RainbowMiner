﻿[PSCustomObject]@{
        "2Miners" = [PSCustomObject]@{
            Currencies=@("XZC")
        }
        "2MinersSolo" = [PSCustomObject]@{
            Currencies=@("XZC")
        }
        "666Pool" = [PSCustomObject]@{
            Currencies=@("PMEER")
        }
        "6Block" = [PSCustomObject]@{
            Currencies=@("HNS")
        }
        "AHashPool" = [PSCustomObject]@{
            Fields=[PSCustomObject]@{Penalty=22}
            Currencies=@("BTC")
            Autoexchange=$true
            Yiimp=$true
        }
        "Aionmine" = [PSCustomObject]@{
            Currencies=@("AION")
        }
        "BaikalMine" = [PSCustomObject]@{
            Currencies=@("REOSC")
        }
        "BaikalMineSolo" = [PSCustomObject]@{
            Currencies=@("REOSC")
        }
        "BeePool" = [PSCustomObject]@{
            Currencies=@("ETH","RVN")
        }
        "BlazePool" = [PSCustomObject]@{
            Fields=[PSCustomObject]@{ExcludeAlgorithm="keccak";Penalty=22}
            Currencies=@("BTC")
            Autoexchange=$true
            Yiimp=$true
        }
        "Blockmasters" = [PSCustomObject]@{
            Fields=[PSCustomObject]@{Penalty=50}
            Currencies=@("BTC")
            Autoexchange=$true
            Yiimp=$true
        }
        "BlockmastersCoins" = [PSCustomObject]@{
            Fields=[PSCustomObject]@{Penalty=50}
            Currencies=@("BTC")
            Autoexchange=$true
            Yiimp=$true
        }
        "Bsod" = [PSCustomObject]@{
            Currencies=@("RVN","SIN")
            Yiimp=$true
        }
        "BsodParty" = [PSCustomObject]@{
            Fields=[PSCustomObject]@{AllowZero="1";PartyPassword=""}
            SetupFields=[PSCustomObject]@{PartyPassword="Enter your Party password"}
            Currencies=@("RVN","SIN")
            Yiimp=$true
        }
        "BsodSolo" = [PSCustomObject]@{
            Fields=[PSCustomObject]@{AllowZero="1"}
            Currencies=@("RVN","SIN")
            Yiimp=$true
        }
        "BtcPrivate" = [PSCustomObject]@{
            Currencies=@("BTCP")
        }
        "CoinFoundry" = [PSCustomObject]@{
            Currencies=@("BCD")
        }
        "Cortexmint" = [PSCustomObject]@{
            Currencies=@("CTXC")
        }
        "CpuPool" = [PSCustomObject]@{
            Currencies=@("CPU","MBC")
        }
        "CryptoKnight" = [PSCustomObject]@{
            Currencies=@("XWP")
        }
        "Equipool" = [PSCustomObject]@{
            Currencies=@("ZEC")
        }
        "EthashPool" = [PSCustomObject]@{
            Currencies=@("ETC","ETH","ETP","GRIN")
        }
        "Ethermine" = [PSCustomObject]@{
            Currencies=@("ETH")
        }
        "F2pool" = [PSCustomObject]@{
            Fields=[PSCustomObject]@{UserName=""}
            SetupFields=[PSCustomObject]@{UserName="Enter your f2pool username, if you want to see balances"}
            Currencies=@("ETH","GRIN","BEAM","XMR","XZC")
        }
        "FairPool" = [PSCustomObject]@{
            Currencies=@("XWP")
        }
        "FlyPool" = [PSCustomObject]@{
            Currencies=@("BEAM","YEC")
        }
        "GosCx" = [PSCustomObject]@{
            Currencies=@("GIN")
            Yiimp=$true
        }
        "GosCxParty" = [PSCustomObject]@{
            Fields=[PSCustomObject]@{AllowZero="1";PartyPassword=""}
            SetupFields=[PSCustomObject]@{PartyPassword="Enter your Party password"}
            Currencies=@("GIN")
            Yiimp=$true
        }
        "GosCxSolo" = [PSCustomObject]@{
            Fields=[PSCustomObject]@{AllowZero="1"}
            Currencies=@("GIN")
            Yiimp=$true
        }
        "Grinmint" = [PSCustomObject]@{
            Fields=[PSCustomObject]@{Password="x"}
            SetupFields=[PSCustomObject]@{Password="Enter your Grinmint password"}
            Currencies=@("GRIN")
        }
        "HashCity" = [PSCustomObject]@{
            Currencies=@("XMR")
        }
        "Hashcryptos" = [PSCustomObject]@{
            Currencies=@("BTC")
            Autoexchange=$true
            Yiimp=$true
        }
        "Hashpool" = [PSCustomObject]@{
            Currencies=@("TRB","HNS","CKB")
        }
        "Hashrefinery" = [PSCustomObject]@{
            Currencies=@("BTC")
            Autoexchange=$true
            Yiimp=$true
        }
        "HashVault" = [PSCustomObject]@{
            Currencies=@("XMR")
        }
        "Hellominer" = [PSCustomObject]@{
            Currencies=@("RVN","XWP")
        }
        "HeroMiners" = [PSCustomObject]@{
            Currencies=@("XWP")
        }
        "Icemining" = [PSCustomObject]@{
            Currencies=@("SIN","MWC")
        }
        "LeafPool" = [PSCustomObject]@{
            Currencies=@("BEAM")
        }
        "LuckyPool" = [PSCustomObject]@{
            Currencies=@("XWP")
        }
        "LuckPool" = [PSCustomObject]@{
            Currencies=@("VRSC","YEC")
        }
        "Luxor" = [PSCustomObject]@{
            Fields=[PSCustomObject]@{User=""}
            SetupFields=[PSCustomObject]@{User="Enter your Luxor username to enable automatic Catalyst mining"}
            Currencies=@("XMR")
        }
        "MinerMore" = [PSCustomObject]@{
            Currencies=@("RVN","SIN","YEC")
        }
        "MinerRocks" = [PSCustomObject]@{
            Currencies=@("XMR")
        }
        "Minexmr" = [PSCustomObject]@{
            Currencies=@("XMR")
        }
        "MiningDutch" = [PSCustomObject]@{
            Fields=[PSCustomObject]@{User="";API_ID="";API_Key="";AECurrency="BTC";Penalty=3}
            SetupFields=[PSCustomObject]@{User="Enter your MiningDutch username";API_ID="Enter your MiningDutch account ID";API_Key = "Enter your MiningDutch API key";AECurrency = "Enter your MiningDutch autoexchange currency"}
            Currencies=@()
            Autoexchange=$true
        }
        "MiningDutchCoins" = [PSCustomObject]@{
            Fields=[PSCustomObject]@{User="";API_ID="";API_Key="";AECurrency="BTC";Penalty=3}
            SetupFields=[PSCustomObject]@{User="Enter your MiningDutch username";API_ID="Enter your MiningDutch account ID";API_Key = "Enter your MiningDutch API key";AECurrency = "Enter your MiningDutch autoexchange currency"}
            Currencies=@("GLT")
            Autoexchange=$true
        }
        "MiningPoolHub" = [PSCustomObject]@{
            Fields=[PSCustomObject]@{User="";API_ID="";API_Key="";AECurrency="BTC";Penalty=12}
            SetupFields=[PSCustomObject]@{User="Enter your MiningPoolHub username";API_ID="Enter your MiningPoolHub user ID";API_Key = "Enter your MiningPoolHub API key";AECurrency = "Enter your MiningPoolHub autoexchange currency"}
            Currencies=@()
            Autoexchange=$true
        }
        "MiningPoolHubCoins" = [PSCustomObject]@{
            Fields=[PSCustomObject]@{User="";API_ID="";API_Key="";AECurrency="BTC"}
            SetupFields=[PSCustomObject]@{User="Enter your MiningPoolHub username";API_ID="Enter your MiningPoolHub user ID";API_Key = "Enter your MiningPoolHub API key";AECurrency = "Enter your MiningPoolHub autoexchange currency"}
            Currencies=@()
            Autoexchange=$true
        }
        "MiningPoolOvh" = [PSCustomObject]@{
            Fields=[PSCustomObject]@{API_Key="";Password="x"}
            SetupFields=[PSCustomObject]@{API_Key="Enter your mining-pool.ovh API-Key";Password="Enter your mining-pool.ovh password"}
            Currencies=@("VRM")
        }
        "MiningRigRentals" = [PSCustomObject]@{
            Fields=[PSCustomObject]@{User="";API_Key="";API_Secret="";EnableMining="0";UseWorkerName="";ExcludeWorkerName="";EnableAutoCreate="0";AutoCreateMinProfitPercent="50";AutoCreateMinCPUProfitBTC="0.00001";AutoCreateMaxMinHours="24";AutoUpdateMinPriceChangePercent="3";AutoCreateAlgorithm="";EnableAutoUpdate="0";EnableAutoExtend="0";AutoExtendTargetPercent="100";AutoExtendMaximumPercent="30";AutoBonusExtendForHours="0";AutoBonusExtendByHours="0";EnableUpdateTitle="1";EnableUpdateDescription="1";EnableAutoPrice="1";EnableMinimumPrice="1";EnablePowerDrawAddOnly="0";AutoPriceModifierPercent="0";EnableUpdatePriceModifier="0";PriceBTC="0";PriceFactor="2.0";PowerDrawFactor="1.0";MinHours="3";MaxHours="48";PriceCurrencies="BTC";Title = "%algorithmex% mining with RainbowMiner rig %rigid%";Description = "Autostart mining with RainbowMiner (https://rbminer.net) on $(if ($IsWindows) {"Windows"} else {"Linux"}). This rig is idle and will activate itself, as soon, as you rent it. %workername%"}
            SetupFields=[PSCustomObject]@{User="Enter your MiningRigRentals username";API_Key="Enter your MiningRigRentals API key";API_Secret = "Enter your MiningRigRentals API secret key";UseWorkerName="Enter workernames to explicitly use (leave empty for all=default)";ExcludeWorkerName="Enter workernames to explicitly exclude (leave empty for none=default)";EnableAutoCreate="Automatically create MRR-rigs";EnableAutoUpdates="Automatically update MRR-rigs";EnableAutoExtend="Enable automatic extend when low average";AutoExtendTargetPercent="Set auto extension target (in percent of rented hashrate)";AutoExtendMaximumPercent="Set maximum extension (in percent of rented time)";AutoBonusExtendForHours="Enter amount of hours, that you want to reward with an automatic bonus extension (e.g. 24)";AutoBonusExtendByHours="Enter bonus extension in hours per rented AutoBonusExtendForHours (e.g. 1)";AutoCreateMinProfitPercent="Enter minimum profitability in percent compared to current best profit, for full rigs to be autocreated on MRR";AutoCreateMinCPUProfitBTC="Enter minimum one-day revenue in BTC, for a CPU-only rig to be autocreated on MRR";AutoCreateMaxMinHours="Enter the maximum hours for minimum rental time, for a rig to be autocreated on MRR";AutoUpdateMinPriceChangePercent="Enter the minimum price change in percent, for a rig to be updated on MRR";AutoCreateAlgorithm="Algorithms that should always be autocreated on MRR, even if below the other limits";EnableAutoPrice="Enable MRR automatic prices";EnableMinimumPrice="Set MRR automatic minimum price";AutoPriceModifierPercent="Autoprice modifier in percent (e.g. +10 will increase all suggested prices by 10%, allowed range -30 .. 30)";EnableUpdatePriceModifier="Enable automatic update of price modifier (can be set globally in pools.config.txt and for each algorithm in algorithms.config.txt parameter MRRPriceModifierPercent)";PriceBTC="Fixed price in BTC (used, if EnableAutoPrice=0 or if the value is greater than the PriceFactor x revenue)";PriceFactor="Enter profit multiplicator: price = rig's average revenue x this multiplicator";PowerDrawFactor="Enter powerdraw multiplicator (only if UsePowerPrice is enabled): minimum price = minimum price + (miner's power draw - rig's average power draw) 24 / 1000 x powerdrawprice x this multiplicator";EnablePowerDrawAddOnly="Add the powerdraw cost difference only, if it is greater than 0";EnableUpdateTitle="Enable automatic updating of rig titles (disable, if you prefer to edit your rig titles online at MRR)";EnableUpdateDescription="Enable automatic updating of rig descriptions (disable, if you prefer to edit your rig descriptions online at MRR)";PriceCurrencies="List of accepted currencies (must contain BTC)";MinHours="Minimum rental time in hours (min. 3)";MaxHours="Maximum rental time in hours (min. 3)";EnableMining="Enable switching to MiningRigRentals, even it is not rentend (not recommended)";Title="Title for autocreate, make sure it contains %algorithm% or %algorithmex% or %display, and %rigid% (values will be substituted like that: %algorithm% with algorithm, %algorithmex% with algorithm plus coin info if needed, %coininfo% with eventual coin info, %display% with MRR specific display title, %rigid% with an unique rigid, %workername% with the workername, %type% with either CPU or GPU, %typecpu% with CPU or empty, %typegpu% with GPU or empty)";Description="Description for autocreate, %workername% will be substituted with rig's workername. Make sure you add [%workername%] (including the square brackets!)"}
            Currencies=@()
            Autoexchange=$true
        }
        "MintPond" = [PSCustomObject]@{
            Currencies=@("XZC")
        }
        "MoneroOcean" = [PSCustomObject]@{
            Fields=[PSCustomObject]@{Password="x"}
            SetupFields=[PSCustomObject]@{Password="Enter your MoneroOcean password (eMail or Password)"}
            Currencies=@("XMR")
        }
        "Nanopool" = [PSCustomObject]@{
            Fields=[PSCustomObject]@{Email=""}
            SetupFields=[PSCustomObject]@{Email="Enter your eMail-Address"}
            Currencies=@("ETH")
        }
        "NiceHash" = [PSCustomObject]@{
            Fields=[PSCustomObject]@{OrganizationID="";API_Key="";API_Secret="";StatAverage="Minute_5";MaxMarginOfError="0"}
            SetupFields=[PSCustomObject]@{OrganizationID="Enter your Nicehash Organization ID (pulls and adds NH balance)";API_Key = "Enter your Nicehash API key (pulls and adds NH balance)";API_Secret = "Enter your Nicehash API secret (pulls and adds NH balance)"}
            Currencies=@("BTC")
            Autoexchange=$true
        }
        "NLPool" = [PSCustomObject]@{
            Fields=[PSCustomObject]@{Penalty=16}
            Currencies=@("BTC")
            Autoexchange=$true
            Yiimp=$true
        }
        "NLPoolCoins" = [PSCustomObject]@{
            Currencies=@("BTC")
            Autoexchange=$true
            Yiimp=$true
        }
        "Poolin" = [PSCustomObject]@{
            Currencies=@("ETH","RVN")
        }
        "Poolium" = [PSCustomObject]@{
            Fields=[PSCustomObject]@{API_Key="";Password="x"}
            SetupFields=[PSCustomObject]@{API_Key="Enter your poolium.win API-Key";Password="Enter your poolium.win password"}
            Currencies=@("VRM")
        }
        "PoolSexy" = [PSCustomObject]@{
            Currencies=@("DBIX")
        }
        "Ravenminer" = [PSCustomObject]@{
            Currencies=@("RVN")
        }
        "Ravepool" = [PSCustomObject]@{
            Currencies=@("GRIMM")
        }
        "RPlant" = [PSCustomObject]@{
            Currencies=@("BIN","CPU","MBC")
        }
        "SoloPool" = [PSCustomObject]@{
            Currencies=@("ETC","ETH","SAFE","SEL","XMR","XWP","ZERO")
        }
        "SparkPool" = [PSCustomObject]@{
            Currencies=@("ETH","GRIN","BEAM","XMR")
        }
        "Sunpool" = [PSCustomObject]@{
            Currencies=@("GRIMM","BEAM","ATOMI")
        }
        "SupportXmr" = [PSCustomObject]@{
            Currencies=@("XMR")
        }
        "SuprNova" = [PSCustomObject]@{
            Currencies=@("BTG")
        }
        "Tecracoin" = [PSCustomObject]@{
            Currencies=@("TCR")
        }
        "UUpool" = [PSCustomObject]@{
            Currencies=@("VOLLAR")
        }
        "ZergPool" = [PSCustomObject]@{
            Fields=[PSCustomObject]@{Penalty=12}
            Currencies=@("BTC")
            Autoexchange=$true
            Yiimp=$true
        }
        "ZergPoolCoins" = [PSCustomObject]@{
            Fields=[PSCustomObject]@{AECurrency="";Penalty=12}
            SetupFields=[PSCustomObject]@{AECurrency="Optionally define your autoexchange currency symbol"}
            Currencies=@("BTC")
            Autoexchange=$true
            Yiimp=$true
        }
        "ZergPoolCoinsParty" = [PSCustomObject]@{
            Fields=[PSCustomObject]@{AllowZero="1";PartyPassword="";AECurrency="";Penalty=12}
            SetupFields=[PSCustomObject]@{AECurrency="Optionally define your autoexchange currency symbol";PartyPassword="Enter your Party password"}
            Currencies=@("BTC")
            Autoexchange=$true
            Yiimp=$true
        }
        "ZergPoolCoinsSolo" = [PSCustomObject]@{
            Fields=[PSCustomObject]@{AllowZero="1";AECurrency="";Penalty=12}
            SetupFields=[PSCustomObject]@{AECurrency="Optionally define your autoexchange currency symbol"}
            Currencies=@("BTC")
            Autoexchange=$true
            Yiimp=$true
        }
        "ZergPoolParty" = [PSCustomObject]@{
            Fields=[PSCustomObject]@{AllowZero="1";PartyPassword="";Penalty=12}
            SetupFields=[PSCustomObject]@{PartyPassword="Enter your Party password"}
            Currencies=@("BTC")
            Autoexchange=$true
            Yiimp=$true
        }
        "ZergPoolSolo" = [PSCustomObject]@{
            Fields=[PSCustomObject]@{AllowZero="1";Penalty=12}
            Currencies=@("BTC")
            Autoexchange=$true
            Yiimp=$true
        }
        "Zpool" = [PSCustomObject]@{
            Fields=[PSCustomObject]@{Penalty=16}
            Currencies=@("BTC")
            Autoexchange=$true
            Yiimp=$true
        }
}
