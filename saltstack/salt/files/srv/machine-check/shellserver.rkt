; Install shellserver packages
(let ((detected-os (detect-os))
      (shellserver-packages (list
			      "autoconf"
			      "automake"
			      "curl"
			      "fakeroot"
			      "gcc"
			      "git"
			      "gzip"
			      "jq"
			      "m4"
			      "make"
			      "nmap"
			      "racket"
			      "screen"
			      "screenfetch"
			      "sudo"
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
	        "vim"
	      ))
      ; Debian packages
      (append shellserver-packages
	      (list
	        "python3-mysqldb"
	        "python3-pip"
	        "python3-sqlparse"
	        "python3-venv"
	        "vim-nox"
	      )))))
