# inferzero-nix

A community nix flake for [inferzero](https://github.com/rizagp/inferzero), a C++ local LLM inference engine designed for Intel Arc GPUs.

- Project website: [rizagp.github.io/inferzero](https://rizagp.github.io/inferzero/index.html)
- Original source repository: [github.com/rizagp/inferzero](https://github.com/rizagp/inferzero)

This flake packages the `runz` command-line client and the `serverz` HTTP server.

## Installation

This project is currently intended for x86_64 Linux systems using Nix flakes.

### Run the package directly:

```bash
nix run github:That1LinuxGuy/inferzero-nix
```

To pass arguments to `serverz`, add `--` after the flake reference:

```bash
nix run github:That1LinuxGuy/inferzero-nix -- --help
```

The package also provides `runz` when installed into a profile or made available through a user's flake.

### Permanent installation:

Add this repository as an input in your `flake.nix`:

```nix
{
  inputs = {
    inferzero-nix.url = "github:That1LinuxGuy/inferzero-nix";
  };

  outputs = { self, nixpkgs, ... }@inputs: {

  nixosConfigurations = {
   x86_64-intel-computer = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./path/to/config.nix

        # Add inferzero-nix to your flake's outputs 
        inputs.inferzero-nix.nixosModules.default
      ];
    };
}
```

## Requirements

- A 64-bit Linux system with Nix flakes enabled.
- An Intel GPU supported by the Intel Compute Runtime 
- A working Intel graphics kernel driver and access to the render device.
- On NixOS, add the Intel OpenCL/Level Zero runtime to the graphics configuration:

  ```nix
  {
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-compute-runtime
      ];
    };
  }
  ```

  If `hardware.graphics` is already configured, add only `intel-compute-runtime` to its existing `extraPackages` list.

For details about supported hardware, models, server options, and the upstream project, see the [inferzero documentation](https://rizagp.github.io/inferzero/index.html).
