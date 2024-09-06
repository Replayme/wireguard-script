#!/bin/bash

# Função para gerar chaves WireGuard
generate_keys() {
  CLIENT_NAME=$1
  wg genkey | tee /etc/wireguard/clients/$CLIENT_NAME/privatekey | wg pubkey > /etc/wireguard/clients/$CLIENT_NAME/publickey
  PRIVATE_KEY=$(cat /etc/wireguard/clients/$CLIENT_NAME/privatekey)
  PUBLIC_KEY=$(cat /etc/wireguard/clients/$CLIENT_NAME/publickey)

  echo "Chaves geradas para o cliente $CLIENT_NAME"
  echo "Chave privada: $PRIVATE_KEY"
  echo "Chave pública: $PUBLIC_KEY"
}

# Função para gerar a configuração do cliente
generate_client_config() {
  CLIENT_NAME=$1
  CLIENT_PRIVATE_KEY=$2
  SERVER_IP=$3
  SERVER_PORT=$4
  SERVER_PUBLIC_KEY=$5
  CLIENT_IP=$6

  # Criar diretório do cliente
  mkdir -p /etc/wireguard/clients/$CLIENT_NAME

  # Gerar arquivo de configuração do cliente
  cat <<EOF > /etc/wireguard/clients/$CLIENT_NAME/$CLIENT_NAME.conf
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

  echo "Arquivo de configuração do cliente $CLIENT_NAME gerado em /etc/wireguard/clients/$CLIENT_NAME/$CLIENT_NAME.conf"
}

# Instalar WireGuard, se necessário
install_wireguard() {
  apt update
  apt install -y wireguard
}

# Função principal
main() {
  CLIENT_NAME=$1
  SERVER_IP=$2
  SERVER_PORT=$3
  SERVER_PUBLIC_KEY=$4
  CLIENT_IP=$5

  # Instalar WireGuard, se necessário
  install_wireguard

  # Gerar chaves para o cliente
  generate_keys $CLIENT_NAME

  CLIENT_PRIVATE_KEY=$(cat /etc/wireguard/clients/$CLIENT_NAME/privatekey)

  # Gerar a configuração do cliente
  generate_client_config $CLIENT_NAME $CLIENT_PRIVATE_KEY $SERVER_IP $SERVER_PORT $SERVER_PUBLIC_KEY $CLIENT_IP

  echo "Cliente $CLIENT_NAME configurado com sucesso!"
}

# Verificar argumentos
if [ "$#" -ne 5 ]; then
  echo "Uso: $0 <NOME_CLIENTE> <IP_SERVIDOR> <PORTA_SERVIDOR> <CHAVE_PUBLICA_SERVIDOR> <IP_CLIENTE>"
  exit 1
fi

# Executar função principal com parâmetros
main "$1" "$2" "$3" "$4" "$5"
