; Install shellserver packages
(let ((detected-os (detect-os))
      (shellserver-packages (list
			      "autoconf"
			      "automake"
			      "curl"
			      "fakeroot"
			      "figlet"
			      "gcc"
			      "git"
			      "gzip"
			      "jq"
			      "m4"
			      "make"
			      "neofetch"
			      "nmap"
			      "racket"
			      "screen"
			      "sudo"
			      "wget"
			      )))
  (check-packages-installed
    (if (equal? detected-os "arch")
      ; Archlinux packages
      (append shellserver-packages
	      (list
	        "cronie"
	        "python-mysqlclient"
	        "python-pip"
	        "python-sqlparse"
	        "python-virtualenv"
	        "vim"
	      ))
      ; Debian packages
      (append shellserver-packages
	      (list
	        "cron"
	        "python3-mysqldb"
	        "python3-pip"
	        "python3-sqlparse"
	        "python3-venv"
	        "vim-nox"
	      )))))
