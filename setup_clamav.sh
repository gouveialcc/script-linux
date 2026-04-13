#!/bin/bash

# --- Configurações e Cores ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # Sem cor

echo -e "${BLUE}=== Iniciando Instalação Automatizada ClamAV (Docker) ===${NC}"

# 1. Instalar Docker
echo -e "${GREEN}[1/6] Instalando docker.io...${NC}"
sudo apt update && sudo apt install -y docker.io

# 2. Criar diretórios no Host
echo -e "${GREEN}[2/6] Criando diretórios de banco de dados e logs...${NC}"
sudo mkdir -p /opt/clamav/
sudo mkdir -p /var/log/clamav/ # Criado no host para persistência se necessário

# 3. Criar o script de scan (clam.sh)
echo -e "${GREEN}[3/6] Criando script de scan interno...${NC}"
cat << 'EOF' > clam.sh
#!/bin/sh
echo "--- Iniciando Scan: $(date) ---"

# Variaveis
TARGET_DIR="/scandir"
EXCLUDE_DIR="/u01 /u02 /u03 /proc /sys /dev /var/log /var/cache /var/run"
LOG_FILE="/var/log/clamav/clamav_log_$(date +%F).log"

# Garante que o diretório de log existe dentro do container
mkdir -p /var/log/clamav/

# Executa o scan com prioridade baixa
nice -n 19 ionice -c 3 clamscan -rv --quiet --infected --max-filesize=100M --max-scansize=100M --cross-fs=no --allmatch=yes --log="$LOG_FILE" --exclude-dir="$EXCLUDE_DIR" "$TARGET_DIR"

# Manutenção de Logs (Guarda 10 dias conforme seu comando find)
find /var/log/clamav/ -name "clamav_log_*.log" -mtime +10 -exec rm {} \;

echo "--- Scan Finalizado: $(date) ---"
EOF

chmod +x clam.sh

# 4. Detectar Arquitetura e Rodar Container
ARCH=$(uname -m)
PLATFORM=""

if [ "$ARCH" = "x86_64" ]; then
    PLATFORM="linux/amd64"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    PLATFORM="linux/arm64"
else
    echo "Arquitetura não suportada: $ARCH"
    exit 1
fi

echo -e "${GREEN}[4/6] Iniciando Container para $PLATFORM...${NC}"
docker run -d \
    -e TZ=America/Sao_Paulo \
    --name clamav \
    --platform "$PLATFORM" \
    --restart always \
    -v /opt/clamav:/var/lib/clamav \
    -v /:/scandir:ro \
    clamav/clamav-debian:1.5.2

# 5. Configurar script dentro do container
echo -e "${GREEN}[5/6] Copiando script para o container...${NC}"
# Aguarda alguns segundos para o container estabilizar
sleep 5
docker exec clamav mkdir -p /opt/clamav/
docker cp clam.sh clamav:/opt/clamav/

# 6. Configurar Cronjob no Host
echo -e "${GREEN}[6/6] Configurando Cronjob (Todo Domingo às 05:00)...${NC}"
CRON_CMD="00 5 * * 0 /usr/bin/docker exec -u root clamav /opt/clamav/clam.sh"
(crontab -l 2>/dev/null; echo "$CRON_CMD") | crontab -

echo -e "${BLUE}=== Instalação Finalizada com Sucesso! ===${NC}"
