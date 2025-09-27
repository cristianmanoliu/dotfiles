#!/usr/bin/env bash
rm -rf nvim
cp -R ~/.config/nvim .
git add *
git commit -m "Update nvim config"
git push origin main
