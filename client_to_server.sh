#!/bin/bash

# Função para adicionar o cliente ao servidor WireGuard
add_client_to_server() {
  CLIENT_NAME=$1
  CLIENT_PUBLIC_KEY=$2
  CLIENT_IP=$3

  # Adicionar cliente ao wg0.conf do servidor
  echo "
# Client: $CLIENT_NAME
[Peer]
PublicKey = $CLIENT_PUBLIC_KEY
AllowedIPs = $CLIENT_IP/32" >> /etc/wireguard/wg0.conf

  echo "Cliente $CLIENT_NAME adicionado ao servidor WireGuard."

  # Reiniciar o serviço WireGuard para aplicar as mudanças
  wg-quick save wg0
  systemctl restart wg-quick@wg0

  echo "Servidor WireGuard reiniciado com sucesso."
}

# Função principal
main() {
  CLIENT_NAME=$1
  CLIENT_PUBLIC_KEY=$2
  CLIENT_IP=$3

  # Adicionar cliente ao servidor
  add_client_to_server $CLIENT_NAME $CLIENT_PUBLIC_KEY $CLIENT_IP

  echo "Cliente $CLIENT_NAME configurado no servidor."
}

# Verificar parâmetros
if [ "$#" -ne 3 ]; então
  echo "Uso: $0 <NOME_CLIENTE> <CHAVE_PUBLICA_CLIENTE> <IP_CLIENTE>"
  exit 1
fi

# Executar função principal com parâmetros fornecidos
main "$1" "$2" "$3"
