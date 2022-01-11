#lang racket

(require "../machine-check/check-helpers.rkt")
(require detect-os-release)
(provide perform-devenv-checks)

(define applied-states (file->lines "/srv/applied_states"))

(define perform-devenv-checks
  (if (member "devenv" applied-states)
    (λ ()
      ; Check devenv configuration files
      (check-file-mode "/usr/local/bin/clone_development_projects.sh" 493)
      (check-file-mode "/home/{{ pillar['shellserver_unprivileged_user_name'] }}/code/projects/homelabmanager" 493)
      (check-file-contains
        "/usr/local/bin/clone_development_projects.sh"
        "vdloo/homelabmanager")
      (check-file-does-not-contain
        "/usr/local/bin/configure_vim.sh"
        "UNPRIVILEGED_USER=root"))
    void))
