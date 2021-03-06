# audit_console_login
#
# Refer to Section(s) 6.4   Page(s) 142-3 CIS CentOS Linux 6 Benchmark v1.0.0
# Refer to Section(s) 6.4   Page(s) 165   CIS RHEL 5 Benchmark v2.1.0
# Refer to Section(s) 6.4   Page(s) 145   CIS RHEL 6 Benchmark v1.2.0
# Refer to Section(s) 5.5   Page(s) 256   CIS RHEL 7 Benchmark v2.1.0
# Refer to Section(s) 9.3.4 Page(s) 134-5 CIS SLES 11 Benchmark v1.0.0
# Refer to Section(s) 6.14  Page(s) 57    CIS Solaris 11.1 Benchmark v1.0.0
# Refer to Section(s) 6.10  Page(s) 95-6  CIS Solaris 10 Benchamrk v5.1.0
#.

audit_console_login () {
  if [ "$os_name" = "SunOS" ]; then
    funct_verbose_message "Root Login to System Console"
    if [ "$os_version" = "10" ]; then
      check_file="/etc/default/login"
      funct_file_value $check_file CONSOLE eq /dev/console hash
    fi
    if [ "$os_version" = "11" ]; then
      service_name="svc:/system/console-login:terma"
      funct_service $service_name disabled
      service_name="svc:/system/console-login:termb"
      funct_service $service_name disabled
    fi
  fi
  if [ "$os_name" = "Linux" ]; then
    funct_verbose_message "Root Login to System Console"
    disable_ttys=0
    check_file="/etc/securetty"
    console_list=""
    if [ "$audit_mode" != 2 ]; then
      echo "Checking:  Remote consoles"
      for console_device in `cat $check_file |grep '^tty[0-9]'`; do
        disable_ttys=1
        console_list="$console_list $console_device"
      done
      if [ "$disable_ttys" = 1 ]; then
        if [ "$audit_mode" = 1 ]; then
          total=`expr $total + 1`
          insecure=`expr $insecure + 1`
          echo "Warning:   Consoles enabled on$console_list [$insecure Warnings]"
          funct_verbose_message "" fix
          funct_verbose_message "cat $check_file |sed 's/tty[0-9].*//g' |grep '[a-z]' > $temp_file" fix
          funct_verbose_message "cat $temp_file > $check_file" fix
          funct_verbose_message "rm $temp_file" fix
          funct_verbose_message "" fix
        fi
        if [ "$audit_mode" = 0 ]; then
          funct_backup_file $check_file
          echo "Setting:   Consoles to disabled on$console_list"
          cat $check_file |sed 's/tty[0-9].*//g' |grep '[a-z]' > $temp_file
          cat $temp_file > $check_file
          rm $temp_file
        fi
      else
        if [ "$audit_mode" = 1 ]; then
          total=`expr $total + 1`
          secure=`expr $secure + 1`
          echo "Secure:    No consoles enabled on tty[0-9]* [$secure Passes]"
        fi
      fi
    else
      funct_restore_file $check_file $restore_dir
    fi
  fi
}
