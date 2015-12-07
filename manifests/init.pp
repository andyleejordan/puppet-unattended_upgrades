class unattended_upgrades(
  $period                       = 1,                                             # Update period (in days)
  $repos                        = {},                                            # Repos to upgrade
  $blacklist                    = [],                                            # Packages to not update
  $email                        = '',                                            # Email for update status
  $autofix                      = true,                                          # Ensure updates keep getting installed
  $minimal_steps                = true,                                          # Allows for shutdown during an upgrade
  $on_shutdown                  = false,                                         # Install only on shutdown
  $on_error                     = false,                                         # Email only on errors, else always
  $autoremove                   = false,                                         # Automatically remove unused dependencies
  $auto_reboot                  = false,                                         # Automatically reboot if needed
  $template_unattended_upgrades = 'unattended_upgrades/unattended-upgrades.erb', # Path to config template
  $template_auto_upgrades       = 'unattended_upgrades/auto-upgrades.erb',       # Path to apt config template
) {

  $conf_path = '/etc/apt/apt.conf.d/50unattended-upgrades'
  $apt_path = '/etc/apt/apt.conf.d/20auto-upgrades'
  $package = 'unattended-upgrades'

  if $::operatingsystem !~ /^(Debian|Ubuntu)$/ {
    fail("${::operatingsystem} is not supported.")
  }

  package { $package:
    ensure => latest,
  }

  file { $conf_path:
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template($template_unattended_upgrades),
  }

  file { $apt_path:
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template($template_auto_upgrades)
  }

  service { $package:
    ensure    => running,
    subscribe => [ File[$conf_path], File[$apt_path], Package[$package], ],
  }
}
