--ad_extension_detail_report
-- Ad Extension Detail Report Transformation
{% assign target_dataset = vars.target_dataset_id %}
{% assign target_table_id = 'ad_extension_detail_report' %}

{% assign source_dataset = vars.source_dataset_id %}
{% assign source_table_id = 'ad_extension_detail_report' %}

{% if vars.models.switchover_ad_extension_detail_report.active == false %}
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
  account_name STRING,
  account_id INT64,
  campaign_name STRING,
  campaign_id INT64,
  ad_group_name STRING,
  ad_group_id INT64,
  ad_id INT64,
  ad_extension_type STRING,
  ad_extension_type_id STRING,
  ad_extension_id STRING,
  ad_extension_version STRING,
  ad_extension_property_value STRING,
  impressions INT64,
  device_type STRING,
  device_os STRING,
  clicks INT64,
  ctr FLOAT64,
  conversions FLOAT64,
  cost_per_conversion FLOAT64,
  conversion_rate FLOAT64,
  spend FLOAT64,
  average_cpc FLOAT64,
  bid_match_type STRING,
  delivered_match_type STRING,
  network STRING,
  top_vs_other STRING,
  assists INT64,
  revenue FLOAT64,
  return_on_ad_spend FLOAT64,
  cost_per_assist FLOAT64,
  revenue_per_conversion FLOAT64,
  revenue_per_assist FLOAT64,
  account_status STRING,
  campaign_status STRING,
  ad_group_status STRING,
  ad_status STRING,
  all_conversions STRING,
  all_revenue STRING,
  all_conversion_rate STRING,
  all_cost_per_conversion STRING,
  all_return_on_ad_spend STRING,
  all_revenue_per_conversion STRING,
  goal STRING,
  goal_type STRING,
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
    account_name,
    account_id,
    campaign_name,
    campaign_id,
    ad_group_name,
    ad_group_id,
    ad_id,
    ad_extension_type,
    ad_extension_type_id,
    ad_extension_id,
    ad_extension_version,
    ad_extension_property_value,
    impressions,
    device_type,
    device_os,
    clicks,
    ctr,
    conversions,
    cost_per_conversion,
    conversion_rate,
    spend,
    average_cpc,
    bid_match_type,
    delivered_match_type,
    network,
    top_vs_other,
    assists,
    revenue,
    return_on_ad_spend,
    cost_per_assist,
    revenue_per_conversion,
    revenue_per_assist,
    account_status,
    campaign_status,
    ad_group_status,
    ad_status,
    all_conversions,
    all_revenue,
    all_conversion_rate,
    all_cost_per_conversion,
    all_return_on_ad_spend,
    all_revenue_per_conversion,
    goal,
    goal_type,
    date,
    run_id,
    _gn_id,
    _gn_synced
  )
  SELECT 
    AccountName,
    AccountId,
    CampaignName,
    CampaignId,
    AdGroupName,
    AdGroupId,
    AdId,
    AdExtensionType,
    AdExtensionTypeId,
    AdExtensionId,
    AdExtensionVersion,
    AdExtensionPropertyValue,
    Impressions,
    DeviceType,
    DeviceOS,
    Clicks,
    Ctr,
    Conversions,
    CostPerConversion,
    ConversionRate,
    Spend,
    AverageCpc,
    BidMatchType,
    DeliveredMatchType,
    Network,
    TopVsOther,
    Assists,
    Revenue,
    ReturnOnAdSpend,
    CostPerAssist,
    RevenuePerConversion,
    RevenuePerAssist,
    AccountStatus,
    CampaignStatus,
    AdGroupStatus,
    AdStatus,
    AllConversions,
    AllRevenue,
    AllConversionRate,
    AllCostPerConversion,
    AllReturnOnAdSpend,
    AllRevenuePerConversion,
    Goal,
    GoalType,
    DATE(TimePeriod),
    run_id,
    TO_HEX(SHA256(CONCAT(
      COALESCE(CAST(AccountId AS STRING), ''),
      COALESCE(CAST(CampaignId AS STRING), ''),
      COALESCE(CAST(AdGroupId AS STRING), ''),
      COALESCE(CAST(AdId AS STRING), ''),
      COALESCE(CAST(AdExtensionId AS STRING), ''),
      COALESCE(CAST(TimePeriod AS STRING), '')
    ))) AS _gn_id,
    CURRENT_TIMESTAMP() AS _gn_synced
  FROM latest_batch;

COMMIT TRANSACTION;

-- Drop the source table after successful insertion
DROP TABLE IF EXISTS `{{source_dataset}}.{{source_table_id}}`;

END IF;

{% endif %} 