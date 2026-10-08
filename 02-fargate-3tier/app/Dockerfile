# https://docs.docker.com/reference/dockerfile/
FROM public.ecr.aws/docker/library/python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app

EXPOSE 80

# https://www.uvicorn.org/settings/
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]
