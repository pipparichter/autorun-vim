# vim-autorun

**NOTE:** This is very much a work-in-progress! It was mostly just a way to familiarize myself with Vimscript syntax, but I've 
found it somewhat useful for quickly executing code. I am continually updating it as I think of additional features or notice any bugs. For anyone who tries it out, I'd appreciate any comments, suggestions, bug information, etc. <br/>
<br/>
This plugin provides commands for running Python and C++ files from Vim.


## Installation

### Dependencies

Use of this plugin requires...
* Python installed on your machine.
* A C++ compiler installed on your machine (so far, this plugin is only set up for the `g++` compiler, which should come
 with most Debian-based Linux distros).
* The Gnome Terminal Emulator. This can be installed on Debian-based Linux systems using `sudo apt install gnome-terminal`.

### Procedure

#### If your plugin manager is [vim-plug][1]...
1. Clone this repository into your `~/.vim` plugin folder. <br/>
    'git clone https://github.com/pipparichter/vim-autorun.git'
2. Add the following line to your .vimrc file, before `call plug#end()` and after the vim-plug setup. <br/>
    `Plug 'pipparichter/vim-autorun'` <br/>
    **NOTE:** Make sure to use single quotes!

#### If your plugin manager is Pathogen...
1. Clone this repository into your .vim plugin folder.

#### If you don't have a plugin manager...
1. Clone this repository into your .vim plugin folder.


## Commands

### Running files
* `:Run` <br/>
This command is basically just a combined version of `:RunPython` and `:RunCPP`. It recognizes the filetype of the buffer and
calls `:RunPython` or `:RunCPP` accordingly.
<br/>
* `:RunPython` <br/>
Saves the current buffer and executes it as a Python file. 

<br/>
* `:RunCPP` <br/>


### Managing projects
* `:MakeCPPProject {project name}` <br/>

<br/>
* `:SetCurrentProject {project name}` <br/>

<br/>

## Configuration


## Troubleshooting


[1]: https://github.com/junegunn/vim-plug
