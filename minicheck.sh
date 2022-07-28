checkers()
{
if [[ $GOTEM ]]; then
unset GOTEM
fi
TEXT_BLD="\e[1m"
TEXT_RST="\e[0m"
if [[ $1 = "" ]]; then
echo "You need to specify an error message. Use: checkers \"Your error message\""
exit
fi
WP_CLI="php -d memory_limit=128M -d disable_functions= $(which wp)"
URL="$($WP_CLI option get siteurl --skip-plugins --skip-themes 2>/dev/null)"
if [[ $(curl -s -A "checkers" $URL 2>&1 | grep -i "$1") = "" ]]; then
echo "I don't see that error message on the site."
exit
fi
PLUGINS="$($WP_CLI plugin list --field=name --status=active --skip-plugins --skip-themes 2>/dev/null)"
echo -e "${TEXT_BLD}The usual suspects:${TEXT_RST}\n$($WP_CLI plugin list --field=title --status=active --skip-plugins --skip-themes 2>/dev/null | awk '{print "* "$0}')\n"
for PLUGIN in $PLUGINS; do
wpDeactivatePlugin="$($WP_CLI plugin deactivate $PLUGIN --skip-plugins --skip-themes 2>/dev/null)"
PLUGIN_NAME="$($WP_CLI plugin get $PLUGIN --field=title --skip-plugins --skip-themes 2>/dev/null)"
echo -e "${TEXT_BLD}Let's check $PLUGIN_NAME${TEXT_RST}:"
if [[ $(curl -s -A "checkers" $URL 2>&1 | grep -i "$1") = "" ]]; then
echo -e "👮‍♂️ Gotcha'"'!'" $PLUGIN_NAME is the imposter."
GOTEM="true"
exit; else
echo -e "😔 Nope. It wasn't $PLUGIN_NAME\n"
wpActivatePlugin="$($WP_CLI plugin activate $PLUGIN --skip-plugins --skip-themes 2>/dev/null)"
fi
done
if [[ $GOTEM ]]; then
unset GOTEM; else
echo -e "None of those were it. Something else must be breaking things."
fi
}
