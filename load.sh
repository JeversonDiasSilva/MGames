#!/bin/bash
# Curitiba 09 de Junho de 2025.
# Editor: Jeverson D. Silva /// @JCGAMESCLASSICOS...
troca
#/usr/share/retroluxxo/scripts/restart-coin.sh

# Função para inicializar a contagem e subtrair 1 de count.txt
iniciar_contagem() {
    rm /userdata/system/.dev/time.tmp >> /dev/null 2>&1 
    echo "" > /userdata/system/.dev/time.tmp

    if [ -f "/userdata/system/.dev/count.txt" ]; then
        count=$(cat /userdata/system/.dev/count.txt)
        [ -z "$count" ] && count=300
        count=$((count - 1))
        echo $count > /userdata/system/.dev/count.txt
        echo "Novo valor de count.txt após subtrair 1: $count"
    else
        echo "Arquivo /userdata/system/.dev/count.txt não encontrado!"
    fi

    if [ -f "/userdata/system/.dev/time.tmp" ]; then
        COIN_PY="/usr/share/retroluxxo/scripts/coin.py"
        if [ -f "$COIN_PY" ]; then
            tempo_game=$(grep -Po 'TEMPO_JOGO_MINUTOS\s*=\s*\K[0-9]+' "$COIN_PY")
        fi
        [ -z "$tempo_game" ] && tempo_game=1

        tempo_segundos=$((tempo_game * 60))
        echo $tempo_segundos > /userdata/system/.dev/tempo_jogo.txt
        echo "Iniciando a contagem regressiva com ${tempo_segundos} segundos."

        last_modified=$(stat --format=%Y /userdata/system/.dev/count.txt)

        while [ $tempo_segundos -gt 0 ]; do
            [ ! -f "/userdata/system/.dev/time.tmp" ] && echo "Arquivo time.tmp não encontrado." && break

            current_modified=$(stat --format=%Y /userdata/system/.dev/count.txt)
            [ "$last_modified" != "$current_modified" ] && echo "count.txt modificado, encerrando contagem." && break

            tempo_segundos=$((tempo_segundos - 1))
            echo $tempo_segundos > /userdata/system/.dev/tempo_jogo.txt
            sleep 1
        done

        if [ $tempo_segundos -le 0 ]; then
            pkill retroarch
	    xdotool key alt+F4
            rm /userdata/system/.dev/tempo_jogo.txt /userdata/system/.dev/time.tmp
            echo "Tempo de jogo acabou, RetroArch foi finalizado!"
        else
            echo "Contagem interrompida. RetroArch continua ativo!"
        fi
    else
        echo "Arquivo /userdata/system/.dev/time.tmp não encontrado!"
    fi
}

# Função para aplicar overlay com base no nome do jogo
aplicar_overlay() {
    local rom_file=$(basename "$ROM")
    local rom_name="${rom_file%.*}"
    local overlay_cfg="/userdata/system/configs/retroarch/overlay.cfg"

    # Busca o primeiro overlay correspondente, em qualquer subpasta
    local overlay_image=$(find /userdata/decorations/thebezelproject/games/ -name "${rom_name}.png" | head -n1)

    if [ -f "$overlay_image" ]; then
        cat > "$overlay_cfg" <<EOF
overlays = 1
overlay0_overlay = "${overlay_image}"
overlay0_full_screen = true
overlay0_descs = 0
EOF
        echo "Overlay aplicado: ${overlay_image}"
    else
        echo "Overlay não encontrado para: ${rom_name}"
    fi
}

# Diretórios das ROMs por sistema
ARCADE="/userdata/roms/windows"
ATOMISWAVE="/userdata/roms/atomiswave"
FBA="/userdata/roms/fba_libretro"
FBNEO="/userdata/roms/fbneo/"
GENESIS="/userdata/roms/megadrive"
MAMELIBRETRO="/userdata/roms/mame/mame_libretro"
MAME0139="/userdata/roms/mame/mame0139"
MAME078PLUS="/userdata/roms/mame/mame078plus"
N64="/userdata/roms/n64"
NAOMI="/userdata/roms/naomi"
NES="/userdata/roms/nes"
PSX="/userdata/roms/psx"
SNES="/userdata/roms/snes"
GAMECUBE="/userdata/roms/gamecube"

ROM=$(readlink -f "$1")
SISTEMA_DIR=$(dirname "$ROM")

CREDITOS_FILE="/userdata/system/.dev/count.txt"
CREDITOS=0
[ -f "$CREDITOS_FILE" ] && CREDITOS=$(grep -o '^[0-9]\+' "$CREDITOS_FILE")
[ -z "$CREDITOS" ] && CREDITOS=0

if [ "$CREDITOS" -le 0 ]; then
    echo "Sem créditos. Adicione créditos para jogar."
    mpv /usr/share/retroluxxo/sound/no.mp3 >/dev/null 2>&1
    exit 1
fi

launch_retroarch() {
    local core=$1
    retroarch -L "$core" "$ROM"
}

case "$SISTEMA_DIR" in
    "$ARCADE")
        iniciar_contagem &
	/usr/share/retroluxxo/scripts/overlay.py &
        Launcher_on
        SDL_RENDER_VSYNC=1 \
        SDL_GAMECONTROLLERCONFIG="030000005e0400008e02000014010000,Microsoft X-Box 360 pad,platform:Linux,b:b1,a:b0,dpdown:h0.4,dpleft:h0.8,rightshoulder:b5,leftshoulder:b4,dpright:h0.2,back:b6,start:b7,dpup:h0.1,y:b2,x:b3," \
        SDL_JOYSTICK_HIDAPI=0 \
        batocera-wine windows play "$ROM"
        Launcher_off
        ;;
    "$ATOMISWAVE")
        aplicar_overlay
        Launcher_on
        retroarch -L /usr/lib/libretro/flycast_libretro.so \
            --config /userdata/system/configs/retroarch/retroarch.cfg \
            --set-shader /usr/share/batocera/shaders/interpolation/sharp-bilinear-simple.slangp \
            --verbose --log-file /userdata/retroarch.log -f "$ROM"
        Launcher_off
        ;;
    "$FBA")
        aplicar_overlay
        Launcher_on ; launch_retroarch "/usr/lib/libretro/fbalpha2012_libretro.so" && Launcher_off
        ;;
    "$FBNEO"*)
        ROM_NAME=$(basename "$ROM")
        [[ "$ROM_NAME" != *.zip ]] && ROM_NAME="${ROM_NAME}.zip"
        ROM_PATH=$(find "$FBNEO" -type f -iname "$ROM_NAME" | head -n 1)

        if [ -z "$ROM_PATH" ]; then
            echo "ROM '$ROM_NAME' não encontrada em subpastas de $FBNEO"
            exit 1
        fi

        ROM="$ROM_PATH"
        aplicar_overlay
        Launcher_on ; launch_retroarch "/usr/lib/libretro/fbneo_libretro.so" && Launcher_off
        ;;
    "$GENESIS")
        iniciar_contagem &
	/usr/share/retroluxxo/scripts/overlay.py &
        sleep 1
        aplicar_overlay
        Launcher_on ; launch_retroarch "/usr/lib/libretro/genesisplusgx_libretro.so" && Launcher_off
        ;;
    "$GAMECUBE")
        iniciar_contagem &
	/usr/share/retroluxxo/scripts/overlay.py &
        sleep 1
        aplicar_overlay
        Launcher_on ; launch_retroarch "/usr/lib/libretro/dolphin_libretro.so" && Launcher_off
        ;;
    "$MAMELIBRETRO")
        aplicar_overlay
        Launcher_on
        retroarch \
            --config /userdata/system/configs/retroarch/config/mame_libretro \
            -L /usr/lib/libretro/mame_libretro.so "$ROM"
        Launcher_off
        ;;

    "$MAME0139")
        aplicar_overlay
        Launcher_on ; launch_retroarch "/usr/lib/libretro/mame0139_libretro.so" && Launcher_off
        ;;
    "$MAME078PLUS")
        aplicar_overlay
        Launcher_on
        launch_retroarch "/usr/lib/libretro/mame078plus_libretro.so" --config "/userdata/system/configs/retroarch/retroarch.cfg"
        Launcher_off
        ;;
    "$N64")
        iniciar_contagem &
	/usr/share/retroluxxo/scripts/overlay.py &
        sleep 1
        aplicar_overlay
        Launcher_on ; launch_retroarch "/usr/lib/libretro/mupen64plus-next_libretro.so" && Launcher_off
        ;;
    "$NAOMI")
        aplicar_overlay
        Launcher_on
        retroarch -L /usr/lib/libretro/flycast_libretro.so \
            --config /userdata/system/configs/retroarch/retroarch.cfg \
            --set-shader /usr/share/batocera/shaders/interpolation/sharp-bilinear-simple.slangp \
            --verbose --log-file /userdata/retroarch.log -f "$ROM"
        Launcher_off
        ;;
    "$PSX")
        iniciar_contagem &
	/usr/share/retroluxxo/scripts/overlay.py &
        sleep 1
        aplicar_overlay
        Launcher_on ; launch_retroarch "/usr/lib/libretro/pcsx_rearmed_libretro.so" && Launcher_off
        ;;
    "$SNES")
        iniciar_contagem &
	/usr/share/retroluxxo/scripts/overlay.py &
        sleep 1
        aplicar_overlay
        Launcher_on ; launch_retroarch "/usr/lib/libretro/snes9x_libretro.so" && Launcher_off
        ;;
    "$NES")
        iniciar_contagem &
	/usr/share/retroluxxo/scripts/overlay.py &
        sleep 1
        aplicar_overlay
        Launcher_on ; launch_retroarch "/usr/lib/libretro/nestopia_libretro.so" && Launcher_off 
        ;;
    *)
        aplicar_overlay
        echo "Sistema desconhecido: $SISTEMA_DIR"
        ;;
esac