if [ $# -ne 2 ]; then
  echo "Usage: $0 num_cut_dirs url"
  exit
fi

wget -nH --cut-dirs=$1 -k -p $2
