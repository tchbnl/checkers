checkers()
{
if [[ $GOTEM ]]; then
unset GOTEM
fi
if [[ $1 = "" ]]; then
echo "You must specify the error message."
exit
fi
WP_CLI="php -d memory_limit=128M -d disable_functions= $(which wp)"
URL="$($WP_CLI option get siteurl --skip-plugins --skip-themes 2>/dev/null)"
if [[ $(curl -s -A "checkers" $URL 2>&1 | grep -i "$1") = "" ]]; then
echo "I don't see that error message on the site."
exit
fi
PLUGINS="$($WP_CLI plugin list --field=name --status=active --skio-plugins --skip-themes 2>/dev/null)"
echo -e "Here's our suspects: "$PLUGINS"\n"
for PLUGIN in $PLUGINS; do
wpDeactivatePlugin="$($WP_CLI plugin deactivate $PLUGIN 2>/dev/null)"
echo -e "Let's see if it's ${PLUGIN}..."
if [[ $(curl -s -A "checkers" $URL 2>&1 | grep -i "$1") = "" ]]; then
echo -e "Found it\u21 $PLUGIN is the imposter."
GOTEM="true"
exit; else
echo -e "It wasn't ${PLUGIN}. Back to the drawing board.\n"
wpActivatePlugin="$($WP_CLI plugin activate $PLUGIN 2>/dev/null)"
fi
done
if [[ $GOTEM ]]; then
unset GOTEM; else
echo -e "None of those were it\u21 Something else must be breaking things."
fi
}
