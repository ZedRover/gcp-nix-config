#!/usr/bin/env bash

# 自动读取当前用户信息
CURRENT_USER="${USER}"
CURRENT_HOME="${HOME}"

echo "检测到当前用户: ${CURRENT_USER}"
echo "检测到用户主目录: ${CURRENT_HOME}"

# 备份原始 flake.nix（如果存在备份则跳过）
if [ ! -f "flake.nix.backup" ]; then
  echo "备份 flake.nix 到 flake.nix.backup"
  cp flake.nix flake.nix.backup
fi

# 使用 sed 替换占位符
echo "更新 flake.nix 中的用户信息..."
sed -i.tmp \
  -e "s|__USERNAME__|${CURRENT_USER}|g" \
  -e "s|__HOME_DIR__|${CURRENT_HOME}|g" \
  flake.nix

# 删除 sed 创建的临时文件
rm -f flake.nix.tmp

echo "开始构建 Home Manager 配置..."
nix run --impure home-manager/master -- switch --flake . -b backup

# 检查并添加 zsh 到系统 shells
ZSH_PATH="$HOME/.nix-profile/bin/zsh"
if grep -q "^${ZSH_PATH}$" /etc/shells 2>/dev/null; then
  echo "zsh 已存在于 /etc/shells 中，跳过添加"
else
  echo "添加 zsh 到 /etc/shells..."
  echo "$ZSH_PATH" | sudo tee -a /etc/shells
fi

# 检查当前默认 shell 是否已经是 zsh
CURRENT_SHELL=$(getent passwd "$CURRENT_USER" | cut -d: -f7)
if [ "$CURRENT_SHELL" = "$ZSH_PATH" ]; then
  echo "当前默认 shell 已经是 zsh，无需修改"
else
  echo "当前默认 shell: $CURRENT_SHELL"
  echo "设置 zsh 为默认 shell..."
  chsh -s "$ZSH_PATH"
  echo "默认 shell 已修改，请重新登录以生效"
fi

echo "构建完成！"
