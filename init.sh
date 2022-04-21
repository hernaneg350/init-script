#!/bin/bash

# Executed in sub-shell since passing in the script to bash using pipes (i.e. curl https://rawgithub... | bash) will mess up input redirection.
#(xcode-select -p > /dev/null 2>&1)

#if [[ $0 > 0 ]] ; then
#    echo "X-Code Command Line Tools not installed. You will be redirected to installation. Please call this script again once finished."
#    (xcode-select --install > /dev/null 2>&1)
#    exit 0
#fi

echo "Provide your PAT..."
read PAT
# As of now, --recurse-submodules does not work. It will try to clone via SSH and at this point, no SSH keys are available. TODO find if there
# is another way around this.
git -C $HOME --no-checkout clone --separate-git-dir=$HOME/.tracker https://$PAT@github.com/hernaneg350/home.git
git -C $HOME --git-dir=.tracker --work-tree=. reset --hard HEAD #CAREFUL!
