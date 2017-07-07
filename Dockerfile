#On choisit une debian
FROM debian:latest

MAINTAINER DiouxX "github@diouxx.be"

#Ne pas poser de question à l'installation
ENV DEBIAN_FRONTEND noninteractive

RUN apt update \
&& apt -y install nano cyrus-admin cyrus-clients cyrus-common cyrus-imapd libauthen-sasl-cyrus-perl libcyrus-imap-perl sasl2-bin

#Config file
COPY config/cyrus.conf /etc/

#Config Script
COPY postfix-start.sh /opt/
RUN chmod +x /opt/postfix-start.sh

ENTRYPOINT ["/opt/postfix-start.sh"]
