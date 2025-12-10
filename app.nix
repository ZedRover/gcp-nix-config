{ config, pkgs, ... }:

{
  # ============================================================
  # Homebrew 环境变量配置
  #    仅配置环境变量，包管理由用户自行处理
  # ============================================================

  programs.zsh.initExtra = ''
    # Homebrew 环境配置（如果已安装）
    if [ -d "/home/linuxbrew/.linuxbrew" ]; then
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    elif [ -d "$HOME/.linuxbrew" ]; then
      eval "$($HOME/.linuxbrew/bin/brew shellenv)"
    fi
  '';
}
