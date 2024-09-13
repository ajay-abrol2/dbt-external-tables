#!/bin/bash


echo "Setting up virtual environment for dbt-$1"
cd ..
VENV="venv/bin/activate"

if [[ ! -f $VENV ]]; then
    python3.8 -m venv venv
    . $VENV
    pip install --upgrade pip setuptools
    pip install dbt-vertica --upgrade --pre
    pip install protobuf==4.25.3
fi

. $VENV
echo "Changing working directory: example_external"
cd example_external

echo "Starting Example External Table"
set -eo pipefail
dbt deps
echo "Data load to External Table"
dbt run-operation dbt_external_tables.stage_external_sources --vars 'ext_full_refresh: true' 
echo "Data load to Vendor Performance"
dbt run
dbt docs generate
dbt docs serve
