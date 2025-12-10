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

echo "添加 zsh 到系统 shells..."
echo "$HOME/.nix-profile/bin/zsh" | sudo tee -a /etc/shells

echo "设置 zsh 为默认 shell..."
chsh -s "$HOME/.nix-profile/bin/zsh"

echo "构建完成！"
