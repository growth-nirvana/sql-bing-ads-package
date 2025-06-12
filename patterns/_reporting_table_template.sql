-- {{table_name | replace: '_', ' ' | capitalize}} Report Transformation
{% assign target_dataset = vars.target_dataset_id %}
{% assign target_table_id = '{{table_name}}' %}
{% assign source_dataset = vars.source_dataset_id %}
{% assign source_table_id = '{{source_table}}' %}

DECLARE latest_run_id INT64;

-- Create target table if it doesn't exist
CREATE TABLE IF NOT EXISTS `{{target_dataset}}.{{target_table_id}}` (
  date DATE,
  account_id STRING,
  campaign_id STRING,
  -- Add other columns here
  metric_1 FLOAT64,
  metric_2 INT64,
  -- ...
  run_id INT64,
  _gn_id STRING,
  _gn_synced TIMESTAMP
)
PARTITION BY date
CLUSTER BY account_id;

-- Get the latest run_id from the source table
SET latest_run_id = (
  SELECT MAX(run_id)
  FROM `{{source_dataset}}.{{source_table_id}}`
);

-- Perform MERGE operation
MERGE `{{target_dataset}}.{{target_table_id}}` T
USING (
  SELECT
    DATE(TimePeriod) AS date,
    CAST(AccountId AS STRING) AS account_id,
    CAST(CampaignId AS STRING) AS campaign_id,
    -- Add other columns and aggregations here
    SUM(Metric1) AS metric_1,
    SUM(Metric2) AS metric_2,
    -- ...
    run_id,
    TO_HEX(SHA256(CONCAT(
      COALESCE(CAST(AccountId AS STRING), ''),
      COALESCE(CAST(CampaignId AS STRING), ''),
      COALESCE(CAST(DATE(TimePeriod) AS STRING), '')
    ))) AS _gn_id,
    CURRENT_TIMESTAMP() AS _gn_synced
  FROM `{{source_dataset}}.{{source_table_id}}`
  -- Optional joins for enrichment
  -- LEFT JOIN `{{source_dataset}}.account_history` ah ON AccountId = ah.id AND ah._gn_active = true
  -- LEFT JOIN `{{source_dataset}}.campaign_history` ch ON CampaignId = ch.id AND ch._gn_active = true
  WHERE run_id = latest_run_id
  GROUP BY date, account_id, campaign_id, run_id
) S
ON T.date = S.date
  AND T.account_id = S.account_id
  AND T.campaign_id = S.campaign_id
WHEN MATCHED THEN
  UPDATE SET
    -- List all columns to update
    metric_1 = S.metric_1,
    metric_2 = S.metric_2,
    -- ...
    run_id = S.run_id,
    _gn_id = S._gn_id,
    _gn_synced = S._gn_synced
WHEN NOT MATCHED THEN
  INSERT (
    date, account_id, campaign_id, metric_1, metric_2, run_id, _gn_id, _gn_synced
  )
  VALUES (
    S.date, S.account_id, S.campaign_id, S.metric_1, S.metric_2, S.run_id, S._gn_id, S._gn_synced
  ); 