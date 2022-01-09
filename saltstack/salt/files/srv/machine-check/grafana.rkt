; Install grafana packages
(check-packages-installed
  (list "grafana"))
(check-file-contains
  "/etc/apt/sources.list.d/grafana.list"
  "deb https://packages.grafana.com/oss/deb stable main")
(check-file-contains
  "/etc/grafana/grafana.ini"
  "org_role = Admin")
(check-file-contains
  "/etc/grafana/grafana.ini"
  "http_port = 80")
