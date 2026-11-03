# Nix dev shells

Development environments, not part of the system :

- `python/` : `nix-shell` with a python venv (data science packages from nixpkgs, the others from `requirements.txt`)
- `swh/swh_mining/` : flake for the swh mining project (see its README to use it with direnv)
- `default.nix` : empty shell to start from

For a new project, prefer a flake with direnv (`use flake` in `.envrc`, see [nixos/README.md](../nixos/README.md#direnv)) : its `flake.lock` pins the versions.
