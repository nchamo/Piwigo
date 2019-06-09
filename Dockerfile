FROM ubuntu:16.04

RUN apt-get update -y
RUN apt-get install -y php7.0 php7.0-gd php7.0-mysqli php7.0-json php7.0-zip imagemagick exiftool libjpeg-progs

ADD . /piwigo/piwigo

RUN mkdir -p /piwigo/piwigo/_data /piwigo/piwigo/_data/i
RUN adduser --system --home /piwigo --disabled-password piwigo
RUN chown -R piwigo /piwigo

WORKDIR /piwigo
USER piwigo

VOLUME ["/piwigo/piwigo/galleries", "/piwigo/piwigo/local", "/piwigo/piwigo/plugins", " /piwigo/piwigo/themes", "/piwigo/piwigo/_data/i", "piwigo/piwigo/upload"]

CMD ["php","-S","0.0.0.0:9000","-t","piwigo"]
