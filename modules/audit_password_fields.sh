# audit_password_fields
#
# Ensure Password Fields are Not Empty
# Verify System Account Default Passwords
# Ensure Password Fields are Not Empty
#
# An account with an empty password field means that anybody may log in as
# that user without providing a password at all (assuming that PASSREQ=NO
# in /etc/default/login). All accounts must have passwords or be locked.
#.

audit_password_fields () {
  if [ "$os_name" = "SunOS" ] || [ "$os_name" = "Linux" ]; then
    funct_verbose_message "Password Fields"
    check_file="/etc/shadow"
    empty_count=0
    if [ "$audit_mode" != 2 ]; then
      echo "Checking:  Password fields"
      total=`expr $total + 1`
      for user_name in `cat /etc/shadow |awk -F":" '{print $1":"$2":"}' |grep "::$" |cut -f1 -d":"`; do
        empty_count=1
        if [ "$audit_mode" = 1 ]; then
          score=`expr $score - 1`
          echo "Warning:   No password field for $user_name in $check_file [$score]"
          funct_verbose_message "" fix
          funct_verbose_message "passwd -d $user_name" fix
          if [ "$os_name" = "SunOS" ]; then
            funct_verbose_message "passwd -N $user_name" fix
          fi
          funct_verbose_message "" fix
        fi
        if [ "$audit_mode" = 0 ]; then
          funct_backup_file $check_file
          echo "Setting:   No password for $user_name"
          passwd -d $user_name
          if [ "$os_name" = "SunOS" ]; then
            passwd -N $user_name
          fi
        fi
      done
      if [ "$empty_count" = 0 ]; then
        score=`expr $score + 1`
        echo "Secure:    No empty password entries"
      fi
    else
      funct_restore_file $check_file $restore_dir
    fi
  fi
}