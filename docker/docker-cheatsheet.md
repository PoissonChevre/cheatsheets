# Docker — Cheat Sheet

Docker runs applications in **containers**. A container is an isolated environment that contains everything the application needs (code, libraries, settings). It does not depend on what is installed on the host, so it works the same way on every machine: laptop, datacenter or cloud.

**Containers vs VMs:** a VM virtualizes a full operating system. A container shares the kernel of the host, so it starts in seconds and uses much less CPU, RAM and disk.

- Docs: <https://docs.docker.com>
- Install: <https://docs.docker.com/engine/install/> (Docker Engine) or <https://docs.docker.com/desktop/> (Docker Desktop)
- Example projects: <https://github.com/docker/awesome-compose>
- Networking (all network types): [docker-networking.md](./docker-networking.md)

---

## General

```bash
sudo systemctl start docker     # Start the Docker daemon (Linux)
sudo systemctl enable docker    # Start it at boot
sudo usermod -aG docker $USER   # Use docker without sudo (log out and in again)

docker version                  # Client and server versions
docker info                     # System-wide information
docker --help                   # Help (works on every subcommand: docker run --help)
```

---

## Images

An image is a read-only package used to create containers.

```bash
docker build -t myapp:1.0 .                      # Build from the Dockerfile in the current folder
docker build -t myapp:1.0 -f Dockerfile.prod .   # Use another Dockerfile
docker build --build-arg ENV=prod -t myapp:1.0 . # Pass a build argument (ARG in Dockerfile)
docker build --no-cache -t myapp:1.0 .           # Build without cache

docker images                    # List local images (same as: docker image ls)
docker tag myapp:1.0 myapp:latest  # Add another tag to an image
docker inspect myapp:1.0         # Details: layers, env variables, ports
docker history myapp:1.0         # Layers (one per RUN, COPY, ADD)

docker rmi myapp:1.0             # Delete an image
docker rmi -f myapp:1.0          # Force delete
```

### Dockerfile — multi-stage build

Simple template to start from: [templates/Dockerfile](./templates/Dockerfile).

The first stage builds the app, the second keeps only what is needed. The final image is smaller.

```dockerfile
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev

FROM node:22-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
USER node
CMD ["node", "app.js"]
```

Good practices: pin image versions, use small base images (alpine, slim), add a `.dockerignore`, don't run as root.

---

## Registry (Docker Hub, GHCR...)

```bash
docker login                               # Docker Hub
docker login ghcr.io -u <username>         # GitHub Container Registry
docker search nginx                        # Search Docker Hub
docker pull nginx:1.27                     # Download an image (tag "latest" if no tag)
docker tag myapp:1.0 <username>/myapp:1.0  # Name the image for the registry
docker push <username>/myapp:1.0           # Upload the image
```

---

## Containers

A container is a running instance of an image.

### Run

```bash
docker run --name web -d nginx           # Run in background (-d) with a name
docker run -it ubuntu bash               # Interactive shell (-i interactive, -t terminal)
docker run --rm -it ubuntu bash          # Delete the container when you exit
docker run -p 8080:80 nginx              # Publish a port: host:container
docker run -e APP_ENV=prod myapp:1.0     # Set an environment variable
docker run --env-file .env myapp:1.0     # Load variables from a file (KEY=value)
docker run --restart unless-stopped myapp:1.0  # Restart policy: no, always, unless-stopped, on-failure
```

### Manage

```bash
docker ps                  # Running containers
docker ps -a               # All containers (running and stopped)
docker ps -q               # IDs only

docker start web           # Start a stopped container
docker stop web            # Stop (SIGTERM, then SIGKILL after 10 s)
docker kill web            # Stop now (SIGKILL)
docker restart web
docker pause web / docker unpause web

docker rm web              # Delete a stopped container
docker rm -f web           # Stop and delete

docker create --name web nginx   # Create without starting
```

### Inspect and debug

```bash
docker logs web                  # Logs
docker logs -f web               # Follow logs (like tail -f)
docker logs --tail 100 web       # Last 100 lines
docker logs --since 1h -t web    # Last hour, with timestamps

docker exec -it web sh           # Open a shell in a running container
docker exec web curl localhost:80  # Run one command (the tool must exist in the image)
docker inspect web               # Details: mounts, env, network, limits
docker top web                   # Processes in the container
docker diff web                  # Files changed since the image (A added, C changed, D deleted)
docker stats                     # Live CPU, RAM, network usage
docker events                    # Live events (create, start, stop...)

docker cp web:/var/log/app.log ./   # Copy from container to host
docker cp ./config.txt web:/app/    # Copy from host to container

docker run -it --user root myapp:1.0 sh   # Run as root to debug permissions
```

---

## Volumes

Data in a container is lost when the container is deleted. Volumes keep it.

| Type | Example | Use |
|---|---|---|
| Named volume | `-v mydata:/app/data` | Data managed by Docker (databases) |
| Bind mount | `-v $(pwd):/app` | A host folder in the container (development) |

```bash
docker volume create mydata
docker volume ls
docker volume inspect mydata     # Shows the path on the host
docker volume rm mydata

docker run -v mydata:/app/data myapp:1.0     # Named volume
docker run -v $(pwd):/app myapp:1.0          # Bind mount
docker run --mount type=volume,source=mydata,target=/app/data myapp:1.0  # Same, longer syntax
docker run -v mydata:/app/data:ro myapp:1.0  # Read-only
```

NFS volume (with the default `local` driver):

```bash
docker volume create --driver local \
  --opt type=nfs \
  --opt o=addr=10.0.0.1,rw \
  --opt device=:/export/data \
  nfsdata
```

---

## Networks (basics)

```bash
docker network create mynet               # Custom bridge network
docker network ls
docker network inspect mynet
docker run -d --network mynet --name app1 myapp:1.0
docker run -d --network mynet --name app2 myapp:1.0   # app2 can reach app1 by name
docker network connect mynet web          # Add a running container to a network
docker network disconnect mynet web
docker network rm mynet
```

All network types (bridge, host, macvlan, ipvlan, overlay, none): see [docker-networking.md](./docker-networking.md).

---

## Docker Compose

Template (web app + database): [templates/compose.yaml](./templates/compose.yaml).

Describe a multi-container application in one YAML file (`compose.yaml`).

```yaml
services:
  web:
    image: myapp:1.0
    ports:
      - "8080:3000"
    environment:
      - APP_ENV=prod
      - DB_HOST=db
    volumes:
      - ./src:/app/src          # Bind mount (development)
    depends_on:
      db:
        condition: service_healthy   # Wait until db is ready, not only started
    restart: unless-stopped
    networks:
      - mynet

  db:
    image: postgres:16-alpine
    environment:
      - POSTGRES_PASSWORD=secret   # Use a .env file or secrets in real projects
      - POSTGRES_DB=appdb
    volumes:
      - db_data:/var/lib/postgresql/data
    networks:
      - mynet
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  db_data:

networks:
  mynet:
    driver: bridge
```

The `version:` line is not needed anymore.

```bash
docker compose up -d                  # Start all services in background
docker compose up -d --scale worker=3 # 3 replicas of a service
docker compose ps
docker compose logs -f web
docker compose exec db psql -U postgres
docker compose build
docker compose restart web
docker compose down                   # Stop and delete containers and networks
docker compose down -v                # Also delete volumes
```

`docker compose` (with a space) is Compose v2. The old `docker-compose` command is deprecated.

---

## Resource limits

```bash
docker run --memory 512m myapp:1.0                       # Max RAM
docker run --memory-reservation 256m --memory 512m myapp:1.0  # Soft limit 256 MB, hard limit 512 MB
docker run --memory 512m --memory-swap 1g myapp:1.0      # RAM + swap = 1 GB
docker run --cpus 1.5 myapp:1.0                          # Max 1.5 CPU
docker run --cpuset-cpus 0,1 myapp:1.0                   # Only CPU 0 and 1
docker update --memory 1g --cpus 2 web                   # Change limits of a running container
```

---

## Cleanup

```bash
docker system df             # Disk space used by Docker

docker container prune       # Delete stopped containers
docker image prune           # Delete dangling images (no tag)
docker image prune -a        # Delete all images not used by a container
docker volume prune          # Delete unused volumes — data is lost!
docker network prune         # Delete unused networks
docker builder prune         # Delete build cache

docker system prune          # Stopped containers + unused networks + dangling images + build cache
docker system prune -a --volumes   # Everything unused, volumes included — careful!
```

---

## Pitfalls

- A container's data is lost with `docker rm`: use a volume for anything you keep.
- `-p 3306:3306` listens on **all** interfaces and Docker bypasses ufw/firewalld rules: use `-p 127.0.0.1:3306:3306` for local-only services.
- Pin image tags (`nginx:1.27`), avoid `latest`.
- Secrets in `ENV` or in a `RUN` line stay in the image layers (`docker history`): pass them at runtime.
- `docker compose down -v` and `docker system prune --volumes` delete volume data.
- Add `USER` in your Dockerfile: containers run as root by default.
- Use `--rm` for one-shot containers, or stopped containers pile up.

---

## Resources

Official

- [Docker docs](https://docs.docker.com)
- [Dockerfile reference](https://docs.docker.com/reference/dockerfile/)
- [Compose file reference](https://docs.docker.com/reference/compose-file/)
- [Docker Desktop with WSL 2 (Windows)](https://docs.docker.com/desktop/wsl/)

Tutorials

- [Docker Curriculum](https://docker-curriculum.com/) · [code](https://github.com/prakhar1989/docker-curriculum) — hands-on tutorial, deploys an app on AWS
- [TechWorld with Nana — Docker crash course (1 h)](https://www.youtube.com/watch?v=pg19Z8LL06w) (video)
- [TechWorld with Nana — Docker tutorial for beginners (3 h)](https://www.youtube.com/watch?v=3c-iBn73dDE) (video)
- [TechWorld with Nana — Docker Compose tutorial](https://www.youtube.com/watch?v=SXwC9fSwct8) (video)

Other cheat sheets and examples

- [Spacelift — Docker commands cheat sheet](https://spacelift.io/blog/docker-commands-cheat-sheet)
- [wsargent/docker-cheat-sheet](https://github.com/wsargent/docker-cheat-sheet)
- [Awesome Compose examples](https://github.com/docker/awesome-compose)
