pass_encript=wtf
encript () {
    res_encripted=`echo $1 | openssl enc -aes-128-cbc -a -salt -pass pass:$pass_encript`
}

decript () {
    res_decripted=`echo $1 | openssl enc -aes-128-cbc -a -d -salt -pass pass:$pass_encript`
}

res=""
read_file_by_line () {
    local user=""
    local psd=""
    local ctg=""
    local note=""
    # extract the info
    while IFS= read -r line;
    do
		decript $line
        if [[ $res_decripted == user:* ]]; then
            local user=${res_decripted#"user:"}
			if [ ${#user} -eq 0 ]; then
				local user="/"
			fi
        fi
        if [[ $res_decripted == password:* ]]; then
            local psd=${res_decripted#"password:"}
        fi
        if [[ $res_decripted == category:* ]]; then
            local ctg=${res_decripted#"category:"}
			if [ ${#ctg} -eq 0 ]; then
				local ctg="/"
			fi
        fi
        if [[ $res_decripted == note:* ]]; then
            local note=${res_decripted#"note:"}
			if [ ${#note} -eq 0 ]; then
				local note="/"
			fi
        fi
    done < $1
	if [ ${#res} -eq 0 ]; then
        res=False" "$2" "$ctg" "$psd
    else
        res=$res" "False" "$2" "$ctg" "$psd
	echo "$1 False $2 $ctg $psd"
    fi
}

# scan the files, extract the info to be displayed in the main page 
read_content () {
    Username=$1
    for file in `ls .$Username/.*.txt`
    do
    item=${file#".$Username/."}
    item=${item%".txt"}
	if [ $item != "account" ]; then
    	read_file_by_line .$Username/.$item.txt $item
	fi
    done
}

# scan the existing items, extract the unique category set
get_uniq_category () {
	category_list=()
	Username=$1
    for file in `ls .$Username/.*.txt`
    do  
    item=${file#".$Username/."}
    item=${item%".txt"}
    if [ $item != "account" ]; then
		while IFS= read -r line;
    	do
		decript $line
        if [[ $res_decripted == category:* ]]; then
            local ctg=${res_decripted#"category:"}
			category_list+=($ctg)
			#echo $item $category_list
        fi
    	done < .$Username/.$item.txt
    fi  
    done	
	uniq_ctg=`echo "${category_list[@]}" | tr ' ' '\n' | sort -u | tr '\n' '|'`
}

Username_login=$1	# without "." at front
close=1
read_content $Username_login
while [ $close -ne 0 ]
do
var=$(yad \
	--title="keeweb management" \
	--text="welcome! You can manage your password here" \
	--width="200" --height="400" \
	--list --radiolist  \
	--column="select" --column="item" --column="category" --column="password" $res \
	--button="search name:5" \
	--button="detail:6" \
	--button="search category:1" \
    --button="modify:2" \
    --button="new:3" \
    --button="delete:4"
)
choice=$?
item_choice=`echo $var | cut -d\| -f2`
#select_choice=`echo $var | cut -d\| -f1`
#echo $select_choice
#echo $choice
#echo $Username_login
#echo $var
#echo $item_choice

# cancel
if [ $choice -eq 252 ]; then
	break 
# new
elif [ $choice -eq 3 ]; then
	bash page_new.sh .$Username_login # with "." at front
	res=""
	read_content $Username_login
# delete
elif [ $choice -eq 4 ]; then
	# # if you don't choice any radiobutton
	if [ ${#var} -eq 0 ]; then
		yad - notification \
        --title="Ops!" \
        --text="please choose an item to delete!" \
        --image="./images/tiny error.png" \
		--width="400" --height="50"	
	else
		yad - notification \
      		--title="notification" \
        	--text="are you sure about deleting $item_choice ?" \
			--image="./images/question_tiny.png" \
        	--width="400" --height="50"
		# OK
		if [ $? -eq 0 ]; then
			rm .$Username_login/.$item_choice.txt
			res=""
    		read_content $Username_login
		# cancel
		else
			:
		fi
	fi

# search by category
elif [ $choice -eq 1 ]; then
	get_uniq_category $Username_login
	replace="\!"
	#echo uniq_ctg: $uniq_ctg
	ctg_droplist="${uniq_ctg//|/$replace}"
	#echo ctg_droplist: $ctg_droplist
	sea_info=$(yad --form \
        --title="search your items by category" \
        --width="350" --height="50" \
        --field="category":CB \
		--button="show all:2" \
        --button="OK:0" \
        --button="cancel:1" \
        $ctg_droplist)
	choice_sea_button=$?
	sea_info=${sea_info%"|"}
	# OK
	if [ $choice_sea_button -eq 0 ]; then
		res=""
        for file in `ls .$Username_login/.*.txt`
        do
        item=${file#".$Username/."}
        item=${item%".txt"}
		if [ $item != "account" ]; then
        	while IFS= read -r line;
        	do
			decript $line
        	if [[ $res_decripted == category:* ]]; then
            	ctg_this=${res_decripted#"category:"}
				if [ $ctg_this == $sea_info ]; then
					read_file_by_line .$Username_login/.$item.txt $item
       			fi
			fi
        	done < .$Username/.$item.txt
    	fi
        done
	# show all items
	elif [ $choice_sea_button -eq 2 ]; then
		res=""
		read_content $Username_login
	fi

# search by names
elif [ $choice -eq 5 ]; then
	sea_info=$(yad --form \
        --title="search your items by names" \
        --width="200" --height="50" \
        --field="enter title" \
		--button="show all:2" \
        --button="OK:0" \
        --button="cancel:1")
	choice_sea_button=$?
	sea_info=${sea_info%"|"}
	# OK
	if [ $choice_sea_button -eq 0 ]; then
		res=""
		for file in `ls .$Username_login/.*.txt`
    	do  
    	item=${file#".$Username/."}
    	item=${item%".txt"}
    	if [ $item == "account" ]; then
    		continue
		fi
		if [[ $item == *$sea_info* ]]; then
			read_file_by_line .$Username_login/.$item.txt $item
		fi  
    	done
	# show all items
	elif [ $choice_sea_button -eq 2 ]; then
		res=""
		read_content $Username_login
	fi
# modify
elif [ $choice -eq 2 ]; then
	# if you don't choice any radiobutton
    if [ ${#var} -eq 0 ]; then
        yad - notification \
        --title="Ops!" \
        --text="please choose an item to modify!" \
		--image="./images/tiny error.png" \
        --width="400" --height="50"
	else
		modify_succ=1
		while IFS= read -r line;
        do
			decript $line
            if [[ $res_decripted == user:* ]]; then
                modify_user=${res_decripted#"user:"}
				if [ ${#modify_user} -eq 0 ]; then
					modify_user="/"
				fi
            fi
            if [[ $res_decripted == password:* ]]; then
                modify_psd=${res_decripted#"password:"}
            fi
            if [[ $res_decripted == category:* ]]; then
                modify_ctg=${res_decripted#"category:"}
                if [ ${#modify_ctg} -eq 0 ]; then
                    modify_ctg="/"
                fi
            fi
            if [[ $res_decripted == note:* ]]; then
                modify_note=${res_decripted#"note:"}
				if [ ${#modify_note} -eq 0 ]; then
                    modify_note="/"
                fi
            fi
        done < .$Username_login/.$item_choice.txt
		
		# if modification is illegal, then keep trying
		while [ $modify_succ -ne 0 ]
		do
        modify_info=$(yad --form \
        --title="modify information" \
        --width="400" --height="400" \
        --field="title" \
		--field="user" \
		--field="password" \
		--field="category" \
		--field="note" \
		--button="OK:0" \
	    --button="cancel:1" \
		$item_choice $modify_user $modify_psd $modify_ctg $modify_note)
		choice_button_modify=$?
		modified_title=`echo $modify_info | cut -d\| -f1`
		modified_user=`echo $modify_info | cut -d\| -f2`
		modified_psd=`echo $modify_info | cut -d\| -f3`
		modified_ctg=`echo $modify_info | cut -d\| -f4`
		modified_note=`echo $modify_info | cut -d\| -f5`
		#echo title: $modified_title user: $modified_user psd: $modified_psd ctg: $modified_ctg note: $modified_note
		# OK
        if [ $choice_button_modify -eq 0 ]; then
			# check if modification is legal
			if [ ${#modified_title} -eq 0 ]; then
        		yad - notification \
            	--title="Ops!" \
            	--text="please name a title!" \
				--image="./images/tiny error.png" \
            	--width="200" --height="50"
    		elif [ ${#modified_psd} -eq 0 ]; then
        		yad - notification \
            	--title="Ops!" \
            	--text="your password is empty" \
				--image="./images/tiny error.png" \
            	--width="200" --height="50"
    		# succeed, write file
    		else
				modified_file=.$Username_login/.$modified_title.txt
				rm .$Username_login/.$item_choice.txt 
				encript "user:$modified_user"
				echo $res_encripted > $modified_file
				encript "password:$modified_psd"
				echo $res_encripted >> $modified_file
				encript "category:$modified_ctg"
				echo $res_encripted >> $modified_file
				encript "note:$modified_note"
				echo $res_encripted >> $modified_file				

				#echo "user:$modified_user" > $modified_file
        		#echo "password:$modified_psd" >> $modified_file
        		#echo "category:$modified_ctg" >> $modified_file
        		#echo "note:$modified_note" >> $modified_file
            	res=""
            	read_content $Username_login
				modify_succ=0
			fi
        # cancel
        else
            break
        fi
		done

	fi
# detail
elif [ $choice -eq 6 ]; then
	# if you don't choice any radiobutton
	if [ ${#var} -eq 0 ]; then
		yad --form \
    	--title="detail information" \
    	--width="400" --height="400" \
    	--field="title":RO \
    	--field="user":RO \
    	--field="password":RO \
    	--field="category":RO \
    	--field="note":RO
	else	
		while IFS= read -r line;
    	do
			decript $line
        	if [[ $res_decripted == user:* ]]; then
            	detail_user=${res_decripted#"user:"}
                if [ ${#detail_user} -eq 0 ]; then
                    detail_user="/"
				fi
        	fi
        	if [[ $res_decripted == password:* ]]; then
            	detail_psd=${res_decripted#"password:"}
        	fi
        	if [[ $res_decripted == category:* ]]; then
            	detail_ctg=${res_decripted#"category:"}
				if [ ${#detail_ctg} -eq 0 ]; then
					detail_ctg="/"
				fi
        	fi
        	if [[ $res_decripted == note:* ]]; then
            	detail_note=${res_decripted#"note:"}
				if [ ${#detail_note} -eq 0 ]; then
					detail_note="/"
				fi
        	fi
    	done < .$Username_login/.$item_choice.txt
		yad --form \
    	--title="detail information" \
    	--width="400" --height="400" \
    	--field="title":RO $item_choice \
		--field="user":RO $detail_user \
		--field="password":RO $detail_psd \
		--field="category":RO $detail_ctg \
		--field="note":RO $detail_note
	fi
fi
done

