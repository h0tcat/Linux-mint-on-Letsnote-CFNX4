#!/bin/bash
LANG=C xdg-user-dirs-gtk-update
sudo ufw enable
sudo add-apt-repository ppa:mikhailnov/pulseeffects

sudo echo "deb https://qemu.weilnetz.de/debian/ testing contrib" > /etc/apt/sources.list.d/cygwin.list  
cd /etc/apt/trusted.gpg.d && sudo wget https://qemu.weilnetz.de/debian/weilnetz.gpg
sudo curl -s https://qemu.weilnetz.de/debian/gpg.key | sudo apt-key add -
##########
# レポジトリを日本に切り替える
##########
sudo echo "deb http://ftp.jaist.ac.jp/pub/Linux/linuxmint/packages ulyana main upstream import backport" | sudo tee -a /etc/apt/sources.list.d/official-package-repositories.list
sudo echo "deb http://ftp.jaist.ac.jp/pub/Linux/ubuntu focal main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list.d/official-package-repositories.list
sudo echo "deb http://ftp.jaist.ac.jp/pub/Linux/ubuntu focal-updates main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list.d/official-package-repositories.list
sudo echo "deb http://ftp.jaist.ac.jp/pub/Linux/ubuntu focal-backports main restricted universe multiverse" | sudo tee -a /etc/apt/sources.list.d/official-package-repositories.list
sudo sed -i -e "/http:\/\/packages.linuxmint.com\/s/^/#/" /etc/apt/sources.list.d/official-package-repositories.list | sudo tee /etc/apt/sources.list.d/official-package-repositories.list
sudo sed -i -e "/http:\/\/archive.ubuntu.com/ubuntu\/s/^/#/g" /etc/apt/sources.list.d/official-package-repositories.list | sudo tee /etc/apt/sources.list.d/official-package-repositories.list

# ソースの更新と更新パッケージの取得
sudo apt update && sudo apt upgrade

# デフォルトのIMEをfcitxに変更

# HOMEディレクトリを日本語化
LANG=C xdg-user-dirs-gtk-update

##########
# トラックパッドの設定
#########
# Synaptics Driverをインストール
#sudo apt install xserver-xorg-input-synaptics-hwe-18.04
sudo apt install -y xserver-xorg-input-synaptics
sudo apt install -y pulseaudio pulseeffects  whois netdiscover git rustc libncurses-dev curl gufw curl git python3-pip nemo libboost-dev libgtk-3-dev libsdl2-dev curl git gufw python2-pip terminator
sudo apt install -y ubuntu-unity-desktop

sudo dpkg-reconfigure lightdm

sudo snap install obs-studio
sudo snap install clementine
sudo snap install musescore --classic
sudo snap install zoom-client

sudo dpkg -i *.deb
# xinput設定（トラックパッドの感度を下げる）
echo "# Touchpad Speed Configuration" | tee -a ~/.xinputrc
echo $(xinput --set-prop $(echo $(xinput --list --short | grep -i touchpad) | sed -e 's/.\+id=\([0-9]\+\).\+$/\1/g') $(xinput ---list-props $(echo $(xinput --list --short | grep -i touchpad) | sed -e 's/.\+id=\([0-9]\+\).\+$/\1/g') | grep Constant | sed -e 's/.\+(\([0-9]\+\)).\+/\1/g') 7.5) | tee -a ~/.xinputrc

# Synaptics Configuration activete CircularScrolling
cp /usr/share/X11/xorg.conf.d/51-synaptics-quirks.conf ~/51-synaptics-quirks.conf.bk
sudo echo -e "Section \"InputClass\"\n                Identifier \"touchpad catchall\"\n        Driver \"synaptics\"\n        Option \"LeftEdge\" \"1000\"\n        Option \"RightEdge\" \"5600\"\n        Option \"TopEdge\" \"1200\"\n        Option \"BottomEdge\" \"4800\"\n        MatchIsTouchPad \"on\"\n        Option \"CircularScrolling\" \"1\"\n        Option \"CircScrollTrigger\" \"0\"\n        Option \"CircularPad\" \"1\"\n        Option \"CoastingSpeed\" \"1\"\n        Option \"CoastingFunction\" \"40\"\nEndSection" /usr/share/X11/xorg.conf.d/51-synaptics-quirks.conf | sudo tee -a /usr/share/X11/xorg.conf.d/51-synaptics-quirks.conf

##########
# その他HW設定
##########

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
cp ./backups/.vimrc ~/
sudo cp ./backups/.vimrc /root

# HW時間を変更
#sudo hwclock -D --systohc --localtime
sudo timedatectl set-local-rtc true

# NTP
cp /etc/systemd/timesyncd.conf ~/timesyncd.conf.bk
sed -i -e "/^#\(Fallback\)\?NTP=/s/^#//" /etc/systemd/timesyncd.conf | sudo tee /etc/systemd/timesyncd.conf
sed -i -e "/^NTP=/s/$/ntp.nict.jp/" /etc/systemd/timesyncd.conf | sudo tee /etc/systemd/timesyncd.conf
sed -i -e "/^FallbackNTP=/s/=.*$/ntp1.jst.mfeed.ad.jp ntp2.jst.mfeed.ad.jp ntp3.jst.mfeed.ad.jp/" /etc/systemd/timesyncd.conf | sudo tee /etc/systemd/timesyncd.conf

# preload
sudo apt install -y preload
sudo /etc/init.d/preload start

# tlp
sudo add-apt-repository -y ppa:graphics-drivers/ppa && sudo apt update
sudo apt install -y tlp tlp-rdw
sudo tlp start
sudo add-apt-repository ppa:linuxuprising/apps && sudo apt update && sudo apt install tlpui


##########
# アプリインストール後の依存関係処理
##########
# Autofix broken
sudo apt-get --fix-broken install

# id=のあとの数字を取り出す　10
#$(echo $(xinput --list --short | grep -i touchpad) | sed -e 's/.\+id=\([0-9]\+\).\+$/\1/g')

# ()の中身をとりだす  296
#$(xinput ---list-props $(echo $(xinput --list --short | grep -i touchpad) | sed -e 's/.\+id=\([0-9]\+\).\+$/\1/g') | grep Constant | sed -e 's/.\+(\([0-9]\+\)).\+/\1/g')

# 設定
#xinput --set-prop $(echo $(xinput --list --short | grep -i touchpad) | sed -e 's/.\+id=\([0-9]\+\).\+$/\1/g') $(xinput ---list-props $(echo $(xinput --list --short | grep -i touchpad) | sed -e 's/.\+id=\([0-9]\+\).\+$/\1/g') | grep Constant | sed -e 's/.\+(\([0-9]\+\)).\+/\1/g') 8
