#!/bin/bash

# dev database
helm install \
    --name bots-db-dev \
    --set imageTag={{getenv "IMAGE_TAG"}},postgresUser={{getenv "POSTGRES_USER"}},postgresPassword={{getenv "POSTGRES_PASSWORD"}},postgresDatabase={{getenv "POSTGRES_DATABASE"}},persistence.size={{getenv "PERSISTENCE_SIZE"}} \
    stable/postgresql
