; Install prometheus packages
(check-packages-installed
  (list
    "prometheus"))
(check-file-mode "/etc/default/prometheus" 420)
(check-file-contains
  "/etc/default/prometheus"
  "--web.listen-address='0.0.0.0:80'")
