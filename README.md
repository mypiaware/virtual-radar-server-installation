# Virtual Radar Server Installation Script

This script is a very helpful tool to easily install Virtual Radar Server on Linux.

Virtual Radar Server (VRS) provides an amazing website interface of aircraft viewable from an ADS-B receiver.  This script will help with the installation of VRS to those who are brand new to VRS.

When this VRS installation script finishes, some very useful information will be displayed specific to that particular installation. It will be useful to read and record this information.

This script has been confirmed to work with VRS versions 2.4.2, 2.4.3 and 2.4.4 on Raspbian (Stretch & Buster) & Lubuntu.

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
* Allow the user to select the following:
  * [Which port number VRS should use](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#port-number)
  * [Which default language the VRS website should display](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#default-language)
* [Download additional files (all optional):](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#download-additional-files)
  * Airline operator flags
  * Aircraft silhouettes
  * Sample database
* [Create a set of directories to contain all of the user's custom files](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#directory-structure)
* [Auto-fill the directory/file paths in the VRS settings for a few of the custom directories/files](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#auto-fill-directory--file-paths)
* Create additional commands/scripts
  * [A global command to start VRS](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#global-command-to-start-vrs)
  * [A script to routinely backup the database file](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#script-to-backup-database)
  * [A script to autorun VRS at system boot](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#script-to-autorun-vrs)
* [Provide an easy method of displaying an announcement at the top of the VRS webpage](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#display-an-announcement-on-the-webpage)
* [Restore a previous installation of VRS if the following files are with this installation script:](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#how-to-restore-a-previous-installation)
  * Configuration.xml
  * PluginsConfiguration.txt
  * BaseStation.sqb

---

## How to Install VRS
```
bash -c "$(wget -O - https://github.com/mypiaware/virtual-radar-server-installation/raw/master/virtual_radar_server_install.sh)"
```
Run the above one-line command to execute this VRS installation script. The vast majority of the installation time will involve installing Mono - a prerequisite to installing VRS. After the VRS installation is complete, the user will then need to manually enter the receiver information of the ADS-B receiver(s) to get VRS to display aircraft on the VRS webpage.  Further customization and experimentation is also encouraged.

## VRS Plugins

This VRS installation script will install the following four VRS plugins. Click on each for more information on the plugin.
  * [Custom Content Plugin](http://www.virtualradarserver.co.uk/Documentation/CustomContent/Default.aspx)
  * [Database Editor Plugin](http://www.virtualradarserver.co.uk/Download.aspx#panel-database-editor)
  * [Database Writer Plugin](http://www.virtualradarserver.co.uk/Documentation/DatabaseWriter/Default.aspx)
  * [Tile Server Cache Plugin](http://www.virtualradarserver.co.uk/Download.aspx#panel-tileservercache)
  * [Web Admin Plugin](http://www.virtualradarserver.co.uk/Download.aspx#panel-web-admin)

## Language Packs

This VRS installation script will download and install the language packs created for VRS.  Based on the current language set for the Linux operating system, the VRS server interface will automatically set the language for the VRS server interface.  Not all languages are supported. [More info](http://www.virtualradarserver.co.uk/Download.aspx#panel-translations)

## Port Number

This VRS installation script will prompt the user for the port number VRS should use.  By default, a typical installation of VRS will use port 8080.  However, this VRS installation script will use 8090 as the default port number in the event the same system is running FlightAware's Skyview - which uses port 8080.  The user is free to choose any available port number.

## Default Language

The default language for a typical VRS installation for the webpage is "English (United Kingdom)".  However, this script will allow the user to choose from a number of languages and regional locales.

## Download Additional Files

This VRS installation script will also provide the option to download some sample files to help enhance the VRS webpage if the user does not already have any of these files. These files will be downloaded to the directories described below. These additional files include:
  * Airline operator flags (downloaded to the `OperatorFlags` directory)
  * Aircraft silhouettes (downloaded to the `Silhouettes` directory)
  * A sample database (downloaded to the `Database` directory)

## Directory Structure

As mentioned in the Overview section above, this VRS installation script will create a directory structure to contain all of the user's custom files.  This section will describe the purpose of each of the directories and some of the files contained in the directories.  Advanced users may edit the VRS installation script to relocate or rename some of these directories and files.  However, the information below will give the description of the default directory structure produced by this script.

Here is a visual of the default directory structure:

![VRS Directory Structure](https://i.imgur.com/xknv8i1.png "VRS Directory Structure")

### Installation

This directory contains the main installation of VRS. There should never be any need to edit the contents of this directory.

### VRS-Extras

This directory contains all of the user's custom files used to enhance the VRS website. Here are all of the subdirectories:

#### Autorun

This directory will contain a script that gets created by this VRS installation script.  The name of this script is `autorunvrs.sh`.  If wanting to have VRS start at the moment the system starts, create a [cron job](https://www.cyberciti.biz/faq/how-do-i-add-jobs-to-cron-under-linux-or-unix-oses/) to run this script every time the system starts.  For example, the cron job may look like this:
```
@reboot /home/<username>/VirtualRadarServer/VRS-Extras/Autorun/autorunvrs.sh
```

#### CustomContent/CustomInjectedFiles

VRS webpage files simply can not be removed or edited in any way, otherwise VRS will not start. However, it is possible to make small additions (also known as "injections") to the HTML files used by VRS found in the `Installation/Web` directory and subdirectories. The Custom Content Plugin is a tool to allow such injections, and the Custom Content Plugin will utilize files in this `CustomInjectedFiles` directory. This directory can contain files with HTML code to be injected into any existing VRS HTML file. By default, an `Announcement.html` file is already created in this directory to be injected into both the `Installation/Web/desktop.html` and `Installation/Web/mobile.html` files. This `Announcement.html` file may be used to produce a small announcement bar at the top of the VRS website.  This could be useful to make an announcement that the server will be under maintenance for a short amount of time, for example. [More info](http://www.virtualradarserver.co.uk/Documentation/CustomContent/Default.aspx#inject-file)

#### CustomContent/CustomWebFiles

VRS webpage files simply can not be removed or edited in any way, otherwise VRS will not start.  However, if wanting to entirely replace any of the existing VRS webpage files, simply make a copy of the webpage file and place it within this `CustomWebFiles` directory.  The Custom Content Plugin is a tool to allow for such webpage file replacements to occur, and the Custom Content Plugin will utilize the webpage files in this directory. This directory should replicate the actual root directory structure found in the `Installation/Web` directory and subdirectories. Therefore, be sure to also add any subdirectories, if needed, to this `CustomWebFiles` directory. This VRS installation script will produce five HTML files in this `CustomWebFiles` directory to change the default language of the VRS webpage. [More info](http://www.virtualradarserver.co.uk/Documentation/CustomContent/Default.aspx#site-root-folder)

#### Databases/Database

This `Database` directory will contain the one `BaseStation.sqb` database file used by VRS to record all the aircraft seen by the ADS-B receiver(s).  A `BaseStation.sqb` file may be created from scratch, or a sample `BaseStation.sqb` database file may be downloaded with this VRS installation script.  The Database Writer Plugin and the Database Editor Plugin will use this database file. [More info](http://www.virtualradarserver.co.uk/Documentation/DatabaseWriter/Default.aspx)

#### Databases/DatabaseBackup

This VRS installation script will create a `backupvrsdb.sh` script in this `DatabaseBackup` directory that may be used by a [cron job](https://www.cyberciti.biz/faq/how-do-i-add-jobs-to-cron-under-linux-or-unix-oses/) to routinely backup the `BaseStation.sqb` database file located in the `Database` directory.  Running this script will create a copy of the `BaseStation.sqb` database file and place the copy in this `DatabaseBackup` directory.  The copied database file will be named `BaseStation_BACKUP.sqb`.  Here is an example of a cron job utilizing the `backupvrsdb.sh` script to backup the database every day at 2:00am.
```
0 2 * * * bash /home/<username>/VirtualRadarServer/VRS-Extras/Databases/DatabaseBackup/backupvrsdb.sh
```

#### OperatorFlags

This directory will store all of the *\*.bmp* airline operator flag files. If VRS detects the airline ICAO code for a particular aircraft, and a *\*.bmp* image file exists for that particular airline ICAO code, then VRS will display the airline operator flag image that is named with the same airline ICAO code. ([More info](http://www.virtualradarserver.co.uk/Documentation/WebServer/DataSourcesOptions.aspx#flags-folder)) An example of an operator flag named `AAL.bmp`:

![American Airlines operator flag](https://i.imgur.com/Od7H8Tw.png "American Airlines operator flag")


#### Pictures

If the user has any personal pictures of any aircraft, those pictures may be placed in this `Pictures` directory.  The filename of each picture should simply be either the ICAO24 hex code or the registration number (tail number) of the aircraft.  If an aircraft is received by the ADS-B receiver(s), VRS will display the picture of this aircraft that was found in this `Pictures` directory.  [More info](http://www.virtualradarserver.co.uk/Documentation/WebServer/DataSourcesOptions.aspx#pictures-folder)

#### Silhouettes

This directory may contain silhouette *\*.bmp* images of aircrafts. If a silhouette image for a particular type of aircraft is in this directory, and VRS sees an aircraft of this same type from the ADS-B receiver(s), then VRS will display that silhouette image with that aircraft in the list of aircrafts. The filename of each silhouette image should be the same as the ICAOTypeCode for the aircraft. ([More info](http://www.virtualradarserver.co.uk/Documentation/WebServer/DataSourcesOptions.aspx#silhouettes-folder))
An example of a silhouette image named `B748.bmp`:

![Boeing 747-800 silhouette](https://i.imgur.com/HuYWHFZ.png "Boeing 747-800 silhouette")

#### TileCache

This directory will hold cached copies of the map tiles from the tile servers if the Tile Server Cache Plugin is enabled.  This may improve the load time of the map tiles appearing on the VRS webpage. [More info](http://www.virtualradarserver.co.uk/Download.aspx#panel-tileservercache)

## Auto-fill Directory & File Paths

This VRS installation script will auto-fill the paths of directories and files in the VRS settings for the simple sake of convenience.

## Created Additional Scripts

### Global Command to Start VRS

This VRS installation script will also create a global command to allow the user to quickly and easily start VRS. After this VRS installation script is finished, just run either one of these two commands to start VRS:
```
vrs
vrs -nogui
```
The second command with the *-nogui* parameter will start VRS without the GUI.  If VRS has been installed on a Linux installation with only a command-line interface (e.g. Raspbian Stretch Lite), the `vrs` command will automatically detect that it should run with the *-nogui* parameter.

### Script to Backup Database

This VRS installation script will also create a script to backup the database file through a [cron job](https://www.cyberciti.biz/faq/how-do-i-add-jobs-to-cron-under-linux-or-unix-oses/).  By default, the script is called `backupvrsdb.sh` and is located in the `DatabaseBackup` directory. [More info](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#databasesdatabasebackup)

### Script to Autorun VRS

This VRS installation script will also create a script to automatically start VRS through a [cron job](https://www.cyberciti.biz/faq/how-do-i-add-jobs-to-cron-under-linux-or-unix-oses/) when the system starts. By default, the script is called `autorunvrs.sh` and is located in the `Autorun` directory. [More info](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#autorun)

## Display an Announcement on the Webpage

As already described above in the ["CustomInjectedFiles"](https://github.com/mypiaware/virtual-radar-server-installation/blob/master/README.md#customcontentcustominjectedfiles) description, a template HTML file will be created by this VRS installation script to help display an announcement at the top of the VRS webpage.  Simply edit the existing `Announcement.html` file in the `CustomInjectedFiles` directory to display whatever text deemed necessary at the top of the VRS webpage.

## How to Restore a Previous Installation

Not only will this VRS installation script do a great job of performing a clean installation of VRS, but it may also restore a previous installation. If the following files are present in the same directory along with this VRS installation script, the VRS installation script will automatically incorporate these files into the new installation of VRS. Therefore, the settings for the new installation of VRS will be configured exactly the same as the previous installation. This VRS installation script can incorporate any or all three of these files from a previous installation of VRS:
  * Configuration.xml
  * PluginsConfiguration.txt
  * BaseStation.sqb

From a previous installation, the two settings files (`Configuration.xml` and `PluginsConfiguration.txt`) may be found in the following locations:
  * `/home/<username>/.local/share/VirtualRadar/Configuration.xml`
  * `/home/<username>/.local/share/VirtualRadar/PluginsConfiguration.txt`

## Other Information

When this VRS installation script finishes, some very useful information will be displayed specific to that particular installation. It will be useful to read and record this information.
