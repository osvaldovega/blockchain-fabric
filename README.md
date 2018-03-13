# Blockchain Fabric

This repository holds the necessary configuration files to build and start a Hyperledger Fabric business network.
The main purpose of this is have PoC project to see how can implement it and use it.

# Prerequesites

## Install cURL

Download the latest version of the [cURL] tool if it is not already installed or if you get errors running the curl commands from the documentation.

## Windows extras

If you are developing on Windows, you will want to work within the Docker Quickstart Terminal which provides a better alternative to the built-in Windows such as [Git Bash] which you typically get as part of installing Docker Toolbox on Windows 7.

However experience has shown this to be a poor development environment with limited functionality. It is suitable to run Docker based scenarios, such as Getting Started, but you may have difficulties with operations involving the make command.

Before running any *git clone* commands, run the following commands:

```bash
  git config --global core.autocrlf false git config --global core.longpaths true
```

You can check the setting of these parameters with the following commands:

```bash
  git config --get core.autocrlf
  git config --get core.longpaths
```
These need to be `false` and `true` respectively.

The *curl* command that comes with Git and Docker Toolbox is old and does not handle properly the redirect used
in Getting Started. Make sure you install and use a newer version from the [cURL downloads page].

For Node.js you also need the necessary Visual Studio C++ Build Tools which are freely available and can be installed with the following command:

```bash
  npm install --global windows-build-tools
```

See the [NPM windows-build-tools page] for more details.

Once this is done, you should also install the NPM GRPC module with the following command:

```bash
  npm install --global grpc
```

Your environment should now be ready.

## Docker and Docker Compose
You will need the following installed on the platform on which you will be operating, or developing on (or for), Hyperledger Fabric:

* MacOSX, *nix, or Windows 10: [Docker] Docker version 17.03.0-ce or greater is required.

* Older versions of Windows: [Docker Toolbox] - again, Docker version Docker 17.03.0-ce or greater is required.

You can check the version of Docker you have installed with the following command from a terminal prompt:

```bash
  docker --version
```

> **Note:** Installing Docker for Mac or Windows, or Docker Toolbox will also install Docker Compose. If you already had Docker installed, you should check that you have Docker Compose version 1.8 or greater installed. If not, we recommend that you install a more recent version of Docker.
>

You can check the version of Docker Compose you have installed with the following command from a terminal prompt:

```bash
  docker-compose --version
```


## Go Programming Language

Hyperledger Fabric uses the Go programming language 1.7.x for many of its components.

Given that we are writing a Go chaincode program, we need to be sure that the source code is located somewhere
within the `$GOPATH` tree. First, you will need to check that you have set your `$GOPATH` environment variable.

```bash
  echo $GOPATH
  /Users/xxx/go
```

 If nothing is displayed when you echo `$GOPATH`, you will need to set it. Typically, the value will be a directory tree child of your development workspace, if you have one, or as a child of your `$HOME` directory. Since we’ll be doing a bunch of coding in Go, you might want to add the following to your `~/.bashrc`:

 ```bash
  export GOPATH=$HOME/go
  export PATH=$PATH:$GOPATH/bin
 ```

After this you need to install globally the following NPM Pacakges:

```bash
  npm install -g composer-cli
  npm install -g composer-rest-server
  npm install -g generator-hyperledger-composer
```

# Download Docker Images

To get the docker images to work with Hyperledger Fabric you need to download the hyperledger images from docker, but we made it easy for you, so in this case you just need to execute the `get-docker-images.sh` file, that is located in the root of this folder.

```bash
  $ ./downloadFabric.sh
```

# Generate the Certificates and Artifacts for the blockchain network and Network Start

After download the images, you need to execute the following command:

```bash
  $ ./startFabric.sh
```

This command will create all the necessary certs to sign/validate the transactions in the network. After run this you will see the data into the `./config/crypto-config` fodler and in the terminal you will see this message.

```bash
=> STATUS:  CRYPTO CONFIG AND ARTIFACTS GENERATION SUCCESSFULLY
```

After thi you need to run the createPeerAdminCard.sh file

```bash
  $ ./createPeerAdminCard.sh
```

# Note

For more information you can check this PDF file with the explanation of what is happening in the background.
[code details].






[cURL]: https://curl.haxx.se/download.html
[cURL downloads page]: https://curl.haxx.se/download.html
[Docker]: https://www.docker.com/get-docker
[Docker Toolbox]: https://docs.docker.com/toolbox/toolbox_install_windows/
[Git Bash]: https://git-scm.com/downloads
[NPM windows-build-tools page]: https://www.npmjs.com/package/windows-build-tools
[code details]: https://media.readthedocs.org/pdf/hyperledger-fabric/latest/hyperledger-fabric.pdf




