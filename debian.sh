#!/data/data/com.termux/usr/bin/bash 
dist="debian" distro="Debian" suite="stable" # default suite
folder="${dist}-fs" tarball="${dist}.tar.xz"
script="start-${dist}.sh"
current="$(pwd)" # current directory
function install {
	function set_suite() {
		case $suite in
			stable|unstable|testing|oldstable|oldoldstable)
				echo "Using Rolling Release '$suite'... ";;
			buster|sid|bullseye|stretch|jessie)
				echo "Using code release '$suite'... " ;;
			*)
				echo "Unsupported suite '$suite'. Aborting"; exit ;;
		esac
	}
	function check_deps {
		echo -n "Checking dependencies... "
		for dep in proot wget
			do
				function fetch_deps {
					echo -e "\nInstalling ${dep}..."
					pkg install -y ${dep} || { echo "An error occured while trying to download dependencies"; exit; }
					deps=1
				}
				command -v $dep 2&>/dev/null || fetch_deps
			done
		[[ $deps -ne 1 ]] && echo "OK" || { echo -en "\nDependencies installed!\n"; }
	}
	function get_arch {
		arch="$(dpkg --print-architecture)"
		case $arch in
			aarch64) arch="arm64v8" ;;
			arm) arch="arm32v7" ;;
			i*86) arch="i386" ;;
			amd64|x64) arch="amd64" ;;
			*) echo "Unsupported architecture ${arch}"; exit ;;
		esac
		echo "Architecture is $arch"
	}
	set_suite "$@"			
	check_deps
	if [ -d $folder ]; then
		first=1
		echo "Skipping download of $tarball"
	fi
	if [ first != 1 ]; then
		if [ ! -f $tarball ]; then
			get_arch
			wget "https://raw.githubusercontent.com/debuerreotype/docker-debian-artifacts/dist-${arch}/${suite}/rootfs.tar.xz" -O $tarball
		fi
		mkdir "$folder"
		cd "$folder"
		echo "Decompressing ${distro} tarball..."
		proot --link2symlink tar -xf ${current}/${tarball} || :
		cd ${current}
	fi
	echo "Writing launch script..."
	cat > ${script} <<- EOF
		cd \$(dirname \$0)
		## unset LD_PRELOAD in case termux-exec is installed
		unset LD_PRELOAD
		command="proot"
		command+=" --link2symlink"
		command+=" -0"
		command+=" -r $folder"
		command+=" -b /dev"
		command+=" -b /proc"
		## uncomment the following line to have access to the home directory of termux
		#command+=" -b /data/data/com.termux/files/home:/root"
		## uncomment the following line to mount /sdcard directly to / 
		#command+=" -b /sdcard"
		command+=" -w /root"
		command+=" /usr/bin/env -i"
			command+=" HOME=/root"
			command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin"
			command+=" TERM=\$TERM"
			command+=" LANG=C.UTF-8"
			command+=" /bin/bash --login"
		com="\$@"
		if [ -z "\$1" ];then
			exec \$command
		else
			\$command -c "\$com"
		fi	
EOF
	echo "Making $script executable..."
	chmod +x $script
	echo "You can now start ${distro} with the ./${script} script"
}
function uninstall() {
    function delete_files() {
        rm -r $script $folder  || echo "An error occured while trying to remove your files" && exit
        echo "done"
    }
    echo -n "Uninstall ${distro}? [Y/n]: "
    read -r opt
    case $opt in
        y|Y) delete_files ;;
        *) echo "Aborted" ;;
    esac
    exit
}
while getopts "v:u" var
	do
		case $var in
			v) suite="$OPTARG" ;;
			u) uninstall; u=1 ;;
			*) echo "Invalid option. Aborting"; u=1;
		esac
	done
[[ $u -ne 1 ]] && install "$@" || exit