#lang racket

(require "../machine-check/check-helpers.rkt")
(require detect-os-release)
(provide perform-desktop-checks)

(define applied-states (file->lines "/srv/applied_states"))

(define perform-desktop-checks
  (if (member "desktop" applied-states)
    (λ ()
      ; Install desktop packages
      (let ((detected-os (detect-os))
            (shellserver-packages (list
      			      "chromium"
      			      "cmatrix"
      			      "feh"
      			      "terminator"
      			      )))
        (check-packages-installed
          (if (equal? detected-os "arch")
            ; Archlinux packages
            (append shellserver-packages
      	      (list
      	        "dmenu"
      	        "libx11"
      	        "libxft"
      	        "libxinerama"
      	        "ttf-dejavu"
      	        "xorg-server"
      	        "xorg-xinit"
      	        "xorg-xrandr"
      	        "xorg-xsetroot"
      	      ))
            ; Debian packages
            (append shellserver-packages
      	      (list
      	        "libx11-6:amd64"
      	        "libxft-dev:amd64"
      	        "libxinerama-dev:amd64"
      	        "suckless-tools"
      	        "x11-xserver-utils"
      	        "xinit"
      	        "xorg"
      	      ))))))
    void))
