
' 获取管理员权限
function get_administrator_permission()
        ' 获取管理员权限
        Set WshShell = WScript.CreateObject("WScript.Shell")
        If WScript.Arguments.Length = 0 Then
        Set ObjShell = CreateObject("Shell.Application")
        ObjShell.ShellExecute "wscript.exe" _
                , """" & WScript.ScriptFullName & """ RunAsAdministrator", , "runas", 1
        WScript.Quit
        End if
end function

' 定义端口映射关系
function port_map_dictionary()
        Dim map
        ' 创建一个端口映射字典
        set map = CreateObject("Scripting.Dictionary")
        map.CompareMode = vbTextCompare
        map.Add "9000", "9000"
        map.Add "9090", "9090"

        set port_map_dictionary = map
end function

' 启动wsl系统
function open_wsl(ws)
        ' 开启wsl子系统，并执行子系统初始化脚本
        ws.run "wsl -d Ubuntu-20.04 -u root /etc/init_service.sh",0
end function

' 获取wslip地址
function get_wsl_ip(ws)
        ' 查询wsl子系统ip
        commandLine = "wsl -d Ubuntu-20.04 -u root /opt/wsl_ip/wsl_ip.sh"
        Set result = ws.Exec(commandLine)
        ' 处理ip
        ipaddr = result.StdOut.ReadAll()
        ipLength = Len(ipaddr)
        ip = Left(ipaddr, ipLength - 1)
        get_wsl_ip = ip
end function

' 处理cmd端口转发指令
function get_cmd_command(ip)
        ' 定义一些变量
        Dim port_map, cmd_array()
        ' 获取端口映射关系
        set port_map = port_map_dictionary()
        ' 获取端口映射字典数量，并重置cmd数组定义
        ReDim cmd_array(UBound(port_map.Keys))
        ' 查询windows所有转发的端口
        ' netsh interface portproxy show all
        ' 删除端口转发
        ' netsh interface portproxy delete v4tov4 listenport=9091 listenaddress=0.0.0.0
        ' 定义cmd指令临时变量
        interface_cmd = "netsh interface portproxy add v4tov4 listenport=listen_port listenaddress=0.0.0.0 connectport=poxt_port connectaddress=" & ip & " protocol=tcp"
        ' 定义cmd数组下表索引临时变量
        cmd_index = 0
        ' 循环端口映射字典，并拼接端口转发cmd指令
        for each i in port_map.Keys
                ' 本地端口
                listen_port = i
                ' 监听代理的linux端口
                poxt_port = port_map(i)
                my_cmd = Replace(interface_cmd, "listen_port", listen_port)
                my_cmd = Replace(my_cmd, "poxt_port", poxt_port)
                ' 新增到cmd数组种
                cmd_array(cmd_index) = my_cmd
                ' 索引 +1
                cmd_index = cmd_index + 1
        Next
        ' 往cmd数组中做拼接, 不能使用拼接的方式执行
        'get_cmd_command = join(cmd_array, ";")
        get_cmd_command = cmd_array
        ' WScript.echo cmd_command
end function

' 执行cmd指令
function execut_cmd(ws, cmd_array)
        for each cmd in get_cmd_command(wsl_ip)
                ws.run cmd,0
        Next
end function


' 主程序运行区
Dim wsl_ip, cmd_command

get_administrator_permission()
Set ws = WScript.CreateObject("WScript.Shell")
open_wsl(ws)
wsl_ip = get_wsl_ip(ws)
execut_cmd ws,get_cmd_command(wsl_ip)
