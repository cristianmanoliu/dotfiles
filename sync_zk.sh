#!/usr/bin/env bash
rm -rf zk
cp -R ~/.config/zk .
git add *
git commit -m "Update zk config"
git push origin main
