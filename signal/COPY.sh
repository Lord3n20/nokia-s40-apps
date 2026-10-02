#!/bin/bash
# Ohne Bluetooth: Handy per USB als Massenspeicher anschließen, Karte ist /dev/sda1.
mkdir -p ~/mnt && sudo mount /dev/sda1 ~/mnt && sudo cp "$(dirname "$0")"/dist/* ~/mnt/. && sudo umount ~/mnt
