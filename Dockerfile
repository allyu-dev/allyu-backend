# Etapa 1: instalar dependencias y compilar TypeScript
FROM node:20-bookworm-slim AS build

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY tsconfig.json ./
COPY src ./src

RUN npm run build


# Etapa 2: imagen final, solo para ejecutar la API
FROM node:20-bookworm-slim AS production

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY --from=build /app/dist ./dist

USER node

EXPOSE 3000

CMD ["node", "dist/server.js"]