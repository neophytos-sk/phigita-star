#!/bin/bash

# Setup filename for the screenshot
myfile=$(date +%Y%m%d%S).png

#Setup paths to dropbox & full url to new screenshot
dropboxwebpath='http://dl.dropbox.com/u/422013/temp/' # PUT YOUR DROPBOX USERID HERE
dropboxfileurl=$dropboxwebpath$myfile

# see: http://code.google.com/p/xmonad/issues/detail?id=476
sleep 0.2

# Use scrot to take a screenshot and stick it in your dropbox screenshots folder
scrot $myfile -e 'mv $f ~/Dropbox/Public/temp/' -s

#  Put full URL to new screenshot into clipboard
echo $dropboxfileurl | xclip -selection c
