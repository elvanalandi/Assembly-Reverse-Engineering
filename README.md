## Assembly Program and Reverse Engineering
This project was part of my Master's degree at Swinburne University of Technology.

I developed the program (**Assignment.exe**) using 32-bit Intel x86 assembly language and the Irvine32 library. It’s a login application that prompts the user for an ID number and password. Upon successful login, the user’s information is written to a text file and logged in a separate log file.

For the reverse engineering part, I used **IDA Freeware** to analyze the program. This involved bypassing the student ID check, saving the unencrypted password, and displaying a warning message. The reverse-engineered version of the application is named **Assignment-Patched.exe**.

These PDF files provide documentation on how to run the program and details on the reverse engineering process.

<a href="Program_Documentation.pdf" class="image fit" type="application/pdf">Program Documentation File</a>

<a href="Reverse_Engineering_Documentation.pdf" class="image fit" type="application/pdf">Reverse Engineering Documentation File</a>
