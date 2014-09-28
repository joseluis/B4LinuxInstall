#!/bin/bash
#
# B4LinuxInstall (version 20140927) by joseLuís
# ----------------------------------------------------------------------
# A bash script for installing B4* RAD tools in Linux systems
#
#
# LINKS
# ######################################################################
# repository:		https://github.com/joseluis/B4LinuxInstall
# forum thread:		http://basic4ppc.com/android/forum/threads/45092/
# B4A:			http://basic4ppc.com/android/b4j.html
# B4J:			http://basic4ppc.com/android/downloads.html
#
#
# IMPORTANT INSTRUCTIONS
# ######################################################################
# - You can replace the contents of the variable b4aURL with the URL of
#	the full version to B4A, sent by email to you after you buy it.
#
#
# LICENSE
# ######################################################################
# The MIT License (MIT)
#
# Copyright (c) 2014 José Luis Cruz
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
# in any way, nor do I work for Anywhere Software.
# 
#
# THANKS TO
# ######################################################################
# - Zolive33 (Oliver MARÉ) for creating the script B4A_Installer_en,
#	from which B4LinuxInstall is built upon and tries to improve.
# - Anywhere Software (Erel Uziel) for creating the fantastic suite of
#	Rapid Application Development tools B4J, B4A and B4I.
#


# GLOBAL CUSTOMIZABLE VARIABLES
# ######################################################################

# Workspace folder (you can change it)
wksB4=${HOME}/workspace_b4

# B4A download link
# If you bought B4A you can change the link to the full version here:
b4aURL=http://www.basic4ppc.com/android/files/b4a-trial.exe # demo version
b4aFile=${b4aURL##*/}

# B4J download link
b4jURL=http://www.basic4ppc.com/b4j/files/B4J.exe
b4jFile=${b4jURL##*/}

# ANDROID & WINE
# ----------------------------------------------------------------------

# Android SDK for Linux
AndroidSdkUrl=http://dl.google.com/android/android-sdk_r23.0.2-linux.tgz
AndroidSdkFile=${AndroidSdkUrl##*/}
AndroidSdkApi="20.0.0" # The folder named after the api version installed. Used to fix a path.

# Compatibility elements for the android SDK and Wine
AndroidSdkWineCompatUrl=http://github.com/joseluis/B4LinuxInstall/raw/master/sdk-B4A.tar.gz
AndroidSdkWineCompatFile=${AndroidSdkUrl##*/}

# Wine version to use
WinePkg="wine1.6" # stable version, preferred
#WinePkg="wine1.7" # beta version, not needed

# ORACLE JAVA
# ----------------------------------------------------------------------
#
# WARNING: Please make sure to update the MD5SUM when updating a file link
#
# Checksum for Java SE 7u67 binaries
# https://www.oracle.com/webfolder/s/digest/java-se-binaries-checksum-1956892.html
# Checksum for Java SE 8u20 binaries
# https://www.oracle.com/webfolder/s/digest/javase8-binaries-checksum-2133161.html


# JDK for Windows
JdkWindowsUrl=http://download.oracle.com/otn-pub/java/jdk/7u67-b01/jdk-7u67-windows-i586.exe # version 1.7
JdkWindowsMd5=dbe6f185f836cd43221827eae1dfff79

#JdkWindowsUrl=http://download.oracle.com/otn-pub/java/jdk/8u20-b26/jdk-8u20-windows-i586.exe # version 1.8 fails installation on wine
#JdkWindowsMd5=a32589ba83f3aa5a8b1737339604b609

JdkWindowsPack=${JdkWindowsUrl##*/}

# JDK for Linux
JdkLinuxUrl32=""
JdkLinuxMd532=""
JdkLinuxFile32=${JdkLinuxUrl32##*/}

JdkLinuxUrl64=""
JdkLinuxMd564=""
JdkLinuxFile64=${JdkLinuxUrl64##*/}

# JavaFX Scene Builder for Linux
JavaFxSBUrl32=http://download.oracle.com/otn-pub/java/javafx_scenebuilder/2.0-b20/javafx_scenebuilder-2_0-linux-i586.deb
JavaFxSBMd532=43ddb9463a784c23a8691932294a3db1
JavaFxSBFile32=${JavaFxSBUrl32##*/}

JavaFxSBUrl64=http://download.oracle.com/otn-pub/java/javafx_scenebuilder/2.0-b20/javafx_scenebuilder-2_0-linux-x64.deb
JavaFxSBMd564=2f3028d4164a09b0a20ee7ea7b942187
JavaFxSBFile64=${JavaFxSBUrl64##*/}


# GLOBAL SYSTEM VARIABLES
# ######################################################################

# 32 or 64 bits
[ $(uname -m) == "x86_64" ] && SObits="64" || SObits="32"

# Text color variables
txtred=$(tput setaf 1)		# Color Red
txtgre=$(tput setaf 2)		# Color Green
txtyel=$(tput setaf 3)		# Color Yellow
txtblu=$(tput setaf 4)		# Color Blue
txtmag=$(tput setaf 5)		# Color Magenta
txtcya=$(tput setaf 6)		# Color Cyan
txtwhi=$(tput setaf 7)		# Color White
txtbld=$(tput bold)		# Style Bold
txtund=$(tput sgr 0 1)		# Style Underline

txtRST=$(tput sgr0)		# Style Reset

txtSECT=${txtwht}${txtbld}	# Section
txtINFO=${txtwhi}		# Info
txtPASS=${txtgre}		# Passed
txtWARN=${txtyel}		# Warning
txtERR=${txtred}		# Error
txtQUES=${txtmag}		# Question
txtCODE=${txtblu}		# Code


# UTILITY FUNCTIONS
# ######################################################################

# Checks if a command is available
# Params: $1=name
bin_exists() {
	command -v ${1} >/dev/null 2>&1
}

# Checks if a package is installed
# Params: $1=Name
package_exists() {
	
	# <DPKG>
	res=$( dpkg-query -l 2>/dev/null "${1}" | tail -1 | awk '{ print $1 }' )
	[ "${res}" == "ii" ]
}

# Downloads a file from oracle.com and saves it to ${TmpDir}
# Params: $1=URL
oracle_download() {
	wget --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" -P ${TmpDir} ${1}
}


# WINE FUNCTIONS
# ######################################################################

init_winedir() {
	Winedir=${1}
	winTmpDirU="${Winedir}/dosdevices/c:/windows/temp"
	winTmpDirW="C:\\windows\\Temp"
}

override_app_dlls() {
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


# SETUP FOLDERS
# ######################################################################
TmpDir=${wksB4}/temp
WineB4=${wksB4}/wine_b4
init_winedir ${WineB4}

# creating workspace folder
if ! [ -d "${wksB4}" ]; then
	mkdir ${wksB4}
fi

# creating temporary folder
if [ -d "${TmpDir}" ]; then
	rm -r ${TmpDir}
fi
mkdir ${TmpDir}


# ORACLE JAVA INSTALLATION (LINUX)
# ######################################################################

echo -e "\n${txtSECT}Installing Java for Linux..."
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
	if [ "$yn" = "y" ]; then
		
		# <UBUNTU>
		echo "${txtINFO}We are going to execute these commands:${txtRST}"
		echo "    ${txtCODE}sudo add-apt-repository ppa:webupd8team/java"
		echo "    sudo apt-get update"
		echo "    sudo apt-get install oracle-java8-installer"
		echo "    sudo update-java-alternatives -s java-8-oracle${txtRST}"
		
		read -p "${txtQUES}Continue? (y/n) ${txtRST}"
		if [ "$yn" = "y" ]; then
			sudo add-apt-repository ppa:webupd8team/java
			sudo apt-get update
			sudo apt-get install oracle-java8-installer
			sudo update-java-alternatives -s java-8-oracle
		fi
	fi
fi


# JAVA FX SCENE BUILDER INSTALLATION (LINUX)
# ######################################################################

# <ORACLE>

echo -e "\n${txtSECT}Installing Java FX Scenebuilder for Linux..."
echo "--------------------------------------------${txtRST}"
if ! package_exists scenebuilder; then # TODO: make a deeper check

# Package to download, depending on architecture and package manager
		
	read -p "${txtQUES}You need Oracle Java FX Scenebuilder. Do you want to install it now? (y/n) ${txtRST}" yn

	if [ "$yn" = "y" ]; then

			
		echo "${txtINFO}We are going to download the package and execute these commands:${txtRST}"
		
		# <DPKG>
		JavaFxSBUrl="JavaFxSBUrl${SObits}"
		JavaFxSBUrl=${!JavaFxSBUrl}
		JavaFxSBFile="JavaFxSBFile${SObits}"
		JavaFxSBFile=${!JavaFxSBFile}	
		echo "${txtCODE}    sudo dpkg -I ${JavaFxSBFile}${txtRST}"
		
		read -p "${txtQUES}Continue? (y/n) ${txtRST}"
		if [ "$yn" = "y" ]; then
			oracle_download ${JavaFxSBUrl}
			sudo dpkg -i ${TmpDir}/${JavaFxSBFile} # TODO: create function package_install
		fi
	fi
	
else
	echo "${txtPASS}You seem to have Java FX SceneBuilder already installed.${txtRST}"
fi


# ANDROID SDK INSTALLATION (LINUX)
# ######################################################################

# The only components that needs to be installed are:
# Inside Tools: SDK Platform-tools + Build-tools (both selected by default)
# Inside the last stable API: SDK Platform + one System Image (e.g. x86 Atom)

echo -e "\n${txtSECT}Installing Android SDK for Linux..."
echo "--------------------------------------------${txtRST}"

# Android SDK Installation
if ! [ -d "${wksB4}/android-sdk-linux/" ]; then
	read -p "${txtQUES}Do you want to install Android SDK? (y/n) ${txtRST}" yn
	if [ "$yn" = "y" ]; then
		wget -P ${TmpDir} ${AndroidSdkUrl};
		tar -zxvf ${TmpDir}/${AndroidSdkFile} -C ${wksB4}
		${wksB4}/android-sdk-linux/tools/android 2>/dev/null
	fi
	
	# Fix missing path when compiling with b4a
	ln -sf ../build-tools/${ApiFolder}/lib ${wksB4}/android-sdk-linux/platform-tools/lib
	
else
	echo "${txtPASS}Android SDK is already installed${txtRST}"

fi

# Adaptation for Android SDK (for Wine compatibility)
if [ -d "${wksB4}/android-sdk-linux/tools/" ] && (! [ -f "${wksB4}/android-sdk-linux/platform-tools/adb.exe" ]); then
	echo "echo OFF" > ${wksB4}/android-sdk-linux/tools/android.bat
	echo "start /unix ${wksB4}/android-sdk-linux/tools/android avd" >> ${wksB4}/android-sdk-linux/tools/android.bat
	wget -P ${TmpDir} -O ${TmpDir}/${AndroidSdkWineCompatFile} ${AndroidSdkWineCompatUrl};  # TODO: change file to sdk-B4.tar.gz ..?
	tar -xzvf ${TmpDir}/${AndroidSdkWineCompatFile} -C ${wksB4}/android-sdk-linux
else
	echo "${txtPASS}Compatibility elements for Android SDK with Wine are already installed${txtRST}"
fi


# WINE INSTALLATION (LINUX)
# ######################################################################

echo -e "\n${txtSECT}Installing Wine for Linux..."
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
	if [ "$yn" = "y" ]; then
	
	# <UBUNTU>
	
		sudo add-apt-repository ppa:ubuntu-wine/ppa
		sudo apt-get update
		sudo apt-get install ${WinePkg} winetricks
	fi
fi

# Environment preparation for Wine (32 bits)
if ! [ -d "${WineB4}" ]; then
	# TODO: It needs to pause here
	echo "${txtINFO}Initializing Wine's environment. . .${txtRST}"
	WINEARCH=win32 WINEPREFIX=${WineB4} wine do_not_exists 2>/dev/null
	WINEARCH=win32 WINEPREFIX=${WineB4} winetricks dotnet20
else
	echo "${txtPASS}Environment for Wine 32 bits width dotnet20 is already installed${txtRST}"
fi


# ORACLE JAVA JDK INSTALLATION (WINE)
# ######################################################################

# The only component that needs to be installed is the Development Tools
# Don't install the Source Code nor the Public JRE

echo -e "\n${txtSECT}Installing Java 1.7 for Windows 32bit. . ."
echo "--------------------------------------------${txtRST}"
# NOTE: Java 1.8 gives error in installation
#
# <ORACLE>

if ! [ -d "${WineB4}/drive_c/Program Files/Java/" ]; then
	read -p "${txtQUES}Do you want to install JDK for windows? (y/n) ${txtRST}" yn
	if [ "$yn" = "y" ]; then
		oracle_download ${JdkWindowsUrl}
		WINEARCH=win32 WINEPREFIX=${WineB4} wine ${TmpDir}/${JdkWindowsPack}
	fi
else
	echo "${txtPASS}JDK for Windows is already installed${txtRST}"
fi


# B4A INSTALLATION (WINE)
# ######################################################################

# TODO: Test if it's ok launching it after installation

echo -e "\n${txtSECT}Installing B4A for Windows 32bit..."
echo "--------------------------------------------${txtRST}"

if [ -f "${WineB4}/drive_c/Program Files/Anywhere Software/Basic4android/Basic4android.exe" ]; then
	echo "${txtPASS}B4A is already installed${txtRST}"
	read -p "${txtQUES}Do you want to update B4A? (y/n) ${txtRST}" yn
else
	read -p "${txtQUES}Do you want to install B4A? (y/n) ${txtRST}" yn
fi

if [ "$yn" == "y" ]; then 
	wget -P ${TmpDir} ${b4aURL}
	WINEARCH=win32 WINEPREFIX=${WineB4} wine ${TmpDir}/${b4aFile} 2>/dev/null
	override_app_dlls Basic4android.exe gdiplus native
	
fi

	B4A_desktop="B4A.desktop" # before: Basic4android.desktop	
	if ! [ -f "${wksB4}/${B4A_desktop}" ]; then
		echo "[Desktop Entry]" >${wksB4}/${B4A_desktop}
		echo "Name=B4A" >>${wksB4}/${B4A_desktop}
		echo "Exec=env WINEPREFIX="\"${WineB4}\"" wine C:\\\\\\\\windows\\\\\\\\command\\\\\\\\start.exe /Unix ${WineB4}/dosdevices/c:/users/Public/Start\\\\ Menu/Programs/Basic4android/Basic4android.lnk" >>${wksB4}/${B4A_desktop}
		echo "Type=Application" >>${wksB4}/${B4A_desktop}
		echo "StartupNotify=true" >>${wksB4}/${B4A_desktop}
		echo "Path=${WineB4}/dosdevices/c:/Program Files/Anywhere Software/Basic4android" >>${wksB4}/${B4A_desktop}
		echo "Icon=B5FB_Basic4android.0" >>${wksB4}/${B4A_desktop}
		chmod +x ${wksB4}/${B4A_desktop}
	else
		echo "${txtPASS}Link for B4A already exists${txtRST}"
	fi


# B4J INSTALLATION (WINE)
# ######################################################################

echo -e "\n${txtSECT}Installing B4J for Windows 32bit..."
echo "--------------------------------------------${txtRST}"

# TODO: Test if it's ok launching it after installation

if [ -f "${WineB4}/drive_c/Program Files/Anywhere Software/B4J/B4J.exe" ]; then
	echo "${txtPASS}B4J is already installed${txtRST}"
	read -p "${txtQUES}Do you want to update B4J? (y/n) ${txtRST}" yn
else
	read -p "${txtQUES}Do you want to install B4J? (y/n) ${txtRST}" yn
fi

if [ "$yn" == "y" ]; then
	wget -P ${TmpDir} ${b4jURL}
	WINEARCH=win32 WINEPREFIX=${WineB4} wine ${TmpDir}/${b4jFile} 2>/dev/null
	override_app_dlls B4J.exe gdiplus native
	
fi
	B4J_desktop="B4J.desktop"	
	if ! [ -f "${wksB4}/${B4J_desktop}" ]; then
		echo "[Desktop Entry]" >${wksB4}/${B4J_desktop}
		echo "Name=B4J" >>${wksB4}/${B4J_desktop}
		echo "Exec=env WINEPREFIX="\"${WineB4}\"" wine C:\\\\\\\\windows\\\\\\\\command\\\\\\\\start.exe /Unix ${WineB4}/dosdevices/c:/users/Public/Start\\\\ Menu/Programs/B4J/B4J.lnk" >>${wksB4}/${B4J_desktop}
		echo "Type=Application" >>${wksB4}/${B4J_desktop}
		echo "StartupNotify=true" >>${wksB4}/${B4J_desktop}
		echo "Path=${WineB4}/dosdevices/c:/Program Files/Anywhere Software/B4J" >>${wksB4}/${B4J_desktop}
		echo "Icon=7BEB_B4J.0" >>${wksB4}/${B4J_desktop}
		chmod +x ${wksB4}/${B4J_desktop}
	else
		echo "${txtPASS}Link for B4J already exists${txtRST}"
	fi


# CLEANUP & EXIT
# ######################################################################

# TODO: Make this an option in the menu. Show size.

echo -e "\n${txtSECT}Cleanup & exit"
echo "--------------------------------------------${txtRST}"

read -p "${txtQUES}Do you want to delete the temporary downloaded files? (y/n) ${txtRST}" yn
if [ "$yn" = "y" ]; then
	echo "${txtINFO}Deleting ${TmpDir} . . .${txtRST}"
	rm -r ${TmpDir}
fi


echo -e "\n${txtcya}Bye!${txtRST}\n"

