node 'default' {
  #include ::desktop_packages
  include role::desktop1
  notify {"Running in the 299 ":}
}
