#!/bin/bash

# Função para gerar chaves WireGuard
generate_keys() {
  # Criar diretório do cliente, caso não exista
  mkdir -p /etc/wireguard/keys

  # Gerar as chaves
  wg genkey | tee /etc/wireguard/keys/privatekey | wg pubkey > /etc/wireguard/keys/publickey
  PRIVATE_KEY=$(cat /etc/wireguard/keys/privatekey)
  PUBLIC_KEY=$(cat /etc/wireguard/keys/publickey)

  echo "Chaves geradas para o cliente único"
  echo "Chave privada: $PRIVATE_KEY"
  echo "Chave pública: $PUBLIC_KEY"
}

# Função para gerar a configuração do cliente
generate_client_config() {
  CLIENT_PRIVATE_KEY=$1
  SERVER_IP=$2
  SERVER_PORT=$3
  SERVER_PUBLIC_KEY=$4
  CLIENT_IP=$5

  mkdir -p /etc/wireguard

  # Gerar arquivo de configuração do cliente
  cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
PrivateKey = $CLIENT_PRIVATE_KEY
Address = $CLIENT_IP/24
DNS = 8.8.8.8

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $SERVER_IP:$SERVER_PORT
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 21
EOF

  echo "Arquivo de configuração do cliente gerado em /etc/wireguard/wg0.conf"
}

# Instalar WireGuard, se necessário
install_wireguard() {
  apt update
  apt install -y wireguard
}

# Função principal
main() {
  SERVER_IP=$1
  SERVER_PORT=$2
  SERVER_PUBLIC_KEY=$3
  CLIENT_IP=$4

  # Instalar WireGuard, se necessário
  install_wireguard

  # Gerar chaves para o cliente
  generate_keys

  CLIENT_PRIVATE_KEY=$(cat /etc/wireguard/keys/privatekey)

  # Gerar a configuração do cliente
  generate_client_config $CLIENT_PRIVATE_KEY $SERVER_IP $SERVER_PORT $SERVER_PUBLIC_KEY $CLIENT_IP

  echo "Cliente configurado com sucesso!"
}

# Verificar argumentos
if [ "$#" -ne 4 ]; then
  echo "Uso: $0 <IP_SERVIDOR> <PORTA_SERVIDOR> <CHAVE_PUBLICA_SERVIDOR> <IP_CLIENTE>"
  exit 1
fi

# Executar função principal com parâmetros
main "$1" "$2" "$3" "$4"
