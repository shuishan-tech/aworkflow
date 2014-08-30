@echo off
@echo =======================================================================
@echo Author：Cai Fangbao@水杉网络科技有限公司
@echo Version: 1.0.2013.1229
@echo 本脚本用于安装项目水杉工作流 
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

PowerShell -command "& {%~dp0ShuiShan.S2.wsp.ps1}" 

@echo 请单击任意键关闭安装程序。

Pause >> nul
@echo on