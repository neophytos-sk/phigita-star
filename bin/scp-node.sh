echo "Recursive copy ${1} to ${2} under ${3}"
scp -r -i ~/.ssh/XO-${2}/id_dsa ${1} root@${2}:${3}
