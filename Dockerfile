# Pull the latest Julia image
FROM julia:latest

# Install Nginx and Supervisor
RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    curl \
    && apt-get clean


#CMD ["/usr/sbin/nginx",  "-g", "'daemon on;'"]

# Create a dedicated user for running the apps
RUN useradd --create-home --shell /bin/bash genie

# Configure permissions
RUN chown -R genie:genie /home/

# Set up the app directories
RUN mkdir /home/genie/FactSimply /home/genie/MultiPageApp

# Copy both app directories into the container
COPY FactSimply /home/genie/FactSimply
COPY MultiPageApp /home/genie/MultiPageApp
COPY WebApps /home/genie/WebApps
COPY WebApps/nginx.conf /etc/nginx/nginx.conf

#

# Expose the necessary ports
EXPOSE 80
EXPOSE 8000
EXPOSE 8080

# Switch to the genie user
#USER genie

# Set up environment variables
ENV JULIA_DEPOT_PATH="/home/genie/.julia"
ENV GENIE_ENV="prod"
ENV GENIE_HOST="0.0.0.0"
ENV EARLYBIND="true"
ENV HOST="0.0.0.0"

#CMD /usr/sbin/nginx -g 'daemon on;'

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/home/genie/WebApps/supervisord.conf"]
