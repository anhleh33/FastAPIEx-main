FROM python:3.8.1-alpine

WORKDIR /src

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

EXPOSE 8000

# Copy requirements file first to leverage cache if dependencies don't change
COPY ./requirements.txt /src/requirements.txt

# Install system dependencies and Python packages
RUN set -eux \
    && apk add --no-cache --virtual .build-deps build-base \
        libressl-dev libffi-dev gcc musl-dev python3-dev \
        postgresql-dev \
    && pip install --upgrade pip setuptools wheel \
    && pip install -r /src/requirements.txt \
    && apk del .build-deps \
    && rm -rf /root/.cache/pip

# Copy project files after dependencies installed
COPY . /src/

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
