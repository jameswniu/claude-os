# Shell Basics

Source: (internal URL)

The command line is a universal constant on any technology environment. Use it to execute commands, read and edit files, script complex tasks, diagnose problems. 

Topics you are expected understand:

  * Navigating the filesystem with `cd` and listing directories with `ls`

  * Pressing `tab` to complete a command

  * Searching command history with `ctrl-r`

  * [Setting and using shell variables](https://www.shellscript.sh/variables1.html)

  * [Setting and using the special $PATH variable](https://linuxhint.com/path_in_bash/)

  * Using `man` to read documentation

  * Enough `vi` to edit and save a file (or how to switch your system's default text editor)

  * How to read a README file to set up and launch Basis apps and services

Topics you should learn eventually to be productive:

  * [Readline key commands](https://spin.atomicobject.com/2017/11/10/readline-productivity/)

  * Scripting/aliases

  * Redirecting output with `|` and `>`

  * `echo`, `cat`, `more`/`less`

  * STDIN/STDOUT

  * Searching for text in a file using `grep`

I strongly recommend using [oh-my-zsh](https://ohmyz.sh) to upgrade from the Mac's default shell experience. It provides a lot of really useful git shortcuts right out of the box and an easy plugin architecture for extending shell functionality even further. I also find it very helpful when I'm pairing with other developers because it provides visual cues for current git branches, process return codes, and readable color schemes. If you have enough shell experience to have a different opinion, you can consider omz optional. Some people might want the bare bones experience of using plain old Bash without the helpful utilities omz provides, as it will be closer to what they will find in server environments as well. 

I also recommend [setting up fzf](https://github.com/junegunn/fzf), the fuzzy-finder once you've mastered enough of the above material. Trust me, it's worth it. 

#### Additional resources

2022-09-29 Bootcamp Session Notes: Shell power user tips + bonus airbrake and datadog demo

<https://commandlinepoweruser.com> A video series for web developers on learning a modern command line workflow with ZSH, Z and related tools.
