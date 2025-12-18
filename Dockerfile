########################################
# STAGE 1 — Build do frontend (React)
########################################
FROM node:18-slim AS frontend-build

WORKDIR /app/client

# Copia apenas o necessário para cache
COPY client/package*.json ./
RUN npm install

# Copia o restante do frontend
COPY client/ ./

# Variáveis de build do React
ENV REACT_APP_API_URL=http://localhost:3001
ENV SKIP_PREFLIGHT_CHECK=true

# Build do React
RUN npm run build

########################################
# STAGE 2 — Build do backend (Node)
########################################
FROM node:18-slim AS backend-build

WORKDIR /app

COPY package*.json ./
RUN npm install --only=production

COPY . .

########################################
# STAGE 3 — Imagem final (runtime)
########################################
FROM node:18-slim

WORKDIR /app

# Copia backend pronto
COPY --from=backend-build /app /app

# Copia build do frontend para servir estático
COPY --from=frontend-build /app/client/build /app/client/build

# Porta padrão do Elastic Beanstalk
EXPOSE 8080

CMD ["npm", "start"]
