FROM onesysadmin/grails:2.4.3
MAINTAINER Yevgeniy Brikman <jim@ybrikman.com>

# Copy the code in
COPY . /app

# Build the war so all the code is pre-compiled, reducing start up time for
# this Docker container
RUN bash -l -c "grails war"

ENTRYPOINT ["bash", "-l", "-c"]
CMD ["grails"]