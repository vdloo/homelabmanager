#!/usr/bin/bash
set -e

UNPRIVILEGED_USER={{ pillar['shellserver_unprivileged_user_name'] }}
if ! id "$UNPRIVILEGED_USER" &>/dev/null; then
    echo "No such user '$UNPRIVILEGED_USER'"
    exit 1
fi

rm -rf /tmp/vim_configure_area
mkdir /tmp/vim_configure_area
cd /tmp/vim_configure_area
wget http://www.vim.org/scripts/download_script.php?src_id=15530 -O zenburn.vim

mkdir -p /root/.vim/{bundle,colors}
mkdir -p /home/$UNPRIVILEGED_USER/.vim/{bundle,colors}
cp -R /etc/vundle /root/.vim/bundle/Vundle
cp -R /etc/vundle /home/$UNPRIVILEGED_USER/.vim/bundle/Vundle
cp /tmp/vim_configure_area/zenburn.vim /root/.vim/colors/zenburn.vim
cp /tmp/vim_configure_area/zenburn.vim /home/$UNPRIVILEGED_USER/.vim/colors/zenburn.vim
cp --no-clobber /etc/dotfiles/.vimrc /root/.vimrc
cp --no-clobber /etc/dotfiles/.vimrc /home/$UNPRIVILEGED_USER/.vimrc

chown -R $UNPRIVILEGED_USER:$UNPRIVILEGED_USER /home/$UNPRIVILEGED_USER/.vimrc
chown -R $UNPRIVILEGED_USER:$UNPRIVILEGED_USER /home/$UNPRIVILEGED_USER/.vim/

echo "Install Vundle dependencies as the unprivileged user"
echo | su $UNPRIVILEGED_USER -c vim +PluginInstall +qall &>/dev/null
echo "Install Vundle dependencies as the root user"
echo | vim +PluginInstall +qall &>/dev/null
