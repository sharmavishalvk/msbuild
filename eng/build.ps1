#
# Copyright (c) .NET Foundation and contributors. All rights reserved.
# Licensed under the MIT license. See LICENSE file in the project root for full license information.
#

param(
    [string]$vsDropName = "",
    [string]$vsBranch = "",
    [string]$vsDropAccessToken = "",

    [Parameter(ValueFromRemainingArguments=$true)][String[]]$ExtraParameters
)

. (Join-Path $PSScriptRoot "build-utils.ps1")

function Build-OptProfData() {
    $insertionDir = Join-Path $VSSetupDir "Insertion"

    $optProfDir = Join-Path $ArtifactsDir "OptProf\$configuration"
    $optProfDataDir = Join-Path $optProfDir "Data"
    $optProfBranchDir = Join-Path $optProfDir "BranchInfo"

    $optProfConfigFile = Join-Path $EngRoot "config\OptProf.json"
    $optProfToolDir = Get-PackageDir "RoslynTools.OptProf"
    $optProfToolExe = Join-Path $optProfToolDir "tools\roslyn.optprof.exe"

    Write-Host "Generating optimization data using '$optProfConfigFile' into '$optProfDataDir'"
    Exec-Console $optProfToolExe "--configFile $optProfConfigFile --insertionFolder $insertionDir --outputFolder $optProfDataDir"

    # Write out branch we are inserting into
    Create-Directory $optProfBranchDir
    $vsBranchFile = Join-Path $optProfBranchDir "vsbranch.txt"
    $vsBranch >> $vsBranchFile

    # Set VSO variables used by MicroBuildBuildVSBootstrapper pipeline task
    $manifestList = [string]::Join(',', (Get-ChildItem "$insertionDir\*.vsman"))

    Write-Host "##vso[task.setvariable variable=VisualStudio.SetupManifestList;]$manifestList"
}

Build-OptProfData

Invoke-Expression ".\common\build.ps1 $ExtraParameters"
if($LASTEXITCODE -ne 0) { throw "Failed to build" }
