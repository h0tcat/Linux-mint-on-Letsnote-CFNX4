##########
# Japanese Localization
##########
# Install fonts
sudo apt install -y fonts-migmix fonts-ipamj-mincho fonts-horai-umefont fonts-takao xfonts-mona fonts-kouzan-mouhitsu

# デフォルトのIMEをfcitxに変更
im-config -n fcitx

# Change Home Dir name
LANG=C xdg-user-dirs-gtk-update

# Add non-free repository
apt-add-repository non-free && sudo apt update
echo -e "deb http://ftp.jp.debian.org/debian/ bullseye main contrib non-free" >> /etc/apt/source.list
echo -e "deb-src http://ftp.jp.debian.org/debian/ bullseye main contrib non-free" >> /etc/apt/source.list


##########
# Application Install
##########
# Google Chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
sudo apt update && sudo apt install -y google-chrome-stable

# Atom Editor
wget -qO - https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list'
sudo apt update && sudo apt install -y atom

# Github Desktop
cd ~/Downloads
wget https://github.com/shiftkey/desktop/releases/download/release-2.5.3-linux1/GitHubDesktop-linux-2.5.3-linux1.deb
sudo dpkg -i ./GitHubDesktop*.deb
sudo apt-get --fix-broken install -y

# slack
wget "https://downloads.slack-edge.com/linux_releases/slack-desktop-4.4.3-amd64.deb" && sudo dpkg -i ./slack-desktop-4.4.3-amd64.deb && rm slack-desktop-4.4.3-amd64.deb

# TLP
sudo apt install -y tlp tlp-rdw

# Google Drive

# Poewrtop
sudo apt install powertop

# hardinfo
sudo apt install -y hardinfo

# iptables
sudo apt install -y iptables-persistent

# VirtualBox
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
echo "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian bionic contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
sudo apt update && sudo apt install -y virtualbox-6.0

##########
# Snap
##########
sudo apt install snapd

# KeePassXC
sudo snap install keepassxc


##########
#
##########
#google-drive-ocamlfuse
# Make dirctory
mkdir ~/GooglDrive
# Mount Google Drive
echo -e "# Mount Google Drive to HOME directory.\ngoogle-drive-ocamlfuse ~/GoogleDrive" >> ~/.profile

##########
# Python Environment
##########
# python3
sudo apt install python3 python3-pip

# Pythonモジュール
pip3 install requests

##########
# After cleaning
##########
# 不要パッケージの削除
sudo apt autoremove && sudo apt autoclean

##########
# SSH config
##########
# ssh公開鍵を生成
mkdir ~/.ssh
ssh-keygen -t rsa
