B4LinuxInstall
==============

Install [www.b4x.com](http://www.b4x.com) RAD tools (B4J, B4A, B4i) in Ubuntu & Mint.

:warning: Since I no longer use B4X I wont maintain this tool anymore. :warning:

If you fork it and continue developing it please open an Issue so I can link it in this README.


## Instructions

1. Download b4linuxinstall.sh script

    `wget https://raw.githubusercontent.com/joseluis/B4LinuxInstall/master/b4linuxinstall.sh`

1. If you have the full version of B4A and/or B4i download them too and put them in the same folder as the script. It should be able to recognize and use the installers.
1. Execute the script

    `bash ./b4linuxinstall.sh`


[See here usage demo video for a previous version (2014-11-22)](https://www.youtube.com/watch?v=s9ZQBiKHGJ8)

## Changelog
	- 20150127 Updated JDK versions; install wine-1.6 stable in 32bit systems and wine-1.7 in 64bit; minor updates
	- 20150117 new B4i install function; removed URL parameter in favor of installer file detection; minor fixes; updated comments
	- 20150116 updated android SDK version; updated URLs
	- 20141217 made clearer that JavaFX is only needed for B4J
	- 20141125 updated readme; minor bugfix
	- 20141112 updated java versions; minor fixes
	- 20140930 mayor version release


## License

This software is licensed under the [MIT License](http://opensource.org/licenses/MIT)

## Disclaimer

This script is not officially supported nor endorsed by Anywhere Software in any way, nor do I work for Anywhere Software. I am not responsible for any damages this script could cause to your system. I've been very careful to make it safe so there shouldn't be any problems, but ultimately you are responsible to ensure its safety before executing it.
