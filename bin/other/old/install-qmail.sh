#!/bin/bash


groupadd nginx
useradd -d /dev/null -s /bin/false nginx

###################################################################

WEBHOME=~nsadmin
source ${WEBHOME}/bin/install-env.sh

###################################################################

mkdir /web
groupadd web
useradd nsadmin -g web -d /web
echo "Enter nsadmin passwd:"
passwd nasdmin
ssh nsadmin@localhost
maildirmake .maildir



###ACCEPT_KEYWORDS="~x86" USE="ssl" emerge qmail-ldap
### unmask all relevant packages in /usr/portage/profile/package.mask
USE="ssl zlib gencertdaily highvolume cluster" ACCEPT_KEYWORDS="~x86" emerge qmail-ldap
env-update && source /etc/profile

cp ${FILESDIR}/qmail-ldap/conf-files/servercert.cnf /var/qmail/control/
rm /var/qmail/control/servercert.pem
rm /var/qmail/control/clientcert.pem
#mkservercert
emerge --config qmail-ldap

cd /var/qmail/control/
echo "cbd-cyprus.com" > me
echo "cbd-cyprus.com" > rcpthosts
# echo "mail.yourdomain.com" >> rcpthosts
# echo "otherdomain.com" >> rcpthosts

echo "dc=cbd-cyprus,dc=com" > ldapbasedn
echo "localhost" > ldapserver
echo "cn=postmaster, o=cbd-cyprus, c=com" > ldaplogin
echo 0 > ldaplocaldelivery
### echo "qmailuser" > ldapobjectclass
echo "/var/qmail/maildirs/" > ldapmessagestore
echo "100000000" > defaultquotasize
echo "10000" > defaultquotacount
echo localhost > plusdomain
echo cbd-cyprus.com > defaulthost
echo cbd-cyprus.com > defaultdomain
echo secret > ldappassword


cp ${FILESDIR}/qmail-ldap/conf-files/slapd.conf to /etc/openldap/slapd.conf
chown root:ldap /etc/openldap/slapd.conf
chmod 444 /etc/openldap/schema/qmail.schema
rc-update add slapd default
/etc/init.d/slapd restart

mkdir /service
ln -s /var/qmail/supervise/qmail-send /service/qmail-send
ln -s /var/qmail/supervise/qmail-smtpd /service/qmail-smtpd

echo postmaster > /var/qmail/alias/.qmail-root
echo postmaster > /var/qmail/alias/.qmail-postmaster
echo postmaster > /var/qmail/alias/.qmail-mailer-daemon
ln -s /var/qmail/alias/.qmail-root /var/qmail/alias/.qmail-anonymous
chmod 644 /var/qmail/alias/.qmail*


echo "cbd-cyprus.com" > /var/qmail/control/locals

source /etc/profile
rc-update add svscan default
/etc/init.d/svscan start

emerge relay-ctrl -va

cp ${FILESDIR}/qmail-ldap/files/tcp-qmail-* /etc/tcprules.d/
tcprules /etc/tcprules.d/tcp.qmail-smtp.cdb /etc/tcprules.d/.tcp.qmail-smtp.tmp < /etc/tcprules.d/tcp.qmail-smtp
cd /etc/tcprules.d
make *
chmod 644 *.cdb

/etc/init.d/svscan restart



openssl ciphers > /var/qmail/control/tlsclientciphers
openssl ciphers > /var/qmail/control/tlsserverciphers

### IMPORTANT! If you can receive mails to your mailbox BUT cannot send, and reason is like "sorry, that domain isn't in my list of allowed rcpthosts", then try to add this lines to this file:
### domain.com:allow,RELAYCLIENT="",RBLSMTPD=""
### NOTE: Easiest way how to forbid any outgoing messages from your SMTP (don't become a public SMTP!) and allow only "localroute" (send mail only from/to domains, that are listed/added by vQadmin):
### :allow,RBLSMTPD="-Reason_here"

echo net-libs/courier-authlib -mysql >> /etc/portage/package.use
emerge courier-imap -va 
USE="ldap" emerge courier-authlib

cp ${FILESDIR}/qmail-ldap/conf-files/authdaemonrc /etc/courier/authlib/authdaemonrc
cp ${FILESDIR}/qmail-ldap/conf-files/authldaprc /etc/courier/authlib/authldaprc
cp ${FILESDIR}/qmail-ldap/conf-files/imapd /etc/courier-imap/imapd

rc-update add courier-authlib default
rc-update add courier-imapd default
rc-update add courier-pop3d default


cp ${FILESDIR}/qmail-ldap/conf-files/imapd.cnf /etc/courier-imap/imapd.cnf
cp ${FILESDIR}/qmail-ldap/conf-files/pop3d.cnf /etc/courier-imap/pop3d.cnf


mkimapdcert
mkpop3dcert

rc-update add courier-imapd-ssl default
rc-update add courier-pop3d-ssl default


/etc/init.d/courier-authlib restart


cd /var/lib/openldap-data/
cp DB_CONFIG.example DB_CONFIG
cd ${FILESDIR}/qmail-ldap/conf-files/
./mkroot.sh

ldapsearch -x -b "dc=cbd-cyprus,dc=com" -w secret -D "uid=admin,dc=cbd-cyprus,dc=com" "(objectclass=*)"

### cp ${FILESDIR}/qmail-ldap/conf-files/gentoo-imapd.rc /usr/lib/courier-imap/
### cp ${FILESDIR}/qmail-ldap/conf-files/gentoo-pop3d.rc /usr/lib/courier-imap/

groupadd -g 600 ldapauth
useradd -u 11184 -g ldapauth ldapauth
echo 600 > /var/qmail/control/ldapgid
echo 11184 > /var/qmail/control/ldapuid
echo cbd-cyprus.com > /var/qmail/control/me

mkdir -p /var/qmail/maildirs/postmaster
chown -R ldapauth:ldapauth /var/qmail/maildirs/
su - ldapauth -c 'maildirmake /var/qmail/maildirs/postmaster/.maildir'



### SMTP-AUTH - NOT WORKING
cp ${FILESDIR}/qmail-ldap/conf-files/conf-smtpd /var/qmail/control/conf-smtpd
cp ${FILESDIR}/qmail-ldap/conf-files/conf-common /var/qmail/control/conf-common




emerge razor -va
razor-admin --home=/etc/mail/spamassassin/.razor -create
razor-admin --home=/etc/mail/spamassassin/.razor -discover
razor-admin --home=/etc/mail/spamassassin/.razor -user=postmaster@cbd-cyprus.com -pass=cbd__k2pts__123test -register


###emerge Mail-SPF-Query -va

echo sys-apps/ucspi-tcp-0.88-r16 >> /etc/portage/package.mask
echo mail-mta/ssmtp >> /etc/portage/package.mask
echo mail-filter/spamassassin qmail ssl >> /etc/portage/package.use
echo sys-apps/ucspi-tcp-0.88-r17 > /etc/portage/package.use
ACCEPT_KEYWORDS="~x86" emerge spamassassin -va 

#vi /etc/mail/spamassassin/local.cf
cp /web/files/qmail-ldap/conf-files/local.cf /etc/mail/spamassassin/local.cf

rc-update add spamd default
/etc/init.d/spamd start


ACCEPT_KEYWORDS="~x86" emerge  clamav
rc-update add clamd default

groupadd qscand -g 210
useradd qscand -g qscand -u 210 -d /var/spool/qscan


chown -R qscand:qscand /var/lib/clamav
chown -R qscand:qscand /var/run/clamav
chown -R qscand:qscand /var/log/clamav

cp /web/files/qmail-ldap/conf-files/clamd.conf /etc/clamd.conf

echo mail-mta/mini-qmail >>/etc/portage/package.mask
echo mail-mta/netqmail>>/etc/portage/package.mask
echo mail-filter/qmail-scanner spamassassin >> /etc/portage/package.use
echo =net-mail/qlogtools-3.1 >> /etc/portage/package.keywords





cp ${FILESDIR}/qmail-ldap/conf-files/qmail-scanner-2.02-r1.ebuild /usr/portage/mail-filter/qmail-scanner/qmail-scanner-2.02-r1.ebuild
ebuild /usr/portage/mail-filter/qmail-scanner/qmail-scanner-2.02-r1.ebuild digest   
USE="clamav ldap" ACCEPT_KEYWORDS="~x86" emerge =mail-filter/qmail-scanner-2.02-r1 -va

cp /web/files/qmail-ldap/conf-files/clamd.conf /etc/clamd.conf
cp /web/files/qmail-ldap/conf-files/freshclam.conf /etc/freshclam.conf
chown -R qscand:qscand /var/lib/clamav
chown -R qscand:qscand /var/run/clamav
chown -R qscand:qscand /var/log/clamav
/etc/init.d/clamd restart
freshclam

chown -R qscand:qscand /etc/mail/spamassassin/
### echo "export QMAILQUEUE=/var/qmail/bin/qmail-scanner-queue" >> /var/qmail/control/conf-common


################ IMPORTANT!!!!!!! ######################
chmod 755 /var/qmail/bin/qmail-scanner-queue
chmod u+s /var/qmail/bin/qmail-scanner-queue.pl 
USE="perlsuid" emerge -avuN perl





### SSL ???
USE="tls" ACCEPT_KEYWORDS="~x86" emerge ucspi-ssl


cp ${FILESDIR}/qmail-ldap/conf-files/defaultdelivery /var/qmail/control/
cp ${FILESDIR}/qmail-ldap/conf-files/maildroprc /etc/maildroprc
chmod 600 /etc/maildroprc

#spamassassin -D < /web/files/qmail-ldap/conf-files/sample-spam.txt



