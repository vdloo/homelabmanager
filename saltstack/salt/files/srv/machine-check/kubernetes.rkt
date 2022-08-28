#lang racket

(require "../machine-check/check-helpers.rkt")
(require detect-os-release)
(provide perform-kubernetes-checks)

(define applied-states (file->lines "/srv/applied_states"))

(define perform-kubernetes-checks
  (if (member "kubernetes" applied-states)
    (λ ()
      ; Install kubernetes packages
      (check-packages-installed
        (list
          "sudo"
          "docker-ce")))
    void))
