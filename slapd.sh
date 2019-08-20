#!/bin/sh

set -eu

status () {
  echo "---> ${@}" >&2
}

set -x
: LDAP_ROOTPASS=${LDAP_ROOTPASS}
: LDAP_DOMAIN=${LDAP_DOMAIN}
: LDAP_ORGANISATION=${LDAP_ORGANISATION}

if [ ! -e /var/lib/ldap/docker_bootstrapped ]; then
  status "configuring slapd for first run"

  cat <<EOF | debconf-set-selections
slapd slapd/internal/generated_adminpw password ${LDAP_ROOTPASS}
slapd slapd/internal/adminpw password ${LDAP_ROOTPASS}
slapd slapd/password2 password ${LDAP_ROOTPASS}
slapd slapd/password1 password ${LDAP_ROOTPASS}
slapd slapd/dump_database_destdir string /var/backups/slapd-VERSION
slapd slapd/domain string ${LDAP_DOMAIN}
slapd shared/organization string ${LDAP_ORGANISATION}
slapd slapd/backend string HDB
slapd slapd/purge_database boolean true
slapd slapd/move_old_database boolean true
slapd slapd/allow_ldap_v2 boolean false
slapd slapd/no_configuration boolean false
slapd slapd/dump_database select when needed
EOF

  dpkg-reconfigure -f noninteractive slapd

  echo "SIZELIMIT	12" >> /etc/ldap/ldap.conf
  # echo "logfile         /tmp/slapd.log" >> /etc/ldap/ldap.conf
  echo "loglevel        any" >> /etc/ldap/ldap.conf
  # echo "logfile         /tmp/slapd.log" >> /usr/share/slapd/slapd.conf
  echo "loglevel        any" >> /usr/share/slapd/slapd.conf

  # # /etc/ldap/ldap.conf
  # # /usr/share/slapd/slapd.conf
  # echo "# Certificate/SSL Section" >> /etc/ldap/ldap.conf
  # # echo "TLSCipherSuite DEFAULT" >> /etc/ldap/ldap.conf
  # # echo "TLSCertificateFile /etc/openldap/ssl/slapdcert.pem" >> /etc/ldap/ldap.conf
  # # echo "TLSCertificateKeyFile /etc/openldap/ssl/slapdkey.pem" >> /etc/ldap/ldap.conf
  # # echo "TLSCipherSuite HIGH:MEDIUM:-SSLv2:-SSLv3" >> /etc/ldap/ldap.conf
  # # echo "TLS_REQCERT allow" >> /etc/ldap/ldap.conf
  # echo "TLSCACertificateFile /etc/openldap/ssl/server.pem" >> /etc/ldap/ldap.conf
  # echo "TLSCertificateFile /etc/openldap/ssl/server.pem" >> /etc/ldap/ldap.conf
  # echo "TLSCertificateKeyFile /etc/openldap/ssl/server.pem" >> /etc/ldap/ldap.conf

  # echo "# Certificate/SSL Section" >> /usr/share/slapd/slapd.conf
  # # echo "TLSCipherSuite DEFAULT" >> /usr/share/slapd/slapd.conf
  # # echo "TLSCertificateFile /etc/openldap/ssl/slapdcert.pem" >> /usr/share/slapd/slapd.conf
  # # echo "TLSCertificateKeyFile /etc/openldap/ssl/slapdkey.pem" >> /usr/share/slapd/slapd.conf
  # # echo "TLSCipherSuite HIGH:MEDIUM:-SSLv2:-SSLv3" >> /usr/share/slapd/slapd.conf
  # # echo "TLS_REQCERT allow" >> /usr/share/slapd/slapd.conf
  # echo "TLSCACertificateFile /etc/openldap/ssl/server.pem" >> /usr/share/slapd/slapd.conf
  # echo "TLSCertificateFile /etc/openldap/ssl/server.pem" >> /usr/share/slapd/slapd.conf
  # echo "TLSCertificateKeyFile /etc/openldap/ssl/server.pem" >> /usr/share/slapd/slapd.conf


  touch /var/lib/ldap/docker_bootstrapped
else
  status "found already-configured slapd"
fi

status "starting slapd"
set -x
exec /usr/sbin/slapd -h "ldap:// ldaps:/// ldapi:///" -u openldap -g openldap -d -1 >> /tmp/slapd.log 2>&1
