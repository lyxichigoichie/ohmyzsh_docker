FROM ubuntu:20.04

LABEL maintainer="Yixiong Li liyx357@mail2.sysu.edu.cn"

COPY ./sources.list /etc/apt/sources.list
# Create a no-passowrd sudo user
RUN apt update \
    && apt install -y sudo \
    && useradd -m ubuntu -s /bin/bash && adduser ubuntu sudo \
    && echo "ubuntu ALL=(ALL) NOPASSWD : ALL" | tee /etc/sudoers.d/nopasswd4sudo

# Adjust Timezone
ENV DEBIAN_FRONTEND=noninteractive
RUN apt install -y tzdata \
    && ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

USER ubuntu
WORKDIR /home/ubuntu

COPY ./install.sh /home/ubuntu/install.sh
COPY ./zshrc_template.txt /home/ubuntu/zshrc_template.txt
# # Install zsh
RUN sudo apt install -y git zsh \
    && sudo chsh -s $(which zsh) \
    && sudo chmod +x /home/ubuntu/install.sh \
    && sh -c /home/ubuntu/install.sh  \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && cp /home/ubuntu/zshrc_template.txt /home/ubuntu/.zshrc

# Clean apt-cache
RUN sudo apt autoremove -y \
    && sudo apt clean -y \
    && sudo rm -rf /var/lib/apt/lists/*