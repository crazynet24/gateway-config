class { 'ffnord::params':
  router_id => "10.112.1.11", # The id of this router, probably the ipv4 address
                              # of the mesh device of the providing community
  icvpn_as => "49009",        # The as of the providing community
  wan_devices => ['eth0'],     # A array of devices which should be in the wan zone
  
  conntrack_max => 131072,
  conntrack_tcp_timeout => 3600,
  conntrack_udp_timeout => 65,

  wmem_default => 1572864,
  wmem_max     => 1572864,
  rmem_default => 1572864,
  rmem_max     => 1572864,

  max_backlog  => 5000,
}

ffnord::mesh { 'mesh_ffhh':
      mesh_name    => "Freifunk Hamburg",
      mesh_code    => "ffhh",
      mesh_as      => 49009,
      mesh_mac     => "de:ad:be:ef:01:01",
      vpn_mac      => "de:ad:be:ff:01:01",
      mesh_ipv6    => "2a03:2267::202/64",
      mesh_ipv4    => "10.112.1.11/18",
      mesh_mtu     => "1406",
      range_ipv4   => "10.112.0.0/16",
      mesh_peerings => "/root/mesh_peerings.yaml",

      fastd_secret => "/root/fastd_secret.key",
      fastd_port   => 10000,
      fastd_peers_git => 'git@git.hamburg.freifunk.net:fastdkeys',

      dhcp_ranges => [ '10.112.2.2 10.112.9.254'
                     ],
      dns_servers => [ '10.112.1.1'
                     ],
}

ffnord::mesh { 'mesh_helgo':
      mesh_name    => "Freifunk Helgoland",
      mesh_code    => "helgo",
      mesh_as      => 65189,
      mesh_mac     => "de:ad:aa:ef:01:01",
      vpn_mac      => "de:ad:ab:ef:01:01",
      mesh_ipv6    => "2a03:2267:4e16:01ad::101/64",
      mesh_ipv4    => "10.189.1.1/18",
      mesh_mtu     => "1406",
      range_ipv4   => "10.189.0.0/18",
      mesh_peerings => "/root/mesh_peerings_helgo.yaml",

      fastd_secret => "/root/fastd_secret_helgo.key",
      fastd_port   => 10100,
      fastd_peers_git => 'git@git.hamburg.freifunk.net:helgokeys',

      dhcp_ranges => [ '10.189.10.2 10.189.17.254'
                     ],
      dns_servers => [ '10.112.1.1'
                     ],
}

ffnord::dhcpd::static {
  'ffhh': static_git => 'https://github.com/freifunkhamburg/dhcp-static.git';
}

ffnord::uplink6::bgp {
    'suede0':
      local_ipv6 => "2a03:2267:ffff:0c00::2",
      remote_ipv6 => "2a03:2267:ffff:0c00::1",
      remote_as => "49009",
      uplink_interface => "eth1";
}
ffnord::uplink6::interface {
    'eth1':;
}

ffnord::icvpn::setup { 'hamburg01':
    icvpn_as => 49009,
    icvpn_ipv4_address => "10.207.0.61",
    icvpn_ipv6_address => "fec0::a:cf:0:3d",
    icvpn_exclude_peerings => [hamburg],
    tinc_keyfile       => "/root/tinc_rsa_key.priv"
}

class {
  'ffnord::uplink::ip':
    nat_network => '185.66.193.61/32',
    tunnel_network => '100.64.0.128/26',
}
ffnord::uplink::tunnel {
    'ffrlber':
      local_public_ip => "80.252.100.115",
      remote_public_ip => "185.66.195.1",
      local_ipv4 => "100.64.0.161/31",
      remote_ip => "100.64.0.160",
      tunnel_mtu => "1400",
      remote_as => "201701";
    'ffrldus':
      local_public_ip => "80.252.100.115",
      remote_public_ip => "185.66.193.1",
      local_ipv4 => "100.64.0.163/31",
      remote_ip => "100.64.0.162",
      tunnel_mtu => "1400",
      remote_as => "201701";
}

class { 'ffnord::alfred': master => false }

class { 'ffnord::etckeeper': }

class {
  'ffnord::monitor::zabbix':
    zabbixserver => "80.252.106.17";
}
