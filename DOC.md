



## 尝试Windows下变成 Daemon 服务

首先是用sc命令安装服务

然后发现我的程序是 blocking 的，无法使用 sc create 安装为服务。


然后尝试把程序改成 daemon 服务，一开始使用了 github.com/sevlyar/go-daemon 这个库。

后来发现它不支持 Windows。

然后尝试使用 github.com/kardianos/service 这个库。

集成成功后发现，windows service执行时，取到的Home目录是错的。

然后又尝试通过参数传递 Home 目录。

最终搞定后，发现一个问题。

如果以系统管理员权限运行，后续打开文件时，也是用的系统管理员权限，这样肯定不行。

又进一步看 kardianos/service 如何支持以其他用户执行，看了一下实现方案，和 NSSM 差不多，也是要传用户名密码……

所以最终还是放弃了。

不如就写个简单的程序，Windows下用 NSSM 安装为服务。
macOS和Linux下用 nohup 运行。


使用 NSSM 后，发现用户名权限都是对的，但是后台进程http service收到请求后无法打开文件。
而双击exe直接运行时，http service收到请求后可以正常打开文件。

最终解决方案，放弃注册为service的方案。

问了一下chatgpt，使 Go 编写的命令行程序在 Windows 上自启动且常驻运行，但不显示命令行窗口，可以使用 `-H=windowsgui` 编译选项。


不再折腾 install/uninstall/start/stop/status 这些命令行操作了。
