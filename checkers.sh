#!/bin/bash
#
# Cycle through active WordPress plugins to find the source of an error
# message. Uses wp-cli and curl.
#
# Nathan P. <notdan@tchbnl.net>
#
# v0.3 Updated on 8/2/2022
#
# Releases
# * v0.1: Initial release
# * v0.2: Overhauled text and visuals
# * v0.3: Reworked code to some semblance of standards
# * v1.0: Can self-compile into a giant robot

# Fancy text
TEXT_BOLD='\e[1m'
TEXT_RESET='\e[0m'

# Check for and variablize the error message
if [[ -n "$1" ]]; then
  ERROR_MSG="$1"; else
  echo "You need to specify an error message. Use: checkers \"Your error message\""
  exit
fi

# We wrap wp-cli around more comfortable PHP settings and skip possible
# problematic plugin and theme code. 2>/dev/null supresses noisy PHP messages
# encountered in wp-cli ≤2.4.0 on PHP 8+.
wp_cli() {
  php -d memory_limit=128M -d disable_functions= "$(which wp)" "$@" --skip-plugins --skip-themes 2>/dev/null
}

# Get site URL
URL="$(wp_cli option get siteurl)"

# Specify a user agent for curl
USER_AGENT="Mozilla/3.0 (compatible; NetPositive/2.1.1; BeOS)"

# Check if we can see the error message; if not, bail out
if ! curl -sA "${USER_AGENT}" "${URL}" | grep -iq "${ERROR_MSG}"; then
  echo "I don't see that error message on the site."
  exit
fi

# Get our active plugins
PLUGINS="$(wp_cli plugin list --field=name --status=active)"

# List our sussy bakas- err, I mean plugins
echo -e "${TEXT_BOLD}Here's our suspects:${TEXT_RESET}
$(wp_cli plugin list --field=title --status=active | awk '{print "* "$0}')\n"

# Do the loop: Deactivate the first plugin in the list and check if the error
# is resolved. If it is, return a success message and exit. If not, reactivate
# the plugin and move onto the next one.
for PLUGIN in $PLUGINS; do
  # Deactivate plugin
  wp_cli plugin deactivate "${PLUGIN}" --quiet

  # Get plugin's "nice" name for output
  SUSPECT="$(wp_cli plugin get "${PLUGIN}" --field=title)"
  echo -e "${TEXT_BOLD}Let's check ${SUSPECT}:${TEXT_RESET}"

  # Check if the error message is still there
  if ! curl -sA "${USER_AGENT}" "${URL}" | grep -iq "${ERROR_MSG}"; then
    echo "👮‍♂️ Gotcha"'!'" ${SUSPECT} is the imposter."

    # Set FOUND for final message check at the end
    FOUND='true'

    # End the loop
    exit; else
    echo -e "😔 Nope, it wasn't ${SUSPECT}.\n"

    # Reactivate the plugin
    wp_cli plugin activate "${PLUGIN}" --quiet
  fi
done

# If the cause was FOUND, clean up and wrap. If not, let the user know none of
# the active plugins are behind the error.
if [[ -v FOUND ]]; then
  unset FOUND; else
  echo "None of those were it"'!'" Something else must be breaking things."
fi
