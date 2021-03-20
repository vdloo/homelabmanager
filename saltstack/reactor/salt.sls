orchestrate_initial_connect:
  runner.state.orchestrate:
      - args:
          - mods: orchestrate.initial_connect
          - pillar:
              minion: {{ data['id'] }}

highstate_run:
    local.state.apply:
        - tgt: {{ data['id'] }}
