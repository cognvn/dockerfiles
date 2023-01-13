FROM mirotalk/sfu:latest as build

#==================
FROM node:lts-alpine

WORKDIR /src

ADD https://github.com/miroslavpejic85/mirotalksfu/archive/main.tar.gz /tmp/mirotalk.tar.gz
RUN tar -xzf /tmp/mirotalk.tar.gz --strip-components=1; \
    cp app/src/config.template.js app/src/config.js; \
    rm /tmp/mirotalk.tar.gz;
COPY --from=build /src/node_modules ./node_modules

CMD yarn start