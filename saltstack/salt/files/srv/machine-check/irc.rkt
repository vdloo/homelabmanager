#lang racket

(require "../machine-check/check-helpers.rkt")
(require detect-os-release)
(provide perform-irc-checks)

(define applied-states (file->lines "/srv/applied_states"))

(define perform-irc-checks
  (if (member "irc" applied-states)
    (λ ()
      ; Install irc packages
      (check-packages-installed
        (list
          "inspircd")))
    void))
