FROM nixpkgs/nix-flakes:nixos-21.05
CMD nix build github:flyx/DSA-4.1-Heldendokument#dsa41held-webui-docker && cp result /dev/stdout