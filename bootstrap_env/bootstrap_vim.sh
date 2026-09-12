#!/bin/bash
mkdir -p ~/.vim/autoload ~/.vim/bundle
git clone --depth=1 https://github.com/tpope/vim-pathogen.git /tmp/vim-pathogen
cp /tmp/vim-pathogen/autoload/pathogen.vim ~/.vim/autoload/
rm -rf /tmp/vim-pathogen

# Load up the bundles you want
git clone --depth=1 https://github.com/qpkorr/vim-renamer.git ~/.vim/bundle/vim-renamer
git clone --depth=1 https://github.com/chrisbra/csv.vim.git ~/.vim/bundle/csv.vim
git clone --depth=1 https://github.com/scrooloose/nerdtree.git ~/.vim/bundle/nerdtree
git clone --depth=1 https://github.com/vim-scripts/vim-renamer.git ~/.vim/bundle/vim-renamer
git clone --depth=1 https://github.com/lervag/vimtex.git ~/.vim/bundle/vimtex

# Set up vimrc
cat > ~/.vimrc << 'EOF'
syntax on
filetype plugin indent on
:set number relativenumber
set mouse=a
:set tabstop=2
execute pathogen#infect()
EOF

