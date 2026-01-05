# ==============================
# TrackerBoard Full Automation
# ==============================

$EthernetName = "Ethernet"
$LocalIP      = "192.168.32.10"
$Gateway      = "192.168.32.1"
$Mask         = "255.255.255.0"
$TargetMAC    = "06-e7-a6-b8-02-27"

Write-Host "=== STEP 1: Configure Ethernet IP ==="

# Remove existing IPv4 addresses
Get-NetIPAddress -InterfaceAlias $EthernetName -AddressFamily IPv4 -ErrorAction SilentlyContinue |
Remove-NetIPAddress -Confirm:$false

# Set static IP
New-NetIPAddress `
    -InterfaceAlias $EthernetName `
    -IPAddress $LocalIP `
    -PrefixLength 24 `
    -DefaultGateway $Gateway

Write-Host "Ethernet set to $LocalIP"
Start-Sleep 2

# ==============================
Write-Host "=== STEP 2: Find Sniffer IP by MAC ==="

# Populate ARP table
ping 192.168.32.1 -n 1 > $null

$Candidates = arp -a | Select-String $TargetMAC

if (-not $Candidates) {
    Write-Error "Sniffer MAC not found in ARP table"
    exit 1
}

$SnifferIP = $null

foreach ($entry in $Candidates) {
    $ip = ($entry -split "\s+")[1]

    Write-Host "Testing $ip ..."
    if (Test-Connection -ComputerName $ip -Count 1 -Quiet) {
        $SnifferIP = $ip
        break
    }
}

if (-not $SnifferIP) {
    Write-Error "No responding sniffer found"
    exit 1
}

Write-Host "Sniffer found at $SnifferIP"

# ==============================
Write-Host "=== STEP 3: Set Sniffer Static IP (192.168.32.2) ==="

$Body = @{
    eth0 = @{
        ipv4 = "192.168.32.2"
        gw   = "192.168.32.1"
        mask = "255.255.255.0"
        dns1 = "192.168.32.1"
        dns2 = "8.8.8.8"
    }
} | ConvertTo-Json

try {
    Invoke-RestMethod `
        -Uri "http://$SnifferIP/config" `
        -Method POST `
        -ContentType "application/json" `
        -Body $Body

    Write-Host "Sniffer successfully configured to 192.168.32.2"
}
catch {
    Write-Error "Failed to configure sniffer"
}
