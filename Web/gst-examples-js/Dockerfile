FROM node:bookworm-slim

COPY ./dist ./dist
RUN npm install -g serve

EXPOSE 3000
CMD ["serve", "-s", "dist", "-l", "3000"]
# docker build . -t hexaforce/gst-examples-js
