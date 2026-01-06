-- ad_groups
-- Ad Groups History Transformation
{% assign target_dataset = vars.target_dataset_id %}
{% assign target_table_id = 'ad_group_history' %}

{% assign source_dataset = vars.source_dataset_id %}
{% assign source_table_id = 'ad_groups' %}

{% if vars.models.switchover_ad_groups_history.active == false %}
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
  ad_rotation STRING,
  bidding_scheme STRING,
  cpc_bid STRING,
  end_date STRING,
  language STRING,
  name STRING,
  network STRING,
  settings STRING,
  start_date STRING,
  status STRING,
  url_custom_parameters STRING,
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
    AdRotation AS ad_rotation,
    BiddingScheme AS bidding_scheme,
    CpcBid AS cpc_bid,
    EndDate AS end_date,
    Language AS language,
    Name AS name,
    Network AS network,
    Settings AS settings,
    StartDate AS start_date,
    Status AS status,
    UrlCustomParameters AS url_custom_parameters,
    tenant AS tenant,
    TO_HEX(SHA256(CONCAT(
      COALESCE(AdRotation, ''),
      COALESCE(BiddingScheme, ''),
      COALESCE(CpcBid, ''),
      COALESCE(EndDate, ''),
      COALESCE(Language, ''),
      COALESCE(Name, ''),
      COALESCE(Network, ''),
      COALESCE(Settings, ''),
      COALESCE(StartDate, ''),
      COALESCE(Status, ''),
      COALESCE(UrlCustomParameters, ''),
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
    ad_rotation = source.ad_rotation,
    bidding_scheme = source.bidding_scheme,
    cpc_bid = source.cpc_bid,
    end_date = source.end_date,
    language = source.language,
    name = source.name,
    network = source.network,
    settings = source.settings,
    start_date = source.start_date,
    status = source.status,
    url_custom_parameters = source.url_custom_parameters,
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
    ad_rotation,
    bidding_scheme,
    cpc_bid,
    end_date,
    language,
    name,
    network,
    settings,
    start_date,
    status,
    url_custom_parameters,
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
    source.ad_rotation,
    source.bidding_scheme,
    source.cpc_bid,
    source.end_date,
    source.language,
    source.name,
    source.network,
    source.settings,
    source.start_date,
    source.status,
    source.url_custom_parameters,
    source.tenant,
    source._gn_id
  );

-- Drop the source table after successful insertion
DROP TABLE IF EXISTS `{{source_dataset}}.{{source_table_id}}`;

END IF;

{% endif %} 