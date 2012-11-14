param($installPath, $toolsPath, $package, $project)

Import-Module (Join-Path $toolsPath "MSBuild.psm1")

function Uninstall-Targets ( $project )
{
    Write-Host ("Uninstalling Targets file import from project " + $project.Name)

    $buildProject = Get-MSBuildProject

    $buildProject.Xml.Imports | Where-Object { $_.Project -match "GenerateCommonAssemblyInfo.targets" } | foreach-object {
        Write-Host ("Removing old import:      " + $_.Project)
        $buildProject.Xml.RemoveChild($_) 
    }

    $project.Save() 

    Write-Host ("Import removed!")
}

function Remove-MSBuildTasks ( $project ) 
{
    $solutionDir = Get-SolutionDir
    $tasksToolsPath = (Join-Path $solutionDir "Build")

    if(!(Test-Path $tasksToolsPath)) {
        return
    }

    Write-Host "Removing Targets files from $tasksToolsPath"
    Remove-Item "$tasksToolsPath\GenerateCommonAssemblyInfo.targets" | Out-Null
}

function Main
{
    Uninstall-Targets $project
    Remove-MSBuildTasks $project
}

Main
