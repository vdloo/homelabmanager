; Install shellserver packages
(let ((detected-os (detect-os))
      (shellserver-packages (list
			      "curl"
			      "git"
			      "jq"
			      "nmap"
			      "racket"
			      "screen"
			      "screenfetch"
			      "wget"
			      )))
  (check-packages-installed
    (if (equal? detected-os "arch")
      ; Archlinux packages
      (append shellserver-packages
	      (list
	        "python-mysqlclient"
	        "python-pip"
	        "python-sqlparse"
	        "python-virtualenv"
	      ))
      ; Debian packages
      (append shellserver-packages
	      (list
	        "python3-mysqldb"
	        "python3-pip"
	        "python3-sqlparse"
	        "python3-venv"
	      )))))
