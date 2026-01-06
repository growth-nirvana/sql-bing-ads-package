-- goals_and_funnels_report
-- Goals and Funnels Report Transformation
{% assign target_dataset = vars.target_dataset_id %}
{% assign target_table_id = 'goals_and_funnels_report' %}

{% assign source_dataset = vars.source_dataset_id %}
{% assign source_table_id = 'goals_and_funnels_report' %}

{% if vars.models.switchover_goals_and_funnels_report.active == false %}
select 1
{% else %}
DECLARE min_date DATE;
DECLARE max_date DATE;
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
  account_id INT64,
  campaign_id INT64,
  ad_group_id INT64,
  keyword_id INT64,
  goal STRING,
  all_conversions STRING,
  assists INT64,
  all_revenue STRING,
  goal_id INT64,
  device_type STRING,
  device_os STRING,
  goal_type STRING,
  view_through_conversions STRING,
  date DATE,
  run_id INT64,
  _gn_id STRING,
  _gn_synced TIMESTAMP
);

-- Step 1: Create temp table for latest batch
CREATE TEMP TABLE latest_batch AS
SELECT *
FROM `{{source_dataset}}.{{source_table_id}}`
WHERE run_id = (
  SELECT MAX(run_id)
  FROM `{{source_dataset}}.{{source_table_id}}`
);

-- Step 2: Assign min/max dates using SET + scalar subqueries
SET min_date = (
  SELECT MIN(DATE(TimePeriod)) FROM latest_batch
);

SET max_date = (
  SELECT MAX(DATE(TimePeriod)) FROM latest_batch
);

-- Step 3: Conditional delete and insert
BEGIN TRANSACTION;

  IF EXISTS (
    SELECT 1
    FROM `{{target_dataset}}.{{target_table_id}}`
    WHERE date BETWEEN min_date AND max_date
      AND account_id IN (
        SELECT DISTINCT AccountId
        FROM latest_batch
      )
    LIMIT 1
  ) THEN
    DELETE FROM `{{target_dataset}}.{{target_table_id}}`
    WHERE date BETWEEN min_date AND max_date
      AND account_id IN (
        SELECT DISTINCT AccountId
        FROM latest_batch
      );
  END IF;

  INSERT INTO `{{target_dataset}}.{{target_table_id}}` (
    account_id,
    campaign_id,
    ad_group_id,
    keyword_id,
    goal,
    all_conversions,
    assists,
    all_revenue,
    goal_id,
    device_type,
    device_os,
    goal_type,
    view_through_conversions,
    date,
    run_id,
    _gn_id,
    _gn_synced
  )
  SELECT 
    AccountId,
    CampaignId,
    AdGroupId,
    KeywordId,
    Goal,
    AllConversions,
    Assists,
    AllRevenue,
    GoalId,
    DeviceType,
    DeviceOS,
    GoalType,
    ViewThroughConversions,
    DATE(TimePeriod),
    run_id,
    TO_HEX(SHA256(CONCAT(
      COALESCE(CAST(AccountId AS STRING), ''),
      COALESCE(CAST(CampaignId AS STRING), ''),
      COALESCE(CAST(AdGroupId AS STRING), ''),
      COALESCE(CAST(KeywordId AS STRING), ''),
      COALESCE(CAST(GoalId AS STRING), ''),
      COALESCE(Goal, ''),
      COALESCE(DeviceType, ''),
      COALESCE(CAST(TimePeriod AS STRING), '')
    ))) AS _gn_id,
    CURRENT_TIMESTAMP() AS _gn_synced
  FROM latest_batch;

COMMIT TRANSACTION;

-- Drop the source table after successful insertion
DROP TABLE IF EXISTS `{{source_dataset}}.{{source_table_id}}`;

END IF;

{% endif %} 