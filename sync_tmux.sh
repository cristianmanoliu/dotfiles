#!/usr/bin/env bash
rm -rf tmux
cp -R ~/.tmux tmux/
git add *
git commit -m "Update tmux config"
git push origin main
