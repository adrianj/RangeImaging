Readme file for RangeImaging Git project.

The goal for this Git repository is to host all of my code for the Victoria University Range Imaging project. Different aspects include:

VHDL code -  VHDL source code for FPGA projects
Altera - Altera Quartus projects and associated settings


More to come later, including the java packet capturing application, PMD19k VHDL code and Nios II application.





Also - here are some reminders to myself about how to use Git:

git add <file> : Adds files to repositories. Be careful when adding directories, since it adds all files in the directory. Better to go into the directory and add only files with matching patterns, eg, "git add *.vhd"

git commit -a -m "message" : Commits changes to all modified files.

git push : pushes commited changes to github.

git --help
git <command> --help.  Gives help info for git and git commands (eg, commit, add, etc.