{% macro vertica__create_external_table(source_node) %}

    {%- set columns = source_node.columns.values() -%}
    {%- set external = source_node.external -%}
    {%- set partitions = external.partitions -%}

{# https://docs.aws.amazon.com/redshift/latest/dg/r_CREATE_EXTERNAL_TABLE.html #}
{# This assumes you have already created an external schema #}

    create external table {{source(source_node.source_name, source_node.name)}} (
        {% for column in columns %}
            {{adapter.quote(column.name)}} {{column.data_type}}
            {{- ',' if not loop.last -}}
        {% endfor %}
    )
    As copy FROM {{external.location}} 
        {% if external.file_format=='csv' -%}  {{external.exprasion}}  {%- endif %}
        {% if external.file_format=='json' -%} PARSER FJSONPARSER(suppress_warnings='unmatched_key') {%- endif %}
        {% if external.file_format=='avro' -%} WITH PARSER FAVROPARSER() {%- endif %}
        {% if external.file_format=='parquet' -%} PARQUET {%- endif %}
        
    {% if partitions -%} partition columns (
        {%- for partition in partitions -%}
            {{adapter.quote(partition.name)}} {{', ' if not loop.last}}
        {%- endfor -%}
    {%- endif %}
   ;
{% endmacro %}
