#lang racket

(require "../machine-check/check-helpers.rkt")
(require detect-os-release)
(provide perform-powerdns-checks)

(define applied-states (file->lines "/srv/applied_states"))

(define perform-powerdns-checks
  (if (member "powerdns" applied-states)
    (λ ()
      ; Install powerdns packages
      (check-packages-installed
        (list
          "pdns-server")))
    void))
