# Ruski's Arch Guide
## About
I am stupid, and usually forget important steps when setting up arch. While initially I made this guide for myself, I thought that sharing it would be much better. This guide is mostly tailored to new users, those who like me on their first install were told to read the wiki and had absolutely no idea what they were doing and why, or those who have experience with arch and want a friendly reminder on what to do on your install. Here, I'll be talking about common pitfalls, general recomendations and what to do when you're stuck.

## Considerations
+ This install is mostly tailored toward my needs, you might find it useful or you mind find it lacking in other aspects. While I do try to explain lots of things for first time installers, I won't go knees deep into how everything works.

+ I will be using the packages I want to install as a reference, but you can use any you like. You can check the wiki for all of the listed packages when it comes to wifi, DE, WM, etc.

+ While it is meant as a more readable version of the arch wiki, it is NOT supposed to replace it. If in any point you're stuck or don't understand, I suggest you head on over and have a quick read :)

+ I am by no means an arch expert, so please take my opinion with a grain of salt. If you happen to spot a mistake, missed step, incorrect command or find a better way to do some of these steps, you can add an issue or send me a message! Similarly if you want help, you can also message me @ruskki_

+ At the moment, this is currently a WIP. Please be patient, I am aware there might be some sections that are hard to read or understand. I'm trying my best to make it easier to understand and more organized. So if you happen to stumble by, hello!


## Install

Before you install arch, you must have a USB with Arch. 
[Setting up the Arch USB](https://github.com/Ruskki/RAG/wiki/Flashing-the-ISO)

There are two main ways to install arch, via the script or the manual way. If you want to use the script, just type "archinstall" and you'll have some handholding. You can still follow this guide if you use the script, but many of the steps will be done by the script. If you want to do the manual way, keep reading

### Keyboard

Before we start, lets make sure the keymap is the correct one. By default the install ISO uses US Qwerty. While I skip this step, here's what to do to change it.

```
localectl list-keymaps
loadkeys LAYOUT_HERE
```

### Connect to the Internet

```
iwctl
```

While in my experience wlan0 is usually the main wifi card, you should use "station list" to see all of your wifi cards

```
station wlan0 get-networks
station wlan0 connect "NETWORK NAME"
exit
```

### Create the partitions

I like to create 4 partitions for my install, but you technically only need two (boot and root).

First we list all of the disks and partitions on the computer
```
fdisk -l
```

After we choose what disk we want to use, we'll use its directory to access it with fdisk. It might not be sda for you, it might have another name, use that instead.
```
fdisk /dev/sda
```

Now we partition the disk. If your disk is already partitioned and you would like to wipe its partition table, you can use "g" to wipe the existing partition table.

If you're new, here I go a bit in depth on what the minimums are for every partition.
[Choosing partition sizes](https://github.com/Ruskki/RAG/wiki/Choosing-partition-sizes)

This is the convention **I** like to use for my system and this is the order in which I create them. I personally like to have home separate, in case I need to reinstall arch and it keeps my personal files away from system files. You don't need to do this.

| Type  | Size   |
|:-----:|:------:|
| boot  | 512MB  |
| swap  | 4GB    |
| root  | 80GB+  |
| home  | 80GB+  |


#### Fdisk commands
```
n        create new partitions
t        change partition type
d        delete existing partition
w        write changes to partition table
```

#### Partition Types
Keep in mind that after creating your partitions, you have to change which types they are

| Partition  | Type   |
|:-----:|:------:|
| boot  | efi    |
| swap  | swap   |
| root  | ext4   |
| home  | ext4   |


NOTE: keep in mind the directory each partition, we will need them for next step. If in any case you forget, do "fdisk -l" to see all of the partitions

### Formating

Now we format our disks with the correct file systems

First lets format our home and root partitions
```
mkfs.ext4 /dev/ROOT_PARTITION
mkfs.ext4 /dev/HOME_PARTITION
```

Second we format swap
```
mkswap /dev/SWAP PARTITION
```

Lastly we format our boot partition
```
mkfs.fat -F 32 /dev/BOOT_PARTITION
```

### Mounting

This part caused a lot of headaches for me when I was first learning, you HAVE to mount root FIRST. You do not need to mount home, but they will make your life simpler. If you decide to not mount, you'll have to change your fstab file later on.

```
mount /dev/ROOT_PARTITION /mnt
mount /dev/HOME_PARTITION /mnt/home
mount --mkdir /dev/BOOT_PARTITION /mnt/boot
swapon /dev/SWAP_PARTITION
```

### Installing Linux

There's not much to say, this will install the linux kernel and firmware onto your root folder. Just copy and paste!

```
pacstrap -K /mnt base linux linux-firmware
```

### Generating your fstab

This generates your fstab file, which is in charge of telling your system how to mount partitions on startup.

```
genfstab -U /mnt >> /mnt/etc/fstab
```

## Changing root

If you've gotten this far without any hiccups, we're 1/3 there. Let's keep going.
Let's change into our root partition.

```
arch-chroot /mnt
```

### Installing packages

Now here's the fun part, installing a bunch of stuff. Here are MUSTS

+ internet manager
+ dns solver (IF your internet manager of choice doesn't come with one)
+ terminal
+ audio
+ DE or WM
+ Login Manager
+ text editor (terminal based)
+ sudo
+ bootloader
+ display server

Don't know what to install?

For this next package you can take two routes, Desktop enviroment or Window manager. Each have their pros and cons, but if you want something more simple, go with the desktop manager.

Other things you can install either in this step of the install or after

+ git
+ fun packages like cmatrix or cowsay
+ browser
+ wine (for running .exe)
+ etc

```
pacman -Syu [INTERNET] [DNS] [TERMINAL] [DE or WM] [LOGIN] [AUDIO] [TEXT EDITOR] [SUDO] [BOOTLOADER] [DISPLAY] [EXTRAS]
```

Here's how i use the above command with the packages I want. You can change any for any other package you like, just make sure to install everying you need.

```
pacman -Syu iwd dhcpcd alacritty qtile sddm pipewire wireplumber pipewire-pulse pavucontrol vi neovim sudo grub xorg-server firefox git
```

If you're a first time user, I recommend replacing qtile with gnome or kde. Qtile has a bit of a learning curve and wouldn't really recommend it for first timers

### Time & Zone

Here we replace YOURREGION with well... your region, same goes for YOURCITY. Please keep in mind which timezone you're in. Here's an example of a timezone "America/LosAngeles"

```
ln -sf /usr/share/zoneinfo/YOUR_REGION/YOUR_CITY /etc/localtime
```

Next we set the system clock using the hardware clock

```
hwclock --systohc
```

### Locale

With the terminal editor we just install, we use it to edit the locale file. Since I installed neovim, i'll use that.

```
nvim /etc/locale.gen
```

You can also cd into the directory aka move into it, create it and then open it

```
cd /etc
touch locale.gen
TEXT_EDITOR locale.gen
```

Uncomment by removing the # on the locale you use. Save and close the file.

```
locale-gen
```

We now create the locale.conf file. Here I'm creating and accesing it.

```
nvim /etc/locale.conf
```

Add this line and replace.

```
LANG=YOUR_LOCALE
```

### Hostname

We do tha same as before, but with the hostname file

```
nvim /etc/hostname
```

Add what you would like the pc's name to be. I'm using the name below for example purposes

```
ruski-computer
```

### Intramfs

While I'm not exactly sure why we must do this, I do know that you have to

```
mkinitcpio -P
```

### Root password

Here we create our root password. Think of it as an admin password

```
passwd
```

### Create user

Here we'll add a user and add a password for it

```
useradd -m ruski
passwd ruski
```

### Bootloader

You can choose any bootloader, here I'll be explaining how to set install grub, which is the one I use.

In these two commands, we'll be installing grub to our boot partition, and generating it's config in our root partition

If you mounted boot somewhere else, make sure that directory is there, otherwise you can use the same command. I added the removable flag, since I tend to move my disks in between computers.

```
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --removable
grub-mkconfig
```

## Post Install

Congrats if you made it here! All you need to do now is type these two commands

```
exit
reboot
```

Arch should now appear in your BIOS. Change your boot order if you'd like, and boot into Arch.
While the wiki makes it seem like it's the end, we're far from it. Lets get our system working like most.


### GUI
After first booting into arch, you'll be meeted with no GUI, but don't worry, we can fix that.

First we must run this command as root (admin), and then we can tell our system to enable the LM.

```
su
systemctl enable sddm --now
```

Now we'll be shown a not so pretty login screen and we have a GUI!

NOTE: If something fails here, screen freezes, etc, you can always go back to the terminal before. The tty (that's what it's called), can be accessed at any time with the following keybind

```
Ctrl + Alt + F3
```

You can use any of the function keys from F3 and onwards and have multiple tty instances. To go back, to the same keycombo but with F2. If your function keys have special actions, use the keybing with the "Fn" key as well

### Permissions & Groups

Despite the fact we now have the posibility of opening apps thanks to our DE or WM, we don't have the permissions to do certain things like connecting to the internet.

```
su
usermod -aG network YOUR_USER
usermod -aG wheel YOUR_USER
```

You can also cd into the directory, this means moving into it and creating it
Here we're adding the user to the groups network and wheel. Why wheel? There's a trusty package called sudo we installed earlier that can give any command admin priviliges. This is extremely useful, since some commands need this priviledge and constantly logging into root might be cumbersome. This is considerably even more useful when considering the fact some commands WON'T work when given these permissions

Now we tell sudo that the user can use it
```
visudo
```

Look for the line User priviledge specification. Uncomment the line under "allow members of group wheel to execute any command". Now you can use sudo.

NOTE: Everytime you use sudo you will be promted for the root password, if you do not wish to be asked each time, uncomment the line after that.

### Internet

As we did at the start of the install, connect to the internet. If you installed the same as I did, do this extra step

```
sudo systemctl enable dhcpcd --now
sudo systemctl enable iwd --now
```

### Repositories

We have our permissions working, now lets sync the repos and update

```
sudo pacman -Syu
```

Now sometimes we might want 32 bit packages, here's how to change it

```
sudo nvim /etc/pacman.conf
```

Search for the line "[multilib-testing]" and uncomment that and the one below.

Since we're here, lets do some QoL changes.

Over on the ParallelDownloads line, uncomment it for faster downloads. This is useful if you have fast internet speeds.
You can uncomment Color if you want some spice in your terminal.
For a little secret, you can add the line "ILoveCandy" anywhere under the "Misc Options".



You might find yourself wanting packages that aren't in pacman, here's where the AUR (Arch User Repository) comes in handy. To be able to download packages from there, you must use an aur helper. Here, we'll install and build paru

Assuming you installed git, here's how to do it

```
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```

You use paru exactly how you use pacman, with the exeption of not adding sudo before.

### Audio

The same thing we did with the internet now applies to our audio, assuming you installed pipewire and wireplumber

```
systemctl --user enable wireplumber --now
systemctl --user enable pipewire --now
```

You may need to restart your session (log out) for you to see that the audio is now working

### Extras

These packages aren't necesary but are nice to have in your system, in case you're not sure what you're missing. The ones in parenthesis are the ones I use

+ File manager (nautilus)
+ Screenshots (flameshot)
+ Screen Recorder
+ Info bar (eww)
+ Games
+ Messaging
+ Battery (acpi)
+ Bluetooth (bluetoothctl)
+ Brightness (brightnessctl)

+ Rofi
+ Wine

Note: If you didn't uncomment the line for 32bit packages, you won't be able to install steam.

Note: If you want an info bar, use polybar. I am insane and like rummaging in docs, don't be like me.


## Closing

That's it! If you reached the end it hopefully means you managed to install Arch and get it running like most computers. I hope it helped you in your journey.

As I stated earlier if you get stuck, you can go over to the arch wiki or you can send me a message over on Discord

@ruskki_

I wish you the best of luck using Arch.

## Special Thanks

+ Kimbix & Clara
+ Arch Wiki
