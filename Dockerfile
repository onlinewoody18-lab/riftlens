# RiftLens online version. Runs the same app in online mode: the Riot key and region come
# from environment variables, settings are locked, and visitors' data stays in their browsers.
FROM node:22-alpine
WORKDIR /app
COPY package.json ./
COPY server ./server
COPY public ./public
ENV NODE_ENV=production \
    RIFTLENS_HOSTED=1 \
    DATA_DIR=/data \
    PORT=3170
RUN mkdir -p /data && chown node:node /data
USER node
VOLUME ["/data"]
EXPOSE 3170
HEALTHCHECK --interval=60s --timeout=5s CMD wget -qO- http://127.0.0.1:3170/api/status >/dev/null || exit 1
CMD ["node", "server/index.js"]
