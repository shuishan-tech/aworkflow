## 安装
在进行`AWorkflow 2013`安装前，请确保您仔细阅读过上一章节**安装前准备**，并对将要安装的SharePoint环境进行过数据备份，且已经下载过`AWorkflow 2013`解决方案安装包。

### 执行cmd命令
在`AWorkflow 2013`解决方案安装包中，找到名为`Install.cmd`的cmd命令文件，右键执行`以管理员身份运行`，如下图：
![执行cmd命令](imgs/installation.1.png)

如果您是第一次在当前SharePoint环境安装`AWorkflow 2013`,脚本将执行以下过程：

1. 添加解决方案包。
2. 部署解决方案包。

如果当前的SharePoint 环境已经安装过`AWorkflow 2013`,则脚本将执行以下过程：

1. 卸载解决方案包。
2. 删除解决方案包。
3. 添加解决方案包
4. 部署解决方案包。

### 确认解决方案包安装完成
当上一步的cmd命令执行完成后，您需要去`SharePoint 管理中心`确认解决方案包是否安装正确。

1. 在Windows Server桌面上找到`SharePoint 管理中心`图标并点击：![SharePoint 管理中心](imgs/installation.2.png)
2. 管理中心将在浏览器中打开，点击左边菜单栏中的**系统设置**，进入系统设置后点击**管理场解决方案**：![管理场解决方案](imgs/installation.3.png)