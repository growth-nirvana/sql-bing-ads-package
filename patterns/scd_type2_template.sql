-- SCD Type 2 Transformation Pattern
{% assign target_dataset = vars.target_dataset_id %}
{% assign target_table_id = 'table_name_history' %}

{% assign source_dataset = vars.source_dataset_id %}
{% assign source_table_id = 'stream_table_name' %}

{% if vars.models.switchover_table_name_history.active == false %}
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
  id INT64,  -- Primary key of the entity
  _gn_active BOOL,
  _gn_end TIMESTAMP,
  _gn_synced TIMESTAMP,
  updated_at TIMESTAMP,
  -- Add your business columns here
  _gn_id STRING  -- Hash of all business columns for change detection
);

-- Step 1: Create temp table for latest batch with deduplication
CREATE TEMP TABLE latest_batch AS
WITH base AS (
  SELECT *
  FROM `{{source_dataset}}.{{source_table_id}}`
)
SELECT 
  CURRENT_TIMESTAMP() AS _gn_start,
  CAST(id AS INT64) AS id,  -- Adjust based on your source ID field
  TRUE AS _gn_active,
  CAST(NULL AS TIMESTAMP) AS _gn_end,
  CURRENT_TIMESTAMP() AS _gn_synced,
  TIMESTAMP '9999-01-01' AS updated_at,
  -- Map your source columns to target columns here
  TO_HEX(SHA256(CONCAT(
    -- Add all business columns to the hash
    COALESCE(CAST(id AS STRING), ''),
    -- Add other columns to hash
    -- Example: COALESCE(column_name, '')
  ))) AS _gn_id
FROM base;

-- Step 2: Handle SCD Type 2 changes
BEGIN TRANSACTION;

  -- Close existing active records that have changed
  UPDATE `{{target_dataset}}.{{target_table_id}}` target
  SET 
    _gn_active = FALSE,
    _gn_end = CURRENT_TIMESTAMP()
  WHERE target._gn_active = TRUE
    AND target.id IN (SELECT id FROM latest_batch)
    AND EXISTS (
      SELECT 1
      FROM latest_batch source
      WHERE source.id = target.id
        AND source._gn_id != target._gn_id
    );

  -- Insert new records
  INSERT INTO `{{target_dataset}}.{{target_table_id}}` (
    _gn_start,
    id,
    _gn_active,
    _gn_end,
    _gn_synced,
    updated_at
    -- Add your business columns here
  )
  SELECT 
    _gn_start,
    id,
    _gn_active,
    _gn_end,
    _gn_synced,
    updated_at
    -- Add your business columns here
  FROM latest_batch source
  WHERE NOT EXISTS (
    SELECT 1
    FROM `{{target_dataset}}.{{target_table_id}}` target
    WHERE target.id = source.id
      AND target._gn_active = TRUE
  );

COMMIT TRANSACTION;

-- Drop the source table after successful insertion
DROP TABLE IF EXISTS `{{source_dataset}}.{{source_table_id}}`;

END IF;

{% endif %} 