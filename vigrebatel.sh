#!/bin/bash

if [ -e /home/$USER/gomer_rabbit ]; then
	if [ -e /home/$USER/gomer_rabbit/.git ]; then
		echo "Подпуливаю изменения..."
		cd /home/$USER/gomer_rabbit && git pull https://github.com/maxnacho/gomer_rabbit
	else 
		echo "Отсутствует директория .git."
 		echo "Удаляю директорию /home/$USER/gomer_rabbit, используемую для репозитория."
 		rm -rf /home/$USER/gomer_rabbit/
 		echo "Отсутствует директория .git. Клоню репозиторий..."
		cd && git clone -b master https://github.com/maxnacho/gomer_rabbit
	fi
else
	echo -e "Привет! Вижу, ты сильно обозлён на \033[0m\n\033[0m\033[31msupervisor...\033[0m Лыжню! (ง ͠° ͟ل͜ ͡°)ง"
	echo "Распаковываю сумки..."
	echo
	cd && git clone -b master https://github.com/maxnacho/gomer_rabbit
	echo "Ну чё, я уже чувствую себя как дома. Поехали!"
	echo
	echo " ̿̿ ̿̿ ̿'̿'\̵͇̿̿\з= (▀ ͜͞ʖ▀) =ε/̵͇̿̿/'̿'̿ ̿ ̿̿ ̿̿ ̿̿" 
	echo
	echo "======================================================================"
fi

declare -A crons
while IFS="=" read -r key value
do
    crons[$key]="$value"
done < <(jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]' /home/$USER/gomer_rabbit/rabbit.json)

vigrebatel() {
	querylist=$(docker exec -it rabbit-mq bash -c "rabbitmqctl list_queues name messages_ready" | grep -v 'Timeout: 60.0 seconds ...' | grep -v 'Listing queues for vhost / ...' | grep -v 'uploader_move_price_to_storage' | grep -v 'lisa_sendMailNotifications' | grep [1-9])
	if [ -n "$querylist" ]; then 
		for query in $(echo "$querylist" | cut -f 1)
		do
			for key in "${!crons[@]}"
		  	do
			  	if [[ "$query" == "$key" ]]; then
			  		echo
			  		echo -ne "Дёргаем \033[1m$query\033[1m:"
			  		echo
			  		docker exec -it php-fpm bash -c "php /var/www/gomer.local/www/yii ${crons[$key]}"
			  	fi
		  	done
		done
		vigrebatel
	else 
		echo
		echo "Всё выгреблось, закругляюсь..."
	fi	
}

echo
echo "Я пришёл сюда щёлкать семки и выгребать очереди. Семки я уже дощёлкал."
vigrebatel

