#判断当前上下文环境中是否装在了SharePoint的Powershell环境，如果没有装载，则装载到当前运行环境。适合在使用SharePoint Powershell的脚本中调用。
$Snapin = get-PSSnapin | Where-Object {$_.Name -eq 'Microsoft.SharePoint.Powershell'}
if($Snapin -eq $null){
    Write-Output -InputObject "Loading SharePoint Powershell Snapin"
	try
	{
    	Add-PSSnapin "Microsoft.SharePoint.Powershell"
		Write-Output -InputObject "Loaded SharePoint PowerShell Snapin"
	}
	catch
	{
		$(throw "There was an error loading SharePoint PowerShell Snapin in LoadSharePointPowershell.ps1")
		exit
	}
}

$solutionName = "ShuiShan.S2.OrganizationChart.wsp";
$p = Get-Location;
$spath = $p.Path + "/" + $solutionName;


$solution = Get-SPSolution $solutionName -ErrorAction Continue;

if ($solution -ne $null)
{
	if ($solution.Deployed)
	{
		Write-Output -InputObject "Prepare to update solution: $solutionName";
		Update-SPSolution -Identity $solution -LiteralPath $spath -GACDeployment;
		$solution = Get-SPSolution $solutionName;
		while($solution.JobExists)
		{
			start-sleep 1
			Write-Output -InputObject "Updating solution: $solutionName";
		}
		Write-Output -InputObject "Updated solution: $solutionName";
	}
	else
	{
		Write-Output -InputObject "Remove solution: $solutionName";
		Remove-SPSolution -Identity $solutionName -Force:$true -Confirm:$false;
		Write-Output -InputObject "Add solution: $solutionName";
		Add-SPSolution -LiteralPath $spath;
		Write-Output -InputObject "Added solution: $solutionName";
		Write-Output -InputObject "Prepare to install solution: $solutionName";
		$solution = Get-SPSolution $solutionName;
		Install-SPSolution -Identity $solution -AllWebApplications -Force -GACDeployment 
		$solution = Get-SPSolution $solutionName;
		while($solution.JobExists)
		{
			start-sleep 1
			Write-Output -InputObject "Installing solution: $solutionName";
		}
		Write-Output -InputObject "Installed solution: $solutionName";
	}
}
else
{
	Write-Output -InputObject "$solutionName is null.";
	
	Add-SPSolution -LiteralPath $spath;
	Write-Output -InputObject "Added solution: $solutionName";
	Write-Output -InputObject "Prepare to install solution: $solutionName";
	$solution = Get-SPSolution $solutionName;
	Install-SPSolution -Identity $solution -AllWebApplications -Force -GACDeployment 
	$solution = Get-SPSolution $solutionName;
	while($solution.JobExists)
	{
		start-sleep 1
		Write-Output -InputObject "Installing solution: $solutionName";
	}
	Write-Output -InputObject "Installed solution: $solutionName";
}