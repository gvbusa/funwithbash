FROM arm64v8/nginx:latest

# copy nginx configuration
COPY conf/nginx.conf /etc/nginx/nginx.conf

# create /var/nginx directory
RUN mkdir -p /var/nginx

# expose ports 80 and 443
EXPOSE 80
EXPOSE 443
