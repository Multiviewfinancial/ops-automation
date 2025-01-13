param(
    [Parameter(Mandatory = $true)][string]$ProductPackage,
    [Parameter(Mandatory = $true)][string]$AWSAccessKey,
    [Parameter(Mandatory = $true)][string]$AWSSecretKey,
    [Parameter()][string]$OutputFolder
)

if ( !($ProductPackage) ) {
    Write-Error "ProductPackage not specified" -ErrorAction stop
}
if ( !($AWSAccessKey) ) {
    Write-Error "AWSAccessKey not specified" -ErrorAction stop
}
if ( !($AWSSecretKey) ) {
    Write-Error "AWSSecretKey not specified" -ErrorAction stop
}
if ( !($OutputFolder) ) {
    Write-Output "OutputFolder not specified, will default to D:\MVCS\admin\updates\downloads"
    $OutputFolder = "D:\MVCS\admin\updates\downloads"
}

Set-DefaultAWSRegion -Region us-east-1
Set-AWSCredential -AccessKey $AWSAccessKey -SecretKey $AWSSecretKey 

$SourceBucket = "multiviewcorp-multiview-prod-customer-artifacts-bucket"
$KeyPath = "core/Upgrades/Internal"

#Check to make sure output folder exists
if (!(Test-Path -Path $OutputFolder)) {
  Write-Output "$OutputFolder does not exist. Creating it now."
  mkdir $OutputFolder
}
#Get upgrade package from S3 if not on disk
if (!(Test-Path -Path "$OutputFolder\$ProductPackage")) {
  Write-Output "Getting file $KeyPath/$ProductPackage from S3"
  try {
    Read-S3Object -BucketName $SourceBucket -Key "$KeyPath/$ProductPackage" -File "$OutputFolder\$ProductPackage"
  }
  catch {
    Write-Error "Failed to download file from S3. $_.Exception.Message" -ErrorAction stop
    exit 1
  }
  Write-Output "Successfully downloaded $ProductPackage from S3"
}
else {
  Write-Output "$ProductPackage already exists at $OutputFolder\$ProductPackage"
}
exit 0