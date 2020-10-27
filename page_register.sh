pass_encript=wtf
encript () {
    res_encripted=`echo $1 | openssl enc -aes-128-cbc -a -salt -pass pass:$pass_encript`
}

decript () {
    res_decripted=`echo $1 | openssl enc -aes-128-cbc -a -d -salt -pass pass:$pass_encript`
}

regis_succ=1
while [ $regis_succ -ne 0 ]
do
choice_regis=$(yad --form \
             --title="Keeweb for bash" \
             --text="Please enter your info" \
             --field="Username" \
             --field="Password":H \
             --field="Password confirm":H \
             --button="register:0" \
			 --button="cancel:1")
choice_button=$?
Username_regis=`echo $choice_regis | cut -d\| -f1`
Pass_regis=`echo $choice_regis | cut -d\| -f2`
PassCon_regis=`echo $choice_regis | cut -d\| -f3`
#echo Username_regis: $Username_regis Pass_regis: $Pass_regis PassCon_regis $PassCon_regis

# cancel
if [ $choice_button -eq 1 ] || [ $choice_button -eq 252 ]; then
	break
fi

# check if the username is legal
if test -d $Username_regis; then
	yad - notification \
		--title="Ops!" \
		--text="the username is occupied, choose another one" \
		--image="./images/tiny error.png" \
		--width="600" --height="50"
elif [ ${#Username_regis} -lt 3 ]; then
	yad - notification \
        --title="Ops!" \
        --text="the username is too short, choose another one" \	
		--image="./images/tiny error.png" \
		--width="600" --height="50"
else
	# check if the password is legal
	if [ $Pass_regis != $PassCon_regis ]; then
		yad - notification \
            --title="Ops!" \
            --text="your password is inconsistent" \
			--image="./images/tiny error.png" \
			--width="600" --height="50"
	elif [ ${#Pass_regis} -lt 3 ]; then
		yad - notification \
        	--title="Ops!" \
        	--text="your password is too simple, choose another one" \
			--image="./images/tiny error.png" \
			--width="600" --height="50"
	else
		mkdir .$Username_regis
		encript "Username:$Username_regis"
		echo $res_encripted >> .$Username_regis/.account.txt 
		encript "Password:$Pass_regis"
		echo $res_encripted >> .$Username_regis/.account.txt
		#echo "Username:$Username_regis" >> .$Username_regis/.account.txt
		#echo "Password:$Pass_regis" >> .$Username_regis/.account.txt
    	yad - notification \
			--title="Congratulations!" \
			--text="your account $Username_regis is created" \
			--image="./images/hook_tiny.png" \
			--width="600" --height="50"
			#--image="./images/congratulations.png" \
		regis_succ=0
	fi
fi
done






