param($installPath, $toolsPath, $package, $project)

Import-Module (Join-Path $toolsPath "MSBuild.psm1")

function Delete-Temporary-File 
{
    Write-Host "Delete temporary file"

    $project.ProjectItems | Where-Object { $_.Name -eq 'Delete_Me.txt' } | Foreach-Object {
        Remove-Item ( $_.FileNames(0) )
        $_.Remove() 
    }
}

function Install-Targets ( $project, $importFile )
{
    Write-Host ("Installing Targets file import into project " + $project.Name)

    $buildProject = Get-MSBuildProject

    $buildProject.Xml.Imports | Where-Object { $_.Project -match "GenerateCommonAssemblyInfo.targets" } | foreach-object {
        Write-Host ("Removing old import:      " + $_.Project)
        $buildProject.Xml.RemoveChild($_) 
    }

    Write-Host ("Import will be added for: " + $importFile)
    $target = $buildProject.Xml.AddImport( $importFile )

    $project.Save() 

    Write-Host ("Import added!")
}

function Copy-MSBuildTasks ( $project ) 
{
    $solutionDir = Get-SolutionDir
    $tasksToolsPath = (Join-Path $solutionDir "Build")

    if(!(Test-Path $tasksToolsPath)) {
        mkdir $tasksToolsPath | Out-Null
    }

	if(!(Test-Path "$toolsPath\GenerateCommonAssemblyInfo.targets")) {
		Write-Host "Copying Targets files to $tasksToolsPath"
		Copy-Item "$toolsPath\GenerateCommonAssemblyInfo.targets" $tasksToolsPath -Force | Out-Null
	}

    Write-Host "Don't forget to commit the Build folder"
    return '$(SolutionDir)\Build'
}

function Main
{
    Delete-Temporary-File
    $taskPath = Copy-MSBuildTasks $project
    
    Install-Targets $project '$(SolutionDir)\Build\GenerateCommonAssemblyInfo.targets'
}

Main

