properties {
	$pwd = Split-Path $psake.build_script_file	
	$build_directory  = "$pwd\output\condep-dsl-operations"
	$configuration = "Release"
	$preString = "beta"
	$releaseNotes = ""
}
 
include .\..\tools\psake_ext.ps1

function GetNugetAssemblyVersion($assemblyPath) {
	$versionInfo = Get-Item $assemblyPath | % versioninfo

	return "$($versionInfo.FileMajorPart).$($versionInfo.FileMinorPart).$($versionInfo.FileBuildPart)-$preString"
}

task default -depends Build-All, Pack-All
task ci -depends Build-All, Pack-All

task Build-All -depends Clean, Build, Create-BuildSpec-ConDep-Dsl-Operations, Create-BuildSpec-ConDep-Dsl-Operations-Aws
task Pack-All -depends Pack-ConDep-Dsl-Operations, Pack-ConDep-Dsl-Operations-Aws

task Build {
	Exec { msbuild "$pwd\..\src\condep-dsl-operations.sln" /t:Build /p:Configuration=$configuration /p:OutDir=$build_directory /p:GenerateProjectSpecificOutputFolder=true}
}

task Clean {
	Write-Host "Cleaning Build output"  -ForegroundColor Green
	Remove-Item $build_directory -Force -Recurse -ErrorAction SilentlyContinue
}

task Create-BuildSpec-ConDep-Dsl-Operations {
	Generate-Nuspec-File `
		-file "$build_directory\condep.dsl.operations.nuspec" `
		-version $(GetNugetAssemblyVersion $build_directory\ConDep.Dsl.Operations\ConDep.Dsl.Operations.dll) `
		-id "ConDep.Dsl.Operations" `
		-title "ConDep.Dsl.Operations" `
		-licenseUrl "http://www.con-dep.net/license/" `
		-projectUrl "http://www.con-dep.net/" `
		-description "ConDep is a highly extendable Domain Specific Language for Continuous Deployment, Continuous Delivery and Infrastructure as Code on Windows. This package contians all the default operations found in ConDep. For additional operations, look for ConDep.Dsl.Operations.Contrib." `
		-iconUrl "https://raw.github.com/torresdal/ConDep/master/images/ConDepNugetLogo.png" `
		-releaseNotes "$releaseNotes" `
		-tags "Continuous Deployment Delivery Infrastructure WebDeploy Deploy msdeploy IIS automation powershell remote" `
		-dependencies @(
			@{ Name="ConDep.Dsl"; Version="[3.0.18-beta,4)"},
			@{ Name="SlowCheetah.Tasks.Unofficial"; Version="1.0.0"}
		) `
		-files @(
			@{ Path="ConDep.Dsl.Operations\ConDep.Dsl.Operations.dll"; Target="lib/net40"}, 
			@{ Path="ConDep.Dsl.Operations\ConDep.Dsl.Operations.xml"; Target="lib/net40"}
		)
}

task Create-BuildSpec-ConDep-Dsl-Operations-Aws {
	Generate-Nuspec-File `
		-file "$build_directory\condep.dsl.operations.aws.nuspec" `
		-version $(GetNugetAssemblyVersion $build_directory\ConDep.Dsl.Operations.Aws\ConDep.Dsl.Operations.Aws.dll) `
		-id "ConDep.Dsl.Operations.Aws" `
		-title "ConDep.Dsl.Operations.Aws" `
		-licenseUrl "http://www.con-dep.net/license/" `
		-projectUrl "http://www.con-dep.net/" `
		-description "ConDep is a highly extendable Domain Specific Language for Continuous Deployment, Continuous Delivery and Infrastructure as Code on Windows. This package contians operations for interacting with Amazon AWS, like bootstrapping Windows servers." `
		-iconUrl "https://raw.github.com/torresdal/ConDep/master/images/ConDepNugetLogo.png" `
		-releaseNotes "$releaseNotes" `
		-tags "Amazon AWS VPC Bootstrap Bootstrapping Continuous Deployment Delivery Infrastructure WebDeploy Deploy msdeploy IIS automation powershell remote" `
		-dependencies @(
			@{ Name="ConDep.Dsl"; Version="[3.0.18-beta,4)"},
			@{ Name="ConDep.Dsl.Operations"; Version="[$(GetNugetAssemblyVersion $build_directory\ConDep.Dsl.Operations\ConDep.Dsl.Operations.dll),4)"},
			@{ Name="AWSSDK"; Version="2.2.3.0"}
		) `
		-files @(
			@{ Path="ConDep.Dsl.Operations.Aws\ConDep.Dsl.Operations.Aws.dll"; Target="lib/net40"}, 
			@{ Path="ConDep.Dsl.Operations.Aws\ConDep.Dsl.Operations.Aws.xml"; Target="lib/net40"}
		)
}

task Pack-ConDep-Dsl-Operations {
	Exec { nuget pack "$build_directory\condep.dsl.operations.nuspec" -OutputDirectory "$build_directory" }
}

task Pack-ConDep-Dsl-Operations-Aws {
	Exec { nuget pack "$build_directory\condep.dsl.operations.aws.nuspec" -OutputDirectory "$build_directory" }
}