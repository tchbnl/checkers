# checkers
![checkers](https://user-images.githubusercontent.com/86271004/181606800-e6b4afef-7053-473f-9dce-f06bad2dfa7e.png)
checkers is a simple Bash script for WordPress that tries to find the plugin behind critical errors. Useful when DEBUG mode doesn't provide additional info (ugh), and the site has 50+ plugins installed. It takes the inputted error message, gets the list of active plugins, and deactivates them one at a time until the error no longer shows. It uses curl and wp-cli.

There's some basic checks to make sure an error message is actuallty provided, and that the script can see the error for itself before it tries to do anything. It also shows each plugin it found, and the results of trying each one for verbosity.

**Can I have a version without the emojis and that stupid Among Us reference?**

No.

checkers.min.sh is a compact version of the script that can be run directly in the shell without downloading.

checkers was inspired by one of Tyler's [excellent WordPress scripts](https://github.com/Risingfeanyx/cPanel_centos_scripts#wordpress).
