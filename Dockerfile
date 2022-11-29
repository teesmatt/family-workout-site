FROM node:slim
COPY . .
RUN npm install
CMD [ "node", "index.js" ]
