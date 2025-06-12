-- Combined Performance Report Transformation
{% assign target_dataset = vars.combined_report_dataset_id %}
{% assign target_table_id = 'combined_performance_report' %}

{% assign source_dataset = vars.target_dataset_id %}
DECLARE latest_run_id INT64;

-- Create target table if it doesn't exist
CREATE TABLE IF NOT EXISTS `{{target_dataset}}.{{target_table_id}}` (
  date DATE,
  account_id STRING,
  account_name STRING,
  campaign_id STRING,
  campaign_name STRING,
  spend FLOAT64,
  clicks INT64,
  impressions INT64,
  conversions FLOAT64,
  channel STRING,
  segment STRING,
  run_id INT64,
  _gn_id STRING,
  _gn_synced TIMESTAMP
)
PARTITION BY date,segment
CLUSTER BY account_id;

-- Get the latest run_id from the source table
SET latest_run_id = (
  SELECT MAX(run_id)
  FROM `{{source_dataset}}.campaign_performance_report`
);

-- Perform MERGE operation
MERGE `{{target_dataset}}.{{target_table_id}}` T
USING (
  SELECT 
    date,
    'MICROSOFT_ADS' as channel,
    'PERFORMANCE' as segment,
    CAST(account_id AS STRING) as account_id,
    ah.name as account_name,
    CAST(campaign_id AS STRING) as campaign_id,
    campaign_name,
    run_id,
    TO_HEX(SHA256(CONCAT(
      COALESCE(CAST(account_id AS STRING), ''),
      COALESCE(CAST(campaign_id AS STRING), ''),
      COALESCE(CAST(date AS STRING), '')
    ))) AS _gn_id,
    CURRENT_TIMESTAMP() AS _gn_synced,
    SUM(spend) as spend,
    SUM(clicks) as clicks,
    SUM(impressions) as impressions,
    SUM(conversions) as conversions,
  FROM `{{source_dataset}}.campaign_performance_report` report
  LEFT JOIN `{{source_dataset}}.account_history` ah
    ON report.account_id = ah.id
    AND ah._gn_active = true
  WHERE run_id = latest_run_id
  GROUP BY 
    1,2,3,4,5,6,7,8,9,10
) S
ON T.date = S.date 
  AND T.account_id = S.account_id 
  AND T.campaign_id = S.campaign_id
WHEN MATCHED THEN
  UPDATE SET
    account_name = S.account_name,
    campaign_name = S.campaign_name,
    spend = S.spend,
    clicks = S.clicks,
    impressions = S.impressions,
    conversions = S.conversions,
    channel = S.channel,
    segment = S.segment,
    run_id = S.run_id,
    _gn_id = S._gn_id,
    _gn_synced = S._gn_synced
WHEN NOT MATCHED THEN
  INSERT (
    date, account_id, account_name, campaign_id, campaign_name,
    spend, clicks, impressions, conversions, channel, segment,
    run_id, _gn_id, _gn_synced
  )
  VALUES (
    S.date, S.account_id, S.account_name, S.campaign_id, S.campaign_name,
    S.spend, S.clicks, S.impressions, S.conversions, S.channel, S.segment,
    S.run_id, S._gn_id, S._gn_synced
  );