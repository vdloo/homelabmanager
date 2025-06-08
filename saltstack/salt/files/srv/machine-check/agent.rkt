#lang racket

(require "../machine-check/check-helpers.rkt")
(require detect-os-release)
(provide perform-agent-checks)

(define applied-states (file->lines "/srv/applied_states"))

(define perform-agent-checks
  (if (member "agent" applied-states)
    (λ ()
      (check-packages-installed
        (list
          "lighttpd"
          ))
      (check-file-contains
        "/etc/aider/venv/bin/activate"
        "source"))
    void))
