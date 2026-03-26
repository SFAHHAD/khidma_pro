# Khidma Pro Backend Deployment (DigitalOcean)

This guide deploys the FastAPI backend and PostgreSQL using Docker on a DigitalOcean Droplet.

## 1) Create Droplet

- Create an Ubuntu 24.04 Droplet (2 GB RAM minimum recommended).
- Open inbound ports in DigitalOcean firewall:
  - `22` (SSH)
  - `8001` (API)

## 2) Install Docker + Compose

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER
newgrp docker
```

## 3) Clone Repository

```bash
git clone https://github.com/SFAHHAD/khidma_pro.git
cd khidma_pro
```

## 4) Configure Environment

```bash
cp .env.example .env
```

Edit `.env` and set a strong `JWT_SECRET` and secure DB password.

## 5) Build + Run

```bash
docker compose up -d --build
```

## 6) Verify Health

```bash
curl http://127.0.0.1:8001/health
curl http://127.0.0.1:8001/ready
```

Expected:
- `/health` returns app metadata and launch cities
- `/ready` returns `{"status":"ready","database":"ok"}`

## 7) Seed Provider (Optional)

```bash
docker compose exec web python seed_provider.py
```

## 8) Point Flutter App to Public API

In `frontend/lib/core/state.dart`, replace local base URLs with your droplet public IP/domain:

- Android emulator: `http://10.0.2.2:8001` (for local only)
- Production/mobile: `https://api.yourdomain.com` (recommended with reverse proxy + TLS)

## 9) Recommended Next Hardening

- Put Nginx/Caddy in front with HTTPS (Let's Encrypt).
- Disable public PostgreSQL port and keep DB private to Docker network.
- Add backups for `postgres_data` volume.
- Add CI/CD pipeline for image build and deployment.
