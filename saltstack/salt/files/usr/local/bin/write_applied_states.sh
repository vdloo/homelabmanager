#!/usr/bin/bash
set -e

salt-call state.show_states concurrent=true --out json | jq -r '.local | .[]' > /srv/applied_states
