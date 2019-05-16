# Advanced fully configurable Docker Request Tracker 4

 **Overview**

Provides a fully configurable Request Tracker 4 with Optional RTIR installation.
The full proyect includes RabbitMQ and Fetchmail support dockers for incoming email handling.

Full Services Failover and high availability on incoming email handling if deployed using Rancher.

**Caveats**

The complete stack will not work on standard docker environments as it relies on
Rancher's Metadata Service for the autodiscovery feature.

This container could also be deployed standalone on any docker host but modifications will be required
in order to provide internal fetchmail retrieval services.

**Features**

- Automatic Database integration + Fulltext indexing if deployed alongisde MariaDB linked container. 
- Fully configurable through Docker ENV vars.
- Active Directory/LDAP support.
- Syslog support.
- RTIR available optionally.
- Loadbalancer support.
- Fetchmail/RabbitMQ integration for distributed incoming email handling.
- Nodes with integrated healhcheck for self-healing, recovery.

**Usage**

*Available ENVIRONMENT Variables*

      RT_DBTYPE: mysql
      RT_DBHOST: 1.2.3.4
      RT_DBPORT: 3306
      RT_DBNAME: myrtdb
      RT_DBUSER: rtuser
      RT_DBPASS: rtpass
      RT_LBURL: https://rt.example.com
      RT_LDAP: '1'
      RT_LDAP_ATTR_ACCOUNT: sAMAccountName
      RT_LDAP_ATTR_MAIL: mail
      RT_LDAP_ATTR_NAME: cn
      RT_LDAP_ATTR_ORG: physicalDeliveryOfficeName
      RT_LDAP_BASE: CN=Users,DC=domain,DC=local
      RT_LDAP_FILTER: (&(objectClass=user))
      RT_LDAP_GROUP: CN=RT-enabled,CN=Users,DC=domain,DC=local
      RT_LDAP_GRPATTR: member
      RT_LDAP_GRPATTR_VALUE: dn
      RT_LDAP_GRPFILTER: (&(objectClass=group))
      RT_LDAP_PASS: ldapRequestTrackerPass
      RT_LDAP_PORT: '389'
      RT_LDAP_SERVER: ldap://mydomain.local
      RT_LDAP_USER: ldap-rt-user
      RT_LDAP_VER: '3'
      RT_LOGHOST: 1.2.3.4
      RT_LOGID: RT4
      RT_LOGLEVEL: debug
      RT_LOGPORT: '514'
      RT_LOGPROTO: tcp
      RT_MAILOWNER: rtowner@example.com
      RT_MAXATTACH: 10*1024*1024
      RT_NAME: rt.example.com
      RT_ORG: example.com
      RT_RELAYHOST: 1.2.3.4
      RT_TIMEZONE: Europe/Zurich
      RT_RTIR: '1'
      RT_RTIR_VER: 4.0.1
      RT_MQ_RECYCLE: '10'


**Important**

The easiest way for deploying this is through one of the docker_compose example files.
Pay special attention to the linked server aliases, only specific ones could be used for the automation to work.

```
    links:
    - RT-Database:database
    - MessageQueue:rabbitmq
    - Fetchmail:fetchmail
```

**Head over the folder `ComposeFiles` on the repo for complete examples.**
