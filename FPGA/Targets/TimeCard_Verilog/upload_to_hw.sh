#!/bin/bash -xeu
echo 'Before removal: '
ssh reynauld 'lspci -s 26:00.0'
ssh reynauld 'echo 1 | sudo tee /sys/bus/pci/devices/0000:26:00.0/remove || true'
ssh reynauld 'lspci -s 26:00.0 | grep -q "Memory controller" && echo "PCIe device still here after removal!" && exit 1 || true'
read -p "Program Bitstream..."
ssh reynauld 'echo 1 | sudo tee /sys/bus/pci/rescan'
echo 'After rescan: '
ssh reynauld 'lspci -s 26:00.0'
echo 'Launch GPSD if not already: '
ssh reynauld 'ps -eLF | grep -v grep | grep gpsd || sudo gpsd /dev/ttyS4 -s 115200'
