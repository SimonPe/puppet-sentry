# == Class: sentry::install
#
# Installs Sentry from pip into a virtualenv
#
# === Authors
#
# Dan Sajner <dsajner@covermymeds.com>
# Scott Merrill <smerrill@covermymeds.com>
#
# === Copyright
#
# Copyright 2015 CoverMyMeds
#
# === Params
#
# @param admin_email Sentry admin user email address
# @param admin_password Sentry admin user password
# @param bootstrap Should this node bootstrap the database
# @param extensions hash of sentry extensions and source URL to install
# @param group UNIX group to own Sentry files
# @param ldap_auth_version version of the sentry-ldap-auth plugin to install
# @param organization default Sentry organization to create
# @param team default Sentry team to create
# @param path path into which to create virtualenv and install Sentry
# @param project initial Sentry project to create
# @param url URL from which to install Sentry
# @param user UNIX user to own Sentry files
# @param version version of Sentry to install
#
class sentry::install (
  $admin_email       = $sentry::admin_email,
  $admin_password    = $sentry::admin_password,
  $bootstrap         = $sentry::bootstrap,
  $extensions        = $sentry::extensions,
  $group             = $sentry::group,
  $ldap_auth_version = $sentry::ldap_auth_version,
  $organization      = $sentry::organization,
  $team              = $sentry::team,
  $path              = $sentry::path,
  $project           = $sentry::project,
  $url               = $sentry::url,
  $user              = $sentry::user,
  $version           = $sentry::version,
) {
  assert_private()

  Python::Pip {
    ensure     => present,
    virtualenv => $path,
  }

  python::pip { 'sentry':
    ensure => $version,
    url    => $url,
  }

  # we install this *after* Sentry to ensure that a newer version of
  # Sentry is installed.  This only requires 4.3.0, so Pip's dependency
  # resolution may install an older version of Sentry, which would
  # then be promptly upgraded.
  python::pip { 'sentry-ldap-auth':
    ensure  => $ldap_auth_version,
    require => Python::Pip['sentry'],
  }

  # Install any extensions we might have been given. We install these
  # *after* Sentry to ensure the correct version of Sentry is installed
  case $extensions {
    Hash: {
      $extensions.each |String $extension, String $url| {
        python::pip { $extension:
          url     => $url,
          require => Python::Pip['sentry'],
        }
      }
    }
    Array[String]: {
      $extensions.each |String $extension| {
        python::pip { $extension:
          require => Python::Pip['sentry'],
        }
      }
    }
    true: {
      python::pip { 'sentry-plugins':
        ensure => $::sentry::version,
      }
    }
    false: {
      python::pip { 'sentry-plugins':
        ensure => absent,
      }
    }
    default: {
      fail("don't know what to do with extensions parameter: ${extensions}")
    }
  }

  if $bootstrap {
    # this exec will handle creating a new database, as well as upgrading
    # an existing database.  The `creates` parameter is version-specific,
    # so this should run automatically on version upgrades.
    # The initial bootstrap migrations can take a while, especially on underpowered dev machines.
    # Disable the timeout so we don't fail.
    exec { 'sentry-database-install':
      command => "${path}/bin/sentry --config=${path} upgrade --noinput > ${path}/install-${version}.log 2>&1 && touch ${path}/install-${version}.success",
      creates => "${path}/install-${version}.success",
      path    => "${path}/bin:/bin:/usr/bin",
      timeout => 0,
      user    => $user,
      group   => $group,
      cwd     => $path,
      require => [ Python::Pip['sentry'], User[$user], ],
    }

    # the `creates` log file is not version-specific, so as to ensure
    # this only runs once, upon initial installation.
    # Note: A failure here is catastrophic, and will prevent additional
    # Sentry configuration.
    exec { 'sentry-create-admin':
      command => "${path}/bin/sentry --config=${path} createuser --superuser --email=${admin_email} --password=${admin_password} --no-input > ${path}/admin-${admin_email}.log 2>&1 && touch ${path}/admin-${admin_email}.success",
      creates => "${path}/admin-${admin_email}.success",
      path    => "${path}/bin:/usr/bin:/usr/sbin:/bin",
      require => Exec['sentry-database-install'],
    }

    file { "${path}/bootstrap.py":
      ensure  => present,
      mode    => '0744',
      content => template('sentry/bootstrap.py.erb'),
      require => Exec['sentry-create-admin'],
    }

    exec { 'sentry-bootstrap':
      command => "${path}/bootstrap.py && touch ${path}/bootstrap.success",
      creates => "${path}/bootstrap.success",
      path    => "${path}/bin:/usr/bin/:/usr/sbin:/bin",
      require => File["${path}/bootstrap.py"],
    }

    file { "${path}/dsn":
      ensure  => directory,
      mode    => '0755',
      owner   => $user,
      group   => $group,
      require => File["${path}/bootstrap.py"],
    }
  }
}
