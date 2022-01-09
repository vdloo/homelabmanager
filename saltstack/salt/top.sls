base:
  '*':
    - core
  'role:shellserver':
    - match: grain
    - shellserver
  'role:devenv':
    - match: grain
    - devenv
  'role:desktop':
    - match: grain
    - desktop
  'role:jenkinsci':
    - match: grain
    - jenkinsci
  'role:jenkinsagent':
    - match: grain
    - jenkinsagent
  'role:powerdns':
    - match: grain
    - powerdns
  'role:prometheus':
    - match: grain
    - prometheus
