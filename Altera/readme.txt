This folder contains Altera Quartus Project files, and TCL scripts to be run within the Quartus projects (with various settings, eg pin assignments).

I've tried to keep these project folders as lightweight as possible. At a minimum, you'll find in each a Quartus project file (.qpf), and Quartus settings file (.qsf), and maybe some associated SOPC files (.ptf,.sopc) and VHDL files associated with those SOPC files.  The .sof file is not included, and certainly not the DB folder. If you want these, you'll have to open up the project and compile it on your own machine.

If all is structured properly, the actual VHDL source code used by these projects do not reside in these folders - they are in the VHDL folder.

Also in here is a folder of TCL scripts. These can be great for automating Pin assignments, as well as defining custom SOPC components.
