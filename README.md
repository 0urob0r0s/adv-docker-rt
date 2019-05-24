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

      RT_DBTYPE: mysql                          #DB type could be oracle, postgres
      RT_DBHOST: 1.2.3.4                        #DB Server
      RT_DBPORT: 3306                           #DB Port
      RT_DBNAME: myrtdb                         #Schema Name
      RT_DBUSER: rtuser                               #Schema user
      RT_DBPASS: rtpass                               #Schema pass
      RT_URL: rt.example.com                          #Hostname / Server URL
      RT_LBURL: https://rt.example.com                				#External Loadbalancer URL
      RT_URL_WHITELIST: rt.example.com:80 rt.example.com:443		#URL Whitelist for the CSRF Filter
      RT_LDAP: '1'                                    				#Enable LDAP Support
      RT_LDAP_ATTR_ACCOUNT: sAMAccountName            #Account Attribute
      RT_LDAP_ATTR_MAIL: mail                         #Email Attribute
      RT_LDAP_ATTR_NAME: cn                                           #Real Name
      RT_LDAP_ATTR_ORG: physicalDeliveryOfficeName                    #Org Name
      RT_LDAP_BASE: CN=Users,DC=domain,DC=local                       #LDAP Base
      RT_LDAP_FILTER: (&(objectClass=user))                           #User Filter (Optional)
      RT_LDAP_GROUP: CN=RT-enabled,CN=Users,DC=domain,DC=local        #Group Filtering for access control.
      RT_LDAP_GRPATTR: member                                         #Group membership attribute
      RT_LDAP_GRPATTR_VALUE: dn                                       #Group membership value
      RT_LDAP_GRPFILTER: (&(objectClass=gro))                         #Group filter
      RT_LDAP_PASS: ldapRequestTrackerPass                         #LDAP Pass
      RT_LDAP_USER: ldap-rt-user                                   #LDAP User
      RT_LDAP_PORT: '389'                                          #LDAP Port
      RT_LDAP_SERVER: ldap://mydomain.local                        #LDAP URI
      RT_LDAP_VER: '3'                                   #LDAP Version
      RT_LOGHOST: 1.2.3.4                                #Syslog Server
      RT_LOGID: RT4                                      #Syslog app ID
      RT_LOGLEVEL: debug                                 #Log level. Also info, error available.
      RT_LOGPORT: '514'                                  #Syslog port
      RT_LOGPROTO: tcp                                   #Syslog protocol
      RT_MAILOWNER: rtowner@example.com                  #Email for sending errors and alerts
      RT_MAXATTACH: 10*1024*1024                         #Max attachment size (example = 10Mb)
      RT_NAME: My RT4                                    #RT installation Name
      RT_ORG: example.com                                #RT Org
      RT_RELAYHOST: 1.2.3.4                              #SMTP relay host
      RT_TIMEZONE: Europe/Zurich                         #App Timezone
      RT_RTIR: '1'                                       #Install RTIR (run once) - Enable/disable RTIR
      RT_RTIR_VER: 4.0.1                                 #Version to install (runs once)
      RT_MQ_RECYCLE: '10'                                #Message count to recycle worker


**Important**

The easiest way for deploying this is through one of the docker_compose example files.
Pay special attention to the linked server aliases, only specific ones could be used for the automation to work.

```
    links:
    - RT-Database:database
    - MessageQueue:rabbitmq
    - Fetchmail:fetchmail
```

**Useful links**

 - RT and RTIR latest versions (use to get RT_RTIR_VER) - https://download.bestpractical.com/pub/rt/release/
 - RT Documentation - https://docs.bestpractical.com/rt/4.4.4/RT_Config.html
 - RTIR documentation - https://docs.bestpractical.com/rtir/4.0.0/README.html
 - List of timezones - https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
 - Some extra steps inside RT - https://rt-wiki.bestpractical.com/wiki/ItsFinallyInstalledNowWhat#Allowing_users_to_open_tickets_via_E-mail


**Head over the folder `ComposeFiles` on the repo for complete examples.**
