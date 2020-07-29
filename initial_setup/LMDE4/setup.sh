##########
# Initial Setup for LMDE4 on CF-NX4
##########

##########
# レポジトリ変更&追加
##########
# 日本のレポジトリに変更

# non-freeレポジトリを追加
apt-add-repository non-free && sudo apt update

# TEST版（bullseye）を追加
#echo -e "deb http://ftp.jp.debian.org/debian/ bullseye main contrib non-free" >> /etc/apt/source.list
#echo -e "deb-src http://ftp.jp.debian.org/debian/ bullseye main contrib non-free" >> /etc/apt/source.list

##########
# 日本語化
##########
# 日本語化パッケージ
sudo apt install -y language-pack-ja language-pack-gnome-ja fonts-takao-gothic fonts-takao-mincho fonts-takao-pgothic fonts-vlgothic fonts-ipafont-gothic fonts-ipafont-mincho libreoffice-l10n-ja libreoffice-help-ja firefox-locale-ja manpages-ja thunderbird-locale-ja ibus-mozc ibus-anthy kasumi ibus-gtk ibus-gtk3 poppler-data cmap-adobe-japan1 fcitx-mozc fcitx-anthy fcitx-frontend-qt5 fcitx-config-gtk fcitx-config-gtk2 fcitx-frontend-gtk2 fcitx-frontend-gtk3 mozc-utils-gui fcitx-frontend-qt4 fcitx-frontend-qt5 libfcitx-qt0 libfcitx-qt5-1
sudo apt install -y fonts-migmix fonts-ipamj-mincho fonts-horai-umefont fonts-takao xfonts-mona fonts-kouzan-mouhitsu


# Install fonts
sudo apt install -y fonts-migmix fonts-ipamj-mincho fonts-horai-umefont fonts-takao xfonts-mona fonts-kouzan-mouhitsu

# デフォルトのIMEをfcitxに変更
im-config -n fcitx

# HOMEディレクトリを英語表記に変更
LANG=C xdg-user-dirs-gtk-update

# Synaptics Driver
sudo apt install -y xserver-xorg-input-synaptics

# xinput設定（トラックパッドの感度を下げる）
echo "# Touchpad Speed Configuration" | tee -a ~/.xinputrc
echo $(xinput --set-prop $(echo $(xinput --list --short | grep -i touchpad) | sed -e 's/.\+id=\([0-9]\+\).\+$/\1/g') $(xinput ---list-props $(echo $(xinput --list --short | grep -i touchpad) | sed -e 's/.\+id=\([0-9]\+\).\+$/\1/g') | grep Constant | sed -e 's/.\+(\([0-9]\+\)).\+/\1/g') 7.5) | tee -a ~/.xinputrc

# CircularScrollingを有効化
cp /usr/share/X11/xorg.conf.d/51-synaptics-quirks.conf ~/51-synaptics-quirks.conf.bk
sudo echo -e "Section \"InputClass\"\n                Identifier \"touchpad catchall\"\n        Driver \"synaptics\"\n        Option \"LeftEdge\" \"1000\"\n        Option \"RightEdge\" \"5600\"\n        Option \"TopEdge\" \"1200\"\n        Option \"BottomEdge\" \"4800\"\n        MatchIsTouchPad \"on\"\n        Option \"CircularScrolling\" \"1\"\n        Option \"CircScrollTrigger\" \"0\"\n        Option \"CircularPad\" \"1\"\n        Option \"CoastingSpeed\" \"1\"\n        Option \"CoastingFunction\" \"40\"\nEndSection" /usr/share/X11/xorg.conf.d/51-synaptics-quirks.conf | sudo tee -a /usr/share/X11/xorg.conf.d/51-synaptics-quirks.conf

##########
# その他HW設定
##########
# バックライトの輝度調整を有効化
cp /etc/default/grub ~/grub.bk
sudo su
sed -i -e '/GRUB_CMDLINE_LINUX_DEFAULT=/s/".*"/"quiet splash acpi_backlight=video acpi_osi=!!"/g' /etc/default/grub | sudo tee /etc/default/grub
update-grub

# サウンド設定の修正
cp /usr/share/pulseaudio/alsa-mixer/paths/analog-output-speaker.conf ~/analog-output-speaker.conf.bk
sed -i -e "/\[Element Headphone\]/{N;N;s/volume = off/volume = merge\noverride-map.1 = all\noverride-map.2 = all-left,all-right/g}" /usr/share/pulseaudio/alsa-mixer/paths/analog-output-speaker.conf | tee /usr/share/pulseaudio/alsa-mixer/paths/analog-output-speaker.conf
sed -i -e "/\[Element Speaker\]/{N;N;N;s/volume = merge/volume = off/g}" /usr/share/pulseaudio/alsa-mixer/paths/analog-output-speaker.conf | tee /usr/share/pulseaudio/alsa-mixer/paths/analog-output-speaker.conf
sudo pulseaudio -k && pulseaudio --start

# pulseaudioの有効化（Bluetooth）
sudo echo -e "[General]\nDisable=Socket\nEnable=Media,Source,Sink,Gateway" | sudo tee -a /etc/bluetooth/audio.conf
sudo service bluetooth restart
sudo pactl load-module module-bluetooth-discover
sudo pactl load-module module-switch-on-connect

##########
# システム設定
##########
# vimのvi互換モードをOFF
touch ~/.vimrc
echo -e "set nocompatible\nset backspace=indent,eol,start" | tee -a ~/.vimrc
sudo cp ~/.vimrc /root

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
tlp start

# Google Drive
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 9EA4D6FCA5D37A5D1CA9C09AAD5F235DF639B041
sudo sh -c "echo 'deb http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu focal main' > /etc/apt/sources.list.d/google-drive.list"
sudo sh -c "echo 'deb-src http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu focal main' >> /etc/apt/sources.list.d/google-drive.list"
sudo apt update && sudo apt install -y google-drive-ocamlfuse fuse

# Poewrtop
sudo apt install powertop -y

# hardinfo
sudo apt install -y hardinfo

# iptables
sudo apt install -y iptables-persistent

# VirtualBox
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
echo "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian bionic contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
sudo apt update && sudo apt install -y virtualbox-6.0

# KeePassXC
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv D89C66D0E31FEA2874EBD20561922AB60068FCD6
sudo sh -c "echo 'deb http://ppa.launchpad.net/phoerious/keepassxc/ubuntu focal main'"
sudo sh -c "echo 'deb-src http://ppa.launchpad.net/phoerious/keepassxc/ubuntu focal main'"
sudo apt install -y keepassxc=2.5.4+dfsg.1-1~bpo10+1

##########
# Snap
##########
#sudo apt install snapd

# KeePassXC
#sudo snap install keepassxc

##########
# Google Drive Configuration
##########
google-drive-ocamlfuse
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
