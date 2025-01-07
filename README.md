


# prepare_git_now

## 简介

**prepare_git_now** 是一个让你在国内任何地方快速配置好 Git 身份的脚本，通过将你的私钥嵌入到脚本中。你可以将此脚本拷贝到你的 U 盘，遇到新电脑直接执行，完成配置！（用完记得删除或更改可读权限）

### 动机

你是不是经常上不了 Git？
你是不是经常换各种机器开发并且需要把 Git 代码上传，同时又不想打扰到其他用户？

那就快使用这个脚本吧！你只需将你的私钥写进这个脚本，然后拷贝到你的 U 盘，遇到新电脑直接执行，结束！（用完记得删/更改可读权限）

## 使用方式：
有两种运行方式：

### 1. 无痕方式（一次性）
```bash
source prepare_git_now.sh
```
只会执行 `start_ssh_agent_logic`，即自动启动 `ssh-agent` 并添加脚本同级的 `id_rsa`。
用于您想要在当前会话中直接获取身份，并在任何目录下使用。
**注意：**建议仅在您信任该脚本的环境中使用 `source`。

### 2. 永久方式（要求独享账户）
```bash
bash prepare_git_now.sh
```
会交互式询问您是否“独享”。
- 如果选择“是”，则复制 `id_rsa` 到 `~/.ssh/id_rsa` 并使用原有逻辑。
- 如果选择“否”，则执行 `ssh-agent` 逻辑并添加私钥，不会修改您的 `~/.ssh/id_rsa`。

*****************如果你在共享账户上使用，可能会覆盖别人的 Git 配置*****************



# prepare_git_now

## Introduction

**prepare_git_now** is a script that allows you to quickly configure your Git identity anywhere in China by embedding your private key into the script. You can copy this script to your USB drive, execute it on a new computer, and finish! (Remember to delete/change the read permissions after use.)

### Motivation

Do you often find yourself unable to access Git?
Do you frequently switch between different machines for development and need to upload Git code without disturbing other users?

Then quickly use this script! You only need to write your private key into this script, copy it to your USB drive, and execute it directly on a new computer. After use, remember to delete/change the read permissions!

## Usage:
There are two modes of operation:

### 1. No Trace Mode (One-time)
```bash
source prepare_git_now.sh
```
This will only execute `start_ssh_agent_logic`, which automatically starts `ssh-agent` and adds the `id_rsa` located in the same directory as the script.
Use this when you want to obtain your identity directly in the current session and use it in any directory.
**Note:** It is recommended to only source this script in trusted environments.

### 2. Permanent Mode (Requires Private Account)
```bash
bash prepare_git_now.sh
```
This will interactively ask you whether the environment is "private".
- If you choose "Yes", it will copy `id_rsa` to `~/.ssh/id_rsa` and use the original logic.
- If you choose "No", it will execute the `ssh-agent` logic and add the private key without modifying your `~/.ssh/id_rsa`.

*****************Using this on a shared account may overwrite other users' Git configurations*****************


