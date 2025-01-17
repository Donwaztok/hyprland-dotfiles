#!/bin/bash

# Nomes dos dispositivos que você deseja alternar
DEVICE_NAME_CREATIVE="Creative Stage SE"
DEVICE_NAME_HYPERX="HyperX Cloud Stinger Core Wireless + 7.1"

# Volumes padrão
VOLUME_CREATIVE="60%"
VOLUME_HYPERX="90%"

# Função para obter ID de um dispositivo de saída pelo nome
get_device_id_by_name() {
    local device_name="$1"
    wpctl status \
      | awk '/Sinks:/{flag=1;next}/Sources:/{flag=0}flag' \
      | grep -F "$device_name" \
      | head -n1 \
      | sed -E 's/[^0-9]*([0-9]+).*/\1/'
}

# Obter IDs dinamicamente
DEVICE_CREATIVE=$(get_device_id_by_name "$DEVICE_NAME_CREATIVE")
DEVICE_HYPERX=$(get_device_id_by_name "$DEVICE_NAME_HYPERX")

# Obter o dispositivo atual
CURRENT_DEVICE=$(wpctl status | grep -A 2 "Sinks:" | grep '\*' | sed -E 's/[^0-9]*([0-9]+).*/\1/')

# Lógica de alternância
if [[ "$CURRENT_DEVICE" == "$DEVICE_CREATIVE" ]]; then
    NEW_DEVICE="$DEVICE_HYPERX"
    NEW_VOLUME="$VOLUME_HYPERX"
    echo "Alternando para $DEVICE_NAME_HYPERX ... Volume: $NEW_VOLUME"
elif [[ "$CURRENT_DEVICE" == "$DEVICE_HYPERX" ]]; then
    NEW_DEVICE="$DEVICE_CREATIVE"
    NEW_VOLUME="$VOLUME_CREATIVE"
    echo "Alternando para $DEVICE_NAME_CREATIVE ... Volume: $NEW_VOLUME"
else
    # Caso o dispositivo atual não seja reconhecido, define o Creative como padrão
    NEW_DEVICE="$DEVICE_CREATIVE"
    NEW_VOLUME="$VOLUME_CREATIVE"
    echo "Dispositivo atual não reconhecido. Definindo saída para $DEVICE_NAME_CREATIVE como padrão..."
fi

# Alterar o dispositivo de saída padrão
wpctl set-default "$NEW_DEVICE"

# Ajustar volume e desmutar
wpctl set-volume "$NEW_DEVICE" "$NEW_VOLUME"
wpctl set-mute "$NEW_DEVICE" 0

# Mover fluxos ativos para o novo dispositivo
for STREAM_ID in $(wpctl status | grep -Eo 'Stream\s+[0-9]+' | awk '{print $2}'); do
    wpctl move "$STREAM_ID" "$NEW_DEVICE"
done

echo "Saída de áudio alternada com sucesso para o dispositivo $NEW_DEVICE."
