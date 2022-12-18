#!/usr/bin/sh

db=tasker

for file in $(ls test_data/*.sql); do
    psql -f ${file} ${db}
done
