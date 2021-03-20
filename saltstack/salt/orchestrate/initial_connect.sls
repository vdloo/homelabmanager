notify_initial_connect:
  salt.runner:
    - name: salt.cmd
    - arg:
      - fun=cmd.run
      # TODO: re-add something that notifies on connect here
      - cmd="echo 1"

highstate_run:
    local.state.apply:
        - tgt: {{ data['id'] }}
