#!/bin/bash

#Todd Goldfinger
#This is in the public domain.
#2/12/06
#
#Backup/Install important files
#'goodfiles backup tarfile.tgz' to generate a tar file 
#'goodfiles install tarfile.tgz' to install them
#
#Edit the list below for your own files.
#Some of these may not actually be in use.
#Remeber to create links to;
#/usr/share/emacs/.emacs
#/usr/share/xorg/.xinitrc
#/usr/share/shell/.bashrc
#/usr/share/shel/.bash_profile

files[0]="/etc/sysconfig/dump"
files[1]="/etc/make.conf"
files[2]="/etc/conf.d/net"
files[3]="/etc/dumputils.conf"
files[4]="/etc/raidtab"
files[5]="/etc/modules.d/aliases"
files[6]="/etc/modules.d/cdr"
files[7]="/etc/conf.d/domainname"
files[8]="/etc/conf.d/keymaps"
files[9]="/etc/conf.d/net"
files[10]="/etc/conf.d/clock"
files[11]="/etc/sysconfig/network"
files[12]="/etc/bluetooth/hcid.conf"
files[13]="/sbin/rc"
files[14]="/etc/portage/package.keywords"
files[15]="/usr/share/emacs/.emacs"
files[16]="/usr/share/emacs/backup.el"
files[17]="/usr/share/emacs/doctest-mode.el"
files[18]="/usr/share/emacs/inf-ruby.el"
files[19]="/usr/share/emacs/mapback.el.txt"
files[20]="/usr/share/emacs/pycomplete.el"
files[21]="/usr/share/emacs/pycomplete.py"
files[22]="/usr/share/emacs/python-mode.el"
files[23]="/usr/share/emacs/ruby-electric.el"
files[24]="/usr/share/emacs/ruby-mode.el"
files[25]="/usr/share/emacs/rubydb2x.el"
files[26]="/usr/share/emacs/rubydb3x.el"
files[27]="/usr/share/shell/.bashrc"
files[28]="/usr/share/shell/.bash_profile"
files[29]="/root/linuxcommands.txt"
files[30]="/usr/src/linux/mkkernel"
files[31]="/etc/fstab"
files[32]="/etc/modules.autoload.d/kernel-2.6"
files[33]="/etc/X11/xorg.conf"
files[34]="/usr/share/xorg/.xinitrc"
files[35]="/usr/src/linux/.config"
files[36]="/boot/grub/device.map"
files[37]="/boot/grub/grub.conf"
files[38]="/etc/conf.d/mysql"
files[39]="/etc/apache2/vhosts.d/00_default_vhost.conf"
files[40]="/usr/share/emacs/buffer2xhtml.el"
files[41]="/etc/flexbackup.conf"
files[42]="/etc/apache2/httpd.conf"
files[43]="/etc/conf.d/apache2"
files[44]="/usr/share/emacs/matlab.el"
files[45]="/usr/share/emacs/api-tools.el"

#separate the file and dir
#in: $1 - full path to file
#out: ${file} - file name
#     ${dir}  - directory to file
get_file_and_dir() {
  pos=${#1}
  while [ "${1:`expr $pos`:1}" != "/" ]
  do
    pos=`expr $pos - 1`
  done 
  
  file="${1:`expr $pos + 1`:`expr ${#1} - $pos - 1`}"
  dir="${1:0:$pos}"
}

bootmount=`ls /boot | wc --lines`
if [ ${bootmount} == "0" ]; then
  mount /dev/md0 /boot
fi

if [ $# == 2 ] && [ $1 == "install" ]; then
  for ((i=0; i<${#files[*]}; i++))
  do 
    get_file_and_dir ${files[i]}
    yesno="y"
    if [ -e ${files[i]} ]; then
      echo -n "File" ${files[i]} "exists.  Overwrite? [n] "
      read yesno
    fi
    if [ "${yesno}" == "y" ]; then
      mkdir -p ${dir}
      cp ${file} ${dir}
    fi
  done
elif [ $# == 2 ] && [ $1 == "backup" ]; then
  for ((i=0; i<${#files[*]}; i++))
  do
    cp ${files[i]} .
  done
  
  #this is really a dir, but let's pretend
  get_file_and_dir `pwd`
  cd .. #must NOT be in root directory
  tar cfz $2 $file
  mv $2 $file
else 
  echo "Usage {install file.tgz|backup file.tgz}"
fi
