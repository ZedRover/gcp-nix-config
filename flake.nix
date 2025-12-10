{
  description = "Ubuntu Server Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      # 1. 这里的用户信息会被 build.sh 自动替换
      system = "x86_64-linux";
      username = "__USERNAME__";
      homeDirectory = "__HOME_DIR__";

      pkgs = nixpkgs.legacyPackages.${system};
      
      # 定义配置逻辑，方便复用
      myHomeConfig = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
          ./app.nix  # Homebrew 包管理模块
          {
            home.username = username;
            home.homeDirectory = homeDirectory;
          }
        ];
      };
    in {
      homeConfigurations = {
        # 2. 动态暴露用户名作为入口点，支持多种格式
        "${username}" = myHomeConfig;
        "${username}@ml-training" = myHomeConfig;
      };
    };
}
