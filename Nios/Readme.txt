This folder contains .c code for Nios II Applications.

Typically, within the Nios II IDE you would create a new C++ application - I usually base it on the Hello World example. Then replace the example application source with the code from within here.

Since the Nios II IDE gets unhappy if you create a project on top of an existing folder, there is a bit of a long winded workaround to get a project with the same directory structure as GIT is expecting.

1) Download the GIT source code.  This will have just folders and .c/.h files within those folders.
2) Switch your Nios II IDE workspace to the RangeImaging\Nios\ folder.
3) Rename the folders from the GIT source.
4) Create a new application as mentioned above with the correct name (ie, the GIT folder name) for the project.
5) Cut and paste the correct source code into the newly created Nios project.
6) Remove the old (renamed) folder to avoid confusion.


If anyone has a more elegant solution, please let me know how! Besides putting the entire Nios project on GIT.