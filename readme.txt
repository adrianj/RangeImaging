Readme file for RangeImaging Git project.

The goal for this Git repository is to host all of my code for the Victoria University Range Imaging project. Different aspects include:

VHDL code -  VHDL source code for FPGA projects.
Altera - Altera Quartus projects and associated settings.
Nios - Code specific to the Nios II microprocessor by Altera.


More to come later, including the java packet capturing application.





Also - here are some reminders to myself about how to use Git:

git add <file> : Adds files to repositories. Be careful when adding directories, since it adds all files in the directory. Better to go into the directory and add only files with matching patterns, eg, "git add *.vhd"

git commit -m "message" : Commits changes to all modified files. Without the -m "message" it opens up VIM asking for a message. Quitting is not intuitive - type "<esc> :wq" to save and quit. There must surely be an easier way!!

git push : pushes commited changes to github.

git --help
git <command> --help :  Gives help info for git and git commands (eg, commit, add, etc.
