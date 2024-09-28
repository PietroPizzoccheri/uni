The examples in this zip file can be built either manually or using "make".
"make" is a tool that automatically executes the appropriate commands for
performing the build, which are derived by a file called "Makefile".

To build manually, run the following commands (in order):

  cd directory-of-the-example
  flex *.l
  bison -d *.y
  cc -o output *.tab.c *.yy.c

You can optionally replace *.l/*.y/*.tab.c with the names of all the files with
that extension, otherwise they are found automatically by the shell.

To build with Make, instead, there is a single command to run:

  make
