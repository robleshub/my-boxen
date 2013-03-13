class people::robleshub{
  #applications
  include sublime_text_2
  include macvim
  include iterm2::stable
  include adium
  include wget

  $env = {
    apps_dir => '/Applications',
    directories => {
      home      => '/Users/drobles',
      dotfiles  => '/Users/drobles/Dev/.dotfiles'
    },
    dotfiles => [
      'gitconfig',
      'janus/solarized',
      'janus/jellybeans',
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
  boxen::osx_defaults{ 'Display full POSIX path as Finder Window':
    key    => '_FXShowPosixPathInTitle',
    domain => 'com.apple.finder',
    value  => 'true',
  }
  boxen::osx_defaults { 'Do not create .DS_Store':
    key    => 'DSDontWriteNetworkStores',
    domain => 'com.apple.dashboard',
    value  => 'true',
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
  
  # Dotfile Setup
  repository { 'robleshub-dotfiles':
    source => 'robleshub/dotfiles',
    path   => "${env['directories']['dotfiles']}",
  }

  #This should be a shell script
  -> people::robleshub::dotfile::link { $env['dotfiles']:
    source_dir => $env['directories']['dotfiles'],
    dest_dir   => $env['directories']['home'],
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
  
  define dotfile::link($source_dir, $dest_dir){
    file { "${dest_dir}/.${name}":
      ensure => symlink,
      target => "${source_dir}/${name}",
    }
  }
}
