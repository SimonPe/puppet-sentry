# == Class: sentry::setup
#
# Installs Sentry prerequisites
#
# === Params
#
# group: UNIX group to own Sentry files
# path: path into which to create virtualenv and install Sentry
# user: UNIX user to own Sentry files
#
# === Authors
#
# Scott Merrill <smerrill@covermymeds.com>
#
# === Copyright
#
# Copyright 2016 CoverMyMeds
#
class sentry::setup (
  $system_dependencies,
  $db_dependencies   = {},
  $group             = $sentry::group,
  $path              = $sentry::path,
  $user              = $sentry::user,
  String $db_engine  = $sentry::db_engine,
) {
  assert_private()

  group { $group:
    ensure => present,
  }

  user { $user:
    ensure  => present,
    gid     => $group,
    home    => $path,
    shell   => '/bin/false',
    require => Group[$group],
  }

  file { '/var/log/sentry':
    ensure  => directory,
    owner   => 'sentry',
    group   => 'sentry',
    mode    => '0755',
    require => User[$user],
  }

  ensure_packages($system_dependencies)
  if $db_dependencies[$db_engine] {
    ensure_packages($db_dependencies[$db_engine])
  }

  python::virtualenv { $path:
    ensure  => present,
    owner   => $user,
    group   => $group,
    version => 'system',
  }

  Python::Pip {
    ensure     => present,
    virtualenv => $path,
  }

  $pip_dependencies = [
    'django-auth-ldap',
    'hiredis',
    'nydus',
    'python-memcached',
    'python-ldap',
    'redis',
  ]
  $pip_db_dependencies = $db_engine ? {
    'mysql' => 'mysqlclient',
    'pgsql' => 'psycopg2',
    default => [],
  }

  python::pip { $pip_dependencies: }
  python::pip { $pip_db_dependencies: }

}
