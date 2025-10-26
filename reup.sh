#!/bin/bash
# Curitiba, 20 de Outubro de 2025
# Editor: Jeverson D. da Silva /// @JCGAMESCLASSICOS

batocera_conf="/userdata/system/batocera.conf"
custom_source="/userdata/system/.dev/scripts/.wine"

# 🎨 Estilos ANSI
BOLD="\e[1m"
BOLD_GREEN="\e[1;32m"
BOLD_YELLOW="\e[1;33m"
BOLD_RED="\e[1;31m"
BOLD_CYAN="\e[1;36m"
BOLD_WHITE="\e[1;37m"
UNDERLINE="\e[4m"
RESET="\e[0m"

# 📌 Nome do jogo atual
dir_game="$(pwd)"
game="$(basename "$dir_game")"
game_prefixo="${game}.wine"

# 🔍 Busca o wine-runner no batocera.conf
wine_runner=$(grep -oP "windows\[\"$game\"\]\.wine-runner=\K.+" "$batocera_conf" | tr -d '\r')

if [ -z "$wine_runner" ]; then
    echo -e "❌ ${BOLD}${BOLD_RED}wine-runner não encontrado para o jogo '${BOLD}${BOLD_GREEN}$game${RESET}${BOLD}${BOLD_RED}' em $batocera_conf${RESET}"
    exit 1
fi

# 🖼️ Mostra nome do jogo e runner com estilo
echo -e "🎮 ${BOLD}Jogo: ${BOLD_GREEN}$game${RESET}"
sleep 1.5
echo -e "🍷 ${BOLD}wine-runner vigente: ${BOLD_GREEN}$wine_runner${RESET}"
sleep 1.5

# 📁 Caminhos dos prefixos
raiz="/userdata/system/wine-bottles/windows"
dir_usado="$raiz/$wine_runner/$game_prefixo"

# ❌ Verifica existência do prefixo
if [ ! -d "$dir_usado" ]; then
    echo -e "❌ ${BOLD}${BOLD_RED}Prefixo esperado não encontrado:${RESET} $dir_usado"
    exit 1
fi

# 🧮 Função para calcular espaço ocupado de um diretório
espaco_poupado() {
    local dir="$1"
    if [ -d "$dir" ]; then
        du -sb "$dir" 2>/dev/null | awk '{print $1}'
    else
        echo 0
    fi
}

# 🧮 Converte bytes para MB/GB
formatar_espaco() {
    numfmt --to=iec-i --suffix=B "$1"
}

# 🧹 Remove prefixos em outros wine-runners e soma espaço
echo -e "🧹 ${BOLD}Procurando e apagando versões alternativas do prefixo...${RESET}"
sleep 1.5

espaco_total_poupado=0

for dir in "$raiz"/*; do
    if [ -d "$dir" ] && [ "$(basename "$dir")" != "$wine_runner" ]; then
        other_prefix="$dir/$game_prefixo"
        if [ -d "$other_prefix" ]; then
            size=$(espaco_poupado "$other_prefix")
            ((espaco_total_poupado+=size))
            echo -e "🚮 ${BOLD}Apagando prefixo: ${BOLD_RED}$other_prefix${RESET}"
            rm -rf "$other_prefix"
            sleep 1.5
        fi
    fi
done

# ⚙️ Lógica do modo -up
if [ "$1" == "-up" ]; then
    if [ ! -d "$custom_source" ]; then
        echo -e "❌ ${BOLD}${BOLD_RED}Diretório de origem não encontrado:${RESET} $custom_source"
        exit 1
    fi

    size_before=$(espaco_poupado "$dir_usado")
    ((espaco_total_poupado+=size_before))

    rm -rf "${dir_usado:?}/"*
    ln -s "$custom_source"/* "$dir_usado"

    size_readable=$(formatar_espaco "$espaco_total_poupado")
    echo -e "✅ ${BOLD}Reup padrão concluído espaço poupado: ${BOLD_RED}$size_readable${RESET}"
    exit 0
fi

# 🗂️ Modo padrão com .base
dir_pai="$(dirname "$dir_usado")"
base="${dir_pai}/.base"

# Cria .base silenciosamente se não existir
if [ ! -d "$base" ]; then
    mkdir -p "$base"
    cp -a "$dir_usado"/. "$base"/
fi

size_before=$(espaco_poupado "$dir_usado")
((espaco_total_poupado+=size_before))

sleep 1.5
rm -rf "${dir_usado:?}/"*
ln -s "$base"/* "$dir_usado"

size_readable=$(formatar_espaco "$espaco_total_poupado")
echo -e "✅ ${BOLD}Reup padrão concluído espaço poupado: ${BOLD_RED}$size_readable${RESET}"