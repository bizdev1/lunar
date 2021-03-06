# audit_aws_elb
#
# Refer to http://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html
# Refer to https://www.cloudconformity.com/conformity-rules/ELB/elb-access-log.html
# Refer to https://www.cloudconformity.com/conformity-rules/ELB/elb-insecure-ssl-ciphers.html
# Refer to https://www.cloudconformity.com/conformity-rules/ELB/elb-insecure-ssl-protocols.html
# Refer to https://www.cloudconformity.com/conformity-rules/ELB/elb-listener-security.html
# Refer to https://www.cloudconformity.com/conformity-rules/ELB/elb-security-group.html
#.

audit_aws_elb () {
  # Ensure ELBs have logging enabled
	elbs=`aws elb describe-load-balancers --region $aws_region --query "LoadBalancerDescriptions[].LoadBalancerName" --output text`
  for elb in $elbs; do
    total=`expr $total + 1`
    check=`aws elb describe-load-balancers --region $aws_region --load-balancer-name $elb  --query "LoadBalancerDescriptions[].AccessLog" |grep true`
    if [ ! "$check" ]; then
      insecure=`expr $insecure + 1`
      echo "Warning:   ELB $elb does not have access logging enabled [$insecure Warnings]"
      funct_verbose_message "" fix
      funct_verbose_message "aws elb modify-load-balancer-attributes --region $aws_region --load-balancer-name $elb --load-balancer-attributes \"{\\\"AccessLog\\\":{\\\"Enabled\\\":true,\\\"EmitInterval\\\":60,\\\"S3BucketName\\\":\\\"elb-logging-bucket\\\"}}\"" fix
      funct_verbose_message "" fix
    else
      secure=`expr $secure + 1`
      echo "Secure:    ELB $elb has access logging enabled [$secure Passes]"
    fi
    # Ensure ELBs are not using HTTP
    total=`expr $total + 1`
    protocol=`aws elb describe-load-balancers --region $aws_region --load-balancer-name $elb  --query "LoadBalancerDescriptions[].ListenerDescriptions[].Listener.Protcol" --output text`
    if [ "$protocol" = "HTTP" ]; then
      insecure=`expr $insecure + 1`
      echo "Warning:   ELB $elb is using HTTP [$insecure Warnings]"
    else
      secure=`expr $secure + 1`
      echo "Secure:    ELB $elb is not using HTTP [$secure Passes]"
    fi
    # Ensure ELB SGs do not have port 80 open to the world
    sgs=`aws elb describe-load-balancers --region $aws_region --load-balancer-name $elb  --query "LoadBalancerDescriptions[].SecurityGroups" --output text`
    for sg in $sgs; do
      funct_aws_open_port_check $sg 80 tcp HTTP ELB $elb
    done
    # Ensure no deprecated ciphers of protocols are being used
    policies=`aws elb describe-load-balancer-policies --region $aws_region --load-balancer-name $elb  --query "PolicyDescriptions[].PolicyName" --output text`
    for policy in $policies; do
      for cipher in SSLv2 RC2-CBC-MD5 PSK-AES256-CBC-SHA PSK-3DES-EDE-CBC-SHA KRB5-DES-CBC3-SHA KRB5-DES-CBC3-MD5 \
                    PSK-AES128-CBC-SHA PSK-RC4-SHA KRB5-RC4-SHA KRB5-RC4-MD5 KRB5-DES-CBC-SHA KRB5-DES-CBC-MD5 \
                    EXP-EDH-RSA-DES-CBC-SHA EXP-EDH-DSS-DES-CBC-SHA EXP-ADH-DES-CBC-SHA EXP-DES-CBC-SHA \
                    SSLv3 EXP-RC2-CBC-MD5 EXP-KRB5-RC2-CBC-SHA EXP-KRB5-DES-CBC-SHA EXP-KRB5-RC2-CBC-MD5 \
                    EXP-KRB5-DES-CBC-MD5 EXP-ADH-RC4-MD5 EXP-RC4-MD5 EXP-KRB5-RC4-SHA EXP-KRB5-RC4-MD5; do
        total=`expr $total + 1`
        check=`aws elb describe-load-balancer-policies --region $aws_region --load-balancer-name $elb |grep $cipher |grep true`
        if [ "$check" ]; then
          insecure=`expr $insecure + 1`
          echo "Warning:   ELB $elb is using deprecated cipher $cipher [$insecure Warnings]"
        else
          secure=`expr $secure + 1`
          echo "Secure:    ELB $elb is not using deprecated cipher $cipher [$secure Passes]"
        fi
      done
    done
  done
}
