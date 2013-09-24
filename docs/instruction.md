1. Instruction 
==============

**Cobot** is a robot to release SW. It checkouts the latest tag, makes all
the targets pre-configed, and releases output SW.

Files:  

	|-- cygwin.tar.gz 		--Cygwin install package
	|-- flowchart.jpeg		--flowchart of release robot's working
	|-- readme       		--this file
	|-- robot
	|   |-- cygwin_rel_robot.bat	--A batch for windows xp task schedule
	|   |-- entrance.sh        	--the gateway to rel_robot.sh
	|   |-- make_sw.sh         	--a script file to make a list of target
	|   |-- rel_robot.sh       	--a script acts as a release robot
	|   `-- target.txt         	--a file to list all targets for robot
	`-- use_case.jpeg          	--use case

2. Installation on Windows XP
=============================

2.1 Project compiler
----------------

Install your own compiler. 

2.2 Cygwin
----------

Install cygwin with default utils plus subversion and make.

As the robot depends on specific string of svn output, Cygwin must be set to 
english environment. To do it, add below line to *~/.bash_profile*

    export LANG=en_US.UTF-8

2.3 Config 
----------

Create a new folder in your workspace. Copy all files in robot to workspace.
Change targets in file *target.txt*.
Change settings at the head of file *rel_robot.sh*.

3. Run 
======

3.1 Schedule
------------

Add *cygwin_rel_robot.bat* to windows xp task schedule.

3.2 Manual Test
---------------

To test robot manually, open Cygwin, change directory to the folder that holding 
*rel_robot.sh*, and run below command

    ./rel_robot.sh

3.3 Output
----------

Three folders are created after robot runs.

*   code  
    source code that downloaded from svn server
*   log  
    folder for make log and release log. Remove the relase log makes robot do a fresh release.
*   release  
    folder for released SW

4. Bugs
=======

No bugs found yet.
