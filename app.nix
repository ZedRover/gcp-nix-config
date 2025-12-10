{ config, pkgs, lib, ... }:

{
  # ============================================================
  # Homebrew 声明式包管理模块
  #    使用 Brewfile 实现声明式配置，类似 nix-darwin 的方式
  # ============================================================

  # Homebrew 环境配置
  programs.zsh.initExtra = ''
    # Homebrew 环境配置（如果已安装）
    if [ -d "/home/linuxbrew/.linuxbrew" ]; then
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    elif [ -d "$HOME/.linuxbrew" ]; then
      eval "$($HOME/.linuxbrew/bin/brew shellenv)"
    fi
  '';

  # 生成 Brewfile 配置文件
  home.file.".config/brewfile/Brewfile".text = ''
    # ============================================================
    # Homebrew 声明式包配置
    # 使用 `brew bundle install` 来同步此配置
    # ============================================================

    # Taps (第三方仓库)
    # tap "homebrew/cask-fonts"
    # tap "homebrew/cask-versions"

    # Brews (命令行工具)
    # brew "node"
    # brew "python@3.11"
    # brew "go"
    # brew "docker"
    # brew "kubectl"
    # brew "terraform"
    # brew "ansible"

    # 示例：取消下面的注释来安装这些工具
    # brew "gh"              # GitHub CLI
    # brew "jq"              # JSON 处理工具
    # brew "httpie"          # HTTP 客户端
    # brew "tmux"            # 终端复用器
    # brew "neovim"          # 编辑器
  '';

  # 使用 home.activation 自动执行 brew bundle
  home.activation.syncHomebrewPackages = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # 检查 Homebrew 是否已安装
    if command -v brew > /dev/null 2>&1; then
      echo "检测到 Homebrew，使用 Brewfile 同步包..."

      # 使用 brew bundle 声明式安装包
      if [ -f "$HOME/.config/brewfile/Brewfile" ]; then
        cd "$HOME/.config/brewfile"

        # --no-lock: 不生成 Brewfile.lock.json
        # --no-upgrade: 不自动升级已安装的包（可选）
        $DRY_RUN_CMD brew bundle install --no-lock --verbose

        echo "Homebrew 包同步完成"
      else
        echo "警告：Brewfile 不存在"
      fi
    else
      echo "未检测到 Homebrew，跳过包安装"
      echo "如需安装 Homebrew，请访问: https://brew.sh"
    fi
  '';
}
