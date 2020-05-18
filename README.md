# Virtual Radar Server Installation Script

This script is a very helpful tool to easily install Virtual Radar Server on Linux.

Virtual Radar Server (VRS) provides an amazing website interface of aircraft viewable from an ADS-B receiver.  This script will help with the installation of VRS to those who are brand new to VRS.  With just a few keystrokes, VRS may be installed and operating with planes appearing on the VRS webpage.  This is assuming an ADS-B receiver has already been built and is operating properly.

This script is only intended to get VRS installed, configured and running as quickly as possible for the novice user.  Many more options are left to the user for further customization of VRS.  Some research and experimenting is encouraged and expected to enhance and secure VRS.

When this VRS installation script finishes, some very useful information will be displayed specific to that particular installation. It will be useful to read and record this information.

This script may be safely ran multiple times if necessary perhaps if needing to change a few of the settings from the original installation.

This script has been confirmed to work with VRS version 2.4.4 on Raspbian Buster (Desktop & Lite) & Lubuntu.

The author of this VRS installation script has nothing to do with the creation, development or support of VRS.  Please visit the VRS website and also consider donating towards this amazing project:  [www.virtualradarserver.co.uk](http://www.virtualradarserver.co.uk/)

## Overview

Here is a very brief summary of what this script will do:

* [Install VRS](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#how-to-install-vrs)
  * Install Mono (necessary to run VRS on Linux)
  * Install a quick fix to Mono
  * Download and install VRS server files
* [Download and install the following VRS plugins:](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#vrs-plugins)
  * Custom Content Plugin
  * Database Editor Plugin
  * Database Writer Plugin
  * Tile Server Cache Plugin
  * Web Admin Plugin
* [Download and install the VRS language packs](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#language-packs)
* Allow the user to select/enter the following:
  * [Which port number VRS should use](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#port-number)
  * [Which default language the VRS website should display](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#default-language)
  * [The latitude and longitude of the center of the VRS webpage map](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#latitiude-and-longitude-of-the-vrs-map)
  * [Enter a receiver](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#enter-a-receiver)
* [Download additional files (all optional):](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#download-additional-files)
  * Airline operator flags
  * Aircraft silhouettes
  * Aircraft pictures
  * Sample database
* [Create a set of directories to contain all of the user's custom files](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#directory-structure)
* [Auto-fill the directory/file paths in the VRS server settings for a few of the custom directories/files](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#auto-fill-directory--file-paths)
* Create additional commands/scripts
  * [A global command to start VRS](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#global-command-to-start-vrs)
  * [A script to routinely backup the database file](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#script-to-backup-database)
  * [A script to autorun VRS at system boot](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#script-to-autorun-vrs)
* [Provide an easy method of displaying an announcement at the top of the VRS webpage](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#display-an-announcement-on-the-webpage)

---

## How to Install VRS
```
bash -c "$(wget -O - https://github.com/mypiaware/virtual-radar-server-installation/raw/master/virtual_radar_server_install.sh)"
```
Run the above one-line command to execute this VRS installation script. The vast majority of the installation time will involve installing Mono which is a prerequisite to installing VRS.

## VRS Plugins

This VRS installation script will install the following five VRS plugins. Note that many of the plugins are disabled by default.  Click on each for more information on the plugin.
  * [Custom Content Plugin](http://www.virtualradarserver.co.uk/Documentation/CustomContent/Default.aspx)
  * [Database Editor Plugin](http://www.virtualradarserver.co.uk/Download.aspx#panel-database-editor)
  * [Database Writer Plugin](http://www.virtualradarserver.co.uk/Documentation/DatabaseWriter/Default.aspx)
  * [Tile Server Cache Plugin](http://www.virtualradarserver.co.uk/Download.aspx#panel-tileservercache)
  * [Web Admin Plugin](http://www.virtualradarserver.co.uk/Download.aspx#panel-web-admin)

## Language Packs

This VRS installation script will download and install the language packs created for VRS.  Based on the current language set for the Linux operating system, the VRS server interface will automatically set the language for the VRS server interface.  Not all languages are supported. [More info](http://www.virtualradarserver.co.uk/Download.aspx#panel-translations)

## Port Number

This VRS installation script will prompt the user for the port number VRS should use.  By default, a typical installation of VRS will use port 8080.  However, this VRS installation script will use 8090 as the default port number in the event the same system is running FlightAware's SkyAware SkyAware (formerly called "Skyview") - which uses port 8080.  The user is free to choose any available port number.

## Default Language

The default language for a typical VRS installation for the webpage is "English (United Kingdom)".  However, this script will allow the user to choose from a number of languages and regional locales.

## Latitiude and Longitude of the VRS Map

The user has an option of entering the center of the VRS webpage map.  The benefit of this is to have the map centered exactly where the user would like it to be centered from the very first time the VRS webpage is accessed.  Otherwise, the default center of the map is near London.

## Enter a Receiver

The user has an option of adding and entering the configuration information of a receiver.  There are four critical parameters to enter for a receiver:

  * Receiver name:  User may enter an arbitrary name for the receiver.  The name may essentially have nearly any alphanumeric character, spaces, and most symbols.
  * Receiver source type:  There are six options for the source type.  It may take some knowledge in choosing the appropriate source.  However, if the receiver is using FlightAware's PiAware, then it may be best to use "AVR or Beast Raw Feed".
  * Receiver IP address:  The IP address of the receiver device.  If VRS is installed on the same device as the receiver, the IP address will be 127.0.0.1.
  * Receiver IP port:  Enter the receiver's port value of the source of aircraft messages.  If using FlightAware's PiAware, the user may consider using port 30005 for non-MLAT messages, and 30105 for MLAT messages.
  
This script will only ask for the user to enter the informtion for one receiver.  However, more receivers may be added in the VRS server settings after VRS is installed.  However, it is possible to run this script multiple times and an additional receiver each time the script is ran.

## Download Additional Files

This VRS installation script will also provide the option to download some sample files to help enhance the VRS webpage if the user does not already have any of these files. These files will be downloaded to the directories described below. These additional files include:
  * Airline operator flags (downloaded to the `OperatorFlags` directory)
  * Aircraft silhouettes (downloaded to the `Silhouettes` directory)
  * Aircraft pictures (downloaded to the `Pictures` directory)
  * A sample database (downloaded to the `Database` directory)

## Directory Structure

This VRS installation script will create a directory structure to conveniently contain the VRS installation files and all of the user's custom files all under one directory.  This section will describe the purpose of each of the directories and some of the files contained in the directories.  Advanced users may edit the VRS installation script to relocate or rename some of these directories and files.  However, the information below will give the description of the default directory structure produced by this script.

Here is a visual of the default directory structure:

![VRS Directory Structure](https://i.imgur.com/xknv8i1.png "VRS Directory Structure")

### Installation

This directory contains the main installation of VRS. There should never be any need to edit the contents of this directory.

### VRS-Extras

This directory contains the user's custom files used to enhance and support the VRS website. Here are all of the subdirectories under the `VRS-Extras` directory:

#### Autorun

This directory will contain a script that gets created by this VRS installation script.  The name of this script is `autorunvrs.sh`.  If wanting to have VRS start at the moment the system starts, create a [cron job](https://www.cyberciti.biz/faq/how-do-i-add-jobs-to-cron-under-linux-or-unix-oses/) to run this script as a background process every time the system starts.  For example, the cron job may look like this:
```
@reboot /home/<username>/VirtualRadarServer/VRS-Extras/Autorun/autorunvrs.sh
```

#### CustomContent/CustomInjectedFiles

VRS webpage files simply can not be removed or edited in any way, otherwise VRS will not start. However, it is possible to make small additions (also known as "injections") to the HTML files used by VRS found in the `Installation/Web` directory and any possible subdirectories. The Custom Content Plugin is a tool to allow such injections, and the Custom Content Plugin will utilize files in this `CustomInjectedFiles` directory. This directory can contain files with HTML code to be injected into any existing VRS HTML file. By default, an `Announcement.html` file is already created in this directory to be injected into both the `Installation/Web/desktop.html` and `Installation/Web/mobile.html` files. This `Announcement.html` file may be used to produce a small announcement bar at the top of the VRS website.  This could be useful to make an announcement that the server will be under maintenance for a short amount of time, for example. [More info](http://www.virtualradarserver.co.uk/Documentation/CustomContent/Default.aspx#inject-file)

#### CustomContent/CustomWebFiles

VRS webpage files simply can not be removed or edited in any way, otherwise VRS will not start.  However, if wanting to entirely replace any of the existing VRS webpage files, simply make a copy of the webpage file and place it within this `CustomWebFiles` directory.  The Custom Content Plugin is a tool to allow for such webpage file replacements to occur, and the Custom Content Plugin will utilize the webpage files in this directory and any possible subdirectories. This `CustomWebFiles` directory should replicate the actual root directory structure found in the `Installation/Web` directory and its subdirectories. Therefore, be sure to also add any subdirectories, if needed, to this `CustomWebFiles` directory. This VRS installation script will produce five HTML files in this `CustomWebFiles` directory to change the default language of the VRS webpage. [More info](http://www.virtualradarserver.co.uk/Documentation/CustomContent/Default.aspx#site-root-folder)

#### Databases/Database

This `Database` directory will contain the one `BaseStation.sqb` database file used by VRS to record all of the aircraft seen by VRS.  A `BaseStation.sqb` file may be created from scratch, or a sample `BaseStation.sqb` database file may be downloaded with this VRS installation script.  The Database Writer Plugin and the Database Editor Plugin will use this database file. [More info](http://www.virtualradarserver.co.uk/Documentation/DatabaseWriter/Default.aspx)

#### Databases/DatabaseBackup

This VRS installation script will create a `backupvrsdb.sh` script in this `DatabaseBackup` directory that may be used by a [cron job](https://www.cyberciti.biz/faq/how-do-i-add-jobs-to-cron-under-linux-or-unix-oses/) to routinely backup the `BaseStation.sqb` database file located in the `Database` directory.  Running this script will create a copy of the `BaseStation.sqb` database file and place the copy in this `DatabaseBackup` directory.  The copied database file will be named `BaseStation_BACKUP.sqb`.  Here is an example of a cron job utilizing the `backupvrsdb.sh` script to backup the database every day at 2:00am.
```
0 2 * * * bash /home/<username>/VirtualRadarServer/VRS-Extras/Databases/DatabaseBackup/backupvrsdb.sh
```

#### OperatorFlags

This directory will store all of the *\*.bmp* airline operator flag files. If VRS detects the airline ICAO code for a particular aircraft, and a *\*.bmp* image file exists in the `OperatorFlags` directory for that particular airline ICAO code, then VRS will display the airline operator flag *\*.bmp* image that is named with the same airline ICAO code. ([More info](http://www.virtualradarserver.co.uk/Documentation/WebServer/DataSourcesOptions.aspx#flags-folder)) An example of an operator flag named `AAL.bmp`:

![American Airlines operator flag](https://i.imgur.com/Od7H8Tw.png "American Airlines operator flag")


#### Pictures

If the user has any personal pictures of any aircraft, those pictures may be placed in this `Pictures` directory.  The filename of each picture should simply be either the ICAO24 hex code or the registration number (tail number) of the aircraft.  When an aircraft is received by VRS, VRS will display the picture of this aircraft that was found in this `Pictures` directory.  [More info](http://www.virtualradarserver.co.uk/Documentation/WebServer/DataSourcesOptions.aspx#pictures-folder)

#### Silhouettes

This directory may contain silhouette *\*.bmp* images of aircrafts. If a silhouette image for a particular type of aircraft is in this `Silhouettes` directory, and VRS sees an aircraft of this same type, then VRS will display that silhouette image with that aircraft in the list of aircrafts. The filename of each silhouette image should be the same as the ICAOTypeCode for the aircraft. ([More info](http://www.virtualradarserver.co.uk/Documentation/WebServer/DataSourcesOptions.aspx#silhouettes-folder))
An example of a silhouette image named `B748.bmp`:

![Boeing 747-800 silhouette](https://i.imgur.com/HuYWHFZ.png "Boeing 747-800 silhouette")

#### TileCache

This directory will hold cached copies of map tiles from the tile servers if the Tile Server Cache Plugin is enabled.  This may improve the load time of the map tiles appearing on the VRS webpage. [More info](http://www.virtualradarserver.co.uk/Download.aspx#panel-tileservercache)

## Auto-fill Directory & File Paths

This VRS installation script will auto-fill the paths of directories and files in the VRS server settings for the simple sake of convenience.

## Created Additional Scripts

### Global Command to Start VRS

This VRS installation script will also create a global command to allow the user to quickly and easily start VRS. After this VRS installation script is finished, just run either one of these two commands to start VRS:
```
vrs
vrs -nogui
```
The second command with the *-nogui* parameter will start VRS without the GUI.  If VRS has been installed on a Linux installation with only a command-line interface (e.g. Raspbian Stretch Lite), the `vrs` command will automatically detect that it should run with the *-nogui* parameter.

VRS will start and operate fine in a command-line interface environment.  However, two things should be noted:
  * To view a GUI interface for the VRS server settings, the [Web Admin](http://www.virtualradarserver.co.uk/Download.aspx#panel-web-admin) plugin should be utilized.
  * If using a SSH client (such as [PuTTY](https://www.putty.org)), the terminal window will need to remain open.  However, if wanting to close the terminal window, installing a utility such as [screen](https://www.tecmint.com/screen-command-examples-to-manage-linux-terminals/) will allow VRS to continue running even if the terminal window is closed.

### Script to Backup Database

This VRS installation script will also create a script to backup the database file through a [cron job](https://www.cyberciti.biz/faq/how-do-i-add-jobs-to-cron-under-linux-or-unix-oses/).  By default, the script is called `backupvrsdb.sh` and is located in the `DatabaseBackup` directory. [More info](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#databasesdatabasebackup)

### Script to Autorun VRS

This VRS installation script will also create a script to automatically start VRS through a [cron job](https://www.cyberciti.biz/faq/how-do-i-add-jobs-to-cron-under-linux-or-unix-oses/) when the system starts. By default, the script is called `autorunvrs.sh` and is located in the `Autorun` directory. [More info](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#autorun)

## Display an Announcement on the Webpage

As already described above in the ["CustomInjectedFiles"](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#customcontentcustominjectedfiles) description, a template HTML file will be created by this VRS installation script to help display an announcement at the top of the VRS webpage.  Simply edit the existing `Announcement.html` file in the `CustomInjectedFiles` directory to display whatever text deemed necessary at the top of the VRS webpage.

## Other Information

When this VRS installation script finishes, some very useful information will be displayed specific to that particular installation. It will be useful to read and record this information.
