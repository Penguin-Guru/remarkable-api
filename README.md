
## A simple Bash script to interact with Remarkable devices' local A.P.I. via C.L.I.

This script is pretty basic and I don't expect to maintain it. I've already written a more robust one that does not use their A.P.I. With that said, if anyone does want to use their A.P.I., this script should be a good place to start. I tried several others before writing it and none of them worked for me. Most are archived and unmaintained.

I am not aware of any models or software versions this does not work with, but there may well be some. If you know of any, feel free to submit a pull request or file an issue about it.

So far, known to work with:
- Remarkable Paper Pro (3.24.0.149)

### Functionality:

- Listing contents (of folders).
- Downloading files:
  - .pdf
  - .rmdoc (raw notebook archive)
- Uploading files:
  - .pdf
  - .epub

The local A.P.I. does not seem to support When .epub files are uploaded, the device seems to generate a .pdf version, which can be downloaded later. The .epub file is also stored on the device.

Some basic functionalities are not supported because I haven't figured out how or whether they are possible. Additional A.P.I. functionality seems to be available if you use Remarkable's authentication service to generate a token, but I don't intend to do that so those functionalities are not currently supported by this script. Pull requests are welcome if anyone wants to add them.
- Renaming objects.
- Deleting objects.
- Creating folders.
- Moving objects (with respect to folders).
- Searching for objects (supposedly possible without auth, or at least used to be somewhat possible).

I have also not developed the functions that do work much, since I decided to write a different script instead. If anyone actually wants to use this, I may be able to make the U.X. a bit more comfortable. File feature requests as issues.
- Specifying objects by visible name rather than than G.U.I.D.
- Recursive operations on folders.
- Support for iterative processing of multiple objects per invocation.

### Dependencies:

- Bash.
- Curl.
- jq.

### Set-up:

For this script to work, you will need:
- The Remarkable device's local web interface enabled.
- The device to be routable by your computer (e.g. plugged in or on the same WiFi network).

I've described the requirements for and process of connecting to Remarkable devices from a Linux host [here](https://wiki.gentoo.org/wiki/User:Penguin-Guru/Remarkable). Note that distribution kernels probably already support the necessary drivers and do not need to be rebuilt.


### Attribution:

My understanding of the A.P.I. as applied in this script is based almost entirely on [this](https://remarkable.guide/tech/usb-web-interface.html#api) web page and digging through the web interface's JavaScript. I have since read through several other open-source projects and blog articles examining the A.P.I., but I did not discover any additional information about end-points independent of authentication.

