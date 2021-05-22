base:
  '*':
    - core
  'role:shellserver':
    - match: grain
    - shellserver
  'role:desktop':
    - match: grain
    - desktop
