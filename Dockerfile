# Pull the latest Julia image
FROM julia:latest

# Install Nginx and Supervisor
RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    curl \
    && apt-get clean

COPY WebApps/nginx.conf /etc/nginx/nginx.conf


# Create a dedicated user for running the apps
RUN useradd --create-home --shell /bin/bash genie

# Set up the app directories
RUN mkdir /home/genie/FactSimply /home/genie/MultiPageApp

# Copy both app directories into the container
COPY FactSimply /home/genie/FactSimply
COPY MultiPageApp /home/genie/MultiPageApp
COPY WebApps /home/genie/WebApps

# Configure permissions
RUN chown -R genie:genie /home/

#USER genie

# Expose the necessary ports
EXPOSE 80
EXPOSE 8000
EXPOSE 8080

# Set up environment variables
ENV JULIA_DEPOT_PATH="/home/genie/.julia"
ENV JULIA_REVISE="off"
ENV GENIE_ENV="prod"
ENV GENIE_HOST="0.0.0.0"
ENV EARLYBIND="true"

#CMD /usr/sbin/nginx -g 'daemon on;'

CMD ["/usr/bin/supervisord", "-c", "/home/genie/WebApps/supervisord.conf"]
