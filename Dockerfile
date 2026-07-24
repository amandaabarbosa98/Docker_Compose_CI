# Estágio 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .

# Estágio 2: Imagem Final
FROM node:20-alpine
WORKDIR /app

# Copia as dependências e o código
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app ./

# Cria o diretório do banco de dados e concede permissão ao usuário node
RUN mkdir -p /etc/todos && chown -R node:node /etc/todos

EXPOSE 3000
USER node

CMD ["node", "src/index.js"]
