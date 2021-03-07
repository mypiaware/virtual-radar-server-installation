# Virtual Radar Server Installation Script

This script is a very helpful tool to easily install Virtual Radar Server on Linux.

Virtual Radar Server (VRS) provides an amazing webpage display of any aircraft detected by an ADS-B receiver.  This script will help with the installation of VRS to those who are brand new to VRS.  With just a few keystrokes, VRS may be installed and operating with planes appearing on the VRS webpage.  This is assuming an ADS-B receiver has already been built and is operating properly.  (It is possible for VRS to also be installed on a ADS-B receiver device.)

This script is only intended to get VRS installed, configured and running as quickly as possible for the novice user.  Many more options are left to the user for further customization of VRS.  Some research and experimenting is encouraged and expected to enhance and secure VRS.

When this VRS installation script finishes, some very useful information will be displayed specific to that particular installation. It will be useful to read and record this information.

This script may be safely ran multiple times if wanting to change a few of the settings from the original installation.

This script has been confirmed to work with VRS version 2.4.4 (the latest stable release) on:
* Raspberry Pi OS Buster (32-bit -- Desktop & Lite)
* Debian 10.8
* Fedora 33
* openSUSE 15.2
* Arch Linux

This script may also install VRS on other popular Linux distributions such as Ubuntu.  However, please read the important note below regarding other operating systems and the [Mono issue](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#mono-issue).  Note that "Raspberry Pi OS" was recently known as "Raspbian".

If this scripts fails to install because it is reporting that the operating system is not recognized or supported, please try the following steps below for [advanced users](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#advanced-users).

For anyone interested in trying a preview version (versions 2.4.5 or 3.0.0), this installation script offers the choice to install a preview version instead of the stable version (ver 2.4.4).  Even though it is always risky to install a preview version that is under development, the [Mono issue](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#mono-issue) may make a preview version the better choice under certain circumstances.

The author of this VRS installation script has nothing to do with the creation, development or support of VRS.  Please visit the VRS website and also consider donating towards this amazing project:  [www.virtualradarserver.co.uk](http://www.virtualradarserver.co.uk/ "Virtual Radar Server")


An example of a VRS webpage:
![VRS Webpage](https://i.imgur.com/JUuRSxA.png "VRS Webpage")

## Overview

Here is a very brief summary of what this script will do:

* [Install VRS](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#how-to-install-vrs)
  * Install Mono (necessary to run VRS on Linux)
  * Install VRS server files
  * Install a small VRS Mono fix (only needed for the stable version)
* [Download and install the following VRS plugins:](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#vrs-plugins)
  * Custom Content Plugin
  * Database Editor Plugin
  * Database Writer Plugin
  * Tile Server Cache Plugin
  * Web Admin Plugin
  * Feed Filter Plugin (only with a preview version of VRS)
  * SQL Server Plugin (only with preview version 3.0.0 of VRS)
* [Download and install the VRS language packs](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#language-packs)
* [Fix libpng warnings](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#fix-libpng-warnings)
* [Download additional files (all optional):](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#download-additional-files)
  * Airline operator flags
  * Aircraft silhouettes
  * Aircraft pictures
  * Sample database
* Allow the user to select/enter the following:
  * [Which port number the VRS server should use](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#server-port-number)
  * [Which default language the VRS webpage should display](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#webpage-default-language)
  * [The latitude and longitude of the center of the VRS webpage map](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#center-location-of-the-vrs-map)
  * [Enter a receiver](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#enter-a-receiver)
* [Create a set of directories to contain most of the user's custom files](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#directory-structure)
* [Auto-fill the directory/file paths in the VRS server settings for a few of the custom directories/files](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#auto-fill-directory--file-paths)
* [Create a global command to start VRS](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#global-command-to-start-vrs)
* [Create a script to routinely backup the database file](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#script-to-backup-database)
* [Provide an easy method of displaying an announcement at the top of the VRS webpage](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#display-an-announcement-on-the-webpage)

---

## How to Install VRS
```
bash -c "$(wget -O - https://github.com/mypiaware/virtual-radar-server-installation/raw/master/virtual_radar_server_install.sh)"
```
Run the above one-line command to execute this VRS installation script. The vast majority of the installation time will involve installing Mono (if Mono is not already installed) which is a prerequisite to installing VRS.

## VRS Plugins

This VRS installation script will install the following VRS plugins. Note that many of the plugins are disabled by default.  Click on each for more information on the plugin.
  * [Custom Content Plugin](http://www.virtualradarserver.co.uk/Documentation/CustomContent/Default.aspx)
  * [Database Editor Plugin](http://www.virtualradarserver.co.uk/Download.aspx#panel-database-editor)
  * [Database Writer Plugin](http://www.virtualradarserver.co.uk/Documentation/DatabaseWriter/Default.aspx)
  * [Tile Server Cache Plugin](http://www.virtualradarserver.co.uk/Download.aspx#panel-tileservercache)
  * [Web Admin Plugin](http://www.virtualradarserver.co.uk/Download.aspx#panel-web-admin)
  * Feed Filter Plugin (only with a preview version of VRS)
  * SQL Server Plugin (only with preview version 3.0.0 of VRS)

## Language Packs

This VRS installation script will download and install the language packs that will be used by the VRS server settings interface.  Based on the current language set for the Linux operating system, the VRS server settings interface will automatically set the language to be used.  Not all languages are supported. [More info](http://www.virtualradarserver.co.uk/Download.aspx#panel-translations)

## Fix libpng warnings

The stable version of VRS (ver 2.4.4) can produce "libpng warning" messages at the command line.  The problem resides with two image files in the `images/markers` directory used to display a generic airplane marker on the VRS webpage.  The following steps fix the issue:

  * Filenames need to be changed:
    * `Marker_Airplane.png` to `Airplane.png`
    * `Marker_AirplaneSelected.png` to `AirplaneSelected.png`
  * Each of these two image files also need to have its color profile converted.

This VRS installation script will download and install two image files that have already been corrected to the `CustomWebFiles` directory to eliminate these messages from appearing.  The Custom Content Plugin will utilize these two corrected image files.  Therefore, the Custom Content Plugin should be enabled and the "Site root folder" field in the Custom Content Plugin should be properly set.  By default, this script will ensure these conditions are met.  It is recommended to apply this fix as there is no known reason why this fix should not be applied.

## Download Additional Files

This VRS installation script will also provide the option to download some sample files to help enhance the VRS webpage if the user does not already have any of these files. These files will be downloaded to the directories described below. These additional files include:
  * Airline operator flags (downloaded to the `OperatorFlags` directory)
  * Aircraft silhouettes (downloaded to the `Silhouettes` directory)
  * Aircraft pictures (downloaded to the `Pictures` directory)
  * A sample database (downloaded to the `Databases/Database` directory)

## Server Port Number

The VRS server will use a port number.  This port number must be set and will be used in the URL to access the VRS webpage.  For example, the URL for a VRS webpage on a local network using port 8090 may appear as such:  
```
http://192.168.1.100:8090/VirtualRadar
```
This VRS installation script will prompt the user for the port number the VRS server should use.  By default, a typical installation of VRS will use port 8080 for the server port.  However, this VRS installation script will use 8090 as the default port number in the event the same system is running FlightAware's SkyAware (formerly called "Skyview") - which uses port 8080.  The user is free to choose any available port number.  However, this script will not check if the selected port number is available.

## Webpage Default Language

The default language for the VRS webpage from a typical installation of VRS is "English (United Kingdom)".  However, this script will allow the user to choose from a limited number of languages and regional locales.

## Center Location of the VRS Map

The user has an option of entering the GPS coordinates for the center of the VRS webpage map.  The benefit of this is to have the map centered exactly where the user would like it to be centered from the very first time the VRS webpage is accessed.  Otherwise, the default center of the map will be near London.

## Enter a Receiver

The user has an option of adding and entering the configuration information of an ADS-B receiver.  There are four critical parameters to enter for a receiver:

  * Receiver name:  User may enter an arbitrary name for the receiver.  The name may essentially have nearly any alphanumeric character, spaces, and most symbols.
  * Receiver source type:  There are six options for the source type.  It may take some knowledge in choosing the appropriate source.  However, if the ADS-B receiver is using FlightAware's PiAware, then the user may consider selecting "AVR or Beast Raw Feed".
  * Receiver IP address:  The IP address of the ADS-B receiver device.  If VRS is installed on the same device as the receiver, the user should enter 127.0.0.1 as the IP address.
  * Receiver IP port:  Enter the ADS-B receiver's port value that is supplying the aircraft messages.  If using FlightAware's PiAware, the user may consider using port 30005 for non-MLAT messages, or port 30105 for MLAT messages.

It is possible the receiver parameters set by this installation script may not be adequate for some receivers. For those rare occasions, the receiver can always still be further modified in the VRS server settings after VRS is installed.

This script will only ask the user to enter information for one receiver.  However, more receivers may be added in the VRS server settings after VRS is installed.  It is possible to run this script multiple times and add an additional receiver each time the script is ran.

## Directory Structure

This VRS installation script will create a directory structure to conveniently contain the VRS installation files and most of the user's custom files all under one directory.  This section will describe the purpose of each of the directories and some of the files contained in the directories.  Advanced users may edit the VRS installation script to relocate or rename some of these directories and files.  However, the information below will give the description of the default directory structure produced by this script.

Here is a visual of the default directory structure:

![VRS Directory Structure](https://i.imgur.com/YUKq8bl.png "VRS Directory Structure")

### Installation

This directory contains the main installation of VRS. There should never be any need to edit the contents of this directory.

### VRS-Extras

This directory contains many of the user's custom files used to enhance and support the VRS webpage. Here are all of the subdirectories under the `VRS-Extras` directory:

#### CustomContent/CustomInjectedFiles

VRS webpage files simply can not be removed or edited in any way, otherwise VRS will not start. However, it is possible to make small additions (also known as "injections") to the HTML files used by VRS found in the `Installation/Web` directory and any possible subdirectories. The Custom Content Plugin is a tool to allow such injections, and the Custom Content Plugin will utilize files in this `CustomInjectedFiles` directory. This directory can contain files with HTML code to be injected into any existing VRS HTML file. By default, an `Announcement.html` file is already created in this directory to be injected into both the `Installation/Web/desktop.html` and `Installation/Web/mobile.html` files. This `Announcement.html` file may be used to produce a small announcement bar at the top of the VRS webpage.  This could be useful to make an announcement that the server will be under maintenance for a short amount of time, for example. Even if this `Announcement.html` is never utilized, it does provide a decent example to the novice user of how the Custom Content Plugin utilizes the Custom Injected Files.  [More info](http://www.virtualradarserver.co.uk/Documentation/CustomContent/Default.aspx#inject-file)

#### CustomContent/CustomWebFiles

VRS webpage files simply can not be removed or edited in any way, otherwise VRS will not start.  However, if wanting to entirely replace any of the existing VRS webpage files, simply make a copy of the webpage file and place it within this `CustomWebFiles` directory.  The Custom Content Plugin is a tool to allow for such webpage file replacements to occur, and the Custom Content Plugin will utilize the webpage files in this directory and any possible subdirectories. This `CustomWebFiles` directory should replicate the actual root directory structure found in the `Installation/Web` directory and its subdirectories. Therefore, be sure to also add any subdirectories, if needed, to this `CustomWebFiles` directory. This VRS installation script will produce five HTML files in this `CustomWebFiles` directory to change the default language of the VRS webpage. [More info](http://www.virtualradarserver.co.uk/Documentation/CustomContent/Default.aspx#site-root-folder)

#### Databases/Database

This `Database` directory will contain the one `BaseStation.sqb` database file used by VRS to record all of the aircraft seen by VRS.  A `BaseStation.sqb` file may be created from scratch or a sample `BaseStation.sqb` database file may be downloaded with this VRS installation script.  The Database Writer Plugin and the Database Editor Plugin will use this database file. [More info](http://www.virtualradarserver.co.uk/Documentation/DatabaseWriter/Default.aspx)

#### Databases/DatabaseBackup

This VRS installation script will create a `backupvrsdb.sh` script in this `DatabaseBackup` directory that may be used by a [cron job](https://www.cyberciti.biz/faq/how-do-i-add-jobs-to-cron-under-linux-or-unix-oses/ "Good cron job tutorial") to routinely backup the `BaseStation.sqb` database file located in the `Database` directory.  Running this script will create a copy of the `BaseStation.sqb` database file and place the copy in this `DatabaseBackup` directory.  The copied database file will be named `BaseStation_BACKUP.sqb`.  Note that the database should only be backed up at time when VRS is known to have the fewest planes visible.  Here is an example of a cron job utilizing the `backupvrsdb.sh` script to backup the database every day at 3:00 AM.
```
0 3 * * * bash /home/<username>/VirtualRadarServer/VRS-Extras/Databases/DatabaseBackup/backupvrsdb.sh
```

#### OperatorFlags

This directory will store all of the *\*.bmp* airline operator flag files. If VRS detects the airline ICAO code for a particular aircraft, and a *\*.bmp* image file exists in the `OperatorFlags` directory for that particular airline ICAO code, then VRS will display the *\*.bmp* image that is named with the same airline ICAO code. ([More info](http://www.virtualradarserver.co.uk/Documentation/WebServer/DataSourcesOptions.aspx#flags-folder)) An example of an operator flag named `AAL.bmp` for American Airlines:

![American Airlines operator flag](https://i.imgur.com/Od7H8Tw.png "American Airlines operator flag")


#### Pictures

If the user has any personal pictures of any aircraft, those pictures may be placed in this `Pictures` directory.  The filename of each picture should simply be either the ICAO24 hex code or the registration number (tail number) of the aircraft.  When an aircraft is detected by VRS, VRS will display the picture of this aircraft from within this `Pictures` directory on the VRS webpage.  [More info](http://www.virtualradarserver.co.uk/Documentation/WebServer/DataSourcesOptions.aspx#pictures-folder)

#### Silhouettes

This directory may contain silhouette *\*.bmp* images of aircrafts. If a silhouette image for a particular type of aircraft is in this `Silhouettes` directory, and VRS sees an aircraft of this same type, then VRS will display the silhouette image of that aircraft in the list of aircrafts on the VRS webpage. The filename of each silhouette image should be the same as the ICAO type code for the aircraft. ([More info](http://www.virtualradarserver.co.uk/Documentation/WebServer/DataSourcesOptions.aspx#silhouettes-folder))
An example of a silhouette image named `B748.bmp` for a Boeing 747-800 aircraft:

![Boeing 747-800 silhouette](https://i.imgur.com/HuYWHFZ.png "Boeing 747-8 silhouette")

#### TileCache

This directory will hold cached copies of map tiles from the tile servers if the Tile Server Cache Plugin is enabled.  This may improve the load time of the map tiles appearing on the VRS webpage. [More info](http://www.virtualradarserver.co.uk/Download.aspx#panel-tileservercache)

## Auto-fill Directory & File Paths

This VRS installation script will auto-fill the paths of directories and files in the VRS server settings for the simple sake of convenience.

## Global Command to Start VRS

This VRS installation script will create a global command to allow the user to quickly and easily start VRS. This `vrs` command will provide options as to how VRS is started as well as providing an option of having VRS start at every system boot.  After this VRS installation script is finished, simply run this command:

`vrs`

The `vrs` command will provide options on how a user may want to start or stop VRS.  These are all the command options:

| Command         | Description                                                     |
| --------------- | --------------------------------------------------------------- |
| `vrs -gui`      | Start VRS with a GUI in a GUI desktop environment               |
| `vrs -nogui`    | Start VRS without a GUI                                         |
| `vrs -startbg`  | Start VRS as a background service                               |
| `vrs -stopbg`   | Stop VRS if running as a background service                     |
| `vrs -enable`   | Allow VRS to start at every system boot as a background service |
| `vrs -disable`  | Disable VRS from starting at every system boot                  |
| `vrs -webadmin` | Create username & password for Web Admin & also start VRS       |
| `vrs -log`      | View history log of VRS running as a background service         |
| `vrs -?`        | Display the help menu                                           |

#### Further notes on using the `vrs` command:

`vrs -gui` will start VRS with a GUI as long as the command is executed in a GUI desktop environment.  If `vrs -gui` is attempted in a command-line environment, VRS will fail to load.

`vrs -nogui` will start VRS without the GUI.  VRS will start and operate fine in a command-line interface environment with this `-nogui` option.  However, two things should be noted:
  * To view a GUI webpage interface for the VRS server settings, the [VRS Web Admin](http://www.virtualradarserver.co.uk/Download.aspx#panel-web-admin) plugin should be utilized.  The Web Admin username and password may be created with the `vrs -webadmin` command.
  * If using an SSH client (such as [PuTTY](https://www.putty.org "PuTTY's homepage")), the terminal window will need to remain open.  However, if wanting to close the terminal window, installing a utility such as [screen](https://www.tecmint.com/screen-command-examples-to-manage-linux-terminals/ "Good screen tutorial") will allow VRS to continue running even if the terminal window is closed.

`vrs -startbg` will allow the user to quickly and easily start VRS as a background process. This can be especially useful if wanting to run VRS in a command-line environment and not wanting to bother with running a program such as [screen](https://www.tecmint.com/screen-command-examples-to-manage-linux-terminals/ "Good screen tutorial"). `vrs -stopbg` will stop VRS only if it has already been started as a background process.  Just as with the `vrs -nogui` command, the [VRS Web Admin](http://www.virtualradarserver.co.uk/Download.aspx#panel-web-admin) will need to be used to access all the VRS settings.

`vrs -enable` will enable VRS to start at every system boot as a background process. `vrs -disable` will prevent VRS from starting at every system boot.

`vrs -webadmin` will allow the user to create a username & password for accessing the VRS Web Admin webpage. Note that this will also start VRS without a GUI. If not wanting VRS to run, the user will simply need to wait until VRS has completely started and then press `Q ` to quit VRS.

`vrs -log` will show the log of the previous instances of VRS running as a background process since the most recent system boot. The log will only show the records of the previous instances of VRS running as a background process. This includes any instance of VRS that may have started at system boot if the `vrs -enable` command was used to start VRS at every system boot.

`vrs` command just by itself will give the current running status of VRS and the help menu.

## Script to Backup Database

This VRS installation script will also create a script to backup the database file through a [cron job](https://www.cyberciti.biz/faq/how-do-i-add-jobs-to-cron-under-linux-or-unix-oses/ "Good cron job tutorial").  By default, the script is called `backupvrsdb.sh` and is located in the `Databases/DatabaseBackup` directory. [More info](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#databasesdatabasebackup)

## Display an Announcement on the Webpage

As already described above in the ["CustomInjectedFiles"](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#customcontentcustominjectedfiles) description, a template HTML file will be created by this VRS installation script to help display an announcement at the top of the VRS webpage.  Simply edit the existing `Announcement.html` file in the `CustomContent/CustomInjectedFiles` directory to display whatever text deemed necessary at the top of the VRS webpage.

<br/><br/>
# Other Information
<br/><br/>

## Installation Summary

When this VRS installation script finishes, some very useful information will be displayed specific to that particular installation. It will be useful to read and record this information.

## Ubuntu Fix

When starting VRS in a few versions of Linux, an error message may appear that reads: `Failed to load module "canberra-gtk-module"`.  No known issue with VRS has come from this error.  However, this installation script installs `libcanberra-gtk-module` just to be safe and to prevent this error message from appearing.

## Advanced Users

If this scripts fails to install because it is reporting that the operating system is not recognized or supported, please try to manually install Mono on the operating system first and then running this VRS installation script only after Mono is installed.  For any Linux operating system, if Mono is already installed, this script will simply bypass any attempt to install Mono and simply install the VRS files.  VRS will get installed just as fine as with any other supported Linux operating system.  However, the user will need to fully test if VRS works as expected on that particular operating system.  Also note that a few Linux distributions do not have `unzip` already installed.  Therefore, it may also be necessary to manually install `unzip`.

## Mono Issue

This script will install VRS on most popular Linux distributions.  However, VRS on a few operating systems could possibly have an issue with the latest versions of Mono.

The stable version of VRS (ver 2.4.4) appears to have an issue with the latest versions of Mono (versions equal to or greater than 6.4) on some Debian-based operating systems.  The issue is the plane icons and the altitude stalks will not appear on the VRS webpage.

However, the preview versions (versions 2.4.5 or 3.0.0) of VRS will not have this issue with the latest versions of Mono.  The drawback is that these preview versions are under development.

This VRS installation script allows the user to choose to install either the latest stable version or an under-development preview version.  If wanting to change from one version to another, simply run the script again and choose another version to install.  This script will cleanly remove whichever version was already installed by this script and then install the newly selected version.

Although installing a preview version (versions 2.4.5 or 3.0.0) of VRS may solve the Mono issue, a preview version may introduce additional unforseen issues.  Please use caution when installing a preview version.

If any method of downgrading Mono has been found for the operating systems that need to have Mono downgraded, please kindly post instructions in the Issues section of this GitHub project.  Thanks in advance!

As of this writing, the default versions of Mono that will get installed on the following operating systems are:

| Linux                    | Default Mono Version Installed |Stable Version Works?|
| ------------------------ |:------------------------------:|:-------------------:|
| Raspberry Pi OS (Buster) | 5.18.0.240                     | :heavy_check_mark:  |
| Debian 10.8              | 5.18.0.240                     | :heavy_check_mark:  |
| Ubuntu 18.04.5 LTS       | 4.6.2.7                        | :heavy_check_mark:  |
| Ubuntu 20.04.2 LTS       | 6.8.0.105                      | :x:                 |
| Ubuntu 20.10             | 6.8.0.105                      | :x:                 |
| Linux Mint 19.3          | 4.6.2.7                        | :heavy_check_mark:  |
| Linux Mint 20.1          | 6.8.0.105                      | :x:                 |
| Fedora 31*               | 5.20.1.34                      | :heavy_check_mark:  |
| Fedora 32*               | 6.6.0.166                      | :heavy_check_mark:  |
| Fedora 33*               | 6.8.0.123                      | :heavy_check_mark:  |
| openSUSE 15.2*           | 6.8.0.105                      | :heavy_check_mark:  |
| Arch Linux*              | 6.12.0                         | :heavy_check_mark:  |


\* Stable version of VRS works fine on Fedora, openSUSE and Arch Linux regardless of which version of Mono was installed.
