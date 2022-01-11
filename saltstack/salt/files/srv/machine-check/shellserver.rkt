#lang racket

(require "../machine-check/check-helpers.rkt")
(require detect-os-release)
(provide perform-shellserver-checks)

(define applied-states (file->lines "/srv/applied_states"))

(define perform-shellserver-checks
  (if (member "shellserver" applied-states)
    (λ ()
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
      			      "prometheus-node-exporter"
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
      	        "python-wheel"
      	        "vim"
      	      ))
            ; Debian packages
            (append shellserver-packages
      	      (list
      	        "cron"
      	        "crudini"
      	        "python3-mysqldb"
      	        "python3-pip"
      	        "python3-sqlparse"
      	        "python3-venv"
      	        "python3-wheel"
      	        "vim-nox"
      	      )))))
      (check-file-mode "/root/.ssh/config.d" 448)
      (check-file-mode "/home/{{ pillar['shellserver_unprivileged_user_name'] }}/.ssh/config.d" 448))
    void))
