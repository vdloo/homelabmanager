; Tests for the homelabmanager configuration management
; Directory structure should correspond with the saltstack
; state file directories.

(define applied-states (file->lines "/srv/applied_states"))

(define-syntax-rule (include-if-needed state path)
  (if (member state applied-states)
    (include path)
    '()))

(include-if-needed "core" "core.rkt")
(include-if-needed "desktop" "desktop.rkt")
(include-if-needed "devenv" "devenv.rkt")
(include-if-needed "prometheus" "prometheus.rkt")
(include-if-needed "shellserver" "shellserver.rkt")
(include-if-needed "grafana" "grafana.rkt")
(include-if-needed "booksbooksbooks" "booksbooksbooks.rkt")
