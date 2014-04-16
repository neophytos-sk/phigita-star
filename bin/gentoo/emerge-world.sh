#emerge --quiet --sync
#emerge --noreplace portage

emerge $* -auDN world
echo "=== REMINDER ==="
echo "emerge @preserved-rebuild"
echo "emerge --depclean -a"
echo "revdep-rebuild"
