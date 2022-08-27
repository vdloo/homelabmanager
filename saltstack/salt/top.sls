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
  'role:grafana':
    - match: grain
    - grafana
  'role:booksbooksbooks':
    - match: grain
    - booksbooksbooks
  'role:debianrepo':
    - match: grain
    - debianrepo
  'role:irc':
    - match: grain
    - irc
  'role:vmsaltmaster':
    - match: grain
    - vmsaltmaster
  'role:openstack':
    - match: grain
    - openstack
  'role:rancher':
    - match: grain
    - rancher
  'role:kubernetes':
    - match: grain
    - kubernetes
