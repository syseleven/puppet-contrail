puppet-contrail
===============

# Puppet recipes for setting up OpenContrail

This software is licensed under the Apache License, Version 2.0 (the "License");
you may not use this software except in compliance with the License.
You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and


### Overview

This module sets up OpenContrail. It follows the profile/role pattern, i.e. it
contains profile classes for services and other atomic pieces of configuration
such as network devices. These profiles are aggregated into roles to be
assigned to machines in an OpenContrail enabled OpenStack cloud. At present the
following roles are defined:


1. role/compute - Contains the minimum set of profiles required to configure
   contrail on a Nova compute node.

2. role/controller - Contains all contrail services not running on compute
   nodes. This includes the controller, log collection and analytics, database
   services and the web UI among others.


### State of Development

This module is currently being readied for public consumption and very much
alpha. Some profiles may work, some may not. Use at your own risk.
