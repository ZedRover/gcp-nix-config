{ config, pkgs, ... }:

{
  # 注意：username 和 homeDirectory 已由 flake.nix 动态传入
  programs.home-manager.enable = true;
  home.stateVersion = "24.05";

  # ============================================================
  # PATH 配置（推荐方式）
  # ============================================================
  home.sessionPath = [
    "$HOME/.local/bin"
    # 可以添加更多路径
    # "$HOME/bin"
    # "$HOME/go/bin"
  ];

  # ============================================================
  # 环境变量配置
  # ============================================================
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  }; 

  # ============================================================
  # 1. 软件包安装 (Packages)
  # ============================================================
  home.packages = with pkgs; [
    # 核心环境
    pixi
    uv

    # 基础工具
    git
    curl
    wget
    neovim      # 现代化的 vim
    htop

    # 现代化命令行工具 (Rust 重写版)
    fd          # 替代 find (速度极快)
    ripgrep     # 替代 grep
    jq          # JSON 处理
    duf         # 磁盘使用情况
    # 注意: eza, bat, zoxide, fzf 通过下方模块安装以获得 shell 集成
  ];

  # ============================================================
  # 2. 现代化工具原生集成 (Native Modules)
  #    这些模块会直接生成优化的 Shell 函数，启动速度毫秒级
  # ============================================================

  # [替代 zsh-z] Zoxide: 智能目录跳转
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # [替代 fzf-zsh-plugin] FZF 原生配置
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f"; # 使用 fd 作为后端
    fileWidgetCommand = "fd --type f";
  };

  # [替代 eza-zsh] Eza (ls 的替代品)
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    git = true;
    extraOptions = [ "--group-directories-first" "--header" ];
  };

  # [替代 cat] Bat
  programs.bat = {
    enable = true;
  };

  # [替代 Oh-My-Zsh 主题] Starship 提示符
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      # 扫描超时时间（毫秒）
      scan_timeout = 10;

      # 命令执行时间显示
      cmd_duration = {
        min_time = 500;
        format = "took [$duration](bold yellow)";
      };

      # Git 状态配置
      git_status = {
        conflicted = "🏳";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        untracked = "🤷";
        stashed = "📦";
        modified = "📝";
        staged = "➕";
        renamed = "👅";
        deleted = "🗑";
      };

      # Python 环境显示
      python = {
        symbol = "🐍 ";
        pyenv_version_name = true;
        format = "via [\${symbol}\${pyenv_prefix}(\${version} )(\\($virtualenv\\) )]($style)";
      };

      # 目录显示
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
      };

      # 字符提示符
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };

  # ============================================================
  # 3. Zsh 终极配置
  # ============================================================
  programs.zsh = {
    enable = true;
    
    # 启用自动补全
    enableCompletion = true;

    # [原生模块] 语法高亮
    syntaxHighlighting.enable = true;

    # [原生模块] 自动建议
    autosuggestion.enable = true;

    # [原生模块] 历史记录子串搜索
    historySubstringSearch = {
      enable = true;
      searchUpKey = [ "^[[A" "^P" ];   # Up Arrow / Ctrl+P
      searchDownKey = [ "^[[B" "^N" ]; # Down Arrow / Ctrl+N
    };

    # Oh-My-Zsh 模块（主题已由 Starship 接管）
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
        "extract"
        "colored-man-pages"
      ];
      theme = ""; # 禁用主题，使用 Starship
    };

    # Shell 别名
    shellAliases = {
      # 习惯映射
      ls = "eza";
      ll = "eza -l";
      la = "eza -la";
      lt = "eza --tree";
      cat = "bat";
      g = "git";
      py = "python";

      # 编辑器别名
      vi = "nvim";
      vim = "nvim";
    };

    # 环境初始化脚本 (加载 uv/pixi 补全)
    initExtra = ''
      # 1. 加载 uv 补全
      if command -v uv > /dev/null; then
        eval "$(uv generate-shell-completion zsh)"
      fi

      # 2. 加载 pixi 补全
      if command -v pixi > /dev/null; then
        eval "$(pixi completion --shell zsh)"
      fi

      # 3. 优化历史记录
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_SAVE_NO_DUPS
    '';
  };
}
