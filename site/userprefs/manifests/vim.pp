class userprefs::vim (
  $user        = 'root',
  $group       = 'root',
  $homedir     = '/root',
  $default     = true,
  $monochrome  = undef,
  $line_number = true,
) {

  if $monochrome == true {
    $syntax   = 'off'
    $hlsearch = 'nohlsearch'
    $t_Co     = 't_Co=0'
  }
  else {
    $syntax   = 'on'
    $hlsearch = 'hlsearch'
    $t_Co     = 't_Co=256'
  }

  if $line_number == true {
    $line_num = 'number'
  }
  else {
    $line_num = 'nonumber'
  }

  File {
    owner => $user,
    group => $group,
    mode  => '0644',
  }

  package { 'vim-enhanced':
    ensure => present,
  }

  file { "${homedir}/.vim":
    ensure  => 'directory',
    source  => 'puppet:///modules/userprefs/vim/vim',
    recurse => true,
  }

  file { "${homedir}/.vimrc":
    content => template('userprefs/vimrc.erb'),
  }

  if $default {
    file_line { 'default editor':
      path    => "${homedir}/.profile",
      line    => 'export EDITOR=vim',
      match   => "EDITOR=",
      require => Package['vim-enhanced'],
    }
  }
}
