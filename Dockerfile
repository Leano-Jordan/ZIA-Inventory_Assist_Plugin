FROM node:22.15.0-alpine
RUN apk add --no-cache openssl

EXPOSE 3000

WORKDIR /app

ENV NODE_ENV=production

COPY package.json ./

RUN npm install --include=dev

COPY . .

# Prisma's install hook runs before the schema is copied into the image.
# Generate the client explicitly now so the app build has the generated client.
RUN npx prisma generate && npm run build

CMD ["sh", "-c", "npm run setup && npm run start"]
