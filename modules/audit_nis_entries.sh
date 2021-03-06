# audit_nis_entries
#
# Refer to Section(s) 9.2.2-4 Page(s) 163-5   CIS CentOS Linux 6 Benchmark v1.0.0
# Refer to Section(s) 9.2.2-4 Page(s) 188-190 CIS RHEL 5 Benchmark v2.1.0
# Refer to Section(s) 9.2.2-4 Page(s) 166-8   CIS RHEL 6 Benchmark v1.2.0
# Refer to Section(s) 13.2-4  Page(s) 154-6   CIS SLES 11 Benchmark v1.0.0
# Refer to Section(s) 9.4     Page(s) 118-9   CIS Solaris 10 Benchmark v1.1.0
#.

audit_nis_entries () {
  if [ "$os_name" = "SunOS" ] || [ "$os_name" = "Linux" ]; then
    funct_verbose_message "NIS Map Entries"
    if [ "$audit_mode" != 2 ]; then
      echo "Checking:  Legacy NIS '+' entries"
    fi
    total=`expr $total + 1`
    for check_file in /etc/passwd /etc/shadow /etc/group; do
      if [ "$audit_mode" != 2 ]; then
        for file_entry in `cat $check_file |grep "^+"`; do
          if [ "$audit_mode" = 1 ]; then
            insecure=`expr $insecure + 1`
            echo "Warning:   NIS entry \"$file_entry\" in $check_file [$insecure Warnings]"
            funct_verbose_message "" fix
            funct_verbose_message 'sed -e "s/^+/#&/" < $check_file > $temp_file' fix
            funct_verbose_message "cat $temp_file > $check_file" fix
            funct_verbose_message "" fix
          fi
          if [ "$audit_mode" = 0 ]; then
            funct_backup_file $check_file
            echo "Setting:   File $check_file to have no NIS entries"
            sed -e "s/^+/#&/" < $check_file > $temp_file
            cat $temp_file > $check_file
            if [ "$os_name" = "SunOS" ]; then
              if [ "$os_version" != "11" ]; then
                pkgchk -f -n -p $check_file 2> /dev/null
              else
                pkg fix `pkg search $check_file |grep pkg |awk '{print $4}'`
              fi
            fi
            rm $temp_file
          fi
        done
        if [ "$file_entry" = "" ]; then
          if [ "$audit_mode" = 1 ]; then
            secure=`expr $secure + 1`
            echo "Secure:    No NIS entries in $check_file [$secure Passes]"
          fi
        fi
      else
        funct_restore_file $check_file $restore_dir
      fi
    done
  fi
}
