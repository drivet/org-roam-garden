#!/bin/bash
for i in org-roam/*.org; do
    lm=`git log -1 --format=%ci $i`
    sed -r -i "s/(^\#\+date: .*$)/\1\n#+hugo_lastmod: $lm/" $i
done
for i in org-roam/**/*.org; do
    lm=`git log -1 --format=%ci $i`
    sed -r -i "s/(^\#\+date: .*$)/\1\n#+hugo_lastmod: $lm/" $i
done
