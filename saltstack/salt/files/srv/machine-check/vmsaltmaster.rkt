#lang racket

(require "../machine-check/check-helpers.rkt")
(require detect-os-release)
(provide perform-vmsaltmaster-checks)

(define applied-states (file->lines "/srv/applied_states"))

(define perform-vmsaltmaster-checks
  (if (member "vmsaltmaster" applied-states)
    (λ ()
      ; Install vmsaltmaster packages
      (check-packages-installed
        (list
          "salt-master")))
    void))
