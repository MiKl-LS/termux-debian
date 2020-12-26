
## ARCHIVED: Termux's [`proot-distro`](https://github.com/termux/proot-distro) is a better alternative that this hunk of junk

A bash (.sh) script to install Debian on a Termux enviroment

![Debian "Banner"](https://wiki.debian.org/FrontPage?action=AttachFile&do=get&target=10-buster-wiki-banner-02.png)

Uses PRoot to virtualize a Linux filesystem (not an OS) to be used in Termux

# Installation:

All you really need to do is to download the script and execute it (using `curl` and `bash`) for this

``` 
curl -sLO https://raw.githubusercontent.com/mikl-ls/termux-debian/master/debian.sh
bash debian.sh (optional flags: -v $VERSION to specify the version. -u to uninstall)
```

$VERSION as in `stable`, `testing`, `unstable`, `jessie`, etc.

Note: EOL (end of life) versions are not supported due to them being in a seperate repo

The script does everything else like installing dependencies, etc. Just in case, here's how to install the dependencies:
```
pkg install -y proot wget
```

To uninstall Debian, just append the `-u` flag, then confirm the uninstall:

```
bash debian.sh -u
```

# Credits:
[Neo-Oli/Termux-Ubuntu](https://github.com/Neo-Oli/termux-ubuntu) for the base bash script that I've rewritten for Debian installation.

[debuerreotype/docker-debian-artifacts](https://github.com/debuerreotype/docker-debian-artifacts) for the rootfs (tar.xz)'s being used in this script
