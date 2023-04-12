# Set up environment
FROM python:3.10
RUN pip install dnspython pymongo flask waitress
COPY . .

# Define build arguments to be populated by build command (docker build --build-arg BUILD_ARG=value)
ARG MONGO_PASSWORD

# Populate environment variables with build arguments
ENV MONGO_PASSWORD=${MONGO_PASSWORD}

# Define entrypoint
CMD ["python", "./app.py"]