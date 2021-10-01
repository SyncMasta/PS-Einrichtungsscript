cls
echo ""
echo ""
echo "**********************************************************"
echo "****           WINDOWS PC Einrichtungstool            ****"
echo "****          (c) 2020-2021 Tobias Wissen             ****"
echo "**********************************************************"
echo ""
echo ""
echo ""
echo "**********************************************************"
echo "****                Admin Benutzer                    ****"
echo "****            Passwort läuft nie ab                 ****"
echo "**********************************************************"
echo ""
$askPE = read-Host -Prompt "Sollen das Kennwort des lokalen Admin nie ablaufen (J/N)"
if($askPE -eq "J") {
	$UserAccount = Get-LocalUser -Name "admin"
	$UserAccount | Set-LocalUser -PasswordNeverExpires:$True 
	$UserAccount | Set-LocalUser -AccountNeverExpires:$True
}

echo ""
echo "**********************************************************"
echo "****                WINDOWS UPDATES                   ****"
echo "****                                                  ****"
echo "****    Bitte Fragen mit J (Y) oder A beantworten!    ****"
echo "**********************************************************"
echo ""
echo ""
$computername = $env:computername

$askWU = read-Host -Prompt "Sollen Windows Updates installiert werden? (J/N)"
if($askWU -eq "J") {
    Install-module PSWindowsUpdate
    Import-Module PSWindowsUpdate
    Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d
    Install-WindowsUpdate -AcceptAll -Install  | Out-File ".\wsuslogs\$(get-date -f yyyy-MM-dd)-$computername-WindowsUpdate.log" -force 
}

echo ""
echo ""
echo "**********************************************************"
echo "****                RDP, .NET & SMB1                  ****"
echo "**********************************************************"
echo ""
echo ""

$askRDP = read-Host -Prompt "Sollen RDP, .NET und SMB1 installiert werden? (J/N)"
if($askRDP -eq "J") {
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
    Enable-NetFirewallRule -DisplayGroup "Remotedesktop"

    $Location = Get-Location
    Push-location "\sources\sxs"

    DISM /Online /Add-Capability /CapabilityName:NetFx3~~~~ /Source:$Location
    Enable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -All -NoRestart
	
	powercfg /hibernate off
    Pop-Location
}

echo ""
echo ""
echo "**********************************************************"
echo "****               Windows aktivieren                 ****"
echo "**********************************************************"
echo ""
echo ""
$askWinaktivieren = read-Host -Prompt "Soll Windows aktiviert werden? (J/N)"
if($askWinaktivieren -eq "J") {
	$askWinaktivieren = read-Host -Prompt "Bitte Windows-Key eintragn (xxxxx-xxxxx-xxxxx-xxxxx-xxxxx)"
	slmgr /ipk $askWinaktivieren
	slmgr /ato
}


echo ""
echo ""
echo "**********************************************************"
echo "****            Netzwerk-Einstellungen                ****"
echo "**********************************************************"
echo ""
echo ""
$askIP = read-Host -Prompt "Sollen die Netzwerk-Einstellungen angepasst werden? (J/N)"
if($askIP -eq "J") {

    Get-NetAdapter -physical | where status -eq 'up' | Select Name
    $NetAdapter = Read-Host -Prompt "Geben Sie den Wert für Network-InterfaceAlias ein"
    
	$deacIPv6 = Read-Host -Prompt "Soll IPv6 deaktiviert werden? (J/N) Default: Ja"
    $newIP = Read-Host -Prompt "Bitte neue Netzwerk-Addresse eingeben. Default: 192.168.1.10"
	$newSubnet = Read-Host -Prompt "Bitte neue Subnetz-Prefix eingeben. Default: 24 (255.255.255.0)"
	$newGateway = Read-Host -Prompt "Bitte neue Gateway eingeben. Default: 192.168.1.254"
	$newDNS1 = Read-Host -Prompt "Bitte neuen DNS1 eingeben. Default: 192.168.1.254"
	$newDNS2 = Read-Host -Prompt "Bitte neuen DNS2 eingeben. Default: keiner"
	$newDNSSuffix = Read-Host -Prompt "Bitte neuen DNS-Suffix eingeben. Default: firm.local"
	
    if ($newIP -eq "") {$newIP = "192.168.1.10"}
	if ($newSubnet -eq "") {$newSubnet = "24"}
	if ($newGateway -eq "") {$newGateway = "192.168.1.254"}
	if ($newDNS1 -eq "") {$newDNS1 = "192.168.1.254"}
	if ($newDNS2 -eq "") {$newDNS2 = ""}
	if ($newDNSSuffix -eq "") {$newDNSSuffix = "firm.local"}
	if ($deacIPv6 -eq "") {Disable-NetAdapterBinding –InterfaceAlias $NetAdapter –ComponentID ms_tcpip6}
	if ($deacIPv6 -eq "J") {Disable-NetAdapterBinding –InterfaceAlias $NetAdapter –ComponentID ms_tcpip6}

    New-NetIPAddress –InterfaceAlias $NetAdapter –IPAddress $newIP –PrefixLength $newSubnet -DefaultGateway $NewGateway
    Set-DnsClientGlobalSetting -SuffixSearchList @($newDNSSuffix)
    Set-DnsClientServerAddress -InterfaceAlias $NetAdapter -ServerAddresses ($newDNS1,$newDNS2)

    echo ""
    echo ""
    echo "Sie müssen nun die Konfiguration des Netzwerk-Ports ändern oder den Port wechseln"
    $ask_NW_Tausch = Read-Host -Prompt "Haben Sie den NW-Port getauscht? (J/N)"
    if($ask_NW_Tausch -eq "N") {
            echo "Bitte Netzwerk-Einstellungen oder -Verbindungen ändern!"
            $ask_NW_Tausch = Read-Host -Prompt "Haben Sie die Änderungen druchgeführt? (J/N)"
            if($ask_NW_Tausch -eq "N") {
                echo "Das Script kann nicht weiter ausgeführt werden."
                echo "Das Script wird beendet."
                Exit-PSHostProcess
            }
    }

}

echo ""
echo ""
echo "**********************************************************"
echo "****               Domänen Beitritt                   ****"
echo "**********************************************************"

$askDOM = read-Host -Prompt "Sollen der PC einer Domäne beitreten? (J/N)"
if($askDOM -eq "J") {

    $newPCName= Read-Host -Prompt "Bitte neuen PC Namen vergeben"
	
	$newDomain = Read-Host -Prompt "Bitte neuen Domain-Namen. Default: firm.local"
	$newDomainAdmin = Read-Host -Prompt "Bitte neuen Domain-Administrator Namen MIT Domain-Kennung. Default: firm\administrator"
	$newDomainOUPath = Read-Host -Prompt "Bitte neuen OU Path ein, in dem der PC einsortiert werden soll. Default: OU=Computer,DC=firm,DC=local"
	
    if ($newDomain -eq "") {$newDomain = "firm.local"}
	if ($newDomainAdmin -eq "") {$newDomainAdmin = "firm\administrator"}
	if ($newDomainOUPath -eq "") {$newDomainOUPath = "OU=Computer,DC=firm,DC=local"}
	
   
	Add-Computer -DomainName $newDomain  -Credential $newDomainAdmin -PassThru -Force -Verbose -NewName $NewPCName -OUPath $newDomainOUPath;
	
	 $ADJoinReboot = Read-Host -Prompt "Soll der PC neugestartet werden? (J/N)"
    if($ADJoinReboot -eq "J") { 
      Restart-Computer
    }
    
}
