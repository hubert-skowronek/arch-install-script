#!/bin/bash

# Debugging mode. 
#set -x

# Stop on errors. 
set -e

dir=$PWD

function min {
	set_keymap
	set_sysclock
	partition
	encrypt
	set_lvm
	format
	mount_devices
	set_pacman_mirrors
	install_min_system
	gen_fstab
	set_timezone
	gen_locale
	set_hostname
	run_initramfs
	set_root_passwd
	install_intel_ucode
	install_bootloader
	create_default_user
	install_gui
	set_network
	create_bookmarks
	enable_firewall
	config_git
	lid_switch_tweak
	create_bash_scripts
	# enable_multilib
	installation_succeeded
}

function full {
	set_keymap
	set_sysclock
	partition
	encrypt
	set_lvm
	format
	mount_devices
	set_pacman_mirrors
	install_system
	gen_fstab
	set_timezone
	gen_locale
	set_hostname
	run_initramfs
	set_root_passwd
	install_intel_ucode
	install_bootloader
	create_default_user
	install_gui
	set_network
	create_bookmarks
	enable_firewall
	config_git
	lid_switch_tweak
	create_bash_scripts
	# enable_multilib
	installation_succeeded
}

function min_vbox_guest {
	min
	arch-chroot /mnt pacman --noconfirm -Syu virtualbox-guest-dkms virtualbox-guest-utils
}

function full_vbox_guest {
	full
	#arch-chroot /mnt pacman --noconfirm -R virtualbox-host-dkms
	arch-chroot /mnt pacman --noconfirm -Syu virtualbox-guest-dkms virtualbox-guest-utils
}

function set_keymap {
	loadkeys pl
	setfont lat2-16 -m 8859-2
}

function set_sysclock {
	timedatectl set-ntp true
	timedatectl status
}

function partition {
	# GTP partition table
	parted -s /dev/sda mklabel gpt

	# EFI boot partition
	parted -s /dev/sda mkpart primary fat32 2048s 1050623s
	parted -s /dev/sda set 1 boot on
	parted -s /dev/sda set 1 esp on

	# LVM partition
	parted -s /dev/sda mkpart primary 1050624s 176351255s
	parted -s /dev/sda set 2 lvm on

	parted -s /dev/sda print
}

function encrypt {
	cryptsetup -qvy -s 512 luksFormat /dev/sda2
	cryptsetup open --type luks /dev/sda2 Vol
}

function set_lvm {
	# initialize physical volume for use by LVM
	pvcreate /dev/mapper/Vol 

	# create a volume group
	vgcreate Vol /dev/mapper/Vol 

	# create logical volumes
	lvcreate -L 20G Vol -n root
	lvcreate -L 8G Vol -n swap
	lvcreate -l 100%FREE Vol -n home
}

function format {
	mkfs.fat -F32 /dev/sda1 # EFI boot
	mkfs.ext4 /dev/mapper/Vol-root
	mkfs.ext4 /dev/mapper/Vol-home

	# format SWAP partition
	mkswap /dev/mapper/Vol-swap
}

function mount_devices {
	mount /dev/mapper/Vol-root /mnt

	mkdir /mnt/boot
	mount /dev/sda1 /mnt/boot

	mkdir /mnt/home
	mount /dev/mapper/Vol-home /mnt/home

	swapon /dev/mapper/Vol-swap
}

function set_pacman_mirrors {
	pl_mirrors=`grep 'Poland' /etc/pacman.d/mirrorlist -A 1 | sed 's/--//'`
	printf "$pl_mirrors\n" | cat - /etc/pacman.d/mirrorlist > temp && mv temp /etc/pacman.d/mirrorlist
}

function install_system {
	pacstrap /mnt base base-devel \
	linux-lts \
	linux-lts-headers \
	squashfs-tools \
	cdrtools \
	syslinux \
	ntfs-3g \
	exfat-utils \
	alsa-utils \
	smartmontools \
	sudo \
	xorg-server \
	xorg-apps \
	xorg-xinit \
	gnome \
	gnome-tweak-tool \
	dconf-editor \
	gedit \
	gnome-weather \
	noto-fonts \
	ttf-roboto \
	ttf-ubuntu-font-family \
	adapta-gtk-theme \
	ufw \
	gufw \
	iw \
	dialog \
	wpa_supplicant \
	networkmanager \
	network-manager-applet \
	screenfetch \
	xf86-video-intel \
	samba \
	parted \
	wget \
	firefox \
	pidgin \
	purple-facebook \
	purple-skypeweb \
	vlc \
	libdvdcss \
	libva-intel-driver \
	docker \
	jdk8-openjdk \
	openjdk8-src \
	jdk13-openjdk \
	openjdk13-src \
	visualvm \
	scala \
	scala-sources \
	sbt \
	maven \
	gradle \
	git \
	intellij-idea-community-edition \
	virtualbox-host-dkms \
	virtualbox \
	libreoffice-still \
	desmume \
	mgba-qt \
	dolphin-emu \
	transmission-gtk \
	unrar \
	p7zip \
	gimp \
	audacity \
	filezilla \
	fbreader

	#qt4
	#bless

	# xnviewmp
	# skypeforlinux-stable-bin
	# spotify
	# sublime
	# flashplugin
	# wireshark-gtk
	# virtualbox-host-modules-arch
	# remmina
	# mesa-demos
	# i7z
	# gparted
	# arc-gtk-theme
	# paper-gtk-theme
	# paper-icon-theme
	# super-flat-remix-icon-theme
}

function install_min_system {
	pacstrap /mnt base base-devel \
	ntfs-3g \
	exfat-utils \
	alsa-utils \
	smartmontools \
	xorg-server \
	xorg-apps \
	xorg-xinit \
	gnome \
	gnome-tweak-tool \
	dconf-editor \
	gedit \
	gnome-weather \
	noto-fonts \
	ttf-roboto \
	adapta-gtk-theme \
	ufw \
	gufw \
	iw \
	dialog \
	wpa_supplicant \
	networkmanager \
	network-manager-applet \
	firefox \
	pidgin \
	purple-facebook \
	purple-skypeweb \
	vlc \
	libdvdcss \
	libva-intel-driver \
	git \
	linux-lts \
	linux-lts-headers \
	wget \
	unrar \
	screenfetch \
	sudo \
	xf86-video-intel \
	samba \
	p7zip \
	parted
}

function gen_fstab {
	genfstab -U /mnt > /mnt/etc/fstab

	line=$(cat /mnt/etc/fstab | grep -n '/home' | grep -o '^[0-9]*')
	sed -i ${line}'s/rw,/nodev,nosuid,rw,/' /mnt/etc/fstab

	line=$(cat /mnt/etc/fstab | grep -n '/boot' | grep -o '^[0-9]*')
	sed -i ${line}'s/rw,/nodev,nosuid,noexec,rw,/' /mnt/etc/fstab
}

function set_timezone {
	arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Warsaw /etc/localtime
	arch-chroot /mnt hwclock --systohc --utc
}

function gen_locale {
	# /etc/locale.gen
	sed -i '/#pl_PL.UTF-8 UTF-8/s/#//g' /mnt/etc/locale.gen
	sed -i '/#en_US.UTF-8 UTF-8/s/#//g' /mnt/etc/locale.gen
	arch-chroot /mnt locale-gen

	# /etc/locale.conf
	cat <<-END > /mnt/etc/locale.conf
	LANG=en_US.UTF-8
	LC_NUMERIC=pl_PL.UTF-8
	LC_TIME=pl_PL.UTF-8
	LC_MONETARY=pl_PL.UTF-8
	LC_PAPER=pl_PL.UTF-8
	LC_MEASUREMENT=pl_PL.UTF-8
	END

	# set the keyboard layout
	cat <<-END > /mnt/etc/vconsole.conf
	KEYMAP=pl2
	FONT=lat2-16
	FONT_MAP=8859-2
	END
}

function set_hostname {
	printf "hubert" > /mnt/etc/hostname

	printf "" > /mnt/etc/hosts
	printf "" > /mnt/etc/hosts

	cat <<-END >> /mnt/etc/hosts
	127.0.0.1	localhost.localdomain	localhost
	::1		localhost.localdomain	localhost
	127.0.0.1	hubert.localdomain	hubert
	END
}

function run_initramfs {
	sed -i '/HOOKS/s/udev autodetect modconf block filesystems keyboard/udev keyboard autodetect modconf block encrypt lvm2 filesystems/g' /mnt/etc/mkinitcpio.conf # rewrite it to smth smarter
	arch-chroot /mnt mkinitcpio -p linux-lts
}

function set_root_passwd {
	printf "Provide a password for the root user:\n"
	arch-chroot /mnt passwd
}

function install_intel_ucode {
	arch-chroot /mnt pacman --noconfirm -S intel-ucode
	printf "$(arch-chroot /mnt dmesg | grep microcode)"
}

function install_bootloader {
	arch-chroot /mnt bootctl --path=/boot install

	cat <<-END > /mnt/boot/loader/entries/arch.conf
	title   Arch Linux
	linux   /vmlinuz-linux-lts
	initrd  /intel-ucode.img
	initrd  /initramfs-linux-lts.img
	options cryptdevice=UUID=$( blkid /dev/sda2 -s UUID -o value ):Vol root=/dev/mapper/Vol-root quiet rw
	END

	cat <<-END > /mnt/boot/loader/loader.conf
	timeout 3
	default arch.conf
	END
}

function create_default_user {
	arch-chroot /mnt useradd -m -G wheel -s /bin/bash hubert
	printf "Provide a password for the hubert user:\n"
	arch-chroot /mnt passwd hubert

	sed -i '/# %wheel ALL=(ALL) ALL/s/#//g' /mnt/etc/sudoers
	arch-chroot /mnt passwd -l root
	chmod 700 /mnt/home/hubert
}

function install_gui {
	arch-chroot /mnt systemctl enable gdm

	cp $dir/setup.sh /mnt/home/hubert/setup.sh
	arch-chroot /mnt chmod +x /home/hubert/setup.sh
	arch-chroot /mnt chown hubert:hubert /home/hubert/setup.sh

	# Dash-to-dock
	arch-chroot /mnt wget https://extensions.gnome.org/review/download/12397.shell-extension.zip
	arch-chroot /mnt unzip 12397.shell-extension.zip -d /usr/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com
	arch-chroot /mnt rm 12397.shell-extension.zip
	chmod 644 /mnt/usr/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/metadata.json

	# Sound
	arch-chroot /mnt wget https://extensions.gnome.org/extension-data/sound-output-device-chooserkgshank.net.v25.shell-extension.zip
	arch-chroot /mnt unzip sound-output-device-chooserkgshank.net.v25.shell-extension.zip -d /usr/share/gnome-shell/extensions/sound-output-device-chooser@kgshank.net
	arch-chroot /mnt rm sound-output-device-chooserkgshank.net.v25.shell-extension.zip
	chmod 644 /mnt/usr/share/gnome-shell/extensions/sound-output-device-chooser@kgshank.net/*.js
	chmod 644 /mnt/usr/share/gnome-shell/extensions/sound-output-device-chooser@kgshank.net/*.json

	# Compile schemas
	cp /mnt/usr/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/org.gnome.shell.extensions.dash-to-dock.gschema.xml /mnt/usr/share/glib-2.0/schemas
	cp /mnt/usr/share/gnome-shell/extensions/sound-output-device-chooser@kgshank.net/schemas/org.gnome.shell.extensions.sound-output-device-chooser.gschema.xml /mnt/usr/share/glib-2.0/schemas
	arch-chroot /mnt glib-compile-schemas /usr/share/glib-2.0/schemas

	# Papirus icon set
	arch-chroot /mnt wget https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/master/install.sh
	arch-chroot /mnt chmod +x install.sh
	arch-chroot /mnt ./install.sh
	arch-chroot /mnt rm install.sh

	# Terminal
	#sed -i '/^PS1/s/PS1/#PS1/g' /mnt/home/hubert/.bashrc
	#printf "PS1='\\\[\\\e[01;32m\\\]\\\u@\\\h \\\[\\\e[01;34m\\\]\\\W \\$ \\\[\\\e[0m\\\]'\n" >> /mnt/home/hubert/.bashrc

	#Gnome settings
	arch-chroot /mnt sudo -u hubert /home/hubert/setup.sh
	arch-chroot /mnt sudo -u hubert rm /home/hubert/setup.sh
}

function set_network {
	arch-chroot /mnt systemctl enable NetworkManager.service
}

function create_bookmarks {
	arch-chroot /mnt sudo -u hubert mkdir -p /home/hubert/Software

	arch-chroot /mnt sudo -u hubert mkdir -p /home/hubert/.config/gtk-3.0
	arch-chroot /mnt sudo -u hubert cat <<-END > /mnt/home/hubert/.config/gtk-3.0/bookmarks
	file:///home/hubert/Desktop
	file:///home/hubert/Software
	END
}

function enable_firewall {
	arch-chroot /mnt systemctl enable ufw.service
	printf "Run ufw enable after reboot in order to get it working."
}	

function config_git {
	cat <<-END > /mnt/home/hubert/.gitconfig
	[user]
	name = Hubert Skowronek
	email = hubert.skowronek@gmail.com
	END
	arch-chroot /mnt chown hubert:hubert /home/hubert/.gitconfig
}

function lid_switch_tweak {
	arch-chroot /mnt sudo -u hubert mkdir -p /home/hubert/.config/autostart
	arch-chroot /mnt sudo -u hubert cat <<-END > /mnt/home/hubert/.config/autostart/ignore-lid-switch-tweak.desktop
	[Desktop Entry]
	Type=Application
	Name=ignore-lid-switch-tweak
	Exec=/usr/lib/gnome-tweak-tool-lid-inhibitor
	END
}

function create_bash_scripts {
	cat <<-END > /mnt/usr/local/bin/sha1sumdir
	#!/bin/bash

	for var in "\$@"
	do
	  echo \$(find "\$var" -type f -exec sha1sum {} \; | sort -k 2 | sha1sum) \$var
	done
	END
	chmod +x /mnt/usr/local/bin/sha1sumdir

	cat <<-END > /mnt/usr/local/bin/smbstart
	#!/bin/bash

	systemctl start smbd
	systemctl start nmbd
	END
	chmod +x /mnt/usr/local/bin/smbstart

	cat <<-END > /mnt/usr/local/bin/smbstop
	#!/bin/bash

	systemctl stop smbd
	systemctl stop nmbd
	END
	chmod +x /mnt/usr/local/bin/smbstop
}

function enable_multilib {
	line=$(cat /mnt/etc/pacman.conf | grep -n '#\[multilib\]' | grep -o '^[0-9]*')
	sed -i ${line}'s/#//' /mnt/etc/pacman.conf

	line=$((line+1))
	sed -i ${line}'s/#//' /mnt/etc/pacman.conf
}

function installation_succeeded {
	printf "Installation completed."
}

$1
