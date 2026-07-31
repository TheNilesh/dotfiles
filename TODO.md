# TODO for Improving Dotfiles

- Provide flag to choose target to apply templated dotfiles. for example k8s devcontainer may not need exa.
  - Check if inside devcontainers, then install only small set of tools
  - Check if macos then only install homebrew and brew bundles

- Switch to NixOS style declarative app installs
  - Pin versions of the app in the config file and let it manage the install
  - Carefully decide what should be installed by nixos manager and what by dotfiles shell scripti
  - Dont switch fully to nix either, keep brewfile for mac. For linux it nix must be preferred.
