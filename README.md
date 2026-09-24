<div align="center">

# asdf-floci [![Build](https://github.com/dave-bell/asdf-floci/actions/workflows/build.yml/badge.svg)](https://github.com/dave-bell/asdf-floci/actions/workflows/build.yml) [![Lint](https://github.com/dave-bell/asdf-floci/actions/workflows/lint.yml/badge.svg)](https://github.com/dave-bell/asdf-floci/actions/workflows/lint.yml)

[floci](https://floci.io) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

**TODO: adapt this section**

- `bash`, `curl`, `tar`, and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).
- `SOME_ENV_VAR`: set this environment variable in your shell config to load the correct version of tool x.

# Install

Plugin:

```shell
asdf plugin add floci
# or
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
