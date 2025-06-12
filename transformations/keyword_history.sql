-- keyword_history
-- Keywords History SCD Type 2 Transformation
{% assign target_dataset = vars.target_dataset_id %}
{% assign target_table_id = 'keyword_history' %}

{% assign source_dataset = vars.source_dataset_id %}
{% assign source_table_id = 'keywords' %}

{% if vars.models.switchover_keywords_history.active == false %}
select 1
{% else %}
DECLARE table_exists BOOL DEFAULT FALSE;

-- Check if the source table exists
SET table_exists = (
  SELECT COUNT(*) > 0
  FROM `{{source_dataset}}.INFORMATION_SCHEMA.TABLES`
  WHERE table_name = '{{source_table_id}}'
);

-- Only proceed if the source table exists
IF table_exists THEN

-- Create target table if it doesn't exist
CREATE TABLE IF NOT EXISTS `{{target_dataset}}.{{target_table_id}}` (
  _gn_start TIMESTAMP,
  id INT64,
  _gn_active BOOL,
  _gn_end TIMESTAMP,
  _gn_synced TIMESTAMP,
  updated_at TIMESTAMP,
  bid STRING,
  final_urls STRING,
  match_type STRING,
  text STRING,
  tenant STRING,
  _gn_id STRING
);

-- Step 1: Create temp table for latest batch with deduplication
CREATE TEMP TABLE latest_batch AS
WITH base AS (
  SELECT *
  FROM `{{source_dataset}}.{{source_table_id}}`
)
SELECT 
  CURRENT_TIMESTAMP() AS _gn_start,
  Id AS id,
  TRUE AS _gn_active,
  CAST(NULL AS TIMESTAMP) AS _gn_end,
  CURRENT_TIMESTAMP() AS _gn_synced,
  _time_loaded AS updated_at,
  Bid AS bid,
  FinalUrls AS final_urls,
  MatchType AS match_type,
  Text AS text,
  tenant AS tenant,
  TO_HEX(SHA256(CONCAT(
    COALESCE(Bid, ''),
    COALESCE(FinalUrls, ''),
    COALESCE(MatchType, ''),
    COALESCE(Text, ''),
    COALESCE(tenant, '')
  ))) AS _gn_id
FROM base;

-- Step 2: Handle SCD Type 2 changes using MERGE
MERGE `{{target_dataset}}.{{target_table_id}}` target
USING latest_batch source
ON target.id = source.id AND target._gn_active = TRUE
WHEN MATCHED AND target._gn_id != source._gn_id THEN
  UPDATE SET
    _gn_active = FALSE,
    _gn_end = CURRENT_TIMESTAMP()
WHEN NOT MATCHED THEN
  INSERT (
    _gn_start,
    id,
    _gn_active,
    _gn_end,
    _gn_synced,
    updated_at,
    bid,
    final_urls,
    match_type,
    text,
    tenant,
    _gn_id
  )
  VALUES (
    _gn_start,
    id,
    _gn_active,
    _gn_end,
    _gn_synced,
    updated_at,
    bid,
    final_urls,
    match_type,
    text,
    tenant,
    _gn_id
  );

-- Drop the source table after successful insertion
DROP TABLE IF EXISTS `{{source_dataset}}.{{source_table_id}}`;

END IF;

{% endif %} 