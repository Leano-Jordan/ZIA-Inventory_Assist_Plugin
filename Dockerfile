FROM node:22.15.0-alpine
RUN apk add --no-cache openssl

WORKDIR /app
EXPOSE 3000
ENV NODE_ENV=production
ENV PORT=3000

COPY package.json ./
RUN npm install --include=dev
COPY . .

# Generate Prisma after schema is copied into the image.
RUN npx prisma generate
RUN npm run build

CMD ["sh", "-c", "npm run setup && npm run start"]
