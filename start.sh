#!/bin/bash

su - postgres -c "prestogres-ctl postgres -D $PGDATA 2>&1 > /tmp/postgres.log &"
sleep 5
prestogres-ctl migrate
prestogres-ctl pgpool

