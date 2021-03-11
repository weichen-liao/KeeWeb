# KeeWeb

### What is this?
this is a KeeWeb application developed on pure **bash** script, as the final project of Unix class.
KeeWeb is a desktop password management solution, you can google it to know about the official software.
I do this project to realize the main functions of the application.

The basic funtionalities include: register, login, new item, view detail, search by name/category, modidy item, delete item.

for more infomation, try my youtube video: https://www.youtube.com/watch?v=kyyQtX5zXj8&t=671s

### Requirement:
Better run it under linux system, you need to install yad in advance: sudo apt-get install -y yad

### How to run:
run the application by entering command: bash page_login.sh

### Detials
The login page:
![tubes](https://github.com/weichen-liao/KeeWeb/blob/main/login.jpeg)

The main page:
![tubes](https://github.com/weichen-liao/KeeWeb/blob/main/mainpage.jpeg)

Detail info:
![tubes](https://github.com/weichen-liao/KeeWeb/blob/main/detail.jpeg)

The app also consider data security. The user data is stored as hiden folder in the local system:
![tubes](https://github.com/weichen-liao/KeeWeb/blob/main/account.jpeg)

Each file represents an item, it includes the key infomation: name, password, type, detail. However, they are encrypted with sha256, thus cannot be easily read like this.
![tubes](https://github.com/weichen-liao/KeeWeb/blob/main/savedfile.jpeg)
