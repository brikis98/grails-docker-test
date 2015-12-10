FROM onesysadmin/grails:2.4.3
MAINTAINER Yevgeniy Brikman <jim@ybrikman.com>

COPY . /app

ENTRYPOINT ["bash", "-l", "-c"]
CMD ["grails"]