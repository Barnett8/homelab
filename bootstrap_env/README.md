## Bootstrap

Automates the setup of system dependencies and Vim configuration on a new machine.
bash

`git clone https://github.com/adam/bootstrap.git && cd bootstrap && ./bootstrap_env.sh`

# Files

-  bootstrap_env.sh: Entry point. Executes the setup scripts in order.
-  bootstrap_apt.sh: Installs system packages (vim, git).
-  bootstrap_vim.sh: Configures .vim directory, installs plugins (Pathogen, NERDTree, etc.), and writes .vimrc.


