FROM oven/bun:1-alpine AS build
WORKDIR /app

RUN apk add --no-cache git bash

COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

COPY . .
RUN bash scripts/sync-content.sh
RUN bunx astro build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
