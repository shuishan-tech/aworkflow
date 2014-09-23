##1. 部署后重启Timer服务##

在系统部署ShuiShan.S2.Workflow.wsp包后，应重启SharePoint Timer服务，避免Timer服务继续装载旧的工作流引擎相关的dll进行流程处理。

重启方法：打开服务器的任务管理器，在详细信息列表中找到“OWSTIMER.EXE”，点击“结束任务”按钮结束该进程，系统将会关闭该进程后在自动重启进场。


