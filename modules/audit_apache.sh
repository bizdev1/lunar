# audit_apache
#
# Refer to Section(s) 3.11,14   Page(s) 66-9    CIS CentOS Linux 6 Benchmark v1.0.0
# Refer to Section(s) 2.2.10    Page(s) 110     CIS Ubuntu Linux 16.04 Benchmark v1.0.0
# Refer to Section(s) 3.11,14   Page(s) 79-81   CIS RHEL 5 Benchmark v2.1.0
# Refer to Section(s) 3.11,14   Page(s) 69-71   CIS RHEL 6 Benchmark v1.2.0
# Refer to Section(s) 2.2.10,13 Page(s) 110,113 CIS RHEL 7 Benchmark v2.1.0
# Refer to Section(s) 6.10,13   Page(s) 59,61   CIS SLES 11 Benchmark v1.0.0
# Refer to Section(s) 2.4.14.7  Page(s) 56-7    CIS OS X 10.5 Benchmark v1.1.0
# Refer to Section(s) 2.10      Page(s) 21-2    CIS Solaris 11.1 v1.0.0
# Refer to Section(s) 2.2.11    Page(s) 30-2    CIS Solaris 10 v5.1.0
# Refer to Section(s) 2.2.10,13 Page(s) 102,105 CIS Amazon Linux Benchmark v2.0.0
#.

audit_apache () {
  if [ "$os_name" = "SunOS" ] || [ "$os_name" = "Linux" ] || [ "$os_name" = "Darwin" ]; then
    funct_verbose_message "Apache and web based services"
    if [ "$os_name" = "SunOS" ]; then
      if [ "$os_version" = "10" ] || [ "$os_version" = "11" ]; then
        funct_verbose_message "Apache"
      fi
      if [ "$os_version" = "10" ]; then
        service_name="svc:/network/http:apache2"
        funct_service $service_name disabled
      fi
      if [ "$os_version" = "11" ]; then
        service_name="svc:/network/http:apache22"
        funct_service $service_name disabled
      fi
      if [ "$os_version" = "10" ]; then
        service_name="apache"
        funct_service $service_name disabled
      fi
    fi
    if [ "$os_name" = "Linux" ]; then
      for service_name in httpd apache apache2 tomcat5 squid prixovy; do
        funct_systemctl_service disable $service_name
        funct_chkconfig_service $service_name 3 off
        funct_chkconfig_service $service_name 5 off
      done
      if [ "$os_vendor" = "CentOS" ] || [ "$os_vendor" = "Red" ] || [ "$os_vendor" = "Amazon" ]; then
        funct_linux_package uninstall httpd
        funct_linux_package uninstall squid
      fi
    fi
    for check_dir in /etc /etc/sfw /etc/apache /etc/apache2 /usr/local/etc /usr/sfw/etc /opt/sfw/etc; do
      check_file="$check_dir/httpd.conf"
      if [ -f "$check_file" ]; then
        funct_file_value $check_file ServerTokens space Prod hash
        funct_file_value $check_file ServerSignature space Off hash
        funct_file_value $check_file UserDir space Off hash
        funct_file_value $check_file TraceEnable space Off hash
      fi
    done
  fi
}
