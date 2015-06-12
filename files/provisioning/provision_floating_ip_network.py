#!/usr/bin/env python
#
# Copyright 2015 c.glaubitz@syseleven.de
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.
#
##############################################################################
#
# Bootstrapping a floating ip network every needed configuration in
# OpenContrail.
#
# Basically it creates:
#  * virtual network with proerties and subnet
#  * network policy
#  * network ipam
#  * floating ip pool
#  * route target
# 
import re
import os
import sys
import logging
try:
    # for kilo ff
    from oslo_config import cfg
    from oslo_config import types
except ImportError:
    from oslo.config import cfg
    from oslo.config import types
from keystoneclient.v2_0 import client
from vnc_api import vnc_api
from vnc_api.gen.resource_client import FloatingIpPool
from vnc_api.gen.resource_client import VirtualNetwork
from vnc_api.gen.resource_client import NetworkIpam
from vnc_api.gen.resource_client import NetworkPolicy

from vnc_api.gen.resource_xsd import VnSubnetsType
from vnc_api.gen.resource_xsd import IpamSubnetType
from vnc_api.gen.resource_xsd import SubnetType

from vnc_api.gen.resource_xsd import PolicyEntriesType
from vnc_api.gen.resource_xsd import PolicyRuleType
from vnc_api.gen.resource_xsd import AddressType
from vnc_api.gen.resource_xsd import PortType
from vnc_api.gen.resource_xsd import ActionListType
from vnc_api.gen.resource_xsd import VirtualNetworkPolicyType
from vnc_api.gen.resource_xsd import RouteTargetList
from vnc_api.gen.resource_xsd import VirtualNetworkType

from cfgm_common.exceptions import NoIdError

class RouteTarget(object):
    """ Validates Route Target Param """
    def __init__(self):
        self.rt_pat = re.compile('[0-9]+:[0-9]+')

    def __call__(self, value):
        if not self.rt_pat.match(value):
            raise ValueError('%s is not a valid route target (1234:4321)' % value)
        return value

    def __repr__(self):
        return "RouteTarget"

    def __eq__(self, other):
        self.__class__ == other.__class__

_default_net_name = 'float24'
conf = {
        'default_project': ['default-domain', 'admin'],
        'default_net_name': _default_net_name,
        'default_net': ['default-domain', 'admin', _default_net_name],
        'default_pool': ['default-domain', u'admin', _default_net_name, 'default'],
        'default_network_policy': ['default-domain', 'admin', 'default'],
        'default_allow_transit': True,
        'default_api_address': '127.0.0.1',
        }

def set_default_net_name(value):
    conf['default_net_name'] = value
    conf['default_net'][2] = value
    conf['default_pool'][2] = value

_common_opts = [
    cfg.Opt('ip_prefix',
            type=types.IPAddress(),
            help='IP address prefix of the floating ip network. Example: 10.0.0.0'),
    cfg.IntOpt('ip_prefix_len',
               help='IP address prefix length of the floating ip network. Example: 24 for ip_prefix/24'),
    cfg.Opt('gateway',
            type=types.IPAddress(),
            help='Default gatway of the floating ip network. Example: 10.0.0.1'),
    cfg.Opt('route_target',
            type=RouteTarget(),
            help='Default route target of the floating ip network. Example: 65000:30'),
    cfg.StrOpt('net_name',
               default=conf.get('default_net_name'),
               help='Name of the floating ip network. Default: %s' % conf.get('default_net_name')),
    cfg.StrOpt('api_address',
        default=conf.get('default_api_address'),
        help='Name of the floating ip network. Default: %s' % conf.get('default_api_address')),
        ]

log = logging.getLogger(__name__)

def get_keystone_client():
    """ Get a configured and connected keystoneclient """
    username = os.environ.get('OS_USERNAME')
    password = os.environ.get('OS_PASSWORD')
    tenant = os.environ.get('OS_TENANT_NAME')
    url = os.environ.get('OS_AUTH_URL')
    assert username is not None
    assert password is not None
    assert tenant is not None
    assert url is not None
    cl = client.Client(username=username, password=password,
                       tenant_name=tenant, auth_url=url)
    return cl

def get_keystone_token(con):
    """ Get the keystone token """
    return con.get_token(con.session)

def get_project(con):
    """ Returns vnc_api.gen.resource_client.Project from api or None """
    try:
        return con.project_read(fq_name=conf.get('default_project', 'UNEXPECTED_VALUE'))
    except:
        log.debug('Unable to find project default-domain, admin:', exc_info=True)
        return None

def get_net(con):
    """ Returns vnc_api.gen.resource_client.VirtualNetwork from api or None """
    try:
        return con.virtual_network_read(fq_name=conf.get('default_net', 'UNEXPECTED_VALUE'))
    except NoIdError:
        log.debug('Unable to find net.')
        return None

def get_default_pool(con):
    """ Returns vnc_api.gen.resource_client.FloatingIpPool from api or None """
    try:
        return con.floating_ip_pool_read(fq_name=conf.get('default_pool', 'UNEXPECTED_VALUE'))
    except NoIdError:
        log.debug('Unable to find pool.')
        return None

def get_default_ipam(con):
    """ Returns vnc_api.gen.resource_client.NetworkIpam from api or None """
    try:
        return con.network_ipam_read(fq_name=conf.get('default_net', 'UNEXPECTED_VALUE'))
    except NoIdError:
        log.debug('Unable to find net ipam')
        return None

def get_default_network_policy(con):
    """ Returns vnc_api.gen.resource_client.NetworkPolicy from api or None """
    try:
        return con.network_policy_read(fq_name=conf.get('default_network_policy', 'UNEXPECTED_VALUE'))
    except NoIdError:
        log.debug('Unable to find default_network_policy')
        return None

def gen_virtual_network(project, route_target_list, virtual_network_properties):
    vnet = VirtualNetwork(name=conf.get('default_net_name'),
                          parent_obj=project,
                          route_target_list=route_target_list,
                          virtual_network_properties=virtual_network_properties)
    return vnet

def gen_route_target_list(route_target):
    """ Returns a configured vnc_api.gen.resource_xsd.RouteTargetList """
    rt = RouteTargetList(route_target=route_target)
    return rt

def gen_virtual_network_properties(allow_transit):
    """ Returns a configured vnc_api.gen.resource_xsd.VirtualNetworkType """
    props = VirtualNetworkType(allow_transit=allow_transit)
    return props

def gen_floating_ip_pool(vnet):
    """ Returns a configured vnc_api.gen.resource_client.FloatingIpPool """
    pool = FloatingIpPool(name='default',
            parent_obj=vnet,
            )
    return pool

def gen_ipam(project):
    """ Returns a configured vnc_api.gen.resource_client.NetworkIpam """
    ipam = NetworkIpam(name=conf.get('default_net_name'),
                       parent_obj=project)
    return ipam

###
# vnet.network_ipam_refs[0]
# subnet = vnet.network_ipam_refs[0]['attr']
# <vnc_api.gen.resource_xsd.VnSubnetsType at 0x7fad355bf050>
# res = subnets.get_ipam_subnets()
# [<vnc_api.gen.resource_xsd.IpamSubnetType at 0x7fad355bf0d0>]
# subnet = res[0]
# res = subnet.get_subnets()
# <vnc_api.gen.resource_xsd.SubnetType at 0x7fad355bf110>
# res.get_ip_prefix()
# u'192.168.0.0'
# res.get_ip_prefix_len()
# 24

## how to delete
# pool = con.floating_ip_pool_read(fq_name=['default-domain', 'admin', 'float24', 'default'])
# vnet = con.virtual_network_read(fq_name=[u'default-domain', u'admin', u'float24'])
# ipam = vnc_lib.network_ipam_read(fq_name=[u'default-domain', u'admin', u'float24'])
# con.floating_ip_pool_delete(id=pool.uuid)
# con.virtual_network_delete(id=vnet.uuid)
# con.network_ipam_delete(id=ipam.uuid)

def gen_ipam_subnet(ip_prefix, ip_prefix_len, default_gateway):
    """ Returns a configured vnc_api.gen.resource_xsd.VnSubnetsType
    
    Filled with SubnetType and IpamSubnetType stuff.
    """
    subnet = SubnetType(ip_prefix=ip_prefix, ip_prefix_len=ip_prefix_len)
    ipam_subnet = IpamSubnetType(subnet=subnet, default_gateway=default_gateway)
    vn_subnet = VnSubnetsType(ipam_subnets=[ipam_subnet])
    return vn_subnet

def gen_network_policy_entries():
    """ Returns a configured vnc_api.gen.resource_xsd.PolicyEntriesType

    Filled with ActionListType and PolicyEntriesType.
    """
    src_port = PortType(start_port=-1, end_port=-1)
    dst_port = PortType(start_port=-1, end_port=-1)
    src_address = AddressType(virtual_network='any')
    dst_address = AddressType(virtual_network='any')
    action = ActionListType(simple_action='pass')
    rule = PolicyRuleType(protocol='any',
                          direction='<>',
                          src_ports=[src_port],
                          src_addresses=[src_address],
                          dst_ports=[dst_port],
                          dst_addresses=[dst_address],
                          action_list=action
                          )
    entry = PolicyEntriesType(policy_rule=[rule])
    return entry

def gen_network_policy(project, entries):
    """ Returns a configured vnc_api.gen.resource_client.NetworkPolicy """
    pol = NetworkPolicy(name='default',
                        parent_obj=project,
                        network_policy_entries=entries)
    return pol

def create_virtual_network(con, project, route_target, allow_transit):
    virtual_network_props = gen_virtual_network_properties(allow_transit)
    route_target_list = gen_route_target_list(route_target)
    vnet = gen_virtual_network(project, route_target_list,
                               virtual_network_props)
    con.virtual_network_create(vnet)

def create_floating_ip_pool(con, vnet):
    pool = gen_floating_ip_pool(vnet)
    con.floating_ip_pool_create(pool)

def create_ipam(con, project):
    ipam = gen_ipam(project)
    con.network_ipam_create(ipam)

def create_network_policy(con, project):
    entries = gen_network_policy_entries()
    policy = gen_network_policy(project, entries)
    con.network_policy_create(policy)

def setup_api():
    keystone_client = get_keystone_client()
    auth_token = keystone_client.get_token(keystone_client.session)
    con = vnc_api.VncApi(api_server_host=conf.get('api_server', cfg.CONF.api_address),
                         auth_token=auth_token)
    return con

def setup_logging(level=logging.INFO):
    logging.basicConfig()
    log.setLevel(level)

def main(con, ip_prefix, ip_prefix_len, default_gateway, route_target):

    # count who many steps were performed
    step_created_cnt = 0

    project = get_project(con)
    if not project:
        log.error('Unable to find project.')
        return -1

    network_policy = get_default_network_policy(con)
    if not network_policy:
        step_created_cnt+=1
        log.debug('Creating network policy.')
        create_network_policy(con, project)
        network_policy = get_default_network_policy(con)
    else:
        log.debug('Network policy already exists.')

    if not network_policy:
        log.error('Unable to continue, since no network_policy default-domain, admin, default found.')
        return -1

    ipam = get_default_ipam(con)
    if not ipam:
        step_created_cnt+=1
        log.debug('Creating network IPAM.')
        create_ipam(con, project)
        ipam = get_default_ipam(con)
    else:
        log.debug('Network IPAM already exists.')

    if not ipam:
        log.error('Unable to continue, since no network_ipam default-domain, admin, %s found.', conf.get('default_net_name'))
        return -1

    vnet = get_net(con)
    if not vnet:
        step_created_cnt+=1
        log.debug('Creating virtual network.')
        allow_transit = conf.get('default_allow_transit', False)
        create_virtual_network(con, project, route_target, allow_transit)
        vnet = get_net(con)
    else:
        log.debug('%s already exists.', conf.get('default_net_name'))

    if not vnet:
        log.error('Unable to continue, since no virtual_network %s available.', conf.get('default_net_name'))
        return -1

    if not vnet.get_network_ipam_refs():
        step_created_cnt+=1
        log.debug('connecting ipam and vn_subnet to vnet')
        vn_subnet = gen_ipam_subnet(ip_prefix, ip_prefix_len, default_gateway)
        vnet.set_network_ipam(ipam, vn_subnet)
        con.virtual_network_update(vnet)
        # rebuild vnet object from db, since the local one, does not contain
        # all the refs yet.
        vnet = get_net(con)

    if not vnet.get_network_policy_refs():
        step_created_cnt+=1
        log.debug('connecting default network policy to vnet')
        vnet.set_network_policy(network_policy, VirtualNetworkPolicyType())
        con.virtual_network_update(vnet)
        # rebuild vnet object from db, since the local one, does not contain
        # all the refs yet.
        vnet = get_net(con)

    pool = get_default_pool(con)
    if not pool:
        step_created_cnt+=1
        log.debug('Creating floating ip pool.')
        create_floating_ip_pool(con, vnet)
        pool = get_default_pool(con)
    else:
        log.debug('floating ip pool already exists.')

    if not pool:
        log.error('Unable to continue, since no default floating_ip_pool available.')
        return -1

    return step_created_cnt

def build_route_target(value):
    return ['target:%s' % value]

def validate_params(cfg):
    if not cfg.CONF.ip_prefix:
        log.error('Please provide a ip_prefix. See --help.')
        exit(1)
    if not cfg.CONF.ip_prefix_len:
        log.error('Please provide a ip_prefix_len. See --help.')
        exit(1)
    if not cfg.CONF.gateway:
        log.error('Please provide a default_gateway. See --help.')
        exit(1)
    if not cfg.CONF.route_target:
        log.error('Please provide a route_target. See --help.')
        exit(1)

if __name__ == '__main__':
    cfg.CONF.register_cli_opts(_common_opts)
    cfg.CONF(sys.argv[1:], project='generate_float',
            prog='generate_float')

    con = setup_api()
    setup_logging(logging.DEBUG)
    log.info('THIS SCRIPT only creates new parts and do not perform any '
             'change to existing parts!!!')
    set_default_net_name(cfg.CONF.net_name)

    validate_params(cfg)

    res = main(con, cfg.CONF.ip_prefix, cfg.CONF.ip_prefix_len,
               cfg.CONF.gateway, build_route_target(cfg.CONF.route_target))
    if res == -1:
        log.error('Failed to create floating ip pool.')
        exit(1)
    elif res == 0:
        log.info('Did not perform _any_ change, since all parts do exist.')
    exit(0)
