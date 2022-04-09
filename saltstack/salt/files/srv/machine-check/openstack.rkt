#lang racket

(require "../machine-check/check-helpers.rkt")
(require detect-os-release)
(provide perform-openstack-checks)

(define applied-states (file->lines "/srv/applied_states"))

(define perform-openstack-checks
  (if (member "openstack" applied-states)
    (λ ()
      ; Install openstack packages
      (check-packages-installed
        (list
          "bridge-utils")))
    void))
