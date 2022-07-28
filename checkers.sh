#!/bin/bash
# checkers: Cycle WordPress plugins to find source of errors
# Nathan Paton <nathanpat@inmotionhosting.com>
# v0.2 Updated on 7/28/2022
#
# Releases
# * v0.1: Initial release
# * v0.2: Visual overhaul
# * v1.0: Can self-compile into a giant robot

# Just in case this wasn't unset last time
if [[ $GOTEM ]]; then
    unset GOTEM
fi

# Support for fancy text
TEXT_BLD="\e[1m" # Bold text
TEXT_RST="\e[0m" # Reset text

# Make sure an error message was given
if [[ $1 = "" ]]; then
    echo "You need to specify an error message. Use: checkers \"Your error message\""
    exit
fi

# Give wp-cli enough to comfortably run
WP_CLI="php -d memory_limit=128M -d disable_functions= $(which wp)"

# Get site URL
URL="$($WP_CLI option get siteurl --skip-plugins --skip-themes 2>/dev/null)"

# Check if the given error message is on the site
if [[ $(curl -s -A "checkers" $URL 2>&1 | grep -i "$1") = "" ]]; then
    echo "I don't see that error message on the site."
    exit
fi

# Get our active plugins
PLUGINS="$($WP_CLI plugin list --field=name --status=active --skip-plugins --skip-themes 2>/dev/null)"

echo -e "${TEXT_BLD}The usual suspects:${TEXT_RST}\n$($WP_CLI plugin list --field=title --status=active --skip-plugins --skip-themes 2>/dev/null | awk '{print "* "$0}')\n"

# Do the loop
for PLUGIN in $PLUGINS; do
    # Deactivate the current plugin
    wpDeactivatePlugin="$($WP_CLI plugin deactivate $PLUGIN --skip-plugins --skip-themes 2>/dev/null)"

    # Get the title/friendly name for the current plugin
    PLUGIN_NAME="$($WP_CLI plugin get $PLUGIN --field=title --skip-plugins --skip-themes 2>/dev/null)"

    echo -e "${TEXT_BLD}Let's check $PLUGIN_NAME${TEXT_RST}:"

    # Check if error is resolved; if not, reactivate plugin and move onto the next one
    if [[ $(curl -s -A "checkers" $URL 2>&1 | grep -i "$1") = "" ]]; then
        echo -e "👮‍♂️ Gotcha'"'!'" $PLUGIN_NAME is the imposter."
        GOTEM="true"
        exit; else
        echo -e "😔 Nope. It wasn't $PLUGIN_NAME\n"
        wpActivatePlugin="$($WP_CLI plugin activate $PLUGIN --skip-plugins --skip-themes 2>/dev/null)"
    fi
done

# Closing thoughts and cleanup
if [[ $GOTEM ]]; then
    unset GOTEM; else
    echo -e "None of those were it. Something else must be breaking things."
fi
