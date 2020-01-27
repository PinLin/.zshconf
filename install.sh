#!/bin/sh

REPO_URL="https://github.com/PinLin/dotfiles"
REPO_NAME="dotfiles"

INSTALL_DIRECTORY=${INSTALL_DIRECTORY:-"$HOME/.$REPO_NAME"}
INSTALL_VERSION=${INSTALL_VERSION:-"master"}

askquestion() {
    printf "$1 [y/N] "

    read ans
    case $ans in
    [Yy*])
        return $(true)
        ;;
    *)
        return $(false)
        ;;
    esac
}

applyzsh() {
    # Check zsh
    if ! command -v zsh >/dev/null 2>&1; then
        echo "zsh is not installed."
        return $(false)
    fi

    # Install zim
    if ! [ -d ${ZIM_HOME:-$HOME/.zim} ]; then
        if command -v curl >/dev/null 2>&1; then
            zsh -c "$(curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh)"
        else
            zsh -c "$(wget -nv -O - https://raw.githubusercontent.com/zimfw/install/master/install.zsh)"
        fi
    fi
    # Install powerlevel10k
    if ! grep "zmodule romkatv/powerlevel10k" $HOME/.zimrc; then
        echo "zmodule romkatv/powerlevel10k" >>$HOME/.zimrc
    fi
    zsh $HOME/.zim/zimfw.zsh install

    echo "source $INSTALL_DIRECTORY/zsh/alias.zsh" >>$HOME/.zshrc
    echo "source $INSTALL_DIRECTORY/zsh/function.zsh" >>$HOME/.zshrc
    echo "source $INSTALL_DIRECTORY/zsh/p10k.zsh" >>$HOME/.zshrc
    echo "DEFAULT_USER=$USER" >>$HOME/.zshrc
}

applyvim() {
    # Check vim
    if ! command -v vim >/dev/null 2>&1; then
        echo "vim is not installed."
        return $(false)
    fi

    if [ -f $HOME/.vimrc ]; then
        mv $HOME/.vimrc $HOME/.vimrc.bak
    fi
    echo "source $INSTALL_DIRECTORY/vim/.vimrc" >>$HOME/.vimrc
}

applytmux() {
    # Check tmux
    if ! command -v tmux >/dev/null 2>&1; then
        echo "tmux is not installed."
        return $(false)
    fi

    if [ -f $HOME/.tmux.conf ]; then
        mv $HOME/.tmux.conf $HOME/.tmux.conf.bak
    fi
    echo "source $INSTALL_DIRECTORY/tmux/.tmux.conf" >>$HOME/.tmux.conf
}

main() {
    # Check Git
    if ! command -v git >/dev/null 2>&1; then
        echo "You must install git before using the installer."
        return $(false)
    fi

    # Remove old one
    if [ -d $INSTALL_DIRECTORY ]; then
        rm -rf $INSTALL_DIRECTORY
    fi

    # Clone repo to local
    git clone $REPO_URL $INSTALL_DIRECTORY
    if [ $? != 0 ]; then
        echo "Failed to clone $REPO_NAME."
        return 1
    fi
    cd $INSTALL_DIRECTORY
    git checkout $INSTALL_VERSION

    # Apply the config of zsh
    if askquestion "Do you want to apply the config of zsh?"; then
        applyzsh
    fi

    # Apply the config of vim
    if askquestion "Do you want to apply the config of vim?"; then
        applyvim
    fi

    # Apply the config of tmux
    if askquestion "Do you want to apply the config of tmux?"; then
        applytmux
    fi

    # Finished
    echo
    echo "Done! $REPO_NAME:$INSTALL_VERSION is ready to go! Restart your shell to use it."
}

main
