#!/bin/bash

ansible-playbook -e eap_source_version=7.3 \
                 -e target_eap_version=7.4 \
                 prepare_migration.yml
