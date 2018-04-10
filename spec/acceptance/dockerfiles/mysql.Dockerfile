FROM mysql:5
ENV container docker

ENV MYSQL_ROOT_PASSWORD toor
ENV MYSQL_DATABASE sentry
ENV MYSQL_USER sentry
ENV MYSQL_PASSWORD sentry

RUN apt-get update
RUN apt-get install -y openssh-server openssh-client curl ntpdate lsb-release
RUN echo root:root | chpasswd

RUN sed -ri 's/^#?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/^#?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN sed -ri 's/^#?UseDNS .*/UseDNS no/' /etc/ssh/sshd_config
# fix broken ssh restart
RUN sed -i 's/--retry 30//' /etc/init.d/ssh

EXPOSE 22

CMD ["sh","-c","service ssh start && exec /usr/local/bin/docker-entrypoint.sh mysqld"]
