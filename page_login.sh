pass_encript=wtf
encript () {
    res_encripted=`echo $1 | openssl enc -aes-128-cbc -a -salt -pass pass:$pass_encript`
}

decript () {
    res_decripted=`echo $1 | openssl enc -aes-128-cbc -a -d -salt -pass pass:$pass_encript`
}


read_account () {
    while read line;
    do
	decript $line
	#echo res_decripted: $res_decripted
    if [[ $res_decripted == Username:* ]]; then
        Usn_input=`echo $res_decripted | cut -d: -f2`
    fi
    if [[ $res_decripted == Password:* ]]; then
        Psd_input=`echo $res_decripted | cut -d: -f2`
    fi  
    #if [ ${#Usn_input} -gt 0 ] && [ ${#Psd} -gt 0 ]; then
    #   break
    #fi 
    done < $1/.account.txt
    #echo Usn_input:$Usn_input Psd_input:$Psd_input
}



login_succ=1
while [ $login_succ -ne 0 ]
do
input_login=$(yad --form \
    --title="Keeweb for bash" \
	--width="200" --height="200" \
	--image="./images/keeweb_icon.png" \
    --text='Welcome to Keeweb' \
    --field="Username" \
    --field="Password":H \
	--field="developed by Weichen":LBL \
    --button="register:1" \
    --button="sign in:2" \
    --button="cancel:3" \
	--buttons-layout=center)

choice_login=$?
Username_login=`echo $input_login | cut -d\| -f1`
Pass_login=`echo $input_login | cut -d\| -f2`
#echo Username_login: $Username_login Pass_login: $Pass_login

# cancel
if [ $choice_login -eq 3 ] || [ $choice_login -eq 252 ]; then
	break
# register
elif [ $choice_login -eq 1 ]; then
	bash page_register.sh
# sign in
else
	# username not exist
	if [ ! -d .$Username_login ] || [ ${#Username_login} -eq 0 ]; then
		yad - notification \
        --title="Ops!" \
        --text="your username doesn't exist, register one first" \
		--image="./images/tiny error.png" \
		--width="600" --height="50" 
	else
		read_account .$Username_login
		# password wrong
		if [ $Pass_login != $Psd_input ]; then
			yad - notification \
        	--title="Ops!" \
        	--text="either your username or password is wrong" \
			--image="./images/tiny error.png" \
			--width="600" --height="50"
		# enter the password management interface
		else
			login_succ=0
			bash page_main.sh $Username_login # without "." at front
		fi
	fi
fi

done
