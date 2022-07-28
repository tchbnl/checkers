# checkers
![checkers](https://user-images.githubusercontent.com/86271004/181606800-e6b4afef-7053-473f-9dce-f06bad2dfa7e.png)

checkers is a simple Bash script for WordPress that tries to find the plugin behind critical errors and similar. Useful if DEBUG mode doesn't provide additional info, and the site has 50-some odd plugins enabled. It takes the inputted error, gets the list of active plugins, and deactivates them one at a time until the error no longer shows (and re-activates the plugins that had no effect). It uses curl and wp-cli - that's it.

There's some basic checks to make sure an error message is actuallty provided, and that the script can see the error for itself before it tries to do anything. It also shows each plugin it found, and the results of trying each one for verbosity.

Unlike telcheck and makesite, it doesn't have any extra options or features. It just does what it says and should work.

## minicheckers
As is tradition, minicheckers is a version of the same script slimmed down without comments and excess spacing. Useful to run directly in the shell instead of having to download and execute a file. As always, review any code you run from the Internet.

checkers was inspired by one of Tyler's [excellent scripts](https://github.com/Risingfeanyx/cPanel_centos_scripts#wordpress).
