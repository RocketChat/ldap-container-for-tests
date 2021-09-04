const fs = require('fs');

// dn: cn=${cn},ou=people,{{ LDAP_BASE_DN }}
// objectClass: inetOrgPerson
// cn: ${cn}
// mail: ${cn}@rocket.chat
// givenName: ${givenName}
// sn: ${sn}
// userPassword: {SSHA}yI6cZwQadOA1e+/f+T+H3eCQQhRzYWx0
// description: ISARCHITECT-TECHNOLOGY
// l: Woonsocket
// postalCode: 00000
// st: RI
// street: 1CVSDrive
// uid: ${uid}`;


fs.writeFileSync('ldif/data.ldif', `
#
# Dummy user database for testing
#
# User 'ldapadmin' is admin, user 'ldapuser' is a regular user.
# Both has the password 'password'
#

#dn: {{ LDAP_BASE_DN }}
#objectClass: top
#objectClass: dcObject
#objectClass: organization
#o: RocketChat users
#dc: RocketChat
#description: RocketChat users

#dn: cn=admin,{{ LDAP_BASE_DN }}
#objectClass: simpleSecurityObject
#objectClass: organizationalRole
#cn: admin
#description: LDAP administrator
#userPassword: {SSHA}yI6cZwQadOA1e+/f+T+H3eCQQhRzYWx0

dn: ou=people,{{ LDAP_BASE_DN }}
objectClass: organizationalUnit
ou: people

dn: ou=groups,{{ LDAP_BASE_DN }}
objectClass: organizationalUnit
ou: groups

dn: cn=admins,ou=groups,{{ LDAP_BASE_DN }}
objectClass: groupOfNames
cn: admins
description: people with infrastructure admin access
member: cn=ldapadmin,ou=people,{{ LDAP_BASE_DN }}

dn: cn=all,ou=groups,{{ LDAP_BASE_DN }}
objectClass: groupOfNames
cn: all
member: cn=ldapadmin,ou=people,{{ LDAP_BASE_DN }}

dn: cn=ldapadmin,ou=people,{{ LDAP_BASE_DN }}
objectClass: inetOrgPerson
cn: ldapadmin
mail: kk@ldapadmin.org
givenName: LDAP Admin
sn: Admin
userPassword: {SSHA}yI6cZwQadOA1e+/f+T+H3eCQQhRzYWx0

dn: cn=ldapuser,ou=people,{{ LDAP_BASE_DN }}
objectClass: inetOrgPerson
cn: ldapuser
mail: ldapuser@rocket.chat
givenName: LDAP User
sn: User
userPassword: {SSHA}yI6cZwQadOA1e+/f+T+H3eCQQhRzYWx0
`);

let data = '';

for (var index = 0; index < 10; index++) {
	const cn = `ldapuser-${index}`;
	const givenName = `LDAP User ${index}`;
	const sn = 'User';
	const uid = cn;

	data += `

dn: cn=${cn},ou=people,{{ LDAP_BASE_DN }}
objectClass: inetOrgPerson
cn: ${cn}
mail: ${cn}@rocket.chat
givenName: ${givenName}
sn: ${sn}
userPassword: {SSHA}yI6cZwQadOA1e+/f+T+H3eCQQhRzYWx0
uid: ${uid}`;

	if (data.length > 10000000) {
		fs.appendFileSync('ldif/99-data.ldif', data);
		data = '';
	}
}

fs.appendFileSync('ldif/99-data.ldif', data);
