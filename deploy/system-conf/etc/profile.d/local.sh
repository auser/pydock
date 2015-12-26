export PYENV_ROOT=/usr/local/pyenv
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$PYENV_ROOT/shims:$PYENV_ROOT/bin"
export LD_LIBRARY_PATH="${HOME}/.local/lib:${LD_LIBRARY_PATH}"

eval "$(pyenv init -)"
