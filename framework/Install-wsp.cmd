@echo off
@echo =======================================================================
@echo Author：Cai Fangbao
@echo Create date：2014-03-23
@echo 本脚本用于安装项目 wsp 
@echo 注意：
@echo 	只能在服务器上执行本脚本程序；
@echo 	必须以管理员身份运行本脚本；
@echo ========================================================================
@echo >> nul
@echo >> nul


@echo Note：确定已选择以管理员身份运行本脚本，然后单击任意键开始导出列表。
Pause >> nul
@echo >> nul
@echo >> nul


PowerShell -command Set-ExecutionPolicy "Bypass" >>nul

@echo 正在安装 ShuiShan.S2.Framework.wsp 请稍等 ...

PowerShell -command "& {%~dp0ShuiShan.S2.Framework.wsp.ps1}" >>install.log

@echo 正在安装 ShuiShan.S2.OrganizationChart.wsp. 请稍等 ...

PowerShell -command "& {%~dp0ShuiShan.S2.OrganizationChart.wsp.ps1}" >>install.log

@echo 正在安装 ShuiShan.S2.Form.wsp. 请稍等 ...

PowerShell -command "& {%~dp0ShuiShan.S2.Form.wsp.ps1}" >>install.log


@echo 正在安装 ShuiShan.S2.Workflow.wsp. 请稍等 ...

PowerShell -command "& {%~dp0ShuiShan.S2.Workflow.wsp.ps1}" >>install.log

@echo 安装已完成。详细信息请查看install.log。
@echo 请单击任意键关闭安装程序。

Pause >> nul
@echo on