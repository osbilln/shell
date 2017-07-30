curl -v -H "X-Auth-User: adamcpf" \
        -H "X-Auth-Key: 3103ce9baa46a2a9cdc844ed3422826f " \
        https://auth.api.rackspacecloud.com/v1.0 2>&1 | grep Storage | awk -F'<' '{print $2}' | grep Token | awk '{print $2}' | tr -d '\r'
