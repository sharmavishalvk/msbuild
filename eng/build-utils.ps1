
# Collection of powershell build utility functions that we use across our scripts.

Set-StrictMode -version 2.0
$ErrorActionPreference="Stop"

# Import Arcade functions
. (Join-Path $PSScriptRoot "common\tools.ps1")

$VSSetupDir = Join-Path $ArtifactsDir "VSSetup\$configuration"

function Get-VersionCore([string]$name, [string]$versionFile) {
    $name = $name.Replace(".", "")
    $name = $name.Replace("-", "")
    $nodeName = "$($name)Version"
    $x = [xml](Get-Content -raw $versionFile)
    $node = $x.SelectSingleNode("//Project/PropertyGroup/$nodeName")
    if ($node -ne $null) {
        return $node.InnerText
    }

    throw "Cannot find package $name in $versionFile"

}

# Return the version of the NuGet package as used in this repo
function Get-PackageVersion([string]$name) {
    return Get-VersionCore $name (Join-Path $EngRoot "Versions.props")
}

# Locate the directory where our NuGet packages will be deployed.  Needs to be kept in sync
# with the logic in Version.props
function Get-PackagesDir() {
    $d = $null
    if ($env:NUGET_PACKAGES -ne $null) {
        $d = $env:NUGET_PACKAGES
    }
    else {
        $d = Join-Path $env:UserProfile ".nuget\packages\"
    }

    Create-Directory $d
    return $d
}

# Locate the directory of a specific NuGet package which is restored via our main 
# toolset values.
function Get-PackageDir([string]$name, [string]$version = "") {
    if ($version -eq "") {
        $version = Get-PackageVersion $name
    }

    $p = Get-PackagesDir
    $p = Join-Path $p $name.ToLowerInvariant()
    $p = Join-Path $p $version
    return $p
}