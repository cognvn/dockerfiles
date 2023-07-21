ARG APP_PATH=/opt/outline
FROM node:16-alpine AS base

ARG APP_PATH
WORKDIR $APP_PATH
ARG BUILD_TAG=v0.67.2
ADD https://github.com/outline/outline/archive/$BUILD_TAG.tar.gz /tmp
RUN tar -xzvf /tmp/$BUILD_TAG.tar.gz -C $APP_PATH --strip-components=1; \
  rm /tmp/$BUILD_TAG.tar.gz; \
  sed -i '/return "public-read";/d' ./server/models/helpers/AttachmentHelper.ts; \
  yarn install --no-optional --frozen-lockfile --network-timeout 1000000; \
  yarn cache clean; \
  yarn build; \
  rm -rf node_modules; \
  yarn install --production --frozen-lockfile --network-timeout 1000000; \
  yarn cache clean;

# ---
FROM node:16-alpine AS runner
ARG APP_PATH=/opt/outline
WORKDIR $APP_PATH
ENV NODE_ENV production

COPY --from=base $APP_PATH/build ./build
COPY --from=base $APP_PATH/server ./server
COPY --from=base $APP_PATH/public ./public
COPY --from=base $APP_PATH/.sequelizerc ./.sequelizerc
COPY --from=base $APP_PATH/node_modules ./node_modules
COPY --from=base $APP_PATH/package.json ./package.json

RUN addgroup -g 1001 -S outline && \
  adduser -S outline -u 1001 && \
  chown -R outline:outline $APP_PATH/build

USER outline

EXPOSE 3000
CMD ["yarn", "start"]
