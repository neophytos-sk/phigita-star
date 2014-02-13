cd flex3
  find bin \( \! -name '*.exe' -a -type f \) -exec dos2unix '{}' \;
  find . -type f -exec chmod 644 '{}' \;
  find . -type d -exec chmod 755 '{}' \;
