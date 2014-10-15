if [ $# -ne 3 ]; then
  echo "Usage: $0 recursion_depth num_cut_dirs url"
  exit
fi

wget --level=$1 -nH --cut-dirs=$2 -m -k $3
