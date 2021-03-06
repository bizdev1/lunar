# audit_telnet_client
#
# Refer to Section(s) 2.1.2 Page(s) 49  CIS CentOS Linux 6 Benchmark v1.0.0
# Refer to Section(s) 2.1.2 Page(s) 56  CIS RHEL 5 Benchmark v2.1.0
# Refer to Section(s) 2.1.2 Page(s) 51  CIS RHEL 6 Benchmark v1.2.0
# Refer to Section(s) 2.3.4 Page(s) 127 CIS RHEL 7 Benchmark v2.1.0
# Refer to Section(s) 2.3.4 Page(s) 114 CIS Amazon Linux Benchmark v2.0.0
#.

audit_telnet_client () {
  if [ "$os_name" = "Linux" ]; then
    if [ "$os_vendor" = "CentOS" ] || [ "$os_vendor" = "Red" ] || [ "$os_vendor" = "Amazon" ]; then
      funct_verbose_message "Telnet Client"
      funct_linux_package uninstall telnet
    fi
  fi
}
