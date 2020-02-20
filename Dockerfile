FROM nickstenning/slapd:previous

ENV LDAP_ROOTPASS rootpassword
ENV LDAP_DOMAIN rocket.chat
ENV LDAP_ORGANISATION MockRocketChat

RUN apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y ldap-utils

ADD slapd.sh /etc/service/slapd/run

RUN chmod -R 755 /etc/service/slapd/run

# # ADD slapdcert.pem /etc/openldap/ssl/slapdcert.pem
# # ADD slapdkey.pem /etc/openldap/ssl/slapdkey.pem
# ADD server.pem /etc/openldap/ssl/server.pem
# RUN chmod -R 755 /etc/openldap/ssl/ &\
# # chmod 400 /etc/openldap/ssl/slapdkey.pem &\
# # chmod 444 /etc/openldap/ssl/slapdcert.pem &\
# # chown ldap /etc/openldap/ssl/slapdkey.pem &\
# chmod 400 /etc/openldap/ssl/server.pem &\
# chown openldap /etc/openldap/ssl/server.pem

EXPOSE 636
EXPOSE 389

ADD ldif /tmp/ldif

RUN /etc/service/slapd/run & sleep 3; \
 ldapmodify -H ldapi:/// -Y EXTERNAL -f /tmp/ldif/config.ldif; \
 ldapadd -H ldapi:/// -Y EXTERNAL -f /etc/ldap/schema/ppolicy.ldif; \
 ldapadd -H ldapi:/// -x -D cn=admin,dc=rocket,dc=chat -w rootpassword -f /tmp/ldif/policiesou.ldif; \
 ldapadd -H ldapi:/// -Y EXTERNAL -f /tmp/ldif/ppolicy_moduleload.ldif; \
 ldapadd -H ldapi:/// -Y EXTERNAL -f /tmp/ldif/ppolicy_overlay.ldif; \
 ldapadd -H ldapi:/// -D cn=admin,dc=rocket,dc=chat -w rootpassword -f /tmp/ldif/ppolicy_default.ldif; \
 ldapadd -H ldapi:/// -x -D cn=admin,dc=rocket,dc=chat -w rootpassword -f /tmp/ldif/data.ldif

# ldapsearch -LLL -x -D "cn=admin,dc=rocket,dc=chat" -w "rootpassword" -b "dc=rocket,dc=chat" -s sub "(cn=ldapuser)"

# https://github.com/stratisproject/archive_azure-quickstart-templates/blob/master/openldap-singlevm-ubuntu/install_openldap.sh
