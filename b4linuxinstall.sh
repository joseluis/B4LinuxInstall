#!/bin/bash
#
# B4LinuxInstall (version 20150929) by joseLuís
# ----------------------------------------------------------------------
# A bash script for installing www.b4x.com RAD tools in Linux systems
#
#
# LINKS
# ######################################################################
# repository:   https://github.com/joseluis/B4LinuxInstall
# forum thread: http://www.b4x.com/android/forum/threads/45092/
#
#
# IMPORTANT INSTRUCTIONS
# ######################################################################
# You can download the installers for B4A and B4i and put them in the
# same directory of B4LinuxInstall. The script will find them and ask
# you if you want to install them. E.g.:
#
#	$ ls
#	  b4i-beta_18.exe b4a-trial.exe b4linuxinstall.sh
#
#	$ bash ./b4linuxinstall.sh
#	  ...
#
#
# LICENSE
# ######################################################################
# The MIT License (MIT)
#
# Copyright (c) 2015 José Luis Cruz
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# ######################################################################
# tldr; https://tldrlegal.com/license/mit-license#summary
#
#
# DISCLAIMER
# ######################################################################
# This script is not officially supported nor endorsed by Anywhere Software
# in any way, nor do I work for Anywhere Software. I am not responsible
# for any damages this script could cause to your system. I've been very
# careful to make it safe so there shouldn't be any problems, but
# ultimately you are responsible to ensure its safety before executing it.
# 
#
# THANKS TO
# ######################################################################
# - Zolive33 (Oliver MARÉ) for creating the script B4A_Installer_en,
#   from which B4LinuxInstall is built upon and tries to improve.
# - Anywhere Software (Erel Uziel) for creating the fantastic suite of
#   Rapid Application Development tools B4J, B4A and B4i.
#


# 1 GLOBAL DATA (DON'T TOUCH THIS. GO TO SECTION 2)
# ######################################################################

# Text color variables
txtred=$(tput setaf 1)     # Color Red
txtgre=$(tput setaf 2)     # Color Green
txtyel=$(tput setaf 3)     # Color Yellow
txtblu=$(tput setaf 4)     # Color Blue
txtmag=$(tput setaf 5)     # Color Magenta
txtcya=$(tput setaf 6)     # Color Cyan
txtwhi=$(tput setaf 7)     # Color White
txtbld=$(tput bold)        # Style Bold
txtund=$(tput sgr 0 1)     # Style Underline
txtRST=$(tput sgr0)        # Style Reset

txtSECT=${txtwht}${txtbld} # Section
txtINFO=${txtwhi}          # Info
txtPASS=${txtgre}          # Passed
txtWARN=${txtyel}          # Warning
txtERR=${txtred}           # Error
txtQUES=${txtmag}          # Question
txtCODE=${txtcya}          # Code

# Script permissions
chmod 770 "${0}"

# Check shell
if [ "${-}" != 'hB' ]; then
	echo "${txtERR}ERROR: Script not executed properly!${txtRST}"
	echo "${txtINFO}Please run the script like this:${txtRST}"
	echo "${txtCODE}\t${0}${txtRST}"
	exit
fi

# 32bit or 64bit OS
[ $(uname -m) == "x86_64" ] && SObits="64" || SObits="32"

# B4J download links
b4jURL=http://www.b4x.com/b4j/files/B4J.exe
b4jFile=${b4jURL##*/}

B4JBridgeUrl=http://www.b4x.com/b4j/files/b4j-bridge.jar
B4JBridgeFile=${B4JBridgeUrl##*/}


# 2 CUSTOMIZABLE VARIABLES (ONLY TOUCH IF YOU KNOW WHAT YOU ARE DOING)
# ######################################################################

# Workspace folder
DirWorkspace=${HOME}/workspace_b4

# ANDROID & WINE
# ----------------------------------------------------------------------

# Android SDK for Linux 32)

AndroidSdkUrl=http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
AndroidSdkFile=${AndroidSdkUrl##*/}

# Compatibility elements for the android SDK and Wine

AndroidSdkWineCompatUrl=http://github.com/joseluis/B4LinuxInstall/raw/master/sdk-B4A.tar.gz
AndroidSdkWineCompatFile=${AndroidSdkUrl##*/}

# Wine version to use
case ${SObits} in
	32)
	WinePkg="wine1.6" # stable version, preferred
	;;
	64)
	WinePkg="wine1.7" # beta version, only needed in 64bit (because of dotnet) # TODO: dotnet40 prob. needs this
	;;
esac

# ORACLE JAVA
# ----------------------------------------------------------------------
#

# Latest version. Check on:
#   - http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html (deprecated but works)
#   - http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html (fails installation in wine <=1.7)
J7VER='7u79'; J7VER_B='b15'
J8VER='8u65'; J8VER_B='b17'

# JDK for Windows 32bit <UPDATE>
JdkWindowsUrl=http://download.oracle.com/otn-pub/java/jdk/${J7VER}-${J7VER_B}/jdk-${J7VER}-windows-i586.exe
#JdkWindowsUrl=http://download.oracle.com/otn-pub/java/jdk/${J8VER}-${J8VER_B}/jdk-${J8VER}-windows-i586.exe
JdkWindowsPack=${JdkWindowsUrl##*/}

# JDK for Linux <UPDATE>
case ${SObits} in
	32)
	# rpm
	JdkLinuxRpmUrl="http://download.oracle.com/otn-pub/java/jdk/${J8VER}-${J8VER_B}/jdk-${J8VER}-linux-i586.rpm"
	# tgz
	JdkLinuxTgzUrl="http://download.oracle.com/otn-pub/java/jdk/${J8VER}-${J8VER_B}/jdk-${J8VER}-linux-i586.tar.gz"
	;;
	64)
	# rpm
	JdkLinuxRpmUrl="http://download.oracle.com/otn-pub/java/jdk/${J8VER}-${J8VER_B}/jdk-${J8VER}-linux-x64.rpm"
	# tgz
	JdkLinuxTgzUrl="http://download.oracle.com/otn-pub/java/jdk/${J8VER}-${J8VER_B}/jdk-${J8VER}-linux-x64.tar.gz"
	;;
esac
JdkLinuxDebFile=${JdkLinuxDebUrl##*/}
JdkLinuxRpmFile=${JdkLinuxRpmUrl##*/}
JdkLinuxTgzFile=${JdkLinuxTgzUrl##*/}


# 3 UTILITY FUNCTIONS
# ######################################################################

# Checks if a command is available
# Params: $1=name
function bin_exists() {
	command -v ${1} >/dev/null 2>&1
}

# Checks if a package is installed
# Params: $1=Name
function package_exists() {

	# <DPKG>
	res=$( dpkg-query -l 2>/dev/null "${1}" | tail -1 | awk '{ print $1 }' )
	[ "${res}" == "ii" ]
}

function wgetFilter() {
# http://stackoverflow.com/a/4687912/940200
	local flag=false c count cr=$'\r' nl=$'\n'
	while IFS='' read -d '' -rn 1 c; do
		if $flag; then
			printf '%c' "$c"
		else
			if [[ $c != $cr && $c != $nl ]]; then
				count=0
			else
				((count++))
				if ((count > 1)); then
					flag=true
				fi
			fi
		fi
	done
}

# Downloads a file from oracle.com and saves it to ${DirTmp}
# Params: $1=URL
function oracle_download() {
	wget --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" -P ${DirTmp} ${1}
}

function wget_download() {
	wget -c --progress=bar:force -P ${DirTmp} ${1} 2>&1 | wgetFilter
}


# 4 WINE FUNCTIONS
# ######################################################################

function init_winedir() {
	Winedir=${1}
	winTmpDirU="${Winedir}/dosdevices/c:/windows/temp"
	winTmpDirW="C:\\windows\\Temp"
}

function override_app_dlls() {
# thank's to winetricks project :-)
# example : w_override_app_dlls winword.exe riched20 native
# options native builtin default
	oad_App="${1}"
	oad_dll="${2}"
	oad_option="${3}"

	echo "REGEDIT4" > "${winTmpDirU}/override-dll.reg"
	echo "" >> "${winTmpDirU}/override-dll.reg"
	echo "[HKEY_CURRENT_USER\\Software\\Wine\\AppDefaults\\$oad_App\\DllOverrides]" >> "${winTmpDirU}/override-dll.reg"

	if [ "$oad_option" = default ]
	then
		echo "\"*$oad_dll\"=-" >> "${winTmpDirU}/override-dll.reg"
	else
		echo "\"*$oad_dll\"=\"$oad_option\"" >> "${winTmpDirU}/override-dll.reg"
	fi
	
	WINEARCH=win32 WINEPREFIX=$Winedir wine regedit "/S" "${winTmpDirW}\\override-dll.reg"

	rm ${winTmpDirU}/override-dll.reg
	unset oad_App oad_dll oad_option
}


# 5 SETUP FOLDERS
# ######################################################################

DirTmp=${DirWorkspace}/temp
DirTools=${DirWorkspace}/tools
DirWine=${DirWorkspace}/wine_b4
init_winedir ${DirWine}

# creating workspace folder
mkdir -p ${DirWorkspace}

# creating workspace folder
mkdir -p ${DirTools}

# creating temporary folder
mkdir -p ${DirTmp}


# 6 ORACLE JAVA INSTALLATION (LINUX)
# ######################################################################

echo -e "\n${txtSECT}Installation of Java for Linux..."
echo "--------------------------------------------${txtRST}"

# <ORACLE>

# Checks java version
if bin_exists java; then
	javaFullVersion=$(java -version 2>&1 | head -1 | awk -F '"' '/version/ {print $2}' )
	javaBigVersion=$(echo ${javaFullVersion} | cut -d'.' -f1-2 )

	#echo "java -version detected: $javaFullVersion" # TEMP
fi

# Installs java
# TODO: make debian compatible
if [ "${javaBigVersion}" == "1.8" ]; then
	echo "${txtPASS}You seem to have java ${javaBigVersion} already installed.${txtRST}"
else
	read -p "${txtQUES}Oracle Java version 1.8 is a requirement for JavaFX Scenebuilder and B4J. Do you want to install Java now? (y/n) ${txtRST}" yn
	if [ "${yn}" = "y" ]; then
		
		# Check for the package
		if ! package_exists oracle-java8-installer; then
		
			# <UBUNTU> add the PPA
			echo "${txtINFO}We are going to add the java8 ppa repository:${txtRST}"
			echo "    ${txtCODE}sudo add-apt-repository ppa:webupd8team/java"
			
			read -p "${txtQUES}Continue? (y/n) ${txtRST}" yn
			if [ "${yn}" = "y" ]; then
				sudo add-apt-repository ppa:webupd8team/java
			fi
		fi
		
		echo "${txtINFO}Now we are going install Java 8:${txtRST}"
		
		echo "    sudo apt-get update"
		echo "    sudo apt-get install oracle-java8-installer"
		echo "    sudo update-java-alternatives -s java-8-oracle${txtRST}"
		
		read -p "${txtQUES}Continue? (y/n) ${txtRST}" yn
		if [ "${yn}" = "y" ]; then
			sudo apt-get update
			sudo apt-get install oracle-java8-installer
			sudo update-java-alternatives -s java-8-oracle
		fi
	fi
fi



# 7 ANDROID SDK INSTALLATION (LINUX)
# ######################################################################

# The only components that needs to be installed are:
# Inside Tools: SDK Platform-tools + Build-tools (both selected by default)
# Inside the last stable API: SDK Platform + one System Image (e.g. x86 Atom)

echo -e "\n${txtSECT}Installation of Android SDK for Linux..."
echo "--------------------------------------------${txtRST}"

# Android SDK Installation
if ! [ -d "${DirWorkspace}/android-sdk-linux/" ]; then
	read -p "${txtQUES}Do you want to install Android SDK (>300MB download)? (y/n) ${txtRST}" yn
	if [ "${yn}" = "y" ]; then
		wget_download ${AndroidSdkUrl};
		echo "${txtINFO}Uncompressing downloaded file \"${AndroidSdkFile}\". . .${txtRST}"
		tar -zxf ${DirTmp}/${AndroidSdkFile} -C ${DirWorkspace}

		echo "${txtINFO}Install from the Android SDK Manager GUI only the necessary components:\nAndroid SDK: Tools, Platform-tools & Build-tools; Android >= 6.0: SDK Platform & Intel x86 System Image. . .${txtRST}"
		${DirWorkspace}/android-sdk-linux/tools/android 2>/dev/null
	fi

else
	echo "${txtPASS}Android SDK is already installed${txtRST}"
	yn="n"
fi

# Adaptation for Android SDK (for Wine compatibility)
if [ -d "${DirWorkspace}/android-sdk-linux/tools/" ] && [ ${yn} == "y" ]; then

	if ! [ -f "${DirWorkspace}/android-sdk-linux/platform-tools/adb.exe" ]; then

		echo "${txtINFO}Installing compatibility elements for Android SDK with Wine...${txtRST}"

		echo "echo OFF" > ${DirWorkspace}/android-sdk-linux/tools/android.bat
		echo "start /unix ${DirWorkspace}/android-sdk-linux/tools/android avd" >> ${DirWorkspace}/android-sdk-linux/tools/android.bat
		wget_download ${AndroidSdkWineCompatUrl};
		echo "${txtINFO}Uncompressing \"$\". . .${txtRST}"
		tar -xzf ${DirTmp}/${AndroidSdkWineCompatFile} -C ${DirWorkspace}/android-sdk-linux
	else
		echo "${txtPASS}Compatibility elements for Android SDK with Wine are already installed${txtRST}"
	fi
fi



# 8 WINE INSTALLATION (LINUX)
# ######################################################################

echo -e "\n${txtSECT}Installation of Wine for Linux..."
echo "--------------------------------------------${txtRST}"

bin_exists wine ; wineFound=$?
bin_exists winetricks ; winetricksFound=$?

if [ $wineFound -eq 0 ]; then
	wineVers=$(wine --version | cut -d'-' -f2 | cut -d'.' -f1-2)
	echo "${txtPASS}Detected wine version ${wineVers}${txtRST}"
else
	echo "${txtWARN}Wine not found${txtRST}"
fi
if [ $winetricksFound -eq 0 ]; then
	winetricksVers=$(winetricks --version)
	echo "${txtPASS}Detected winetricks version ${winetricksVers}${txtRST}"
else
	echo "${txtWARN}Winetricks not found${txtRST}"
fi

# Installing wine
if [ $wineFound -ne 0 -o $winetricksFound -ne 0 ]; then
	echo "${txtINFO}Wine and/or winetricks do not seem to be installed on your system.${txtRST}"
	read -p "${txtQUES}Do you want to install it? (y/n) ${txtRST}" yn
	if [ "${yn}" = "y" ]; then
	
	# <UBUNTU>
	
		sudo add-apt-repository ppa:ubuntu-wine/ppa
		sudo apt-get update
		sudo apt-get install ${WinePkg} winetricks
	fi
fi

# Environment preparation for Wine (32 bits)
if ! [ -d "${DirWine}" ]; then
	echo -n "${txtINFO}We are going to configure wine folder now. ${txtRST}"
	echo "${txtQUES}Press a key to continue.${txtRST}"
	read
	
	echo "${txtINFO}Initializing Wine's environment. . .${txtRST}"
	WINEARCH=win32 WINEPREFIX=${DirWine} wine do_not_exists 2>/dev/null
	echo "${txtINFO}Installing .NET 4.0. . .${txtRST}"
	WINEARCH=win32 WINEPREFIX=${DirWine} winetricks dotnet40 corefonts 2>/dev/null
else
	echo "${txtPASS}Environment for Wine 32 bits width dotnet40 is already installed${txtRST}"
fi


# 9 ORACLE JAVA JDK INSTALLATION (WINE)
# ######################################################################

# The only component that needs to be installed is the Development Tools
# Don't install the Source Code nor the Public JRE

echo -e "\n${txtSECT}Installation of Java 1.7 for Windows 32bit. . ."
echo "--------------------------------------------${txtRST}"
# NOTE: Java 1.8 gives error in installation
#
# <ORACLE>

if ! [ -d "${DirWine}/drive_c/Program Files/Java/" ]; then
	read -p "${txtQUES}Do you want to install JDK for windows? (y/n) ${txtRST}" yn
	if [ "${yn}" = "y" ]; then
		oracle_download ${JdkWindowsUrl}
		WINEARCH=win32 WINEPREFIX=${DirWine} wine ${DirTmp}/${JdkWindowsPack} 2>/dev/null
	fi
else
	echo "${txtPASS}JDK for Windows is already installed${txtRST}"
fi


# 10 B4A INSTALLATION (WINE)
# ######################################################################

echo -e "\n${txtSECT}Installation of B4A for Windows 32bit..."
echo "--------------------------------------------${txtRST}"

# Detect B4A installer in current dir
INSTALLER=$(ls *[Bb]4[Aa]*.exe 2>/dev/null | head -1) # It only detects the first match

# Detect if B4A is already installed
if [ -f "${DirWine}/drive_c/Program Files/Anywhere Software/Basic4android/Basic4android.exe" ]; then
	echo "${txtPASS}B4A is already installed${txtRST}"
    TextUpdateInstall="update"
else
	TextUpdateInstall="install"
fi

# Ask to install
if [ -f "${INSTALLER}" ]; then
    echo "${txtINFO}Found B4A installer file: '${INSTALLER}'.${txtRST}"
	read -p "${txtQUES}Do you want to ${TextUpdateInstall} B4A using this file? (y/n) ${txtRST}" yn
else
	echo "${txtWARN}Can't find B4A installer file. If you want to ${TextUpdateInstall} it, download the installer in this directory.${txtRST}"
    yn="n"
fi

if [ "${yn}" == "y" ]; then 
	wget_download ${b4aURL}
	WINEARCH=win32 WINEPREFIX=${DirWine} wine ${INSTALLER} 2>/dev/null
	override_app_dlls Basic4android.exe gdiplus native

	# App Link
	B4A_desktop="B4A.desktop" # before: Basic4android.desktop	
	echo "[Desktop Entry]" >${DirWorkspace}/${B4A_desktop}
	echo "Name=B4A" >>${DirWorkspace}/${B4A_desktop}
	echo "Exec=env WINEPREFIX="\"${DirWine}\"" wine C:\\\\\\\\windows\\\\\\\\command\\\\\\\\start.exe /Unix ${DirWine}/dosdevices/c:/users/Public/Start\\\\ Menu/Programs/Basic4android/Basic4android.lnk" >>${DirWorkspace}/${B4A_desktop}
	echo "Type=Application" >>${DirWorkspace}/${B4A_desktop}
	echo "StartupNotify=true" >>${DirWorkspace}/${B4A_desktop}
	echo "Path=${DirWine}/dosdevices/c:/Program Files/Anywhere Software/Basic4android" >>${DirWorkspace}/${B4A_desktop}
	echo "Icon=B5FB_Basic4android.0" >>${DirWorkspace}/${B4A_desktop}
	chmod +x ${DirWorkspace}/${B4A_desktop}
fi


# 11 B4J INSTALLATION (WINE)
# ######################################################################

echo -e "\n${txtSECT}Installation of B4J for Windows 32bit..."
echo "--------------------------------------------${txtRST}"

if [ -f "${DirWine}/drive_c/Program Files/Anywhere Software/B4J/B4J.exe" ]; then
	echo "${txtPASS}B4J is already installed${txtRST}"
	read -p "${txtQUES}Do you want to update B4J? (y/n) ${txtRST}" yn
else
	read -p "${txtQUES}Do you want to install B4J? (y/n) ${txtRST}" yn
fi

if [ "${yn}" == "y" ]; then
	# wget_download ${b4jURL} # TEMP
	b4jFile=/mnt/nube/Dropbox/dev/B4LinuxInstall/tmp/b4j-beta-new-ide.exe
	echo "WINEARCH=win32 WINEPREFIX=${DirWine} wine ${DirTmp}/${b4jFile} 2>/dev/null"
	exit

	WINEARCH=win32 WINEPREFIX=${DirWine} wine ${DirTmp}/${b4jFile} 2>/dev/null
	override_app_dlls B4J.exe gdiplus native

	# App Link
	B4J_desktop="B4J.desktop"
	echo "${txtINFO}Creating link for B4J...${txtRST}"
	
	echo "[Desktop Entry]" >${DirWorkspace}/${B4J_desktop}
	echo "Name=B4J" >>${DirWorkspace}/${B4J_desktop}
	echo "Exec=env WINEPREFIX="\"${DirWine}\"" wine C:\\\\\\\\windows\\\\\\\\command\\\\\\\\start.exe /Unix ${DirWine}/dosdevices/c:/users/Public/Start\\\\ Menu/Programs/B4J/B4J.lnk" >>${DirWorkspace}/${B4J_desktop}
	echo "Type=Application" >>${DirWorkspace}/${B4J_desktop}
	echo "StartupNotify=true" >>${DirWorkspace}/${B4J_desktop}
	echo "Path=${DirWine}/dosdevices/c:/Program Files/Anywhere Software/B4J" >>${DirWorkspace}/${B4J_desktop}
	echo "Icon=7BEB_B4J.0" >>${DirWorkspace}/${B4J_desktop}
	chmod +x ${DirWorkspace}/${B4J_desktop}

	# B4J Bridge
	if ! [ -f "${DirWorkspace}/tools/${B4JBridgeFile}" ]; then
		echo "${txtINFO}Downloading B4J Bridge...${txtRST}"

		wget_download ${B4JBridgeUrl}
		cp ${DirTmp}/${B4JBridgeFile} ${DirTools}
	else
		echo "${txtPASS}${B4JBridgeFile} already exists under ${DirTools}${txtRST}"
	fi

	# B4J Bridge Link
	B4JBridge_desktop="B4JBridge.desktop"
	echo "${txtINFO}Creating link for B4J Bridge...${txtRST}"
	
	echo "[Desktop Entry]" >${DirWorkspace}/${B4JBridge_desktop}
	echo "Name=B4J Bridge" >>${DirWorkspace}/${B4JBridge_desktop}
	echo "Exec=x-terminal-emulator -t B4JBridge -e java -jar ${DirTools}/b4j-bridge.jar" >>${DirWorkspace}/${B4JBridge_desktop}
	echo "Type=Application" >>${DirWorkspace}/${B4JBridge_desktop}
	echo "StartupNotify=true" >>${DirWorkspace}/${B4JBridge_desktop}
	echo "Path=${DirWine}/dosdevices/c:/Program Files/Anywhere Software/B4J" >>${DirWorkspace}/${B4JBridge_desktop}
	echo "Icon=terminal" >>${DirWorkspace}/${B4JBridge_desktop}
	chmod +x ${DirWorkspace}/${B4JBridge_desktop}
fi


# 12 B3i INSTALLATION (WINE)
# ######################################################################

echo -e "\n${txtSECT}Installation of B4i for Windows 32bit..."
echo "--------------------------------------------${txtRST}"

# Detect B4i install erin current dir
INSTALLER=$(ls *[Bb]4[Ii]*.exe 2>/dev/null | head -1) # It only detects the first match

# Detect if B4i is already installed
if [ -f "${DirWine}/drive_c/Program Files/Anywhere Software/B4i/B4i.exe" ]; then
	echo -e "${txtPASS}B4i is already installed${txtRST}"
	TextUpdateInstall="update"
else
	TextUpdateInstall="install"
fi

# Ask to install
if [ -f "${INSTALLER}" ]; then
	echo "${txtINFO}Found B4i installer file: '${INSTALLER}'.${txtRST}"
	read -p "${txtQUES}Do you want to ${TextUpdateInstall} B4i using this file? (y/n) ${txtRST}" yn
else
	echo "${txtWARN}Can't find B4i installer file. If you want to ${TextUpdateInstall} it, download the installer in this directory.${txtRST}"
	yn="n"
fi

if [ "${yn}" == "y" ]; then
	WINEARCH=win32 WINEPREFIX=${DirWine} wine ${INSTALLER} 2>/dev/null
	override_app_dlls B4i.exe gdiplus native

	# App Link
	B4i_desktop="B4i.desktop"
	echo "${txtINFO}Creating link for B4i...${txtRST}"
	
	echo "[Desktop Entry]" >${DirWorkspace}/${B4i_desktop}
	echo "Name=B4i" >>${DirWorkspace}/${B4i_desktop}
	echo "Exec=env WINEPREFIX="\"${DirWine}\"" wine C:\\\\\\\\windows\\\\\\\\command\\\\\\\\start.exe /Unix ${DirWine}/dosdevices/c:/users/Public/Start\\\\ Menu/Programs/B4i/B4i.lnk" >>${DirWorkspace}/${B4i_desktop}
	echo "Type=Application" >>${DirWorkspace}/${B4i_desktop}
	echo "StartupNotify=true" >>${DirWorkspace}/${B4i_desktop}
	echo "Path=${DirWine}/dosdevices/c:/Program Files/Anywhere Software/B4i" >>${DirWorkspace}/${B4i_desktop}
	echo "Icon=8DA3_B4i.0" >>${DirWorkspace}/${B4i_desktop}
	chmod +x ${DirWorkspace}/${B4i_desktop}
fi


# 13 CLEANUP & EXIT
# ######################################################################

# TODO: Make this an option in the menu. Show size.

echo -e "\n${txtSECT}Cleanup & exit"
echo "--------------------------------------------${txtRST}"

read -p "${txtQUES}Do you want to delete the temporary downloaded files? (y/n) ${txtRST}" yn
if [ "${yn}" = "y" ]; then
	echo "${txtINFO}Deleting ${DirTmp} . . .${txtRST}"
	rm -r ${DirTmp}
fi


echo -e "\n${txtINFO}Bye!${txtRST}\n"

