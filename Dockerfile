FROM ubuntu:16.04

RUN apt-get update -y
RUN apt-get install -y php7.0 php7.0-gd php7.0-mysqli php7.0-json php7.0-zip imagemagick exiftool libjpeg-progs

#RUN mkdir /piwigo
ADD . /piwigo/piwigo

RUN adduser --system --home /piwigo --disabled-password piwigo
RUN chown -R piwigo /piwigo

WORKDIR /piwigo
USER piwigo

CMD ["php","-S","0.0.0.0:9000","-t","piwigo"]
