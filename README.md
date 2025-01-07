# prepare_git_now

一个让你在国内任何地方快速配置好git身份的脚本, 需要你写入密钥到脚本代码中.

# 动机

你是不是经常上不了git？
你是不是经常换各种机器开发并且需要把git代码上传，并且还不想打扰到其他用户？

那就快使用这个脚本吧！ 你只需把你的私钥写进这个脚本，然后你就可以把它拷贝到你的U盘里面，遇到新电脑直接执行下，结束！（用完记得删/更改可读权限）

# 使用方阿福：
两种运行方式：

## 无痕方式（一次性）
source prepare_git.sh：
只会执行 start_ssh_agent_logic，即自动启动 ssh-agent 并添加脚本同级的 id_rsa。
用于您想要在当前会话中直接获取身份，在任何目录下都可使用。
注意：建议只在您信任该脚本时使用 source。

## 永久方式(要求独享账户)
bash prepare_git.sh：
会交互式询问您是否“独享”。
如果选择“是”，则复制 id_rsa 到 ~/.ssh/id_rsa 并使用原有逻辑；
如果选择“否”，则执行 ssh-agent 逻辑并添加私钥，不会修改您的 ~/.ssh/id_rsa。

*****************如果你在共享账户上使用，可能会覆盖别人的git配置*****************
