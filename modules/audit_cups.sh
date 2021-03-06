# audit_cups
#
# Refer to Section(s) 3.4   Page(s) 61   CIS CentOS Linux 6 Benchmark v1.0.0
# Refer to Section(s) 3.4   Page(s) 73-4 CIS RHEL 5 Benchmark v2.1.0
# Refer to Section(s) 3.4   Page(s) 64   CIS RHEL 6 Benchmark v1.2.0
# Refer to Section(s) 2.2.4 Page(s) 104  CIS RHEL 7 Benchmark v2.1.0
# Refer to Section(s) 6.3   Page(s) 53-4 CIS SLES 11 Benchmark v1.0.0
# Refer to Section(s) 2.2.4 Page(s) 96   CIS Amazon Linux Benchmark v2.0.0
#.

audit_cups () {
  if [ "$os_name" = "Linux" ]; then
    funct_rpm_check cups
    if [ "$rpm_check" = "cups" ]; then
      funct_verbose_message "Printing Services"
      service_name="cups"
      funct_chkconfig_service $service_name 3 off
      funct_chkconfig_service $service_name 5 off
      service_name="cups-lpd"
      funct_chkconfig_service $service_name 3 off
      funct_chkconfig_service $service_name 5 off
      service_name="cupsrenice"
      funct_chkconfig_service $service_name 3 off
      funct_chkconfig_service $service_name 5 off
      funct_check_perms /etc/init.d/cups 0744 root root
      funct_check_perms /etc/cups/cupsd.conf 0600 lp sys
      funct_check_perms /etc/cups/client.conf 0644 root lp
      funct_file_value /etc/cups/cupsd.conf User space lp hash
      funct_file_value /etc/cups/cupsd.conf Group space sys hash
      funct_systemctl_service disable cups
    fi
  fi
}
