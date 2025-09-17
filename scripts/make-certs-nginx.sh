#!/bin/bash

# Create directory for certificates if it doesn't exist
CERT_DIR="/etc/nginx/certs"
mkdir -p $CERT_DIR

# Domain or IP to create certificate for
DOMAIN=${1:-127.0.0.1}

# Generate SSL certificate
openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
  -keyout $CERT_DIR/$DOMAIN.key -out $CERT_DIR/$DOMAIN.crt \
  -extensions san \
  -config <(echo "[req]"; 
          echo "distinguished_name=req";
          echo "[san]";
          echo "subjectAltName=DNS:$DOMAIN,DNS:www.$DOMAIN") \
  -subj "/CN=$DOMAIN"

# Set permissions
chmod 640 $CERT_DIR/$DOMAIN.key
chmod 644 $CERT_DIR/$DOMAIN.crt

echo "Certificates created at:"
echo "Private key: $CERT_DIR/$DOMAIN.key"
echo "Certificate: $CERT_DIR/$DOMAIN.crt"
echo ""
echo "Add to your Nginx site configuration:"
echo "    ssl_certificate     $CERT_DIR/$DOMAIN.crt;"
echo "    ssl_certificate_key $CERT_DIR/$DOMAIN.key;"