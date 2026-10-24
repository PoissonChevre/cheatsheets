# Image for a simple Python web app (app.py + requirements.txt)
# Build: docker build -t myapp:1.0 .
# Run:   docker run -d -p 8000:8000 myapp:1.0

FROM python:3.12-slim

WORKDIR /app

# Install the dependencies first: Docker keeps this step in cache
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the code
COPY . .

# Don't run as root
RUN useradd --create-home appuser
USER appuser

EXPOSE 8000
CMD ["python", "app.py"]
