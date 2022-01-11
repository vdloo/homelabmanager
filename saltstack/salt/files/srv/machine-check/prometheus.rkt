#lang racket

(require "../machine-check/check-helpers.rkt")
(require detect-os-release)
(provide perform-prometheus-checks)

(define applied-states (file->lines "/srv/applied_states"))

(define perform-prometheus-checks
  (if (member "prometheus" applied-states)
    (λ ()
      ; Install prometheus packages
      (let ((detected-os (detect-os)))
        (check-packages-installed
          (list "prometheus"))
        (if (equal? detected-os "arch")
          (check-file-contains "/etc/conf.d/prometheus"
            "--web.listen-address='0.0.0.0:80'")
          (check-file-contains "/etc/default/prometheus"
            "--web.listen-address='0.0.0.0:80'"))
        (if (equal? detected-os "arch")
          (check-file-mode "/etc/conf.d/prometheus" 420)
          (check-file-mode "/etc/default/prometheus" 420))
        (check-file-mode "/usr/local/bin/update_prometheus_config.sh" 493)
        (check-file-contains
          "/usr/local/bin/update_prometheus_config.sh"
          "nmap --open -sS -p 19100 192.168.1.0/24 -oG -")))
    void))
