FROM ubuntu:18.04

RUN apt-get update \ 
    && apt-get install -y git sudo
# sudo
## unsure if this is necessary, if so, `docker run --user ubuntu`
# RUN useradd ubuntu -m -s /bin/bash \
#     && usermod -aG sudo ubuntu

# RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu \
#     && touch /home/ubuntu/.sudo_as_admin_successful \
#     && chown ubuntu.ubuntu /home/ubuntu/.sudo_as_admin_successful

ENV HOME /root

WORKDIR $HOME

RUN git clone https://github.com/steffen-sbt/RTX-KG2.git

# ARG CACHEBUST=3

# RUN echo $(pwd)

# RUN echo $(ls)

# RUN echo $(ls -1 RTX-KG2)

# RUN bash -x RTX-KG2/setup-kg2-build.sh