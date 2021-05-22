base:
  '*':
    - core
  'role:shellserver':
    - match: grain
    - shellserver
  'role:desktop':
    - match: grain
    - desktop
  'role:jenkins':
    - match: grain
    - jenkins
