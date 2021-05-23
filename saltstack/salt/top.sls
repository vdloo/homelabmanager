base:
  '*':
    - core
  'role:shellserver':
    - match: grain
    - shellserver
  'role:desktop':
    - match: grain
    - desktop
  'role:jenkinsci':
    - match: grain
    - jenkinsci
  'role:jenkinsagent':
    - match: grain
    - jenkinsagent
