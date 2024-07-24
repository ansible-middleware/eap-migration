Wildfly Migration
=================

This repository contains a set of Ansible based playbooks that demonstrate how to use a the [JBoss Migration tool](https://access.redhat.com/documentation/en-us/red_hat_jboss_enterprise_application_platform/7.1/html/using_the_jboss_server_migration_tool/index) to migrate the configuration of a Wildfly or JBoss EAP
instance to a newer version.

Note: this demonstration is using JBoss EAP rpm installation and the Red Hat productized collection (redhat.eap) available on Automation Hub. Thus it requires access to those assets. However, the content can easily be adapted to use the upstream version of JBoss EAP (Wildfly) and the upstream version of the collection [Wildfly](https://github.com/middleware_automation/wildfly)

## Prerequistes

As this demo uses a collection available on [Red Hat Automation Hub](https://www.ansible.com/products/automation-hub), on top of collection coming from Ansible Galaxy, you'll need to properly configure access to both system and provide your credentials for Automation Hub, in the ansible.cfg file:

    [galaxy]
    server_list = automation_hub, galaxy

    [galaxy_server.galaxy]
    url=https://galaxy.ansible.com/

    [galaxy_server.automation_hub]
    url=https://cloud.redhat.com/api/automation-hub/

    auth_url=https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token

    token=<your-token>

The playbook prepare_migration expects the jboss-eap-7.3.0.zip to be available on the target system (localhost), you'll need to retrieve this archive from the [Red Hat Customers portal](https://access.redhat.com/).

## Set up

Three playbooks compose this demo:

1. setup_eap.yml - this playbook will setup and configure the EAP 7.2.0 instance to use a MariaDB datasources and deploy the associated JDBC driver.

2. prepare_migration - this playbook prepare the migration from EAP 7.2.0 to EAP 7.3.0

3. perform_migration - this playbook execute the migration

All are designed to run directly on the RHEL system hosting the EAP instance.

Before running the first playbook, ensure the required Ansible collection have been installed :

    $ ansible-galaxy collection install -r requirements.yml

Then you can simply each playbook, one after the other:

    $ ansible-playbook -i inventory setup_eap.yml

At the end of this first playbook's execution, the 'eap' service is running and the instance is configured to use MariaDB:

    # systemctl status eap
	# /opt/rh/eap7/root/usr/share/wildfly/bin/jboss-cli.sh --connect
	[standalone@localhost:9990 /] ls /subsystem=datasources/data-source=
	ExampleDS    MariaDBPool

From there, you can use the next playbook to prepare the migration:

	$ ansible-playbook -i inventory prepare_migration.yml

And finally, perform the migration itself:

	$ ansible-playbook -i inventory perform_migration.yml

Note that the same playbooks can be used to migrate again from 7.3.0 to 7.4.0 :

	$ ansible-playbook  -i inventory \
                        -e eap_source_version=7.3.0 \
                 		-e target_eap_version=7.4.0 \
                 		prepare_migration.yml
	$ ansible-playbook 	-i inventory \
                        -e eap_source_version=7.3.0 \
                 		-e target_eap_version=7.4.0 \
                 		perform_migration.yml
