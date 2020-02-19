FROM nickstenning/slapd:previous

ENV LDAP_ROOTPASS s3cr3t
ENV LDAP_DOMAIN jenkins-ci.org
ENV LDAP_ORGANISATION MockJenkins

RUN apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y ldap-utils

ADD slapd.sh /etc/service/slapd/run
ADD data.ldif /tmp/data.ldif
ADD config.ldif /tmp/config.ldif
ADD pwpolicyoverlay.ldif /tmp/pwpolicyoverlay.ldif
ADD pwpolicyoverlay1.ldif /tmp/pwpolicyoverlay1.ldif
ADD pwpolicyoverlay2.ldif /tmp/pwpolicyoverlay2.ldif
ADD ppolicy_default.ldif /tmp/ppolicy_default.ldif
ADD ldif /tmp/ldif

RUN chmod -R 755 /etc/service/slapd/run

# # ADD slapdcert.pem /etc/openldap/ssl/slapdcert.pem
# # ADD slapdkey.pem /etc/openldap/ssl/slapdkey.pem
# ADD server.pem /etc/openldap/ssl/server.pem
# RUN chmod -R 755 /etc/openldap/ssl/ &\
#     # chmod 400 /etc/openldap/ssl/slapdkey.pem &\
#     # chmod 444 /etc/openldap/ssl/slapdcert.pem &\
#     # chown ldap /etc/openldap/ssl/slapdkey.pem &\
#     chmod 400 /etc/openldap/ssl/server.pem &\
#     chown openldap /etc/openldap/ssl/server.pem


EXPOSE 636
EXPOSE 389

# RUN ln -s /usr/local/lib/run/ldapi /var/run/slapd/ldapi

RUN /etc/service/slapd/run & sleep 3; \
    ldapadd -H ldap:/// -x -D cn=admin,dc=jenkins-ci,dc=org -w s3cr3t < /tmp/data.ldif

RUN /etc/service/slapd/run & sleep 3; \
    ldapmodify -Y EXTERNAL -H ldapi:/// -f /tmp/config.ldif

# RUN /etc/service/slapd/run & sleep 3; \
#     ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/pwpolicyoverlay.ldif

# RUN /etc/service/slapd/run & sleep 3; \
#     ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/pwpolicyoverlay2.ldif

# RUN /etc/service/slapd/run & sleep 3; \
#     ldapadd -H ldap:/// -x -D cn=admin,dc=jenkins-ci,dc=org -w s3cr3t < /tmp/pwpolicyoverlay1.ldif

RUN /etc/service/slapd/run & sleep 3; \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/ldap/schema/ppolicy.ldif

RUN /etc/service/slapd/run & sleep 3; \
    ldapadd -H ldap:/// -x -D cn=admin,dc=jenkins-ci,dc=org -w s3cr3t -f /tmp/ldif/policiesou.ldif

RUN /etc/service/slapd/run & sleep 3; \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/ldif/ppolicy_moduleload.ldif

RUN /etc/service/slapd/run & sleep 3; \
    ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/ldif/ppolicy_overlay.ldif

RUN /etc/service/slapd/run & sleep 3; \
    ldapadd -H ldapi:/// -D cn=admin,dc=jenkins-ci,dc=org -w s3cr3t -f /tmp/ldif/ppolicy_default.ldif

# ldapsearch -LLL -x -D "cn=admin,dc=jenkins-ci,dc=org" -w "s3cr3t" -b "dc=jenkins-ci,dc=org" -s sub "(cn=alice)"

# https://github.com/stratisproject/archive_azure-quickstart-templates/blob/master/openldap-singlevm-ubuntu/install_openldap.sh
