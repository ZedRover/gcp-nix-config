{ config, pkgs, ... }:

{
  # 注意：username 和 homeDirectory 已由 flake.nix 动态传入
  programs.home-manager.enable = true;
  home.stateVersion = "24.05"; 

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
    vim
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

    # Oh-My-Zsh 模块
    oh-my-zsh = {
      enable = true;
      plugins = [ 
        "git" 
        "sudo" 
        "extract" 
        "colored-man-pages" 
      ];
      theme = "robbyrussell";
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
      
      # 4. 设置默认编辑器
      export EDITOR="vim"
    '';
  };
}
