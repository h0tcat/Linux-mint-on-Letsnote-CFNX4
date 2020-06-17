#!/bin/bash
# レポジトリを日本に切り替える
# echo ""

# ソースの更新と更新パッケージの取得
sudo apt update && sudo apt upgrade

# 日本語化パッケージ
sudo apt install language-pack-ja language-pack-gnome-ja fonts-takao-gothic fonts-takao-mincho fonts-takao-pgothic fonts-vlgothic fonts-ipafont-gothic fonts-ipafont-mincho libreoffice-l10n-ja libreoffice-help-ja firefox-locale-ja manpages-ja thunderbird-locale-ja ibus-mozc ibus-anthy kasumi ibus-gtk ibus-gtk3 poppler-data cmap-adobe-japan1 fcitx-mozc fcitx-anthy fcitx-frontend-qt5 fcitx-config-gtk fcitx-config-gtk2 fcitx-frontend-gtk2 fcitx-frontend-gtk3 mozc-utils-gui fcitx-frontend-qt4 fcitx-frontend-qt5 libfcitx-qt0 libfcitx-qt5-1
sudo apt install fonts-migmix fonts-ipamj-mincho fonts-horai-umefont fonts-takao xfonts-mona fonts-kouzan-mouhitsu

# HOMEディレクトリを日本語化
LANG=C xdg-user-dirs-gtk-update

# Synaptics Driver
sudo apt install xserver-xorg-input-synaptics-hwe-18.04

# cd ~/download
cd ~/Downloads

##########
# アプリのインストール
##########
# Google Chrome
sudo echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee -a /etc/apt/sources.list.d/google-chrome.list && wget https://dl.google.com/linux/linux_signing_key.pub && sudo apt-key add linux_signing_key.pub && sudo apt update && sudo apt install google-chrome-stable

# preload
sudo apt install -y preload
sudo /etc/init.d/preload start

# tlp
sudo add-apt-repository -y ppa:graphics-drivers/ppa && sudo apt update
sudo apt install -y tlp tlp-rdw
sudo tlp start
sudo add-apt-repository ppa:linuxuprising/apps && sudo apt update && sudo apt install tlpui

# hardinfo
sudo apt install -y hardinfo

# iptables
sudo apt install -y iptables-persistent

# Slack
wget "https://downloads.slack-edge.com/linux_releases/slack-desktop-4.4.3-amd64.deb" && sudo dpkg -i ./slack-desktop-4.4.3-amd64.deb && rm slack-desktop-4.4.3-amd64.deb

# Atom
sudo add-apt-repository ppa:webupd8team/atom && sudo apt-get update && sudo apt-get install atom

# GitHub Desktop
wget "https://github.com/shiftkey/desktop/releases/download/release-2.5.2-linux1/GitHubDesktop-linux-2.5.2-linux1.deb" && sudo dpkg -i GitHubDesktop-linux-2.5.2-linux1.deb && rm GitHubDesktop-linux-2.5.2-linux1.deb

##########
# アプリインストール最終処理
##########
# Autofix broken
sudo apt-get --fix-broken install

##########
# 開発環境インストール
##########
# python3
sudo apt install python3 python3-pip

##########
# Pythonモジュール
##########
pip3 install requests

# 不要パッケージの削除
sudo apt autoremove && sudo apt autoclean

# デフォルトのIMEをfcitxに変更
im-config -n fcitx

# xinput設定（トラックパッドの感度を下げる）
echo "# Touchpad Speed Configuration" >> ~/.xinput
echo $(xinput --set-prop $(echo $(xinput --list --short | grep -i touchpad) | sed -e 's/.\+id=\([0-9]\+\).\+$/\1/g') $(xinput ---list-props $(echo $(xinput --list --short | grep -i touchpad) | sed -e 's/.\+id=\([0-9]\+\).\+$/\1/g') | grep Constant | sed -e 's/.\+(\([0-9]\+\)).\+/\1/g') 7.5) >> ~/.xinput

# vimのvi互換モードをOFF
touch ~/.vimrc
echo "set nocompatible\nset backspace=indent,eol,start" > ~/.vimrc

# ssh公開鍵を生成
mkdir ~/.ssh
ssh-keygen -t rsa

# Synaptics Configuration activete CircularScrolling
cp /usr/share/X11/xorg.conf.d/51-synaptics-quirks.conf ~/51-synaptics-quirks.conf.bk
sudo echo "Driver \"synaptics\"\n        Option \"LeftEdge\" \"1000\"\n        Option \"RightEdge\" \"5600\"\n        Option \"TopEdge\" \"1200\"\n        Option \"BottomEdge\" \"4800\"\n        MatchIsTouchPad \"on\"\n        Option \"CircularScrolling\" \"1\"\n        Option \"CircScrollTrigger\" \"0\"\n        Option \"CircularPad\" \"1\"\n        Option \"CoastingSpeed\" \"1\"\n        Option \"CoastingFunction\" \"40\"\nEndSection" /usr/share/X11/xorg.conf.d/51-synaptics-quirks.conf > /usr/share/X11/xorg.conf.d/51-synaptics-quirks.conf

# バックライトの輝度調整を有効化
cp /etc/default/grub > ~/grub.bk
sudo su
sed -e '/GRUB_CMDLINE_LINUX_DEFAULT=/s/".*"/"quiet splash acpi_backlight=video acpi_osi=!!"/g' /etc/default/grub > /etc/default/grub
#echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet splash acpi_backlight=video acpi_osi=!!"' >> /etc/default/grub
update-grub

# サウンド設定の修正
sed "/\[Element Headphone\]/{N;N;s/volume = off/volume = merge\noverride-map.1 = all\noverride-map.2 = all-left,all-right/g}" /usr/share/pulseaudio/alsa-mixer/paths/analog-output-speaker.conf > /usr/share/pulseaudio/alsa-mixer/paths/analog-output-speaker.conf
sed "/\[Element Speaker\]/{N;N;N;s/volume = merge/volume = off/g}" /usr/share/pulseaudio/alsa-mixer/paths/analog-output-speaker.conf > /usr/share/pulseaudio/alsa-mixer/paths/analog-output-speaker.conf
sudo pulseaudio -k && pulseaudio --start

# ========== MEMO ==========
# id=のあとの数字を取り出す　10
#$(echo $(xinput --list --short | grep -i touchpad) | sed -e 's/.\+id=\([0-9]\+\).\+$/\1/g')

# ()の中身をとりだす  296
#$(xinput ---list-props $(echo $(xinput --list --short | grep -i touchpad) | sed -e 's/.\+id=\([0-9]\+\).\+$/\1/g') | grep Constant | sed -e 's/.\+(\([0-9]\+\)).\+/\1/g')

# 設定
#xinput --set-prop $(echo $(xinput --list --short | grep -i touchpad) | sed -e 's/.\+id=\([0-9]\+\).\+$/\1/g') $(xinput ---list-props $(echo $(xinput --list --short | grep -i touchpad) | sed -e 's/.\+id=\([0-9]\+\).\+$/\1/g') | grep Constant | sed -e 's/.\+(\([0-9]\+\)).\+/\1/g') 8
