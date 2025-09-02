# syntax=docker/dockerfile:1
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

COPY src/ /app/src/
ENV PYTHONUNBUFFERED=1
EXPOSE 8080

# adjust if your entrypoint differs
CMD ["python", "src/app.py"]
