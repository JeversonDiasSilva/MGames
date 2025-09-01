#!/bin/bash
# Curitiba 01 de Setembro de 2025.
# Editor: Jeverson D. Silva   ///@JCGAMESCLASSICOS...
# Configuração do "sistema comercial" para tv de tubo..


dir_work="/userdata/system/configs/retroarch/CFG"
url="https://github.com/JeversonDiasSilva/MGames/releases/download/V1.0/CONFIGS-TUBO"
squash=$(basename "$url")

cd "$dir_work" || exit

# Limpar diretório
rm -rf "$dir_work"/*

# Remover arquivos antigos
rm -f /userdata/system/.dev/scripts/CONFIG/config-sistema.py
rm -f /usr/share/retroluxxo/scripts/config_switch.py
rm -f /usr/bin/troca

# Baixar o squashfs
wget "$url" -O "$squash"

# Extrair conteúdo
unsquashfs -d "$dir_work" "$squash"

# Remover arquivo baixado
rm -f "$squash"

# Mover arquivos de script
mv "$dir_work/config-sistema.py" "$dir_work/config_switch.py" /usr/share/retroluxxo/scripts/
mv troca /usr/bin

# Salvar alterações
batocera-save-overlay 250
