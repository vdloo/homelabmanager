; Install core packages
(let ((detected-os (detect-os))
      (shellserver-packages (list
			      "htop"
			      "iftop"
			      "sysstat"
			      )))
  (check-packages-installed
    (if (equal? detected-os "arch")
      ; Archlinux packages
      (append shellserver-packages
	      (list
		"bind"
		"iptables"
	        "gnupg"
	      ))
      ; Debian packages
      (append shellserver-packages
	      (list
		"dnsutils"
		"iptables-persistent"
	        "gnupg2"
	      )))))
(check-file-mode "/root/.ssh/id_rsa" 384)
(check-file-mode "/root/.ssh/authorized_keys" 384)
