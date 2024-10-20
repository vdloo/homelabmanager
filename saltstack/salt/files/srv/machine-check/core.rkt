; Install core packages
#lang racket

(require "../machine-check/check-helpers.rkt")
(require detect-os-release)
(provide perform-core-checks)

(define applied-states (file->lines "/srv/applied_states"))

(define perform-core-checks
  (if (member "core" applied-states)
    (λ ()
      ; Install core packages
      (let ((detected-os (detect-os))
            (shellserver-packages
              (list
                "htop"
                "iftop"
                "sysstat"
                )))
        (check-packages-installed
          (if (equal? detected-os "arch")
            ; Archlinux packages
            (append shellserver-packages
              (list
      	        "cronie"
                "bind"
                "gnupg"
                "inetutils"
                "iptables"
                "net-tools"
      	      ))
            ; Debian packages
            (append shellserver-packages
              (list
      	        "cron"
                "dnsutils"
                "gnupg2"
                "iptables-persistent"
      	      )))))
      (check-file-mode "/root/.ssh/id_ed25519" 384)
      (check-file-mode "/root/.ssh/authorized_keys" 384))
    void))
