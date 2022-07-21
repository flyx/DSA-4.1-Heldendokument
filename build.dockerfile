FROM nixos/nix

RUN echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf
CMD nix build github:flyx/DSA-4.1-Heldendokument#dsa41held_webui-docker && cp result /dev/stdout