class people::dorkscript{
  #applications
  include virtualbox
  include vagrant
  include vlc
  include sublime_text_2
  include macvim
  include iterm2::stable
  include gcc
  include colloquy
  #include python
  include chrome
  #include firefox
  include dropbox
  include java
  include alfred
  include adium
  include additemtodock
  include xquartz
  include lastpass
  include diffmerge
  include wget

  class { 'intellij':
    edition => 'community'
  }

  #projects

  #Sane Defaults
  Boxen::Osx_defaults {
    user => $::luser,
  }
  
  $env = {
    apps_dir => '/Applications',
    directories => {
      home      => '/Users/agreen',
      dotfiles  => '/Users/agreen/.dotfiles'
    },
    docked => [
      'Google\ Chrome.app',
      'iTerm.app',
      'Sublime\ Text\ 2.app',
      'Colloquy.app',
      'Firefox.app',
      'Adium.app',
    ],
    dotfiles => [
      'gitconfig',
      #'janus/solarized',
      #'janus/jellybeans',
      'vimrc.after',
    ],
    packages => {
      brew   => [
        'tmux'
      ]
    }
  }

  # Install Brew Applications
  package { $env['packages']['brew']:
    provider => 'homebrew',
  }

  # OSX Defaults
  boxen::osx_defaults { 'Disable Dashboard':
    key    => 'mcx-disabled',
    domain => 'com.apple.dashboard',
    value  => 'YES',
  }
  boxen::osx_defaults { 'Disable reopen windows when logging back in':
    key    => 'TALLogoutSavesState',
    domain => 'com.apple.loginwindow',
    value  => 'false',
  }
  boxen::osx_defaults{ 'Display full POSIX path as Finder Window':
    key    => '_FXShowPosixPathInTitle',
    domain => 'com.apple.finder',
    value  => 'true',
  }
  boxen::osx_defaults { 'Secure Empty Trash':
    key    => 'EmptyTrashSecurely',
    domain => 'com.apple.finder',
    value  => 'true',
  }
  boxen::osx_defaults { 'Do not create .DS_Store':
    key    => 'DSDontWriteNetworkStores',
    domain => 'com.apple.dashboard',
    value  => 'true',
  }

  boxen::osx_defaults { "Disable 'natural scrolling'":
    key    => 'com.apple.swipescrolldirection',
    domain => 'NSGlobalDomain',
    value  => 'false',
    type   => 'bool',
  }

  boxen::osx_defaults { 'Disable the "Are you sure you want to open this application?" dialog':
    key    => 'LSQuarantine',
    domain => 'com.apple.LaunchServices',
    value  => 'true',
  }
  boxen::osx_defaults { 'sane key repeat':
    key    => 'KeyRepeat',
    domain => 'NSGlobalDomain',
    value  => '0',
  }

  boxen::osx_defaults { 'Expand save panel by default':
    key    => 'NSNavPanelExpandedStateForSaveMode',
    domain => 'NSGlobalDomain',
    value  => 'true',
  }
  
  boxen::osx_defaults { 'Expand print panel by default':
    key    => 'PMPrintingExpandedStateForPrint',
    domain => 'NSGlobalDomain',
    value  => 'true',
  }
  
  boxen::osx_defaults { 'Put my Dock on the left':
    key    => 'orientation',
    domain => 'com.apple.dock',
    value  => 'left',
  }
  boxen::osx_defaults { 'Make functional keys do real things, and not apple things':
    key    => 'com.apple.keyboard.fnState',
    domain => 'NSGlobalDomain',
    value  => 'true',
  }

  # Dotfile Setup
  repository { 'dorkscript-dotfiles':
    source => 'DorkScript/dotfiles',
    path   => "${env['directories']['dotfiles']}",
  }

  #This should be a shell script
  -> people::dorkscript::dotfile::link { $env['dotfiles']:
    source_dir => $env['directories']['dotfiles'],
    dest_dir   => $env['directories']['home'],
  }

  #add each application to dock
  ~> people::dorkscript::add_to_dock { $env['docked']:
    app_dir => $env['apps_dir'],
  }

  #Install Janus
  repository { 'janus':
    source => 'carlhuda/janus',
    path   => "${env['directories']['home']}/.vim",
  }
  ~> exec { 'Bootstrap Janus':
    command     => 'rake',
    cwd         => "${env['directories']['home']}/.vim",
    refreshonly => true,
    environment => [
      "HOME=${env['directories']['home']}",
    ],
  }
  
  define add_to_dock($app_dir) {
    exec { "adding ${name} to dock":
      command     => "additemtodock ${app_dir}/${name}",
      refreshonly => true,
    }
  }

  define dotfile::link($source_dir, $dest_dir){
    file { "${dest_dir}/.${name}":
      ensure => symlink,
      target => "${source_dir}/${name}",
    }
  }
}
