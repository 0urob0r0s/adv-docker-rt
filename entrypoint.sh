#!/bin/bash

set -e

rt_config=/data/RT_SiteConfig.pm
rt_configd=/opt/rt4/etc/RT_SiteConfig.d

# Set local resolution
echo "127.0.0.1 ${RT_NAME:-rt.example.com}" >> /etc/hosts

# Basic Settings
echo 'Set($rtname, "RT_NAME");' | sed -e "s=RT_NAME=${RT_NAME:-rt.example.com}=" > ${rt_config}
echo 'Set($WebDomain, "RT_NAME");' | sed -e "s=RT_NAME=${RT_NAME:-rt.example.com}=" >> ${rt_config}
echo 'Set($WebBaseURL, "RT_LBURL");' | sed -e "s=RT_LBURL=${RT_LBURL:-http://${RT_NAME:-rt.example.com}}=" >> ${rt_config}
echo 'Set($Organization, "RT_ORG");' | sed -e "s=RT_ORG=${RT_ORG:-example.com}=" >> ${rt_config}
echo 'Set($Timezone, "RT_TIMEZONE");' | sed -e "s=RT_TIMEZONE=${RT_TIMEZONE:-US/Eastern}=" >> ${rt_config}
echo "Set(\$OwnerEmail, 'RT_MAILOWNER');" | sed -e "s=RT_MAILOWNER=${RT_MAILOWNER:-root}=" >> ${rt_config}
echo 'Set($MaxAttachmentSize, RT_MAXATTACH);' | sed -e "s=RT_MAXATTACH=${RT_MAXATTACH:-10*1024*1024}=" >> ${rt_config}
echo "Set(\$RTAddressRegexp , 'RT_MAILREGEXP');" | sed -e "s=RT_MAILREGEXP=${RT_MAILREGEXP}=" >> ${rt_config}
echo "Set(\$WebURL, RT->Config->Get('WebBaseURL') . RT->Config->Get('WebPath') . \"/\");" >> ${rt_config}

# DB Settings
echo 'Set($DatabaseType, "RT_DBTYPE");' | sed -e "s=RT_DBTYPE=${RT_DBTYPE:-mysql}=" > ${rt_configd}/database.pm
echo 'Set($DatabaseHost, "RT_DBHOST");' | sed -e "s=RT_DBHOST=${RT_DBHOST:-$(echo ${DATABASE_PORT:-":database:"} | awk -F":" '{print $2}' | sed 's/\///'g)}=" >> ${rt_configd}/database.pm
echo 'Set($DatabasePort, "RT_DBPORT");' | sed -e "s=RT_DBPORT=${RT_DBPORT:-$(echo ${DATABASE_PORT:-"::3306"} | awk -F":" '{print $3}')}=" >> ${rt_configd}/database.pm
echo 'Set($DatabaseName, q{RT_DBNAME});' | sed -e "s=RT_DBNAME=${RT_DBNAME:-${DATABASE_ENV_MYSQL_DATABASE:-rt4}}=" >> ${rt_configd}/database.pm
echo 'Set($DatabaseUser, "RT_DBUSER");' | sed -e "s=RT_DBUSER=${RT_DBUSER:-${DATABASE_ENV_MYSQL_USER:-rt_user}}=" >> ${rt_configd}/database.pm
echo 'Set($DatabasePassword, q{RT_DBPASS});' | sed -e "s=RT_DBPASS=${RT_DBPASS:-${DATABASE_ENV_MYSQL_PASSWORD:-rt_pass}}=" >> ${rt_configd}/database.pm

# Log Settings
if [ ! -z "${RT_LOGHOST}" ]; then
	echo "Set(\$LogToSyslog, 'RT_LOGLEVEL');" | sed -e "s=RT_LOGLEVEL=${RT_LOGLEVEL:-info}=" > ${rt_configd}/logs.pm
	echo "Set(@LogToSyslogConf,
		     ident => '${RT_LOGID}',
		     facility => 'local0',
		     socket => [{type => '${RT_LOGPROTO}', host => '${RT_LOGHOST}', port => ${RT_LOGPORT} }],
	);"  >> ${rt_configd}/logs.pm
else
	echo "Set(\$LogToFile , 'RT_LOGLEVEL');" | sed -e "s=RT_LOGLEVEL=${RT_LOGLEVEL:-info}=" > ${rt_configd}/logs.pm
	echo 'Set($LogDir, q{var/log});' >> ${rt_configd}/logs.pm
	echo 'Set($LogToFileNamed , "rt.log");' >> ${rt_configd}/logs.pm
fi

# LDAP Settings
if [ "${RT_LDAP}" = "1" ]; then
	echo "Set(\$ExternalAuthPriority,['Auth_LDAP']);" > ${rt_configd}/ldap.pm
	echo "Set(\$ExternalInfoPriority,['Auth_LDAP']);" >> ${rt_configd}/ldap.pm
	echo "Set( \$UserAutocreateDefaultsOnLogin, { Privileged => 1 } );" >> ${rt_configd}/ldap.pm

	#echo 'Set($ExternalServiceUsesSSLorTLS, RT_LDAP_SSL);' | sed -e "s=RT_LDAP_SSL=${RT_LDAP_SSL:-0}}=" >> ${rt_configd}/ldap.pm

	echo "Set(\$ExternalSettings, {
	'Auth_LDAP' =>  {
	'type' => 'ldap',
	'server' => '${RT_LDAP_SERVER:-ldap://windowsdc.com}',
	'user' => '${RT_LDAP_USER:-myuser}',
	'pass' => '${RT_LDAP_PASS:-mypass}',
	'base' => '${RT_LDAP_BASE:-CN=Users,DC=domain,DC=local}',
	'filter' => '${RT_LDAP_FILTER:-(objectClass=*)}',
	'group' => '${RT_LDAP_GROUP:-CN=Group,CN=Users,DC=domain,DC=local}',
	'group_attr' => '${RT_LDAP_GRPATTR:-member}',
	'group_attr_value' => '${RT_LDAP_GRPATTR_VALUE:-dn}',
	'net_ldap_args' => [
	version =>  ${RT_LDAP_VER:-3},
	port => ${RT_LDAP_PORT:-389},
	],
	'attr_match_list' => [
	'Name',
	'EmailAddress',
	],
	'attr_map' => {
	'Name' => '${RT_LDAP_ATTR_ACCOUNT:-sAMAccountName}',
	'EmailAddress' => '${RT_LDAP_ATTR_MAIL:-mail}',
	'Organization' => '${RT_LDAP_ATTR_ORG:-physicalDeliveryOfficeName}',
	'RealName' => '${RT_LDAP_ATTR_NAME:-cn}',
	'Gecos' => '${RT_LDAP_ATTR_ACCOUNT:-sAMAccountName}',
	'WorkPhone' => 'telephoneNumber',
	'Address1' => 'streetAddress',
	'City' => 'l',
	'State' => 'st',
	'Zip' => 'postalCode',
	'Country' => 'co',
	},
	},
	}
	);" >> ${rt_configd}/ldap.pm


	echo "" >> ${rt_configd}/ldap.pm
	echo "Set(\$LDAPHost,'RT_LDAP_SERVER');" | sed -e "s=RT_LDAP_SERVER=${RT_LDAP_SERVER:-ldap://windowsdc.com}=" >> ${rt_configd}/ldap.pm
	echo "Set(\$LDAPUser,'RT_LDAP_USER');" | sed -e "s=RT_LDAP_USER=${RT_LDAP_USER:-myuser}=" >> ${rt_configd}/ldap.pm
	echo "Set(\$LDAPPassword,'RT_LDAP_PASS');" | sed -e "s=RT_LDAP_PASS=${RT_LDAP_PASS:-mypass}=" >> ${rt_configd}/ldap.pm

	echo 'Set($LDAPCreatePrivileged, 1);' >> ${rt_configd}/ldap.pm
	echo 'Set($LDAPUpdateUsers, 1);' >> ${rt_configd}/ldap.pm
	echo 'Set($LDAPImportGroupMembers, 1);' >> ${rt_configd}/ldap.pm

	echo "Set(\$LDAPBase, '${RT_LDAP_BASE:-CN=Users,DC=domain,DC=local}');" >> ${rt_configd}/ldap.pm
	echo "Set(\$LDAPFilter, '${RT_LDAP_FILTER:-(objectClass=*)}');" >> ${rt_configd}/ldap.pm
	echo "Set(\$LDAPMapping, {
	'Name'         => '${RT_LDAP_ATTR_ACCOUNT:-sAMAccountName}',
	'EmailAddress' => '${RT_LDAP_ATTR_MAIL:-mail}',
	'RealName'     => '${RT_LDAP_ATTR_NAME:-cn}',
	'WorkPhone'    => 'telephoneNumber',
	'Organization' => '${RT_LDAP_ATTR_ORG:-physicalDeliveryOfficeName}',
	});" >> ${rt_configd}/ldap.pm

	echo "Set(\$LDAPGroupBase, '${RT_LDAP_BASE:-CN=Users,DC=domain,DC=local}');" >> ${rt_configd}/ldap.pm
	echo "Set(\$LDAPGroupFilter, '${RT_LDAP_GRPFILTER:-(objectClass=*)}');" >> ${rt_configd}/ldap.pm
   
	echo "Set(\$LDAPGroupMapping, {
	'Name'               => '${RT_LDAP_ATTR_NAME:-cn}',
        'Member_Attr'        => '${RT_LDAP_GRPATTR:-member}',
        'Member_Attr_Value'  => '${RT_LDAP_GRPATTR_VALUE:-dn}',
	});" >> ${rt_configd}/ldap.pm

	# Setup Cron Job
	echo "*/2 * * * * /opt/rt4/sbin/rt-ldapimport --import >/dev/null 2>&1" > /tmp/mycron

fi

# Misc Settings
echo 'Set( %GnuPG, Enable => 0, );' >> ${rt_config}

cp /data/RT_SiteConfig.pm /opt/rt4/etc/RT_SiteConfig.pm
chown rt-service:www-data /opt/rt4/etc/RT_SiteConfig.pm
chmod 0640 /opt/rt4/etc/RT_SiteConfig.pm

if [[ -z  "$RT_RELAYHOST" ]]; then
    echo >&2 "You must specify RT_RELAYHOST."
    exit 1
fi

sed -i -e "s=HOSTNAME=${RT_NAME:-rt.example.com}=" /etc/lighttpd/conf-available/89-rt.conf

cat >> /opt/postfix.sh <<EOF
#!/bin/bash
service postfix start
touch /var/log/mail.log
tail -f /var/log/mail.log
EOF

chmod +x /opt/postfix.sh

postconf -e myhostname="${RT_NAME:-rt.example.com}"
postconf -e inet_interfaces=loopback-only
postconf -e inet_protocols=ipv4
postconf -e mydestination="${RT_NAME:-rt.example.com}",localhost
postconf -e myhostname="${RT_NAME:-rt.example.com}"
postconf -e mynetworks=127.0.0.0/8
postconf -e relayhost="$RT_RELAYHOST"


#### Init DB (Only once)
sleep 10s
touch "/tmp/$(/usr/bin/perl /opt/rt4/sbin/rt-preferences-viewer --user=root 2>&1 | grep "Users' doesn't exist" | grep error -c).lck"

if [ -f /tmp/1.lck ]; then
	rm /tmp/1.lck
	/usr/bin/perl /opt/rt4/sbin/rt-setup-database --action init --skip-create > /tmp/initdb.log 2>&1
	## Setup Full Indexing
	if [ "${RT_DBTYPE:-mysql}" = "mysql" ]; then
		yes "" | /usr/bin/perl /opt/rt4/sbin/rt-setup-fulltext-index  --dba ${RT_DBUSER:-${DATABASE_ENV_MYSQL_USER:-rt_user}} --dba-password ${RT_DBPASS:-${DATABASE_ENV_MYSQL_PASSWORD:-rt_pass}} >> /tmp/initdb.log 2>&1
	
		echo "Set( %FullTextSearch,
		    Enable     => 1,
		    Indexed    => 1,
		    Table      => 'AttachmentsIndex',
		);" > ${rt_configd}/fulltext.pm
	
	fi
fi

# Indexer Cron Job
if [ "${RT_DBTYPE:-mysql}" = "mysql" ]; then
	# Setup Cron Job
	echo "0 23 * * * /opt/rt4/sbin/rt-fulltext-indexer --quiet" >> /tmp/mycron
fi



# Install / Enable RTIR
if [ "${RT_RTIR}" = "1" ]; then

	# Enable RTIR
        echo "Set(@Plugins, 'RT::IR');" > ${rt_configd}/rtir.pm

	if [ ! -d /opt/rt4/local/plugins/RT-IR ]; then
		
		rtir_ver=${RT_RTIR_VER:-4.0.1}
		rtir_log=/tmp/rtir_setup.log
		curl -SL https://download.bestpractical.com/pub/rt/release/RT-IR-${rtir_ver}.tar.gz | tar --overwrite -xzC /tmp/

		# Install RTIR
		if [ -d /tmp/RT-IR-${rtir_ver} ]; then
	
			cd /tmp/RT-IR-${rtir_ver}
			perl Makefile.PL > ${rtir_log}
			make install >> ${rtir_log}

			/usr/bin/perl -I. -Ilib -I/opt/rt4/local/lib -I/opt/rt4/lib /opt/rt4/sbin/rt-setup-database \
			--action insert --datadir etc --datafile /tmp/RT-IR-${rtir_ver}/etc/initialdata \
			--skip-create --package RT::IR --ext-version ${rtir_ver} >> ${rtir_log}

		fi

	fi

else
	# Disable RTIR
	echo "# Set RT_RTIR=1 as Docker ENV to enable RTIR" > ${rt_configd}/rtir.pm

fi


#### Queue consumption for Incoming Messages
declare -a array_queue=(${FETCHMAIL_ENV_FETCH_QUEUES})
declare -a array_type=(${FETCHMAIL_ENV_FETCH_QUEUES_TYPE})
max_iteration=${#array_queue[@]}

# Load Variables
amqp_connect_link="amqp://${FETCHMAIL_ENV_FETCH_MQ_USER:-${RABBITMQ_ENV_RABBITMQ_DEFAULT_USER:-guest}}:${FETCHMAIL_ENV_FETCH_MQ_PASS:-${RABBITMQ_ENV_RABBITMQ_DEFAULT_PASS:-guest}}@${FETCHMAIL_ENV_FETCH_MQ_HOST:-rabbitmq}:${FETCHMAIL_ENV_FETCH_MQ_PORT:-5672}"
amqp_connect=${RT_MQ_URI:-${amqp_connect_link}}

# Generate Cronlines
if [ ${max_iteration} -gt 0 ]; then

	for i in $(seq 0 $((max_iteration-1))); do
	
		if [ "${array_type[$i]}" = "comment" ]; then
			echo "* * * * * /usr/bin/flock -n /tmp/amqp-${array_queue[$i]}.lockfile /usr/bin/amqp-consume -c ${RT_MQ_RECYCLE:-100} -q '${array_queue[$i]}' --url='${amqp_connect}/comment' /root/wrapper.sh '${array_queue[$i]}' '${array_type[$i]}'" >> /tmp/mycron
		else
			echo "* * * * * /usr/bin/flock -n /tmp/amqp-${array_queue[$i]}.lockfile /usr/bin/amqp-consume -c ${RT_MQ_RECYCLE:-100} -q '${array_queue[$i]}' --url='${amqp_connect}/correspond' /root/wrapper.sh '${array_queue[$i]}' '${array_type[$i]}'" >> /tmp/mycron
		fi

	done

fi

#### Cron Setup
declare -p | grep -Ev 'BASHOPTS|BASH_VERSINFO|EUID|PPID|SHELLOPTS|UID' > /container.env

crontab /tmp/mycron >/dev/null 2>&1
rm /tmp/mycron >/dev/null 2>&1

exec "$@"
