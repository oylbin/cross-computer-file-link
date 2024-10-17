# cross-computer-file-link

我在不同的电脑上，用群晖 SynologyDrive 同步了文件，但是不同电脑上文件的目录结构不一致，比如：

- 我的windows电脑的home目录是 `C:\Users\oylb`，群晖中的一个文件路径举例：`C:\Users\oylb\SynologyDrive\工作\业务管理\2024-10-17.xmind`
- 我的macbook pro的home目录是 `/Users/oylb`，群晖中的一个文件路径举例：`/volume1/homes/oylb/SynologyDrive/工作/业务管理/2024-10-17.xmind`

我会在我的obsidian文档中，使用统一的URL引用这些文件，同时又能让我在不同的电脑上都能点击链接，访问到群晖的文件。

cross-computer-file-link 就是一个用来生成和解析这种跨平台文件链接的工具。

上面示例的文件，我在obsidian文档中，使用统一的URL进行引用： http://localhost:10114/redirect/SynologyDrive/工作/业务管理/2024-10-17.xmind

当我在obsidian中点击这个链接时，cross-computer-file-link 会接收到这个http 请求，然后解析URL，获取到文件在当前电脑上的路径，然后调用操作系统的默认程序打开这个文件。

## cursor IDE gpt4o model prompt

项目代码基本使用 Cursor IDE 的 gpt4o model 完成，以下是主要的 prompt 内容：


我想使用golang实现一个名称为 cross-computer-file-link 的工具。
它使用golang开发，运行在macOS，Windows，Linux等操作系统上，以长驻进程方式运行，提供http服务，监听10114端口。

它的核心功能是两个：
1. 功能1：根据本地文件路径生成一个可以跨平台使用的HTTP URL。
2. 功能2：解析跨平台的HTTP URL，并转换为本地文件路径并打开该文件。

功能1的使用方式：

1. 用户用浏览器打开 `http://localhost:10114/` 会进入一个网页
2. 网页上提供一个文本框和一个“转换并复制”按钮
3. 用户在文本框中输入本地文件路径，比如`C:\Users\oylb\SynologyDrive\工作\业务管理\2024-10-17.xmind`
4. 用户点击“转换并复制”按钮后，网页会把上面的路径转为如下链接，并复制到系统剪贴板。
    1. `http://localhost:10114/redirect/SynologyDrive/工作/业务管理/2024-10-17.xmind`
    2. 转换的逻辑如下：
        1. 本地电脑的HOME目录是`C:\Users\oylb`，用户输入`C:\Users\oylb\SynologyDrive\工作\业务管理\2024-10-17.xmind`
        2. 从用户输入的文件路径中，移除最前面的HOME目录，得到`SynologyDrive\工作\业务管理\2024-10-17.xmind`
        3. 然后把剩余部分的路径中的分隔符`\`替换为`/`

功能2的使用方式：

1. 用户用浏览器打开此前由cross-computer-file-link生成的链接
    1.  `http://localhost:10114/redirect/SynologyDrive/工作/业务管理/2024-10-17.xmind`
2. 请求会被 cross-computer-file-link 进程的http service中的 "redirect" handler进行处理。
    1. handler会从URL中解析出 `redirect`后面的部分，得到 `SynologyDrive/工作/业务管理/2024-10-17.xmind`
    2. 如果当前电脑是Windows系统，那么把路径中的分隔符`/`替换为`\`
    3. 加上本机的HOME目录前缀，得到实际的本机文件路径
        1. 比如当前电脑的HOME目录是 `C:\Users\DELL`
        2. 加上HOME目录前缀后，得到`C:\Users\DELL\SynologyDrive\工作\业务管理\2024-10-17.xmind`
    4. 得到正确的本地文件路径后，cross-computer-file-link会调用操作系统的默认程序打开这个文件。


上面的首次prompt生成代码后，一些细节的改进

1. windows获取HOME env，换为 `os.UserHomeDir()` 更为通用
2. 路径转换逻辑，在home page用js实现，不需要额外多一次post请求
3. windows home路径，写入js代码前，需要把 `\` 替换为 `\\`
4. windows 打开 文件时，`exec.Command("cmd", "/c", "start", path)` 改为 `exec.Command("cmd", "/c", "start", "", path)` 这样可以解决文件名中带空格时的问题。