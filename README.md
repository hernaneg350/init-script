# init-script

This script is a convenience script to automatically provision [hernaneg350/home](https://github.com/hernaneg350/home) for you on a clean device.

Simply call it from a terminal with `source <(curl https://raw.githubusercontent.com/hernaneg350/init-script/refs/heads/main/init.sh)` and follow the steps.

You can also call the `develop` branch with latest changes in order to try them out and validate them. Just know that some things might need fixing, and _you are expected to push the 
changes to `main` once you are done fixing and have validated that the script works on a virgin install._

## Branches

 * `master` contains the changes that were last known to fully work. Usually a from-scratch set-up would have been tested against a clean device with the contents of this branch, so things are expected to work out of the box. Might contain some changes that were not technically tested on a virgin device, but are simple enough that they're expected to work without hassle.
 * `develop` contains changes that would potentially break on virgin devices because they haven't really been tested on one. Clean up work, new ideas, and refactors would have their place here, but while they haven't really been shown to work on a virgin device.

Our branch model has a **no-merge-commit** policy. `master` will only have a linear history and chances are expected to rebase over it.

