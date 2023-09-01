#!/bin/bash
# title="$icon_rld Update Dotfiles"

option=$(echo -e "Full\nnewsboat\nsway\nContacts\nssh\nScripts" | sxmo_dmenu.sh -p "Which Dotfiles?")

if [ $option = "Full" ]
then
  cd ~
  git clone https://github.com/cutthroat78/pinephone-dotfiles.git
  git clone http://(insert local address here)/username/hidden-dotfiles.git
  rm -rf ~/.config/sxmo/userscripts/*
  rm -rf ~/.config/sxmo/sway
  rm -rf ~/.config/sxmo/contacts.tsv
  rm -rf ~/.newsboat/urls
  mv -v ~/hidden-dotfiles/contacts.tsv ~/.config/sxmo/contacts.tsv
  mv -v ~/hidden-dotfiles/urls ~/.newsboat/urls
  mv -v ~/pinephone-dotfiles/scripts/* ~/.config/sxmo/userscripts/
  chmod +x ~/.config/sxmo/userscripts/*
  mv -v ~/pinephone-dotfiles/sway ~/.config/sxmo/sway
fi


if [ $option = "newsboat" ]
then
  cd ~
  git clone http://(insert local address here)/username/hidden-dotfiles.git
  rm -rf ~/.newsboat/urls
  mv -v ~/hidden-dotfiles/urls ~/.newsboat/urls
fi

if [ $option = "sway" ]
then
  cd ~
  git clone https://github.com/cutthroat78/pinephone-dotfiles.git
  rm -rf ~/.config/sxmo/sway
  mv -v ~/pinephone-dotfiles/sway ~/.config/sxmo/sway
fi

if [ $option = "Contacts" ]
then
  cd ~
  git clone http://(insert local address here)/username/hidden-dotfiles.git
  rm -rf ~/.config/sxmo/contacts.tsv
  mv -v ~/hidden-dotfiles/contacts.tsv ~/.config/sxmo/contacts.tsv
fi

if [ $option = "ssh" ]
then
  cd ~
  git clone http://(insert local address here)/username/hidden-dotfiles.git
  rm -rf ~/.ssh
  mkdir ~/.ssh
  mv -v ~/hidden-dotfiles/ssh/config ~/.ssh
  mv -v ~/hidden-dotfiles/ssh/private/* ~/.ssh
  chmod 600 ~/.ssh/*
fi

if [ $option = "Scripts" ]
then
  cd ~
  git clone https://github.com/cutthroat78/pinephone-dotfiles.git
  rm -rf ~/.config/sxmo/userscripts/*
  mv -v ~/pinephone-dotfiles/scripts/* ~/.config/sxmo/userscripts/
  chmod +x ~/.config/sxmo/userscripts/*
fi

rm -rf ~/*-dotfiles
