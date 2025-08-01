#!/bin/bash

CFG_FILE="/userdata/system/configs/retroarch/retroarch.cfg"

rm $CFG_FILE
cp /userdata/OVERLAY-SAVESTATE/retroarch.cfg $CFG_FILE

# Verifica se o arquivo existe
if [ ! -f "$CFG_FILE" ]; then
    echo "Arquivo $CFG_FILE não encontrado!"
    exit 1
fi

# === Configuração do Overlay ===

# Substitui exatamente a linha input_overlay = "" pelas novas linhas
sed -i '/^input_overlay *= *""$/c\
input_overlay = /userdata/system/configs/retroarch/overlay.cfg\
input_overlay_enable = true              # Habilita o uso de overlays\
input_overlay_show_mouse_cursor = true  # Mostra o cursor do mouse (relevante para light guns ou toques)\
input_overlay_hide_in_menu = true       # Esconde o overlay no menu\
input_overlay_opacity = 1.0             # Opacidade da moldura (1.0 = totalmente visível)\
input_overlay_scale = 1.0' "$CFG_FILE"

echo "Overlay substituído com sucesso!"

# === Configurações de Savestate ===

# Remove as linhas antigas, se existirem
sed -i '/^savestate_auto_load *=/d' "$CFG_FILE"
sed -i '/^savestate_auto_save *=/d' "$CFG_FILE"
sed -i '/^savestate_directory *=/d' "$CFG_FILE"

# Adiciona as configurações ao final do arquivo
cat <<EOL >> "$CFG_FILE"

# Configurações para carregar e salvar savestates automaticamente
savestate_auto_load = "true"
savestate_auto_save = "false"
savestate_directory = "/userdata/saves/fbneo/fbneo"
EOL

echo "Configuração de savestate atualizada com sucesso!"

rm /userdata/system/configs/retroarch/CFG/retroarch-custom.cfg

cp /userdata/system/configs/retroarch/retroarch.cfg /userdata/system/configs/retroarch/CFG/retroarch-custom.cfg