FROM node:5.7.1

RUN npm install -g artillery artillery-plugin-statsd
ADD ./run_artillery.sh /bin/

VOLUME /code
WORKDIR /code

ENTRYPOINT ["/bin/run_artillery.sh"]
