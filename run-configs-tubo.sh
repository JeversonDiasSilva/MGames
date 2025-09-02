#!/bin/bash
# Curitiba 01 de Setembro de 2025.
# Editor: Jeverson D. Silva   ///@JCGAMESCLASSICOS...
# Configuração do "sistema comercial" para tv de tubo..

dir_work="/userdata/system/configs/retroarch/CFG"
url="https://github.com/JeversonDiasSilva/MGames/releases/download/V1.0/CONFIGS-TUBO"
squash=$(basename "$url")

cd "$dir_work" || exit

# Limpar diretório (incluindo arquivos ocultos)
rm -rf "$dir_work"/.[!.]* "$dir_work"/*

# Remover arquivos antigos
rm -f /userdata/system/.dev/scripts/CONFIG/config-sistema.py
rm -f /usr/share/retroluxxo/scripts/config_switch.py
rm -f /usr/share/retroluxxo/sound/disconect-controle.mp3
rm -f /usr/share/retroluxxo/scripts/load.sh
rm -f /usr/bin/troca

# Baixar o squashfs
wget "$url" -O "$squash"

# Extrair conteúdo
unsquashfs -d "$dir_work" "$squash"

# Remover arquivo baixado
rm -f "$squash"

chmod -R 777 "$dir_work"

# Mover arquivos de script
mv  "$dir_work/config_switch.py" /usr/share/retroluxxo/scripts/
mv "$dir_work"/config-sistema.py /userdata/system/.dev/scripts/CONFIG
mv disconect-controle.mp3 /usr/share/retroluxxo/sound/
mv load.sh /usr/share/retroluxxo/scripts
mv troca /usr/bin

# Reiniciar os Joysticks para surtir a configura;'ao imediatamente
# Desabilitar todos os USBs
for d in /sys/bus/usb/devices/*/authorized; do
    echo 0 |  tee $d
done

# Espera 2 segundos
sleep 2

# Reabilitar todos os USBs
for d in /sys/bus/usb/devices/*/authorized; do
    echo 1 |  tee $d
done


# Salvar alterações
batocera-save-overlay 250
