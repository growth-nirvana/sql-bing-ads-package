-- ad_history
-- Ads History Transformation
{% assign target_dataset = vars.target_dataset_id %}
{% assign target_table_id = 'ad_history' %}

{% assign source_dataset = vars.source_dataset_id %}
{% assign source_table_id = 'ads' %}

{% if vars.models.switchover_ads_history.active == false %}
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
  ad_format_preference STRING,
  device_preference INT64,
  editorial_status STRING,
  final_mobile_urls STRING,
  final_urls STRING,
  status STRING,
  type STRING,
  text STRING,
  path1 STRING,
  path2 STRING,
  text_part2 STRING,
  domain STRING,
  title_part1 STRING,
  title_part2 STRING,
  title_part3 STRING,
  tenant STRING,
  _gn_id STRING
);

-- MERGE from source table (source is truncated on each run, so no deduplication needed)
MERGE `{{target_dataset}}.{{target_table_id}}` target
USING (
  SELECT 
    CURRENT_TIMESTAMP() AS _gn_start,
    Id AS id,
    TRUE AS _gn_active,
    CAST(NULL AS TIMESTAMP) AS _gn_end,
    CURRENT_TIMESTAMP() AS _gn_synced,
    _time_loaded AS updated_at,
    AdFormatPreference AS ad_format_preference,
    DevicePreference AS device_preference,
    EditorialStatus AS editorial_status,
    FinalMobileUrls AS final_mobile_urls,
    FinalUrls AS final_urls,
    Status AS status,
    Type AS type,
    Text AS text,
    Path1 AS path1,
    Path2 AS path2,
    TextPart2 AS text_part2,
    Domain AS domain,
    TitlePart1 AS title_part1,
    TitlePart2 AS title_part2,
    TitlePart3 AS title_part3,
    tenant AS tenant,
    TO_HEX(SHA256(CONCAT(
      COALESCE(AdFormatPreference, ''),
      COALESCE(CAST(DevicePreference AS STRING), ''),
      COALESCE(EditorialStatus, ''),
      COALESCE(FinalMobileUrls, ''),
      COALESCE(FinalUrls, ''),
      COALESCE(Status, ''),
      COALESCE(Type, ''),
      COALESCE(Text, ''),
      COALESCE(Path1, ''),
      COALESCE(Path2, ''),
      COALESCE(TextPart2, ''),
      COALESCE(Domain, ''),
      COALESCE(TitlePart1, ''),
      COALESCE(TitlePart2, ''),
      COALESCE(TitlePart3, ''),
      COALESCE(tenant, '')
    ))) AS _gn_id
  FROM `{{source_dataset}}.{{source_table_id}}`
) source
ON target.id = source.id
WHEN MATCHED THEN
  UPDATE SET
    _gn_start = source._gn_start,
    _gn_active = source._gn_active,
    _gn_end = source._gn_end,
    _gn_synced = source._gn_synced,
    updated_at = source.updated_at,
    ad_format_preference = source.ad_format_preference,
    device_preference = source.device_preference,
    editorial_status = source.editorial_status,
    final_mobile_urls = source.final_mobile_urls,
    final_urls = source.final_urls,
    status = source.status,
    type = source.type,
    text = source.text,
    path1 = source.path1,
    path2 = source.path2,
    text_part2 = source.text_part2,
    domain = source.domain,
    title_part1 = source.title_part1,
    title_part2 = source.title_part2,
    title_part3 = source.title_part3,
    tenant = source.tenant,
    _gn_id = source._gn_id
WHEN NOT MATCHED THEN
  INSERT (
    _gn_start,
    id,
    _gn_active,
    _gn_end,
    _gn_synced,
    updated_at,
    ad_format_preference,
    device_preference,
    editorial_status,
    final_mobile_urls,
    final_urls,
    status,
    type,
    text,
    path1,
    path2,
    text_part2,
    domain,
    title_part1,
    title_part2,
    title_part3,
    tenant,
    _gn_id
  )
  VALUES (
    source._gn_start,
    source.id,
    source._gn_active,
    source._gn_end,
    source._gn_synced,
    source.updated_at,
    source.ad_format_preference,
    source.device_preference,
    source.editorial_status,
    source.final_mobile_urls,
    source.final_urls,
    source.status,
    source.type,
    source.text,
    source.path1,
    source.path2,
    source.text_part2,
    source.domain,
    source.title_part1,
    source.title_part2,
    source.title_part3,
    source.tenant,
    source._gn_id
  );

-- Drop the source table after successful insertion
DROP TABLE IF EXISTS `{{source_dataset}}.{{source_table_id}}`;

END IF;

{% endif %} 