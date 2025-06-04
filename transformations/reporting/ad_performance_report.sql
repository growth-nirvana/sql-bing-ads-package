-- Ad Performance Report Transformation
{% assign target_dataset = vars.target_dataset_id %}
{% assign target_table_id = 'ad_performance_report' %}

{% assign source_dataset = vars.source_dataset_id %}
{% assign source_table_id = 'stream_ad_performance_report' %}

{% if vars.models.switchover_ad_performance_report.active == false %}
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
  ad_id INT64,
  ad_group_id INT64,
  currency_code STRING,
  ad_distribution STRING,
  impressions INT64,
  clicks INT64,
  ctr FLOAT64,
  average_cpc FLOAT64,
  spend FLOAT64,
  average_position FLOAT64,
  conversions FLOAT64,
  conversion_rate FLOAT64,
  cost_per_conversion FLOAT64,
  device_type STRING,
  language STRING,
  network STRING,
  top_vs_other STRING,
  bid_match_type STRING,
  delivered_match_type STRING,
  device_os STRING,
  assists INT64,
  revenue FLOAT64,
  return_on_ad_spend FLOAT64,
  revenue_per_conversion FLOAT64,
  all_conversions STRING,
  all_revenue STRING,
  all_conversion_rate STRING,
  all_cost_per_conversion STRING,
  all_return_on_ad_spend STRING,
  all_revenue_per_conversion STRING,
  view_through_conversions STRING,
  date DATE,
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
    ad_id,
    ad_group_id,
    currency_code,
    ad_distribution,
    impressions,
    clicks,
    ctr,
    average_cpc,
    spend,
    average_position,
    conversions,
    conversion_rate,
    cost_per_conversion,
    device_type,
    language,
    network,
    top_vs_other,
    bid_match_type,
    delivered_match_type,
    device_os,
    assists,
    revenue,
    return_on_ad_spend,
    revenue_per_conversion,
    all_conversions,
    all_revenue,
    all_conversion_rate,
    all_cost_per_conversion,
    all_return_on_ad_spend,
    all_revenue_per_conversion,
    view_through_conversions,
    date,
    _gn_id,
    _gn_synced
  )
  SELECT 
    AccountId,
    CampaignId,
    AdId,
    AdGroupId,
    CurrencyCode,
    AdDistribution,
    Impressions,
    Clicks,
    Ctr,
    AverageCpc,
    Spend,
    AveragePosition,
    Conversions,
    ConversionRate,
    CostPerConversion,
    DeviceType,
    Language,
    Network,
    TopVsOther,
    BidMatchType,
    DeliveredMatchType,
    DeviceOS,
    Assists,
    Revenue,
    ReturnOnAdSpend,
    RevenuePerConversion,
    AllConversions,
    AllRevenue,
    AllConversionRate,
    AllCostPerConversion,
    AllReturnOnAdSpend,
    AllRevenuePerConversion,
    ViewThroughConversions,
    DATE(TimePeriod),
    TO_HEX(SHA256(CONCAT(
      COALESCE(CAST(AccountId AS STRING), ''),
      COALESCE(CAST(CampaignId AS STRING), ''),
      COALESCE(CAST(AdId AS STRING), ''),
      COALESCE(CAST(AdGroupId AS STRING), ''),
      COALESCE(DeviceType, ''),
      COALESCE(Network, ''),
      COALESCE(TimePeriod, '')
    ))) AS _gn_id,
    CURRENT_TIMESTAMP() AS _gn_synced
  FROM latest_batch;

COMMIT TRANSACTION;

-- Drop the source table after successful insertion
DROP TABLE IF EXISTS `{{source_dataset}}.{{source_table_id}}`;

END IF;

{% endif %} 