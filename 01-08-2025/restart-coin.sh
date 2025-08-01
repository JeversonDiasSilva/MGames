#!/bin/bash

PID=$(pgrep -f /usr/share/retroluxxo/scripts/coin.py)

if [ -z "$PID" ]; then
  echo "Processo coin.py não está rodando."
else
  echo "Matando processo coin.py com PID: $PID"
  kill -9 $PID
  sleep 1
  if pgrep -f /usr/share/retroluxxo/scripts/coin.py > /dev/null; then
    echo "Erro: processo ainda está ativo."
    exit 1
  else
    echo "Processo finalizado com sucesso."
  fi
fi

echo "Iniciando coin.py..."
nohup /usr/share/retroluxxo/scripts/coin.py >/dev/null 2>&1 &

echo "coin.py reiniciado com sucesso."