## Root Certification 생성 ##
$cert = New-SelfSignedCertificate -Type Custom -KeySpec Signature `
-Subject "CN=P2SRoot1" -KeyExportPolicy Exportable `
-HashAlgorithm sha256 -KeyLength 2048 `
-CertStoreLocation "Cert:\CurrentUser\My" -KeyUsageProperty Sign -KeyUsage CertSign

$P2SRootCertName="P2SRootCert"
$filePathForCert="C:\P2SRootCert.cer"
$cert=New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($filePathForCert)
$CertBase64 = [system.convert]::ToBase64String($cert.RawData)
$CertBase64


## Client Certification 생성 ##
New-SelfSignedCertificate -Type Custom -DnsName P2SChildCert -KeySpec Signature `
-Subject "CN=ClientCert1" -KeyExportPolicy Exportable `
-HashAlgorithm sha256 -KeyLength 2048 `
-CertStoreLocation "Cert:\CurrentUser\My" `
-Signer $cert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")

## Client Certification 생성 (반복문) ##
for($i=1; $i -lt 5; $i++){
    New-SelfSignedCertificate -Type Custom -DnsName P2SChildCert -KeySpec Signature `
    -Subject "CN=ClientCert$i" -KeyExportPolicy Exportable `
    -HashAlgorithm sha256 -KeyLength 2048 `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -Signer $cert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")
}


## Client Certification 해지 ##
$RevokedThumbprint = "" # Thumbprint 배열

for($i=1; $i -lt 10; $i++){
    $RevokedClientCert = "P2SClient$i"
    Add-AzVpnClientRevokedCertificate -VpnClientRevokedCertificateName $RevokedClientCert `
    -VirtualNetworkGatewayName $GWName -ResourceGroupName $RG `
    -Thumbprint $RevokedThumbprint[$i]
}

