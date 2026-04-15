# ping-sweep.ps1
param (
    [Parameter(Mandatory=$true)]
    [string]$Cidr
)

$liveHosts = @()
$deadHosts = @()

function Ping-Host {
    param (
        [string]$Ip
    )
    
    try {
        $pingResult = Test-Connection -ComputerName $Ip -Count 1 -ErrorAction SilentlyContinue
        return $pingResult -ne $null
    } catch {
        return $false
    }
}

$network = [ipaddress::ParseDnsRecord($Cidr)].Network
$subnetMask = [ipaddress::ParseDnsRecord($Cidr)].SubnetMask

for ($i = 1; $i -le $subnetMask.GetAddressBytes()[3]; $i++) {
    $ip = "$network.$i"
    if (Ping-Host $ip) {
        $liveHosts += $ip
    } else {
        $deadHosts += $ip
    }
}

# Save results to CSV
$csvPath = "ping_sweep_results.csv"
$csvContent = @()
$csvContent += New-Object PSObject -Property @{ IP = "IP Address"; Status = "Status" }
foreach ($host in $liveHosts) {
    $csvContent += New-Object PSObject -Property @{ IP = $host; Status = "Live" }
}
foreach ($host in $deadHosts) {
    $csvContent += New-Object PSObject -Property @{ IP = $host; Status = "Dead" }
}

$csvContent | Export-Csv -Path $csvPath -NoTypeInformation
Write-Output "Results saved to $csvPath"
