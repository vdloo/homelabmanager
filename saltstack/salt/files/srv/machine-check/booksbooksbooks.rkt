#lang racket

(require "../machine-check/check-helpers.rkt")
(require detect-os-release)
(provide perform-booksbooksbooks-checks)

(define applied-states (file->lines "/srv/applied_states"))

(define perform-booksbooksbooks-checks
  (if (member "booksbooksbooks" applied-states)
    (λ ()
      ; Install booksbooksbooks packages
      (check-packages-installed
        (list
          "libxml2-dev"
          "libffi-dev"
          )))
    void))
