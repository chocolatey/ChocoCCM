[CmdletBinding()]
param(
    [Parameter()]
    [string[]]
    $ScriptsToSign,

    [Parameter()]
    [string]
    $TimeStampServer,

    [Parameter(ParameterSetName = "File")]
    [string]
    $CertificatePath,

    [Parameter(ParameterSetName = "File")]
    [string]
    $CertificatePassword,

    [Parameter()]
    [string]
    $CertificateAlgorithm,

    [Parameter(ParameterSetName = "Store")]
    [string]
    $CertificateSubjectName
)

$cert = if ($CertificatePath) {
    New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($CertificatePath, $CertificatePassword)
}
else {
    Get-ChildItem Cert:\LocalMachine\My | Where-Object Subject -Like "*$CertificateSubjectName*"
}

Set-AuthenticodeSignature -FilePath $ScriptsToSign -Certificate $cert -TimestampServer $TimeStampServer -IncludeChain NotRoot -HashAlgorithm $CertificateAlgorithm
