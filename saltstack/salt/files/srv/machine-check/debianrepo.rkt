#lang racket

(require "../machine-check/check-helpers.rkt")
(require detect-os-release)
(provide perform-debianrepo-checks)

(define applied-states (file->lines "/srv/applied_states"))

(define perform-debianrepo-checks
  (if (member "debianrepo" applied-states)
    (λ ()
      ; Install debianrepo packages
      (check-packages-installed
        (list "reprepro")))
    void))
