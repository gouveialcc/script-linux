#!/bin/bash

# --- Cores ---
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
RESET='\033[0m'
BOLD='\033[1m'

TARGET_DIR=${1:-"."}

# --- Cabeçalho ---
clear
printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
printf "  ${BOLD}${MAGENTA}📂 DISK STORAGE ANALYZER v1.1 ${RESET}\n"
printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"

# --- Barra de Progresso (Sintaxe Simples) ---
progress_bar() {
    local cols=30
    printf "${YELLOW}🔍 Escaneando diretórios...${RESET}\n"
    i=0
    while [ $i -le $cols ]; do
        perc=$(( i * 100 / cols ))
        bar=""
        j=0
        while [ $j -lt $i ]; do bar="${bar}█"; j=$((j+1)); done
        space=""
        j=0
        while [ $j -lt $((cols-i)) ]; do space="${space} "; j=$((j+1)); done
        printf "\r   [${GREEN}%s${RESET}%s] %d%%" "$bar" "$space" "$perc"
        i=$((i + 2))
        sleep 0.03
    done
    printf "\n\n"
}

progress_bar

# --- Tabela de Resultados (Colunas Largas) ---
# Usando printf com largura fixa de 15 caracteres para o tamanho
printf "${BOLD}%-15s %-s${RESET}\n" "TAMANHO" "DIRETÓRIO / ARQUIVO"
printf "${CYAN}──────────────────────────────────────────────────────────────${RESET}\n"

# Lógica de detecção de SO e extração de dados
if [ "$(uname)" = "Darwin" ]; then
    # macOS
    DATA=$(du -rg "$TARGET_DIR" 2>/dev/null | sort -rn | head -n 20)
else
    # Linux (Ubuntu)
    DATA=$(du -h --max-depth=2 "$TARGET_DIR" 2>/dev/null | sort -h -r | head -n 20)
fi

# Exibição formatada
echo "$DATA" | while read -r size path; do
    # Define a cor: Vermelho se for Gigabyte (G), Verde se for Megabyte (M) ou menor
    case "$size" in
        *G*) color=$RED ;;
        *)   color=$GREEN ;;
    esac

    # %-15s cria um espaço fixo de 15 caracteres para o tamanho, alinhando os nomes
    printf "${color}%-14s${RESET} %-s\n" "$size" "$path"
done

printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
printf "${BOLD}${GREEN}✅ Análise concluída!${RESET}\n"

