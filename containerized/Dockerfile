FROM alpine:latest
ARG DEPS="curl g++ git libtool cmake make openssl unzip wget fzf ripgrep npm go lazygit yazi"
RUN apk update && \
    apk add neovim ${DEPS}
RUN git clone https://github.com/diegoortizmatajira/LYRD-lua ~/.config/nvim/lua/LYRD && \
    ln -s ~/.config/nvim/lua/LYRD/root-init.lua ~/.config/nvim/init.lua 
