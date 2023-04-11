# Set up environment
FROM python:3.10
RUN pip install dnspython pymongo requests twisted
COPY . .

# Define build arguments to be populated by build command (docker build --build-arg BUILD_ARG=value)
ARG MONGO_PASSWORD
ARG LATITUDE
ARG LONGITUDE
ARG EXECUTION_INTERVAL

# Populate environment variables with build arguments
ENV MONGO_PASSWORD=${MONGO_PASSWORD}
ENV LATITUDE=${LATITUDE}
ENV LONGITUDE=${LONGITUDE}
ENV EXECUTION_INTERVAL=${EXECUTION_INTERVAL}

# Define entrypoint
CMD ["python", "./main.py"]