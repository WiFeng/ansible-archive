## 介绍
Ansible is an IT automation tool. It can configure systems, deploy software, and orchestrate more advanced IT tasks such as continuous deployments or zero downtime rolling updates.

http://docs.ansible.com/ansible/latest/index.html

## 快速入门
为了更加方便使用ansible，需要在目标机（要执行命令的远程服务器）上执行以下命令：
- 开通SSH白名单（这一项需要先完成，方可执行下面的命令，可以在 http://ump.letv.cn 中申请）
- 创建ansible账号
- 使其ansible账号可以通过SSH KEY登陆（也就是无密码登陆）
- 给ansible账号加入sudo权限

可以通过以下的命令来完成上面剩余的3步：
```
ansible -i ./hosts_production msg -m raw -a 'useradd ansible; mkdir /home/ansible/.ssh; echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAnRKDL6b0XJVp3BbY9v7s332UAi7PFPXP+FReSDfiIRYz8dxmkdHIDujTDx/FqtNzZ71teMjMU2p8zrlsWOnODT8eLmzYeqn/XGJ+QuxWdc9sneOhv8U/6BWFKq5u8GVTYYgM1Qfyb8A23DFdgzQU6UBO5+bNCqgG8FlScvmnP4m6JQqMkZpipVHnnj2gP3fM0lfmIlvanUJdkmR99rHcniFU7nYzM8GnZabRiWBMVmiHVRzCrVTqoi38rbNwF6Eqgj7kphNdy3tpk/0qgz2RfkmgWNtnImkI5Exkf4IqRLJeys/UQZCoHyg5RvbT7hVk+SUtOIcpB4ultqZ2eX588Q== ansible@vm-10-112-43-1" >> /home/ansible/.ssh/authorized_keys; chown -R ansible:ansible /home/ansible/.ssh/; chmod 700 /home/ansible/.ssh;  chmod 600 /home/ansible/.ssh/authorized_keys;' --ssh-extra-args='-o StrictHostKeyChecking=no' -b -k -u liuweifeng
ansible -i ./hosts_production msg -m raw -a 'sed -i "s/# %wheel\tALL=(ALL)\tNOPASSWD:\sALL/&\nansible\tALL=(ALL)\tNOPASSWD: ALL/" /etc/sudoers' --ssh-extra-args='-o StrictHostKeyChecking=no' -b -k -u liuweifeng
```
正常情况下，机器分配之后会有一个root账号可以操作，可以把上面的 liuweifeng 换为 root

## 常用命令
### 添加用户
给其他同学开通账号(需要替换对应的账号、密码)
```
第一种方式（原始）：
ssh：
ssh 10.176.30.64:'sudo useradd liuweifeng;echo "ncNW,(Tlu)Or" | passwd liuweifeng --stdin'
ssh 10.176.30.64:'sudo sed -i "s/# %wheel\tALL=(ALL)\tNOPASSWD:\sALL/&\nliuweifeng\tALL=(ALL)\tNOPASSWD: ALL/" /etc/sudoers'
```
```
第二种方式：
ansible:
ansible -i hosts_production cms -m raw -a 'useradd liuweifeng;echo "ncNW,(Tlu)Or" | passwd liuweifeng --stdin' -b
ansible -i hosts_production cms -m raw -a 'sed -i "s/# %wheel\tALL=(ALL)\tNOPASSWD:\sALL/&\nliuweifeng\tALL=(ALL)\tNOPASSWD: ALL/" /etc/sudoers' -b
```

## 注意事项
在大多数情况下应该先执行 lnmp.yml 安装一些基础组件，然后再执行其他软件的安装
