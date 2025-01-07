#!/bin/bash

set -euo pipefail

##############################################
# 公共函数定义
##############################################

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to get the SSH directory
get_ssh_dir() {
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        echo "$USERPROFILE/.ssh"
    else
        echo "$HOME/.ssh"
    fi
}

# Function to get the hosts file location
get_hosts_file() {
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        echo "/c/Windows/System32/drivers/etc/hosts"
    else
        echo "/etc/hosts"
    fi
}

# Function to check if script is run with sudo/admin privileges
check_privileges() {
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        # Check for admin privileges on Windows
        net session >/dev/null 2>&1
    else
        # Check for root privileges on Unix-like systems
        [[ $EUID -eq 0 ]]
    fi
}

# Function to fetch GitHub hosts content
fetch_github_hosts() {
    local url="https://git.yoqi.me/lyq/github-host/raw/master/hosts"
    local content

    if command_exists curl; then
        content=$(curl -sSL "$url")
    elif command_exists wget; then
        content=$(wget -qO- "$url")
    else
        echo "Error: Neither curl nor wget is available. Unable to fetch GitHub hosts." >&2
        return 1
    fi

    if [[ -z "$content" ]]; then
        echo "Error: Failed to fetch GitHub hosts content." >&2
        return 1
    fi

    echo "$content"
}

# Function to update hosts file
update_hosts() {
    local hosts_file
    hosts_file=$(get_hosts_file)
    local temp_hosts
    temp_hosts=$(mktemp)
    local github_hosts

    # Fetch GitHub hosts content
    github_hosts=$(fetch_github_hosts) || return 1

    # Remove existing GitHub entries and add new ones
    sed '/github/d' "$hosts_file" > "$temp_hosts"
    echo "$github_hosts" >> "$temp_hosts"

    # Replace the original hosts file
    if check_privileges; then
        if cp "$temp_hosts" "$hosts_file"; then
            echo "Hosts file updated successfully."
        else
            echo "Error: Failed to update hosts file. Please check permissions and try again."
            rm "$temp_hosts"
            return 1
        fi
    else
        echo "Insufficient privileges to update hosts file."
        echo "Please run this script with sudo or as an administrator."
        echo "Alternatively, manually add the following entries to your hosts file ($hosts_file):"
        echo "$github_hosts"
        rm "$temp_hosts"
        return 1
    fi

    rm "$temp_hosts"
}

# Function to test SSH connection
test_ssh_connection() {
    if command_exists ssh; then
        echo "Testing SSH connection to GitHub..."
        echo "SSH response:"
        ssh -T git@github.com
        echo "Above is the SSH connection test result. Please check if it was successful."
    else
        echo "SSH command not found. Unable to test connection."
    fi
}

##############################################
# 新增：确保脚本同级目录下存在有效的 id_rsa
##############################################
prepare_private_key() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local key_path="$script_dir/id_rsa"

    # 如果不存在 id_rsa，则写入写死在代码中的私钥
    if [[ ! -f "$key_path" ]]; then
        cat <<'EOF' > "$key_path"
-----BEGIN OPENSSH PRIVATE KEY-----
YOU GIT PRIVATE KEY HERE
把你的密钥放在这个地方
-----END OPENSSH PRIVATE KEY-----
EOF
        echo "No local id_rsa found. Created one from the built-in private key."
    else
        echo "Found existing id_rsa in script directory."
    fi

    # 校验并修复权限
    local current_perm
    current_perm=$(stat -c '%a' "$key_path" 2>/dev/null || echo "")
    if [[ "$current_perm" != "600" ]]; then
        chmod 600 "$key_path"
        echo "Fixed permissions of $key_path to 600."
    fi
}

##############################################
# 独享（原有）逻辑：将 id_rsa 文件复制到 ~/.ssh
##############################################
install_key_to_ssh() {
    local key_path="$1"
    local ssh_dir
    ssh_dir=$(get_ssh_dir)

    # Create .ssh directory if it doesn't exist
    mkdir -p "$ssh_dir"
    chmod 700 "$ssh_dir"

    # 复制密钥至 ~/.ssh/id_rsa
    cp "$key_path" "$ssh_dir/id_rsa"

    # Fix permission for ~/.ssh/id_rsa
    chmod 600 "$ssh_dir/id_rsa"
    echo "SSH key has been copied to $ssh_dir/id_rsa"

    # Update hosts file
    update_hosts

    # Test SSH connection
    test_ssh_connection
}

##############################################
# 基于 ssh-agent 的逻辑：启动 agent 并添加私钥
##############################################
start_ssh_agent_logic() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local key_path="$script_dir/id_rsa"

    # 准备私钥 (若无则写入内置的，若权限不对则修复)
    prepare_private_key

    # 启动 ssh-agent（如果尚未启动）
    if [[ -z "${SSH_AUTH_SOCK:-}" ]]; then
        eval "$(ssh-agent -s)"
        echo "ssh-agent started with PID: $SSH_AGENT_PID"
    else
        echo "ssh-agent is already running. PID: $SSH_AGENT_PID"
    fi

    # 添加私钥
    ssh-add "$key_path"
    echo "Private key has been added to ssh-agent."

    # 更新 hosts 并测试
    update_hosts
    test_ssh_connection
}

##############################################
# 当脚本被 "source" 时，自动执行 ssh-agent 逻辑
##############################################
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
    # 当脚本被 source 时
    start_ssh_agent_logic || true
    return 0
fi

##############################################
# 当脚本被直接执行时，询问用户是否独享
##############################################
main() {
    echo "Detected direct script execution."
    read -rp "Is this environment private (独享)? [y/N]: " choice
    case "$choice" in
        [yY][eE][sS]|[yY])
            echo "You chose 独享环境，执行独享逻辑..."
            # 脚本同级目录放置的 id_rsa
            local script_dir
            script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
            local key_path="$script_dir/id_rsa"

            # 先确保脚本目录下的 id_rsa 存在且权限正确
            prepare_private_key
            # 然后将其复制到 ~/.ssh/id_rsa
            install_key_to_ssh "$key_path"
            ;;
        *)
            echo "You chose a non-private (共享) environment，执行 ssh-agent 逻辑..."
            start_ssh_agent_logic
            ;;
    esac
}

# 运行主函数
main

echo "Script completed. Please review the output above to ensure everything worked as expected."
