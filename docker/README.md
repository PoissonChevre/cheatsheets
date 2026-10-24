# Docker — Cheat Sheets

| File | Content |
|---|---|
| [docker-cheatsheet.md](./docker-cheatsheet.md) | Images, containers, volumes, Compose, resource limits, cleanup |
| [docker-networking.md](./docker-networking.md) | Network drivers: bridge, host, macvlan, ipvlan, overlay, none |

## Templates

Starting files for a small web app with a database. Copy them into your project and change the values.

| File | Use |
|---|---|
| [Dockerfile](./templates/Dockerfile) | Image for a Python web app, non-root user |
| [.dockerignore](./templates/.dockerignore) | Files to keep out of the image (`.git`, `.env`...) |
| [compose.yaml](./templates/compose.yaml) | Web app + PostgreSQL, healthcheck, named volume |
| [.env.example](./templates/.env.example) | Variables for Compose: copy to `.env` |

```bash
cp templates/.env.example .env      # Then change the passwords
docker compose up -d
docker compose logs -f
```

Related: [Kubernetes](../k8s/README.md) · [YAML](../yaml/yaml-cheatsheet.md)
