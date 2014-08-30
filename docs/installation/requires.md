
## 安装前准备
### 确认SharePoint平台版本
`AWorkflow 2013`支持以下SharePoint平台版本：
* SharePoint Foundation 2013
* SharePoint Server 2013

### 安装环境要求
首先，针对第一次使用`AWorkflow 2013`的用户，我们强烈建议您在***非生产环境***进行`AWorkflow 2013`的产品评估。

即便如此，我们也建议您在正式部署`AWorkflow 2013`前仔细阅读本文，并且对准备安装`AWorkflow 2013`的SharePoint环境进行必要的数据备份，比如数据库备份，网站及备份或者整个服务器场的备份。
>以上各种备份的方式请参考[Microsoft TechNet](http://technet.microsoft.com)。

整个安装过程我们需要您具有SharePoint场管理员的权限。


### 下载解决方案包
您可以从以下途径下载`AWorkfow 2013`解决方案安装包：
* [水杉公司网站](http://www.shuishan-tech.com)
* [水杉公司GitHub](https://github.com/shuishan-tech/aworkflow)
* 发送邮件到aworkflow@shuishan-tech.com索取

完整的安装包应该包含以下文件：
* ShuiShan.S2.Form.wsp
* ShuiShan.S2.Framework.wsp
* ShuiShan.S2.Mobile.wsp
* ShuiShan.S2.OrganizationChart.wsp
* ShuiShan.S2.Workflow.wsp
* ShuiShan.S2.wsp.ps1
* Install.cmd

以上文件存放到同一目录下，并复制到将要进行安装的SharePoint服务器场中的任意一台Windows Server服务器上。
