checkers()
{
TEXT_BOLD='\e[1m'
TEXT_RESET='\e[0m'
if [[ -n "$1" ]]; then
ERROR_MSG="$1"; else
echo "You need to specify an error message. Use: checkers \"Your error message\""
return
fi
wp_cli() {
php -d memory_limit=128M -d disable_functions= "$(which wp)" "$@" --skip-plugins --skip-themes 2>/dev/null
}
URL="$(wp_cli option get siteurl)"
USER_AGENT="Mozilla/3.0 (compatible; NetPositive/2.1.1; BeOS)"
if [[ -z "$(curl -sA "${USER_AGENT}" ${URL} | grep -i "${ERROR_MSG}")" ]]; then
echo "I don't see that error message on the site."
return
fi
PLUGINS="$(wp_cli plugin list --field=name --status=active)"
echo -e "${TEXT_BOLD}Here's our suspects:${TEXT_RESET}
$(wp_cli plugin list --field=title --status=active | awk '{print "* "$0}')\n"
for PLUGIN in $PLUGINS; do
wp_cli plugin deactivate "${PLUGIN}" --quiet
SUSPECT="$(wp_cli plugin get ${PLUGIN} --field=title)"
echo -e "${TEXT_BOLD}Let's check ${SUSPECT}:${TEXT_RESET}"
if [[ -z "$(curl -sA "${USER_AGENT}" ${URL} | grep -i "${ERROR_MSG}")" ]]; then
echo "👮‍♂️ Gotcha"'!'" ${SUSPECT} is the imposter."
FOUND='true'
return; else
echo -e "😔 Nope, it wasn't ${SUSPECT}.\n"
wp_cli plugin activate "${PLUGIN}" --quiet
fi
done
if [[ -v "${FOUND}" ]]; then
unset FOUND; else
echo "None of those were it"'!'" Something else must be breaking things."
fi
}
