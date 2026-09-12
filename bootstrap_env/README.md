# Bootstrap

Automates the setup of system dependencies and Vim configuration on a new machine.

```bash
mkdir bootstrap_env && cd bootstrap_env \
&& for f in bootstrap_env.sh bootstrap_apt.sh bootstrap_vim.sh bootstrap_pi.sh; do \
     curl -fsSLO "https://raw.githubusercontent.com/<user>/homelab/main/bootstrap_env/$f"; \
   done \
&& chmod +x *.sh \
&& ./bootstrap_env.sh
```

## Files

-  bootstrap_env.sh: Entry point. Executes the setup scripts in order.
-  bootstrap_apt.sh: Installs system packages (vim, git).
-  bootstrap_vim.sh: Configures .vim directory, installs plugins (Pathogen, NERDTree, etc.), and writes .vimrc.


