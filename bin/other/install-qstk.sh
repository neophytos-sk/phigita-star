# QSToolKit - Python - Computational Investing
emerge -av numpy scipy matplotlib setuptools python-dateutil PyQt4 cvxopt
cd ~nkd
git clone https://github.com/tucker777/QSTK QSTK
cd QSTK
cp config.sh local.sh
echo "Add the following line to your ~/.profile, ~/.bash_profile or ~/.cshrc or ~/.bashrc file"
echo "source QSTK/local.sh"

easy_install -U scikits.statsmodels
easy_install --upgrade pytz
easy_install pandas==0.7.3
