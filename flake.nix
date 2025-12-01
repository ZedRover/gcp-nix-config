{
  description = "Ubuntu Server Environment for Zed";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      # 1. 这里直接硬编码你的系统信息，最稳
      system = "x86_64-linux";
      username = "zed"; 
      homeDirectory = "/home/zed";

      pkgs = nixpkgs.legacyPackages.${system};
      
      # 定义配置逻辑，方便复用
      myHomeConfig = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ 
          ./home.nix 
          {
            home.username = username;
            home.homeDirectory = homeDirectory;
          }
        ];
      };
    in {
      homeConfigurations = {
        # 2. 同时暴露 "zed" 和 "zed@ml-training" 两个入口
        # 这样无论 home-manager 怎么猜都能猜中
        "zed" = myHomeConfig;
        "zed@ml-training" = myHomeConfig;
      };
    };
}
