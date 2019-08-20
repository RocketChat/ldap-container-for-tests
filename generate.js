const fs = require('fs');

fs.writeFileSync('data.ldif', `
#
# Dummy user database for testing
#
# User 'kohsuke' is admin, user 'alice' is a regular user.
# Both has the password 'password'
#

#dn: dc=jenkins-ci,dc=org
#objectClass: top
#objectClass: dcObject
#objectClass: organization
#o: Jenkins users
#dc: Jenkins-Ci
#description: Jenkins users

#dn: cn=admin,dc=jenkins-ci,dc=org
#objectClass: simpleSecurityObject
#objectClass: organizationalRole
#cn: admin
#description: LDAP administrator
#userPassword: {SSHA}yI6cZwQadOA1e+/f+T+H3eCQQhRzYWx0

dn: ou=people,dc=jenkins-ci,dc=org
objectClass: organizationalUnit
ou: people

dn: ou=groups,dc=jenkins-ci,dc=org
objectClass: organizationalUnit
ou: groups

dn: cn=admins,ou=groups,dc=jenkins-ci,dc=org
objectClass: groupOfNames
cn: admins
description: people with infrastructure admin access
member: cn=kohsuke,ou=people,dc=jenkins-ci,dc=org

dn: cn=all,ou=groups,dc=jenkins-ci,dc=org
objectClass: groupOfNames
cn: all
member: cn=kohsuke,ou=people,dc=jenkins-ci,dc=org
member: cn=kohsuke2,ou=people,dc=jenkins-ci,dc=org

dn: cn=kohsuke,ou=people,dc=jenkins-ci,dc=org
objectClass: inetOrgPerson
cn: kohsuke
mail: kk@kohsuke.org
givenName: Kohsuke
employeeNumber: kohsuke
preferredLanguage: yyy
sn: Kawaguchi
userPassword: {SSHA}yI6cZwQadOA1e+/f+T+H3eCQQhRzYWx0

dn: cn=alice,ou=people,dc=jenkins-ci,dc=org
objectClass: inetOrgPerson
cn: alice
mail: bob@jenkins-ci.org
givenName: Alice
sn: Ashley
userPassword: {SSHA}yI6cZwQadOA1e+/f+T+H3eCQQhRzYWx0
`);

let data = '';

for (var index = 0; index < 800; index++) {
	const cn = `alice-${index}`;
	const givenName = `Alice-${index}`;
	const sn = 'Ashley';
	const uid = cn;

	data += `

dn: cn=${cn},ou=people,dc=jenkins-ci,dc=org
objectClass: inetOrgPerson
cn: ${cn}
mail: ${cn}@jenkins-ci.org
givenName: ${givenName}
sn: ${sn}
userPassword: {SSHA}yI6cZwQadOA1e+/f+T+H3eCQQhRzYWx0
#cvsbusunit: HEADQ
#cvsempstatus: A
#cvsjobcode: 111111
#cvsmanagerlevel: 1
#cvssupervisor: 1111110
description: ISARCHITECT-TECHNOLOGY
l: Woonsocket
postalCode: 00000
st: RI
street: 1CVSDrive
uid: ${uid}`;

	if (data.length > 10000000) {
		fs.appendFileSync('data.ldif', data);
		data = '';
	}
}

fs.appendFileSync('data.ldif', data);
