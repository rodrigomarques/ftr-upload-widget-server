#Imagem muito grande
#FROM node:20.18

# Imagem mais leve
FROM node:20-alpine3.21 AS base

RUN npm i -g pnpm

FROM base AS dependencies

#Directório de trabalho
WORKDIR /usr/src/app

# Copia os arquivos de configuração do projeto
COPY package.json pnpm-lock.yaml ./

# Copia o código fonte do projeto
RUN pnpm install

FROM base AS build

WORKDIR /usr/src/app

# Copia o restante do código fonte do projeto
COPY . .
# Copiar o node_modules da imagem de dependências
# Isso é necessário para que o build funcione corretamente
COPY --from=dependencies /usr/src/app/node_modules ./node_modules

RUN pnpm build
RUN pnpm prune --prod

#Imagem de execução
#FROM node:20-alpine3.21 AS deploy

#Usar o Distroless do google
FROM gcr.io/distroless/nodejs20-debian12 AS deploy

#Usuario criadfo no build do alpine sem ser root
USER 1000

#RUN npm i -g pnpm

WORKDIR /usr/src/app

COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/node_modules ./node_modules
COPY --from=build /usr/src/app/package.json ./package.json


#ENV CLOUDFLARE_ACCOUNT_ID="91ce49d61822d7880ffd800a9089c1b1"
#ENV CLOUDFLARE_ACCESS_KEY_ID="55f79f01d6fa8ffc264ef77fcd322b95"
#ENV CLOUDFLARE_SECRET_ACCESS_KEY="c2f8791d3da87725930d56078e0534558582fa0bc48f82a7a48cfc0e71cf7b71"
#ENV CLOUDFLARE_BUCKET="upload-server"
#ENV CLOUDFLARE_PUBLIC_URL="https://pub-cbdaaf82413c40679980f39edbf35598.r2.dev"

EXPOSE 3333

#CMD ["pnpm", "start" ]
#CMD ["node", "dist/server.mjs" ]
CMD ["dist/server.mjs" ]