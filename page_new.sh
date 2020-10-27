pass_encript=wtf
encript () {
    res_encripted=`echo $1 | openssl enc -aes-128-cbc -a -salt -pass pass:$pass_encript`
}

decript () {
    res_decripted=`echo $1 | openssl enc -aes-128-cbc -a -d -salt -pass pass:$pass_encript`
}

close=1
Username=$1		#has "." in the head
while [ $close -ne 0 ]
do
var=$(yad --form \
	--title="New Entity" \
	--width="400" --height="400" \
	--field="Please enter the infomation":LBL \
	--field="title":CE \
	--field="user":CE \
	--field="password":CE \
	--field="category":CBE \
	--field="note":TXT \
)
choice_bu=$?
#echo $choice_bu
#echo "$var"
title=`echo $var | cut -d\| -f2`
user=`echo $var | cut -d\| -f3`
psd=`echo $var | cut -d\| -f4`
ctg=`echo $var | cut -d\| -f5`
note=`echo $var | cut -d\| -f6`
if [ ${#user} -eq 0 ]; then
	user="/"
fi
if [ ${#ctg} -eq 0 ]; then
	ctg="/"
fi
if [ ${#note} -eq 0 ]; then
	note="/"
fi
#echo title: $title user: $user psd: $psd ctg: $ctg note: $note
file=$Username/.$title.txt
#echo $file

# cancel
if [ $choice_bu -eq 1 ] || [ $choice_bu -eq 252 ]; then
	break
# OK
else 
	if [ ${#title} -eq 0 ]; then
		yad - notification \
	        --title="Ops!" \
	        --text="please name a title!" \
			--image="./images/tiny error.png" \
	        --width="200" --height="50"
	elif test -f $file; then
		yad - notification \
            --title="Ops!" \
            --text="this title is already used" \
			--image="./images/tiny error.png" \
            --width="200" --height="50"
	elif [ ${#psd} -eq 0 ]; then
        yad - notification \
            --title="Ops!" \
            --text="your password is empty" \
			--image="./images/tiny error.png" \
            --width="200" --height="50"
	# succeed, write file
	else
		touch $file
		encript "user:$user"
		echo $res_encripted >> $file
		encript "password:$psd"
        echo $res_encripted >> $file
		encript "category:$ctg"
        echo $res_encripted >> $file
		encript "note:$note"
        echo $res_encripted >> $file

		#echo "user:$user" >> $file
		#echo "password:$psd" >> $file
		#echo "category:$ctg" >> $file
		#echo "note:$note" >> $file
		close=0
	fi
	
fi
done


