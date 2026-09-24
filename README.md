<div align="center">

# asdf-floci [![Build](https://github.com/dave-bell/asdf-floci/actions/workflows/build.yml/badge.svg)](https://github.com/dave-bell/asdf-floci/actions/workflows/build.yml) [![Lint](https://github.com/dave-bell/asdf-floci/actions/workflows/lint.yml/badge.svg)](https://github.com/dave-bell/asdf-floci/actions/workflows/lint.yml)

[asdf](https://asdf-vm.com) plugin for [floci](https://floci.io)'s official CLI, [`floci-cli`](https://github.com/floci-io/floci-cli).

Floci is a free, open-source local cloud emulator for AWS, GCP, Azure, and OCI.
This plugin installs the `floci` binary that manages Floci's Docker-based
emulator containers — it does not install Floci itself, which runs as a
Docker image.

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, `git`, and standard POSIX utilities (`awk`, `sed`, `sort`,
  `sha256sum` or macOS's `shasum`).
- [Docker](https://www.docker.com), required at runtime by `floci start` to
  run the emulator container. Not required to install the CLI itself.

This plugin installs pre-built native binaries from
[floci-cli's GitHub Releases](https://github.com/floci-io/floci-cli/releases)
for macOS (amd64/arm64) and Linux (amd64/arm64), and verifies each download
against the release's published `sha256sums.txt`. Windows is not supported by
asdf itself; WSL users get the Linux binary automatically.

# Install

Plugin:

```shell
asdf plugin add floci https://github.com/dave-bell/asdf-floci.git
```

floci:

```shell
# Show all installable versions
asdf list-all floci

# Install specific version
asdf install floci latest

# Set a version globally (on your ~/.tool-versions file)
asdf global floci latest

# Now floci commands are available
floci version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/dave-bell/asdf-floci/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Dave Bell](https://github.com/dave-bell/)
