# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

class role {

}

#  Default Role for Windows Desktops 
class role::desktop1 inherits role {
  include profile::desktop::essential
  include profile::desktop::security
}

