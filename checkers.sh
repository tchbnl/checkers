#!/bin/bash
# checkers: Cycle WordPress plugins to find source of errors
# Nathan Paton <nathanpat@inmotionhosting.com>
# v0.1 Updated on 7/27/2022
#
# Releases
# * v0.1: Initial release
# * v1.0: Can self-compile into a giant robot

# Just in case this wasn't unset last time
if [[ $GOTEM ]]; then
    unset GOTEM
fi

# Make sure an error message was given
if [[ $1 = "" ]]; then
    echo "You must specify the error message."
    exit
fi

# Give wp-cli enough to comfortably run
WP_CLI="php -d memory_limit=128M -d disable_functions= $(which wp)"

# Check if the given error message is on the site
URL="$($WP_CLI option get siteurl --skip-plugins --skip-themes)"
if [[ $(curl -A "checkers" $URL 2>&1 | grep -i "$1") = "" ]]; then
    echo "I don't see that error message on the site."
    exit
fi

# Get our active plugins
PLUGINS="$($WP_CLI plugin list --field=name --status=active --skio-plugins --skip-themes 2>/dev/null)"

echo -e "Here's our suspects: "$PLUGINS"\n"

# Do the loop
for PLUGIN in $PLUGINS; do
    wpDeactivatePlugin="$($WP_CLI plugin deactivate $PLUGIN)"

    echo -e "Let's see if it's ${PLUGIN}..."
    if [[ $(curl -A "checkers" $URL 2>&1 | grep -i "$1") = "" ]]; then
        echo -e "Found it\u21 $PLUGIN is the imposter."
        GOTEM="true"
        exit; else
        echo -e "It wasn't ${PLUGIN}. Back to the drawing board.\n"
        wpActivatePlugin="$($WP_CLI plugin activate $PLUGIN)"
    fi
done

# Closing thoughts and cleanup
if [[ $GOTEM ]]; then
    unset GOTEM; else
    echo -e "None of those were it\u21 Something else must be breaking things."
fi
