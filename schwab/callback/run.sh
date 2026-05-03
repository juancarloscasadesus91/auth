#!/usr/bin/env bash
# ============================================================
#  tunnel.sh — Cloudflare Tunnel auto-updater
#  Lanza cloudflared, captura la URL pública y la propaga a:
#    1. El archivo index.php del repo git local
#    2. APP_URL y ASSET_URL en el .env de tu proyecto
# ============================================================

set -eu
set -o pipefail 2>/dev/null || true

# ────────────────────────────────────────────────
#  CONFIGURACIÓN — editá estos valores
# ────────────────────────────────────────────────
GIT_REPO_PATH="/home/jhony/Documentos/TOS/auth/schwab/callback"          # ej: ~/proyectos/infinityfree-proxy
INDEX_FILE="index.php"                    # archivo dentro del repo a actualizar
ENV_FILE="/home/jhony/Documentos/TOS/market-platform/.env"       # ej: ~/proyectos/miapp/.env
LOCAL_PORT=8000
# ────────────────────────────────────────────────

# Colores
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

log()  { echo -e "${CYAN}[tunnel]${NC} $*"; }
ok()   { echo -e "${GREEN}[✔]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
err()  { echo -e "${RED}[✘]${NC} $*"; exit 1; }

# ── Verificaciones previas ───────────────────────
command -v cloudflared &>/dev/null || err "cloudflared no está instalado. Instalalo desde https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/"
command -v git &>/dev/null         || err "git no está instalado."
[[ -d "$GIT_REPO_PATH" ]]          || err "El repo no existe en: $GIT_REPO_PATH"
[[ -f "$ENV_FILE" ]]               || err "El .env no existe en: $ENV_FILE"

TMPLOG=$(mktemp /tmp/cloudflared_XXXXXX.log)
trap 'kill $CF_PID 2>/dev/null' EXIT

# ── Lanzar cloudflared en background ────────────
log "Iniciando túnel en localhost:${LOCAL_PORT}..."
cloudflared tunnel --url "http://localhost:${LOCAL_PORT}" \
    --no-autoupdate --loglevel info >"$TMPLOG" 2>&1 &
CF_PID=$!
log "Cloudflared PID: $CF_PID, Log: $TMPLOG"
sleep 3  # Dar tiempo a cloudflared para iniciar y conectar

# ── Esperar y capturar la URL pública ───────────
log "Esperando URL pública..."
TUNNEL_URL=""
for i in $(seq 1 60); do
    # Verificar si el proceso sigue vivo
    if ! kill -0 $CF_PID 2>/dev/null; then
        err "Cloudflared murió inesperadamente. Log:\n$(cat "$TMPLOG")"
    fi
    
    # Buscar la URL en el formato del log de cloudflared
    TUNNEL_URL=$(grep -oE 'https://[a-z0-9\-]+\.trycloudflare\.com' "$TMPLOG" | head -1)
    if [[ -n "$TUNNEL_URL" ]]; then
        break
    fi
    # Mostrar progreso cada 5 segundos
    if [[ $((i % 5)) -eq 0 ]]; then
        warn "Esperando... ($i/60s)"
        echo "--- Últimas líneas del log ---"
        tail -5 "$TMPLOG" 2>/dev/null || echo "Log vacío o no existe"
        echo "------------------------------"
    fi
    sleep 1
done

if [[ -z "$TUNNEL_URL" ]]; then
    echo -e "${RED}[✘] No se pudo obtener la URL del túnel.${NC}"
    echo -e "${YELLOW}Log guardado en: $TMPLOG${NC}"
    echo -e "${YELLOW}Contenido del log:${NC}"
    cat "$TMPLOG"
    exit 1
fi
ok "URL obtenida: ${GREEN}${TUNNEL_URL}${NC}"

# ── Actualizar index.php en el repo ─────────────
INDEX_PATH="${GIT_REPO_PATH}/${INDEX_FILE}"
[[ -f "$INDEX_PATH" ]] || err "No se encontró $INDEX_PATH"

log "Actualizando \$tunnel en ${INDEX_FILE}..."
# Reemplaza la línea que define $tunnel = "..."
sed -i.bak "s|^\(\$tunnel\s*=\s*\)\".*\";|\1\"${TUNNEL_URL}\";|" "$INDEX_PATH"
ok "index.php actualizado"

# ── Commit y push al repo git ────────────────────
log "Haciendo commit y push en el repo..."
cd "$GIT_REPO_PATH"
git add "$INDEX_FILE"
if git diff --cached --quiet; then
    warn "No hay cambios nuevos en el repo (la URL era la misma)."
else
    git commit -m "chore: update tunnel URL → ${TUNNEL_URL}"
    git push
    ok "Repo actualizado y pusheado"
fi

# ── Actualizar APP_URL y ASSET_URL en el .env ────
log "Actualizando .env en ${ENV_FILE}..."
update_env_key() {
    local key="$1"
    local value="$2"
    if grep -qE "^${key}=" "$ENV_FILE"; then
        sed -i.bak "s|^${key}=.*|${key}=${value}|" "$ENV_FILE"
        ok "${key} actualizado → ${value}"
    else
        echo "${key}=${value}" >> "$ENV_FILE"
        ok "${key} agregado → ${value}"
    fi
}

update_env_key "APP_URL"   "$TUNNEL_URL"
update_env_key "ASSET_URL" "$TUNNEL_URL"

# ── Todo listo ───────────────────────────────────
echo ""
echo -e "${GREEN}══════════════════════════════════════════${NC}"
echo -e "${GREEN}  Túnel activo: ${TUNNEL_URL}${NC}"
echo -e "${GREEN}  Presioná Ctrl+C para detenerlo${NC}"
echo -e "${GREEN}══════════════════════════════════════════${NC}"
echo ""

# Mantener el túnel vivo
wait $CF_PID