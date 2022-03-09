
hosts_path='/C/Windows/System32/drivers/etc/hosts1';

# 获取传入的参数地址，可替换地址常量
# 文件存在
if [ -f "${1}" ];then
	echo "传入的hosts文件地址为：${1}"
	hosts_path="${1}"
elif [ ! -f "${hosts_path}" ];then
	echo "地址错误，无hosts文件"
	echo "程序退出... ..."
	exit
fi

echo "hosts文件地址：${hosts_path}"

echo "获取地址：https://ipaddress.com/website/github.com#ipinfo，设置的ip"
# 获取页面地址
web_ip=`curl https://ipaddress.com/website/github.com#ipinfo | grep -Eo "<tr><th>IP Address</th><td><ul class=\"comma-separated\"><li>[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}</li></ul></td></tr>" | grep -Eo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"`
echo "获取页面地址的IP为：${web_ip}"

echo "获取hosts文件的github代理ip"
#获取hosts文件github.com地址
hosts_ip=`cat ${hosts_path} | grep -Eo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\s+github.com" | grep -Eo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"`
echo "获取hosts文件代理ip为：${hosts_ip}"

# 如果hosts文件存在github.com代理，则替换，否则新增
echo "${hosts_ip}"
if [ -n "${hosts_ip}" ];then
	echo "替换ip地址：${web_ip} -> ${hosts_ip}"
	# 替换
	sed -i "s/${hosts_ip}/${web_ip}/" $hosts_path
else
	echo "为空" 
	# 追加一行
	echo "${web_ip} github.com" >> $hosts_path
fi

echo "替换完成"
