#!/bin/bash
for i in org-roam/**.org; do
    lm=`git log -1 --format=%ci $i`
    echo "$i: $lm"
done
#git log -1 --format=%ci org-roam/20220408123339-emacs_mark.org
