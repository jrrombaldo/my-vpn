#!/usr/bin/env bash

echo "test" > /tmp/test.txt

#curl -sSL https://get.docker.com | sh
#sudo usermod -a -G docker pi


apt install zsh curl get vim -y


sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
echo 'source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh'>> ~/.zshrc
# disabling password prompt for chsh (hacky). The option "--unattended" does not set ZSH as the default shell
sed -i  -r -e  's/^auth\s+required\s+pam_shells.so/auth         sufficient  pam_shells.so/g'  /etc/pam.d/chsh
cat /etc/pam.d/chsh | grep pam_shells.so
chsh -s ~/.oh-my-zsh
# re-enabling password prompt for chsh
sed -i  -r -e  's/^auth\s+sufficient\s+pam_shells.so/auth           required    pam_shells.so/g'  /etc/pam.d/chsh
cat /etc/pam.d/chsh | grep pam_shells.so





yum install docker