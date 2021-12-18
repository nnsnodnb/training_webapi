#!/bin/bash
git clone https://github.com/pyenv/pyenv ~/.pyenv
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> /home/ubuntu/.bashrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> /home/ubuntu/.bashrc
echo 'eval "$(pyenv init --path)"' >> /home/ubuntu/.bashrc
source /home/ubuntu/.bashrc
/home/ubuntu/.pyenv/bin/pyenv install 3.10.1
/home/ubuntu/.pyenv/bin/pyenv global 3.10.1
/home/ubuntu/.pyenv/shims/pip install -U pip
