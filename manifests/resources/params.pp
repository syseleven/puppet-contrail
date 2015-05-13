# Global parameters used throughout the contrail module.
class contrail::resources::params(
  $controllers = hiera_hash('sys11stack::controllers', false),
) {
  $cassandra_server_list = join(suffix(controllers2array($controllers, 'ips'), ':9160'), ' ')
  $collectors = join(suffix(controllers2array($controllers, 'ips'), ':8086'), ' ')
}
