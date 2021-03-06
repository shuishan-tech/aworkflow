############################################################
#   ShuiShan S2 deployment script.
#   Version: 1.0.0.1229
#   8/29/2014
#   http://www.shuishan-tech.com
#   Author: YangLiu@上海水杉网络科技有限公司
############################################################

#判断当前上下文环境中是否装在了SharePoint的Powershell环境，如果没有装载，则装载到当前运行环境。
$Snapin = get-PSSnapin | Where-Object {$_.Name -eq 'Microsoft.SharePoint.Powershell'}
if($Snapin -eq $null){
    Write-Host "Loading SharePoint Powershell Snapin" -ForegroundColor DarkGray
    try
    {
        Add-PSSnapin "Microsoft.SharePoint.Powershell"
        Write-Host "Loaded SharePoint PowerShell Snapin" -ForegroundColor DarkGray
    }
    catch
    {
        $(throw "There was an error loading SharePoint PowerShell Snapin")
        exit
    }
}

function Confirm-SeletedWSPs
{
    param([string]$title="Confirm",[string]$message="Sure to deploy the selected solutions?")
    $choiceYes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
    $choiceNo = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
    $choiceRetry = New-Object System.Management.Automation.Host.ChoiceDescription "&Redo", "Select solutions again"
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($choiceYes, $choiceNo, $choiceRetry)
    $result = $host.ui.PromptForChoice($title, $message, $options, 0)
    switch ($result)
    {
        0 
        {
            Return 0
        }

        1 
        {
            return 1
        }

        2
        {
            Main
        }
    }
}
 
# 获取当前目录下所有的wsp文件
# return：wsp文件列表数组
function GetWSPFils()
{
    $location = Get-Location
    Write-Host
    Write-Host "All solutions package under folder: $location" -ForegroundColor DarkGray
    $array = @()
    $arrayList = [System.Collections.ArrayList]$array
    Get-ChildItem -Filter *.wsp | foreach{
        $arrayList.Add($_.Name) | Out-Null
    }
    return $arrayList
}

# 入口函数
function Main()
{
    Write-Host
    Write-Host "Please input the web url which re-enable features:" -ForegroundColor Red
    $webUrl = Read-Host 
    
    $files = GetWSPFils
    # 显示当前文件夹下的所有wsp包索引值及名称
    $files | foreach{
        Write-Host $files.Indexof($_) $_ -ForegroundColor Yellow
    }
    
    
    Write-Host
    Write-Host "Please input number according the order of the wsps need to be deployed, e.g.: 1 0 2 5" -ForegroundColor Red
    $selectedWSPs = Read-Host 
    $slectedWSPArray = $selectedWSPs.Split(" ")
    Write-Host "Wsps selected and the order: " -ForegroundColor DarkGray
    $slectedWSPArray | foreach{
        Write-Host $_ $files[$_] -ForegroundColor Yellow
    }
    $result = Confirm-SeletedWSPs

    if ($result -eq 0)
    {
        # 1. 安装前准备，先倒序处理选择的解决方案包。
        $slectedWSPArrayLength = $slectedWSPArray.Length
        do
        {
            PrepareBeforeInstall -name $files[$slectedWSPArray[$slectedWSPArrayLength - 1]] -webUrl $webUrl
            $slectedWSPArrayLength--
        }
        while($slectedWSPArrayLength -gt 0)

        # 2. 按照选择顺序部署解决方案包
        $slectedWSPArray | foreach{
            SSInstallSolution -name $files[$_] -webUrl $webUrl
        }
    }
    
    Restart-Service SPAdminV4
    
    Read-Host
}


# 安装解决方案包之前的准备
# 1. 检查解决方案包是否存在当前场中。
# 2. 如果存在，则回收解决方案包。
# 3. 删除解决方案包。
function PrepareBeforeInstall()
{
    param (
        $name,
        $webUrl
    )
    #获取脚本执行的路径。
    $p = Get-Location;
    $spath = $p.Path + "/" + $name
    $solution = Get-SPSolution $name -ErrorAction SilentlyContinue
    Write-Host
    Write-Host "Prepare to install $name" -ForegroundColor Yellow
    #在当前场中找到解决方案。
    if ($solution -ne $null)
    {
        Write-Host "Solution existed in current farm" -ForegroundColor DarkCyan
        #解决方案已经部署过。
        if ($solution.Deployed)
        {
            Write-Host "Solution has been deployed in farm, need to be un-deployed firstly." -ForegroundColor DarkCyan
            #解决方案已经部署，需要先回收。
            SSUninstallSolution -name $name -webUrl $webUrl
        }

        #删除解决方案包。
        SSRemoveSolution($name)
    }
    else
    {
        #在当前场中未找到解决方案，输出提示信息。
        Write-Host "Solution not found in farm." -ForegroundColor DarkCyan
    }
    Write-Host "Deploy preparation for solution $name finished" -ForegroundColor Yellow
}

#回收解决方案包。
function SSUninstallSolution
{
    param (
        $name,
        $webUrl
    )
    $solution = Get-SPSolution $name -ErrorAction SilentlyContinue
    if ($solution -eq $null -or !$solution.Deployed)
    {
        Write-Host "No solution package need to be un-installed found." -ForegroundColor DarkCyan
        exit
    }
    
    Write-Host "Prepare to un-install solution." -ForegroundColor DarkCyan
    if ($webUrl) {
        Get-SPFeature | Where-Object {$_.SolutionId -eq $solution.SolutionId} | % {
            Write-Host "Disable feature:"$_.DisplayName -ForegroundColor DarkCyan
            Disable-SPFeature $_ -Url $webUrl -Confirm:$false -ErrorAction SilentlyContinue
        }
    }

    #如果不是全局部署的解决方案包，需要从WebApplication上回收。
    if ($solution.ContainsWebApplicationResource)
    {
        Uninstall-SPSolution -Identity $solution -AllWebApplications -Confirm:$false | Out-Null
    }
    else {
        Uninstall-SPSolution -Identity $solution -Confirm:$false;
    }
    $count = 0
    while($solution.JobExists)
    {
        $count++
        Write-Progress -Activity "Un-installing solution: $name" -percentcomplete ($count/(60*3)*100)
        start-sleep 1
    }
    Write-Progress -Activity "Solution: $name" -Completed -Status " uninstalled"
    Write-Host "Solutions uninstalled" -ForegroundColor DarkCyan
}

#删除解决方案包。
function SSRemoveSolution($name)
{
    $solution = Get-SPSolution $name -ErrorAction SilentlyContinue
    if ($solution -eq $null -or $solution.Deployed)
    {
        Write-Host "No solution need to be deleted found." -ForegroundColor DarkCyan
        exit
    }
    Write-Host "Prepare to delete solution." -ForegroundColor DarkCyan
    Remove-SPSolution -Identity $solution -Confirm:$false | Out-Null
    $count = 0
    while($solution.JobExists)
    {
        $count++
        Write-Progress -Activity "Deleting solution: $name" -percentcomplete ($count/(60*3)*100)
        start-sleep 1
    }
    Write-Progress -Activity "Solution: $name" -Completed -Status " deleted"
    Write-Host "Solution deleted." -ForegroundColor DarkCyan
}

#部署解决方案包。
function SSInstallSolution()
{
    param (
        $name,
        $webUrl
    )
    Write-Host
    Write-Host "Prepare to deploy solution $name" -ForegroundColor Yellow
    $solution = Get-SPSolution $name -ErrorAction SilentlyContinue
    if ($solution -eq $null)
    {
        Write-Host "Solution doesn't exist in current farm, parepare to add solution." -ForegroundColor DarkCyan
        #获取脚本执行的路径。
        $p = Get-Location;
        $spath = $p.Path + "/" + $name;
        $solution = Add-SPSolution -LiteralPath $spath;
        Write-Host "Solution added successfully." -ForegroundColor DarkCyan
    }
    #解决方案包是否需要安装到WebApplication, 如果需要，则使用-AllWebApplications参数。
    $containsWebApplicationResource = $solution.ContainsWebApplicationResource
    #获取解决方案包是否包含全局程序集，如果有，则需要使用-GACDeployment参数。
    $containsGlobalAssembly = $solution.ContainsGlobalAssembly;
    Write-Host "Prepare to deploye solution." -ForegroundColor DarkCyan
    #解决方案需要部署到。
    if ($containsWebApplicationResource)
    {
        Write-Host "Solution contains resource file for WbeApplication，need to be installed to specified WebApplication." -ForegroundColor DarkCyan
        if ($containsGlobalAssembly)
        {
            Write-Host "Solution contains GlobalAssembly，need to apply GACDeployment。" -ForegroundColor DarkCyan
            Install-SPSolution -Identity $solution -AllWebApplications -Force -GACDeployment -Confirm:$false
        }
        else {
            Install-SPSolution -Identity $solution -AllWebApplications -Force -Confirm:$false
        }

    }
    else
    {
        if ($containsGlobalAssembly)
        {
            Install-SPSolution -Identity $solution -Force -GACDeployment -Confirm:$false
        }
        else {
            Install-SPSolution -Identity $solution -Force -Confirm:$false
        }
    }
    $solution = Get-SPSolution $name
    $count = 0
    while($solution.JobExists)
    {
        $count++
        Write-Progress -Activity "Deploying solution: $name" -percentcomplete ($count/(60*3)*100)
        start-sleep 1
    }
    Write-Progress -Activity "Solution: $name" -Completed -Status " deployed"
    Write-Host "Solution $name deployed" -ForegroundColor Yellow
    
    if ($webUrl) {
        Get-SPFeature | Where-Object {$_.SolutionId -eq $solution.SolutionId} | %{
            Write-Host "Enable feature: "$_.DisplayName -ForegroundColor DarkCyan
            Enable-SPFeature $_ -Url $webUrl -ErrorAction SilentlyContinue
        }
    }
}

Main