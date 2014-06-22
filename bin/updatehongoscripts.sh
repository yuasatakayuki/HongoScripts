#!/bin/bash

#20080818 Takayuki Yuasa

rsync -e ssh -au --verbose ~/bin/HongoScripts/ yuasa@ceres.phys.s.u-tokyo.ac.jp:~/bin/HongoScripts/
rsync -e ssh -au --verbose yuasa@ceres.phys.s.u-tokyo.ac.jp:~/bin/HongoScripts/ ~/bin/HongoScripts/
