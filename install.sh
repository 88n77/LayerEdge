#!/bin/bash

green='\033[0;32m'
yellow='\033[0;33m'
nc='\033[0m'

echo -e "${yellow}Встановлюємо оновлення та залежності...${nc}"

sudo apt update && sudo apt-get upgrade -y

git clone https://github.com/Layer-Edge/light-node.git
cd light-node

LATEST_GO_VERSION="1.23.1"

if ! command -v go &> /dev/null; then
    echo -e "${yellow}Go встановився. Встановлюємо потрібну версію $LATEST_GO_VERSION...${nc}"
else
    INSTALLED_GO_VERSION=$(go version | awk '{print $3}' | cut -d'o' -f2)
    if [[ "$INSTALLED_GO_VERSION" == "$LATEST_GO_VERSION" ]]; then
        echo -e "${green}Go актуальні версії $INSTALLED_GO_VERSION.${nc}"
    else
        echo -e "${yellow}Оновлення Go до версії $LATEST_GO_VERSION...${nc}"
    fi
fi

wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
rm "go$VER.linux-amd64.tar.gz"
[ ! -f ~/.bash_profile ] && touch ~/.bash_profile
 echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
source $HOME/.bash_profile
[ ! -d ~/go/bin ] && mkdir -p ~/go/bin


INSTALLED_GO_VERSION=$(go version | awk '{print $3}' | cut -d'o' -f2)
if [[ "$INSTALLED_GO_VERSION" == "$LATEST_GO_VERSION" ]]; then
    echo -e "${green}Go усіпшно встановлено $INSTALLED_GO_VERSION.${nc}"
else
    echo -e "${red}Помилка: Go не оновлений! Версія: $INSTALLED_GO_VERSION.${nc}"
    exit 1
fi

if ! command -v rustc &> /dev/null; then
    echo -e "${yellow}Встановлення Rust через rustup...${nc}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
    echo -e "${green}Rust успішно${nc}"
else
    echo -e "${yellow}Rust оновлення${nc}"
    rustup update
    source $HOME/.cargo/env
    echo -e "${green}Rust успішно оновлений...${nc}"
fi

curl -L https://risczero.com/install | bash
source "$HOME/.bashrc"
sleep 5
rzup install

echo -e "${yellow}Ваш приватний ключ від гаманця:${nc} "
read PRIV_KEY

cat <<EOF > .env
echo "GRPC_URL=grpc.testnet.layeredge.io:9090" > .env
echo "CONTRACT_ADDR=cosmos1ufs3tlq4umljk0qfe8k5ya0x6hpavn897u2cnf9k0en9jr7qarqqt56709" >> .env
echo "ZK_PROVER_URL=http://127.0.0.1:3001" >> .env
echo "ZK_PROVER_URL=https://layeredge.mintair.xyz/" >> .env
echo "API_REQUEST_TIMEOUT=100" >> .env
echo "POINTS_API=https://light-node.layeredge.io" >> .env
echo "PRIVATE_KEY='$PRIV_KEY'" >> .env
cd

sleep 1

echo -e "${yellow}install rzup...${nc}"

source "$HOME/.bashrc"
rzup install

rzup --version

sleep 3

echo -e "${yellow}Запуск сервіса Merkle...${nc}"

sudo apt update
sudo apt install -y build-essential


USERNAME=$(whoami)
HOME_DIR=$(eval echo ~$USERNAME)

sudo bash -c "cat <<EOT > /etc/systemd/system/merkle.service
[Unit]
Description=Merkle Service for Light Node
After=network.target

[Service]
User=$USERNAME
Environment=PATH=$HOME/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
WorkingDirectory=$HOME_DIR/light-node/risc0-merkle-service
ExecStart=/usr/bin/env bash -c \"cargo build && cargo run --release\"
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOT"

sudo systemctl daemon-reload
sleep 2
sudo systemctl enable merkle.service
sudo systemctl start merkle.service

sudo journalctl -u merkle.service -f

