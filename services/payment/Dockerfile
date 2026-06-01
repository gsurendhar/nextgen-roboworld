# # Stage 1: Build
# FROM python:3.9.23-alpine3.22 AS builder
# WORKDIR /build
# # Install build dependencies
# RUN apk add --no-cache python3-dev build-base linux-headers pcre-dev
# COPY requirements.txt .
# RUN pip3 install --no-cache-dir --prefix=/install -r requirements.txt


# # Stage 2: Final image
# FROM python:3.9.23-alpine3.22
# EXPOSE 8080
# WORKDIR /opt/server
# # Runtime dependencies only
# RUN apk add --no-cache pcre
# # Create app user
# RUN addgroup -S roboshop && adduser -S roboshop -G roboshop
# USER roboshop
# # Copy installed Python packages from builder
# COPY --from=builder /install /usr/local
# # Copy application code
# COPY --chown=roboshop:roboshop payment.ini .
# COPY --chown=roboshop:roboshop *.py .


# CMD ["uwsgi", "--ini", "payment.ini", "--uid", "roboshop", "--gid", "roboshop"]





FROM python:3.9.23-alpine3.22 AS builder
WORKDIR /build
RUN apk  --no-cache add python3-dev build-base linux-headers pcre-dev
COPY requirements.txt .
RUN pip3 install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.9.23-alpine3.22
WORKDIR /opt/server
ENV CART_HOST="cart" \
    CART_PORT="8080" \
    USER_HOST="user" \
    USER_PORT="8080" \
    AMQP_HOST="rabbitmq" \
    AMQP_USER="roboshop" \
    AMQP_PASS="roboshop123"
RUN apk add --no-cache pcre
RUN addgroup -S roboshop && adduser -S roboshop -G roboshop
USER roboshop
COPY --from=builder /install /usr/local
COPY --chown=roboshop:roboshop payment.ini .
COPY --chown=roboshop:roboshop *.py .
CMD ["uwsgi", "--ini", "payment.ini"]






# FROM python:3.9-alpine3.22
# EXPOSE 8080
# WORKDIR /opt/server
# COPY payment.ini .
# COPY requirements.txt .
# COPY *.py .
# RUN apk add python3-dev build-base linux-headers pcre-dev
# RUN pip3 install -r requirements.txt
# ENV CART_HOST="cart" \
#     CART_PORT="8080" \
#     USER_HOST="user" \
#     USER_PORT="8080" \
#     AMQP_HOST="rabbitmq" \
#     AMQP_USER="roboshop" \
#     AMQP_PASS="roboshop123"
# CMD ["uwsgi", "--ini", "payment.ini"]
