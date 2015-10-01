#!/bin/bash

cd ~/dotfiles
for f in .??*
do
    [[ "$f" == ".git" ]] && continue
    [[ "$f" == ".DS_Store" ]] && continue

    echo "$f"
    ln -sf ~/dotfiles/$f ~/$f
done
