# 🐳 Docker — Cheat Sheet
*Container platform for building, shipping, and running applications in isolated environments.*

---

## 🖼️ Images
*Build, manage, and inspect container images.*

```bash
docker build -t myapp:1.0 .  # Build image from Dockerfile in current directory
## -t tags image with name:version; use . for current dir context

docker build -t myapp:1.0 -f Dockerfile.prod .  # Build with specific Dockerfile
## -f specifies alternate Dockerfile path

docker build --build-arg ENV=prod -t myapp:1.0 .  # Pass build arguments
## Arguments available during build via ARG in Dockerfile

docker images  # List all images
## Shows repository, tag, image ID, size

docker image ls  # Alternative list command
docker rmi myapp:1.0  # Remove image by name:tag
docker rmi -f myapp:1.0  # Force remove (with -f flag)
docker image prune  # Remove unused images
## Warning: removes all dangling (untagged) images

docker tag myapp:1.0 myapp:latest  # Create tag alias
## Useful for marking stable/latest versions

docker push registry.example.com/myapp:1.0  # Push image to registry
## Requires docker login first with credentials

docker pull nginx:latest  # Download image from Docker Hub
## Latest tag assumed if tag not specified

docker inspect myapp:1.0  # Detailed image metadata
## Shows layers, architecture, environment variables, exposed ports

docker history myapp:1.0  # Show image layer history
## Each RUN, COPY, ADD creates a layer
```

## Dockerfile best practices
[Minimize layers, use multi-stage builds, clean up after each RUN, pin versions]

```dockerfile
# Multi-stage build (smaller final image)
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["node", "app.js"]
```

---

## 🐚 Containers
*Create, run, manage, and inspect containers.*

```bash
docker run --name myapp -d nginx:latest  # Create and run container in background
## -d for detached mode; --name gives container a readable name

docker run -it ubuntu:latest /bin/bash  # Run interactively with terminal
## -i (interactive) -t (allocate tty) for shell access

docker run -p 8080:80 nginx:latest  # Map ports: host:container
## Exposes container port 80 on host port 8080

docker run -e APP_ENV=prod -d myapp:1.0  # Set environment variables
## -e sets single variable; use --env-file for multiple

docker run --env-file .env.prod -d myapp:1.0  # Load env from file
## File format: KEY=value (one per line)

docker run -v /data:/app/data nginx:latest  # Mount volume: host_path:container_path
## Persists data outside container lifecycle

docker run --memory 512m --cpus 1.5 myapp:1.0  # Set resource limits
## --memory for RAM; --cpus for CPU cores

docker run --restart unless-stopped myapp:1.0  # Auto-restart policy
## Options: no, always, unless-stopped, on-failure

docker ps  # List running containers
docker ps -a  # List all containers (running and stopped)
docker ps -q  # List only container IDs

docker start myapp  # Start stopped container
docker stop myapp  # Stop running container gracefully
docker kill myapp  # Force stop container (SIGKILL)
docker restart myapp  # Stop and start container

docker rm myapp  # Remove container (must be stopped first)
docker rm -f myapp  # Force remove running container

docker inspect myapp  # Detailed container metadata
## Shows mounts, environment, network settings, resource limits

docker diff myapp  # Show filesystem changes since image
## A = added, C = changed, D = deleted
```

## Container lifecycle
[Create → Start → Run → Stop → Remove]

```bash
docker create --name myapp nginx:latest  # Create container but don't start
docker start myapp  # Start the container
docker pause myapp  # Pause running container
docker unpause myapp  # Resume paused container
docker exec -it myapp /bin/bash  # Run command in running container
## Useful for debugging, maintenance, one-off tasks
```

---

## 💾 Volumes
*Manage persistent storage and data sharing.*

```bash
docker volume create mydata  # Create named volume
docker volume ls  # List all volumes
docker volume inspect mydata  # Show volume details
docker volume rm mydata  # Remove volume
docker volume prune  # Remove unused volumes
## Warning: permanently deletes data

docker run -v mydata:/app/data myapp:1.0  # Use named volume
## Path /app/data in container maps to mydata volume

docker run -v $(pwd):/app myapp:1.0  # Bind mount: host path to container
## $(pwd) mounts current directory; useful for development

docker run -v /app/logs --mount type=volume,source=logs,target=/app/logs myapp:1.0  # Mount syntax
## --mount is newer syntax; more explicit than -v

docker inspect --type volume mydata  # View volume mount point on host
## Useful for finding where data actually stored on disk
```

## Volume driver
[Default local driver stores on host; plugins support cloud storage]

```bash
docker volume create --driver local mydata  # Explicit driver specification
docker volume create --driver nfs -o addr=10.0.0.1 mydata  # NFS volume
## Requires driver installed; useful for shared storage
```

---

## 🌐 Networks
*Create and manage container networking.*

```bash
docker network create mynet  # Create custom bridge network
## Default bridge network has limitations (no DNS by name)

docker network ls  # List all networks
docker network inspect mynet  # Show network configuration

docker run --network mynet --name app1 myapp:1.0  # Connect container to network
docker run --network mynet --name app2 myapp:1.0  # Another container on same network
## Containers on same network can reach each other by hostname

docker network connect mynet myapp  # Connect running container to network
docker network disconnect mynet myapp  # Disconnect container from network

docker run --link db:database myapp:1.0  # Link containers (deprecated)
## Use custom networks instead; simpler and more reliable
```

## Network types
[bridge (custom), host (share host network), overlay (swarm), none (no networking)]

```bash
docker run --network host myapp:1.0  # Use host network (bypass isolation)
## Ports directly exposed on host; useful for debugging

docker run --network none myapp:1.0  # No network access
## Complete isolation; app can't reach network
```

---

## 📦 Docker Compose
*Define multi-container applications in YAML.*

```yaml
version: '3.8'  # Compose file format version
services:
  web:  # Service name
    image: myapp:1.0  # Image to use
    ports:
      - "8080:3000"  # Port mapping
    environment:  # Environment variables
      - APP_ENV=prod
      - DB_HOST=db
    volumes:
      - ./src:/app/src  # Bind mount for development
    depends_on:
      - db  # Wait for other service to start
    restart: unless-stopped  # Restart policy
    networks:
      - mynet  # Custom network

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_PASSWORD=secret
      - POSTGRES_DB=appdb
    volumes:
      - db_data:/var/lib/postgresql/data  # Named volume
    ports:
      - "5432:5432"
    networks:
      - mynet
    healthcheck:  # Check service readiness
      test: ["CMD", "pg_isready", "-U", "postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    networks:
      - mynet

volumes:
  db_data:  # Define named volumes

networks:
  mynet:  # Define custom network
    driver: bridge
```

## Docker Compose commands
[Define app structure once, manage entire stack]

```bash
docker-compose up  # Start all services
docker-compose up -d  # Start in background
docker-compose up -d --scale worker=3  # Scale service to 3 replicas

docker-compose down  # Stop and remove containers
docker-compose down -v  # Also remove volumes

docker-compose logs  # View logs from all services
docker-compose logs -f web  # Follow logs from specific service

docker-compose ps  # List containers
docker-compose exec db psql -U postgres  # Execute command in service container
docker-compose build  # Build all services
docker-compose restart web  # Restart specific service
```

---

## 📊 Resource Limits
*Constrain CPU and memory usage.*

```bash
docker run --memory 512m myapp:1.0  # Limit to 512MB RAM
docker run --memory-swap 1g myapp:1.0  # Include swap: 1GB total (RAM + swap)
docker run --cpus 1.5 myapp:1.0  # Limit to 1.5 CPU cores

docker run --cpuset-cpus 0,1 myapp:1.0  # Pin to specific CPUs
## Useful on multi-socket systems for performance

docker update --memory 1g --cpus 2 myapp  # Update running container limits
## Changes apply immediately
```

## Memory strategies
[Reserve vs limit: reserve guarantees; limit prevents OOM]

```bash
docker run --memory-reservation 256m --memory 512m myapp:1.0  # Reserve 256MB, allow burst to 512MB
## Soft limit (reservation) vs hard limit (memory)

docker stats myapp  # Monitor live resource usage
## Shows CPU %, memory usage, network I/O, block I/O
```

---

## 📝 Logs & Debug
*Inspect and troubleshoot containers.*

```bash
docker logs myapp  # View container logs
docker logs -f myapp  # Follow logs (tail -f style)
docker logs --tail 100 myapp  # Show last 100 lines
docker logs --since 1h myapp  # Logs from last hour
docker logs --timestamps myapp  # Include timestamps

docker events  # Stream container events (creates, starts, stops)
docker stats  # Real-time resource stats for all containers
docker top myapp  # View processes running in container

docker exec -it myapp /bin/sh  # Get shell inside running container
## Useful for debugging application state

docker cp myapp:/var/log/app.log ./  # Copy file from container to host
docker cp ./config.txt myapp:/app/  # Copy from host to container

docker run --rm -it myapp:1.0 /bin/sh  # Temporary container for debugging
## --rm automatically removes container after exit
```

## Common debugging techniques
[Run as, check networking, trace system calls, examine logs]

```bash
docker run -it --user root myapp:1.0 /bin/sh  # Run as specific user for permissions
docker exec myapp netstat -an  # Check network connections
docker exec myapp curl localhost:3000  # Test internal connectivity
docker run --privileged myapp:1.0  # Run with extended privileges for low-level debugging
## Use sparingly; reduces security isolation
```

---

## 🧹 Cleanup
*Remove unused resources and reclaim disk space.*

```bash
docker container prune  # Remove all stopped containers
## Warning: deletes all non-running containers

docker image prune  # Remove dangling images (untagged)
docker image prune -a  # Remove all unused images
## Include images not used by any container

docker volume prune  # Remove unused volumes
## Warning: permanently deletes volume data

docker network prune  # Remove unused networks

docker system prune  # Clean everything (containers, images, volumes, networks)
docker system prune -a  # Also remove unused images
docker system df  # Show space usage by resource type

docker rmi $(docker images -q)  # Remove all images
## Dangerous; use with care
```

## Disk space management
[Build cache can grow large; use --no-cache to rebuild clean]

```bash
docker builder prune  # Clean build cache
docker build --no-cache -t myapp:1.0 .  # Rebuild without cache
```
