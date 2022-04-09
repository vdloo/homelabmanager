#lang racket

(require "../machine-check/check-helpers.rkt")
(require detect-os-release)
(provide perform-rancher-checks)

(define applied-states (file->lines "/srv/applied_states"))

(define perform-rancher-checks
  (if (member "rancher" applied-states)
    (λ ()
      ; Install rancher packages
      (check-packages-installed
        (list
          "docker-ce")))
    void))
