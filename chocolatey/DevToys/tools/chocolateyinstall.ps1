﻿$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url64      = 'https://github.com/veler/DevToys/releases/download/v1.0.4.0/64360VelerSoftware.DevToys_1.0.4.0_neutral___j80j2txgjg9dj.Msixbundle'
$checksum64 = '8d97757333df6337c27166b8a6bf95d1160e0856a91867ce3487f2598ad9c2aa'
$WindowsVersion  = [Environment]::OSVersion.Version;
$InstallDir = Split-Path $MyInvocation.MyCommand.Definition;
$AppxPackageName = "64360VelerSoftware.DevToys"

if ($WindowsVersion.Major -lt "10") {
  throw "This package requires Windows 10.";
};

#The .msixbundle format is not supported on Windows 10 version 1709 and 1803. https://docs.microsoft.com/en-us/windows/msix/msix-1709-and-1803-support
$IsCorrectBuild=[Environment]::OSVersion.Version.Build;
if ($IsCorrectBuild -lt "18362") {
  throw "This package requires at least Windows 10 version 1903/OS build 18362.x.";
};

$PackageArgs = @{
  packageName   = $env:ChocolateyPackageName
  unzipLocation = $toolsDir
  url64bit      = $url64

  softwareName  = 'DevToys'

  checksum64    = $checksum64
  checksumType64= 'sha256'

  fileFullPath = Join-Path $InstallDir $([IO.Path]::GetFileName($Url64))
}

Get-ChocolateyWebFile @PackageArgs

if ((Get-AppxPackage -name $AppxPackageName).Version -Match $Version) {
  if($env:ChocolateyForce) {
    #You can't install the same version of an appx package, you need to remove it first
    Write-Host Removing already installed version first. ;
    Get-AppxPackage -Name $AppxPackageName | Remove-AppxPackage;
  } else {
    Write-Host The $Version version of the package is already installed. If you want to reinstall use --force ;
    return;
  };
};

Add-AppxPackage -Path $PackageArgs.fileFullPath
