This folder contains TCL scripts that can be run from inside Altera Quartus projects.
Within your project, goto Assignments -> Settings, then under the Libraries Category add this directory as a library. You will then be able to easily run the TCL scripts by clicking Tools -> TCL Scripts.

Most of the files in here are for speeding up Pin Assignments. Provided your top level pins have the same (case-sensitive) names as those listed in the various files, assigning pins is as simple as running the script.

To use the "nios_slave_16" SOPC entity, within SOPC builder click Tools -> Options and set the IP Search Path to include the TCL_Scripts folder.