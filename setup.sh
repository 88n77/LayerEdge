#!/bin/bash

green='\033[0;32m'
nc='\033[0m'

wget https://raw.githubusercontent.com/88n77/Logo-88n77/main/logo.sh
chmod +x logo.sh
./logo.sh

setup_url="https://raw.githubusercontent.com/88n77/LayerEdge/main/install.sh"
start_url="https://raw.githubusercontent.com/88n77/LayerEdge/main/start.sh"
update_url=""
delete_url="https://raw.githubusercontent.com/88n77/LayerEdge/main/delet.sh"

menu_options=("Встановити" "Запустити ноду" "Оновити" "Видалити" "Вийти")
PS3='Оберіть дію: '

select choice in "${menu_options[@]}"
do
    case $choice in
        "Встановити")
            echo -e "${green}Встановлення...${nc}"
            bash <(curl -s $setup_url)
            ;;
        "Запустити ноду")
            echo -e "${green}Запуск ноди...${nc}"
            bash <(curl -s $start_url)
            ;;
        "Оновити")
            echo -e "${green}Оновлення...${nc}"
            bash <(curl -s $update_url)
            ;;
        "Видалити")
            echo -e "${green}Видалення...${nc}"
            bash <(curl -s $delete_url)
            ;;
        "Вийти")
            echo -e "${green}Вихід...${nc}"
            break
            ;;
        *)
            echo "Невірний вибір!"
            ;;
    esac
done
