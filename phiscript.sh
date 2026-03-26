#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
BLINK='\033[5m'
RESET='\033[0m'

JSON="$HOME/.virus_questions.json"

trap '' SIGINT SIGTERM SIGQUIT SIGHUP SIGTSTP SIGABRT
stty intr undef 2>/dev/null
stty susp undef 2>/dev/null
stty quit undef 2>/dev/null

clear

echo -e "${RED}${BOLD}"
for line in \
    "  ██╗   ██╗██╗██████╗ ██╗   ██╗███████╗" \
    "  ██║   ██║██║██╔══██╗██║   ██║██╔════╝" \
    "  ██║   ██║██║██████╔╝██║   ██║███████╗" \
    "  ╚██╗ ██╔╝██║██╔══██╗██║   ██║╚════██║" \
    "   ╚████╔╝ ██║██║  ██║╚██████╔╝███████║" \
    "    ╚═══╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝"; do
    echo "$line"
    sleep 0.07
done
echo -e "${RESET}"
sleep 0.3

echo -e "${YELLOW}  ════════════════════════════════════════${RESET}"
echo -e "${RED}${BLINK}  [!] SISTEMA INFECTADO - ACCESO BLOQUEADO${RESET}"
echo -e "${YELLOW}  ════════════════════════════════════════${RESET}"
echo ""
sleep 0.5
echo -e "${CYAN}  Inicializando protocolo de desencriptado...${RESET}"
sleep 0.4
echo -e "${CYAN}  Cargando banco de preguntas...${RESET}"
sleep 0.5
echo ""
echo -e "${MAGENTA}  Tu terminal está ${BOLD}BLOQUEADA.${RESET}"
echo -e "${MAGENTA}  Responde ${BOLD}5 preguntas${RESET}${MAGENTA} correctamente para liberarla.${RESET}"
echo -e "${RED}  Ctrl+C, Ctrl+Z... no funcionan aquí. 😈${RESET}"
echo ""
echo -e "${YELLOW}  ════════════════════════════════════════${RESET}"
sleep 1.2

if [ ! -f "$JSON" ]; then
    echo -e "${RED}  [!] No se encontró: $JSON${RESET}"
    stty sane 2>/dev/null
    trap - SIGINT SIGTERM SIGQUIT SIGHUP SIGTSTP SIGABRT
    exit 1
fi

TMPDIR_Q=$(mktemp -d)

python3 - "$JSON" "$TMPDIR_Q" <<'PYEOF'
import json, random, sys, os

with open(sys.argv[1], encoding="utf-8") as f:
    data = json.load(f)

pool = data["preguntas"]
elegidas = random.sample(pool, min(5, len(pool)))

for i, p in enumerate(elegidas, 1):
    d = sys.argv[2]
    open(f"{d}/{i}.area",     "w").write(p["area"])
    open(f"{d}/{i}.pregunta", "w").write(p["pregunta"])
    open(f"{d}/{i}.respuesta","w").write(p["respuesta"].lower().strip())
PYEOF

if [ $? -ne 0 ]; then
    echo -e "${RED}  [!] Error al cargar preguntas.${RESET}"
    rm -rf "$TMPDIR_Q"
    stty sane 2>/dev/null
    trap - SIGINT SIGTERM SIGQUIT SIGHUP SIGTSTP SIGABRT
    exit 1
fi

INTENTOS_TOTALES=0

for NUM in 1 2 3 4 5; do
    AREA=$(cat "$TMPDIR_Q/$NUM.area")
    PREGUNTA=$(cat "$TMPDIR_Q/$NUM.pregunta")
    RESPUESTA=$(cat "$TMPDIR_Q/$NUM.respuesta")
    intentos_preg=0

    while true; do
        echo ""
        echo -e "${YELLOW}  ════════════════════════════════════════${RESET}"
        if [ $intentos_preg -eq 0 ]; then
            echo -e "${CYAN}${BOLD}  [ PREGUNTA $NUM / 5 ]  ${MAGENTA}$AREA${RESET}"
        else
            echo -e "${CYAN}${BOLD}  [ PREGUNTA $NUM / 5 ]  ${MAGENTA}$AREA  ${RED}(reintento)${RESET}"
        fi
        echo -e "${YELLOW}  ════════════════════════════════════════${RESET}"
        echo ""
        echo -e "  ${BOLD}$PREGUNTA${RESET}"
        echo ""
        echo -ne "${CYAN}  >> Tu respuesta: ${RESET}"
        read resp < /dev/tty

        resp_clean=$(echo "$resp" | tr '[:upper:]' '[:lower:]' | xargs 2>/dev/null)
        intentos_preg=$((intentos_preg + 1))
        INTENTOS_TOTALES=$((INTENTOS_TOTALES + 1))

        if [ "$resp_clean" = "$RESPUESTA" ]; then
            echo ""
            echo -e "${GREEN}${BOLD}  [✓] ¡CORRECTO! Capa $NUM desbloqueada...${RESET}"
            sleep 0.7
            break
        else
            echo -e "${RED}  [✗] INCORRECTO. El virus se fortalece...${RESET}"
            if [ $intentos_preg -ge 3 ]; then
                hint="${RESPUESTA:0:1}"
                echo -e "${YELLOW}  [~] Pista: la respuesta empieza con \"$hint\"${RESET}"
            fi
        fi
    done
done

rm -rf "$TMPDIR_Q"

stty sane 2>/dev/null
trap - SIGINT SIGTERM SIGQUIT SIGHUP SIGTSTP SIGABRT

clear
echo ""
echo -e "${GREEN}${BOLD}"
echo "  ██████╗ ███████╗███████╗██████╗ "
echo "  ██╔══██╗██╔════╝██╔════╝██╔══██╗"
echo "  ██████╔╝█████╗  █████╗  ██████╔╝"
echo "  ██╔══██╗██╔══╝  ██╔══╝  ██╔══██╗"
echo "  ██║  ██║██║     ███████╗██║  ██║"
echo "  ╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝"
echo -e "${RESET}"
echo -e "${GREEN}${BOLD}  ╔══════════════════════════════════════╗${RESET}"
echo -e "${GREEN}${BOLD}  ║   VIRUS NEUTRALIZADO CON ÉXITO  🎉   ║${RESET}"
echo -e "${GREEN}${BOLD}  ╚══════════════════════════════════════╝${RESET}"
echo ""
echo -e "${CYAN}  Intentos totales : ${YELLOW}${BOLD}$INTENTOS_TOTALES${RESET}"
echo ""
if   [ "$INTENTOS_TOTALES" -eq 5 ];  then echo -e "${MAGENTA}${BOLD}  🏆 PERFECTO. Felicitaciones sabes usar google.${RESET}"
elif [ "$INTENTOS_TOTALES" -le 9 ];  then echo -e "${CYAN}  te fue... bien... relativamente..${RESET}"
elif [ "$INTENTOS_TOTALES" -le 15 ]; then echo -e "${YELLOW}  🤔 Lo lograste... mediocremente.${RESET}"
else                                       echo -e "${RED}  😅 ¿Seguro que fuiste al colegio?${RESET}"
fi
echo ""
echo -e "${YELLOW}  ════════════════════════════════════════${RESET}"
echo -e "${GREEN}  Terminal desbloqueada. Bienvenido de vuelta.${RESET}"
echo -e "${YELLOW}  ════════════════════════════════════════${RESET}"
echo ""
