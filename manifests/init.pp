# I can't manage to use the ingest-geoip plugin without this.
# A symlink to /etc/elasticsearch/ingest-geoip with proper ownership and
# permissions doesn't work.

# Requires camptocamp/systemd

class elasticpatch(Array $instances) {

    include systemd::systemctl::daemon_reload

    $etcel = '/etc/elasticsearch'
    $rsync = '/bin/rsync -avu --delete'
    $plug = 'ingest-geoip'

    ensure_packages(['rsync'], {'ensure' => 'present'})

    $instances.each |String $i| {
        systemd::dropin_file { "es_${i}_service_patch.conf":
            unit    => "elasticsearch-${i}.service",
            content => join([
              '[Service]',
              '# Execute pre and post scripts as root.',
              'PermissionsStartOnly=true',
              "ExecStartPre=-/bin/bash -c '${rsync} ${etcel}/${plug} ${etcel}/${i}/'\n",
            ], "\n"),
            notify  => Service["elasticsearch-${i}.service"],
            require => Package['rsync'],
        }
    }

}
