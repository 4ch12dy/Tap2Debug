function ILOG(){
	echo -e "\033[32m$1 \033[0m"
}

cydiaRepo="$HOME/xia0/iOSRE/cydiarepo/debs"
ROOT=$(cd `dirname $0`; pwd)

if [[ "$1" = "uninstall" ]]; then
	package_id=$(grep -i "^Package:" "$ROOT/control"  | cut -d' ' -f2-)
	ILOG "[*] uninstall $package_id from device"
	ssh root@localhost -p 2222 -o stricthostkeychecking=no "dpkg -r $package_id"
	ILOG "[*] uninstall $package_id done"
	exit 1
fi

ILOG "[1] clear hosts file."
cat /dev/null > ~/.ssh/known_hosts

ILOG "[2] remove old package."
rm -fr $ROOT/packages

ILOG "[3] compile..."
make -s clean package messages=yes #> /dev/null 2>&1

ILOG "[4] copy deb to xia0Repo if need..."

if [[ -z $1 || "$1" != "cydia" ]]; then
	ILOG "[*] you do not want to copy deb to cydia repo"

else
	ILOG "[*] you do want to copy deb to cydia repo, let's go"
	if [[ "$1" = "cydia" &&  -d $cydiaRepo ]]; then
		
		debName=$(ls $ROOT/packages/ 2>/dev/null | awk -F'_' '{print $1}')

		if [[ -z $debName || $debName == "" ]]; then
			ILOG "[-] no deb file in $ROOT/packages"
			exit
		fi

		ILOG "[*] target deb file: $debName"

		ls $cydiaRepo | grep -q "$debName"

		if [[ "$?" == "0" ]]; then
			ILOG "[*] old $debName in xia0Repo, delete it!"
			rm "$cydiaRepo/$debName"*
		else
			ILOG "[*] $debName not in xia0Repo"
		fi

		ILOG "[*] do copy $debName to $cydiaRepo"
		cp $ROOT/packages/*.deb $cydiaRepo

	else
		ILOG "[*] $cydiaRepo not exsist, do not need copy deb file."
	fi
fi

ILOG "[5] install deb to device"
make install

ILOG "[+] all done. power by xia0@2019"
