# audit_process_accounting
#
# Refer to Section(s) 10.1 Page(s) 137-8 CIS Solaris 10 Benchmark v1.1.0
#.

audit_process_accounting () {
  if [ "$os_name" = "SunOS" ]; then
    funct_verbose_message "Process Accounting"
    check_file="/etc/rc3.d/S99acct"
    init_file="/etc/init.d/acct"
    log_file="$work_dir/acct.log"
    total=`expr $total + 1`
    if [ ! -f "$check_file" ]; then
      if [ "$audit_mode" = 1 ]; then
        insecure=`expr $insecure + 1`
        echo "Warning:   Process accounting not enabled [$insecure Warnings]"
      fi
      if [ "$audit_mode" = 0 ]; then
        echo "Setting:   Process accounting to enabled"
        echo "disabled" > $log_file
        ln -s $init_file $check_file
        echo "Notice:    Starting Process accounting"
        $init_file start 2>&1 > /dev/null
      fi
    else
      if [ "$audit_mode" = 1 ]; then
        secure=`expr $secure + 1`
        echo "Secure:    Process accounting not enabled [$secure Passes]"
      fi
      if [ "$audit_mode" = 2 ]; then
        log_file="$restore_dir/acct.log"
        if [ -f "$log_file" ]; then
          rm $check_file
          echo "Restoring: Process accounting to disabled"
          echo "Notice:    Stoping Process accounting"
          $init_file stop 2>&1 > /dev/null
        fi
      fi
    fi
  fi
}
