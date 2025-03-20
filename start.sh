green='\033[0;32m'
yellow='\033[0;33m'
nc='\033[0m'

echo -e "${green}Запускаємо ноду...${nc}"
USERNAME=$(whoami)
HOME_DIR=$(eval echo ~$USERNAME)

GO_PATH=$(which go)

if [ -z "$GO_PATH" ]; then
    echo "Go не знайдено в PATH. Перевірте версію Go."
    exit 1
fi

sudo bash -c "cat <<EOT > /etc/systemd/system/light-node.service
[Unit]
Description=LayerEdge Light Node Service
After=network.target

[Service]
User=$USERNAME
WorkingDirectory=$HOME_DIR/light-node
ExecStartPre=$GO_PATH build
ExecStart=$HOME_DIR/light-node/light-node
Restart=always
RestartSec=10
TimeoutStartSec=200

[Install]
WantedBy=multi-user.target
EOT"

sudo systemctl daemon-reload
sleep 2
sudo systemctl enable light-node.service
sudo systemctl start light-node.service

echo -e "${yellow}-----------------------------------------------------------------------${nc}"
echo -e "${yellow}Команда для перевірки логів:${nc}"
echo "sudo journalctl -u light-node.service -f"
echo -e "${yellow}-----------------------------------------------------------------------${nc}"
sudo journalctl -u light-node.service -f
