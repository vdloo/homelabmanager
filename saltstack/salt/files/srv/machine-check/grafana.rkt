#lang racket

(require "../machine-check/check-helpers.rkt")
(require detect-os-release)
(provide perform-grafana-checks)

(define applied-states (file->lines "/srv/applied_states"))

(define perform-grafana-checks
  (if (member "grafana" applied-states)
    (λ ()
      ; Install grafana packages
      (check-packages-installed
        (list "grafana"))
      (check-file-contains
        "/etc/apt/sources.list.d/grafana.list"
        "deb https://packages.grafana.com/oss/deb stable main")
      (check-file-contains
        "/etc/grafana/grafana.ini"
        "org_role = Admin")
      (check-file-contains
        "/etc/grafana/grafana.ini"
        "http_port = 80"))
    void))
