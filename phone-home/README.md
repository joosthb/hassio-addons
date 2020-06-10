## About

- Digs a reverse SSH tunnel to target and exposes homeassistant-gui on the defined port remotely.
- Synchronizes the local backups to the target.

### Endpoint container
You can use a container as endpoint for the connection and use traefik to manage SSL certificate.

```
phonehomeendpoint:
  image: panubo/sshd
  ports:
    - "22:22"
  restart: always
  labels:
    - "traefik.enable=true"
    - "traefik.http.routers.phonehomeendpoint.entrypoints=websecure"
    - "traefik.http.routers.phonehomeendpoint.tls.certresolver=myresolver"
    - "traefik.http.routers.phonehomeendpoint.rule=Host(`phonehomeendpoint.example.com`)"
    - "traefik.http.services.phonehomeendpoint.loadbalancer.server.port=8123"
  volumes:
    - ./sshkeys:/etc/ssh/keys
    - ./sshkeys/public_key:/root/.ssh/authorized_keys
    - ./habackup:/backup
  environment:
    - SSH_ENABLE_ROOT=true
    - TCP_FORWARDING=true
    - GATEWAY_PORTS=true
```

