-- campaign_history
-- Campaigns History Transformation
{% assign target_dataset = vars.target_dataset_id %}
{% assign target_table_id = 'campaign_history' %}

{% assign source_dataset = vars.source_dataset_id %}
{% assign source_table_id = 'campaigns' %}

{% if vars.models.switchover_campaigns_history.active == false %}
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
  audience_ads_bid_adjustment INT64,
  bidding_scheme STRING,
  budget_type STRING,
  daily_budget FLOAT64,
  experiment_id INT64,
  name STRING,
  status STRING,
  time_zone STRING,
  tracking_url_template STRING,
  campaign_type STRING,
  settings STRING,
  budget_id INT64,
  languages STRING,
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
    SAFE_CAST(AudienceAdsBidAdjustment AS INT64) AS audience_ads_bid_adjustment,
    BiddingScheme AS bidding_scheme,
    BudgetType AS budget_type,
    DailyBudget AS daily_budget,
    SAFE_CAST(ExperimentId AS INT64) AS experiment_id,
    Name AS name,
    Status AS status,
    TimeZone AS time_zone,
    TrackingUrlTemplate AS tracking_url_template,
    CampaignType AS campaign_type,
    Settings AS settings,
    SAFE_CAST(BudgetId AS INT64) AS budget_id,
    Languages AS languages,
    tenant AS tenant,
    TO_HEX(SHA256(CONCAT(
      COALESCE(CAST(AudienceAdsBidAdjustment AS STRING), ''),
      COALESCE(BiddingScheme, ''),
      COALESCE(BudgetType, ''),
      COALESCE(CAST(DailyBudget AS STRING), ''),
      COALESCE(CAST(ExperimentId AS STRING), ''),
      COALESCE(Name, ''),
      COALESCE(Status, ''),
      COALESCE(TimeZone, ''),
      COALESCE(TrackingUrlTemplate, ''),
      COALESCE(CampaignType, ''),
      COALESCE(Settings, ''),
      COALESCE(CAST(BudgetId AS STRING), ''),
      COALESCE(Languages, ''),
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
    audience_ads_bid_adjustment = source.audience_ads_bid_adjustment,
    bidding_scheme = source.bidding_scheme,
    budget_type = source.budget_type,
    daily_budget = source.daily_budget,
    experiment_id = source.experiment_id,
    name = source.name,
    status = source.status,
    time_zone = source.time_zone,
    tracking_url_template = source.tracking_url_template,
    campaign_type = source.campaign_type,
    settings = source.settings,
    budget_id = source.budget_id,
    languages = source.languages,
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
    audience_ads_bid_adjustment,
    bidding_scheme,
    budget_type,
    daily_budget,
    experiment_id,
    name,
    status,
    time_zone,
    tracking_url_template,
    campaign_type,
    settings,
    budget_id,
    languages,
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
    source.audience_ads_bid_adjustment,
    source.bidding_scheme,
    source.budget_type,
    source.daily_budget,
    source.experiment_id,
    source.name,
    source.status,
    source.time_zone,
    source.tracking_url_template,
    source.campaign_type,
    source.settings,
    source.budget_id,
    source.languages,
    source.tenant,
    source._gn_id
  );

-- Drop the source table after successful insertion
DROP TABLE IF EXISTS `{{source_dataset}}.{{source_table_id}}`;

END IF;

{% endif %} 