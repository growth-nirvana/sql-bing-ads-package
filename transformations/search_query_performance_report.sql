-- search_query_performance_report
-- Search Query Performance Report Transformation
{% assign target_dataset = vars.target_dataset_id %}
{% assign target_table_id = 'search_query_performance_report' %}

{% assign source_dataset = vars.source_dataset_id %}
{% assign source_table_id = 'stream_search_query_performance_report' %}

{% if vars.models.switchover_search_query_performance_report.active == false %}
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
  account_number STRING,
  account_id INT64,
  campaign_id INT64,
  ad_group_id INT64,
  ad_id INT64,
  bid_match_type STRING,
  delivered_match_type STRING,
  impressions INT64,
  clicks INT64,
  ctr FLOAT64,
  average_cpc FLOAT64,
  spend FLOAT64,
  average_position FLOAT64,
  search_query STRING,
  conversions FLOAT64,
  conversion_rate FLOAT64,
  cost_per_conversion FLOAT64,
  language STRING,
  keyword_id INT64,
  network STRING,
  top_vs_other STRING,
  device_type STRING,
  device_os STRING,
  assists INT64,
  revenue FLOAT64,
  return_on_ad_spend FLOAT64,
  revenue_per_conversion FLOAT64,
  customer_id STRING,
  all_conversions STRING,
  all_revenue STRING,
  all_conversion_rate STRING,
  all_return_on_ad_spend STRING,
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
    account_number,
    account_id,
    campaign_id,
    ad_group_id,
    ad_id,
    bid_match_type,
    delivered_match_type,
    impressions,
    clicks,
    ctr,
    average_cpc,
    spend,
    average_position,
    search_query,
    conversions,
    conversion_rate,
    cost_per_conversion,
    language,
    keyword_id,
    network,
    top_vs_other,
    device_type,
    device_os,
    assists,
    revenue,
    return_on_ad_spend,
    revenue_per_conversion,
    customer_id,
    all_conversions,
    all_revenue,
    all_conversion_rate,
    all_return_on_ad_spend,
    date,
    run_id,
    _gn_id,
    _gn_synced
  )
  SELECT 
    AccountNumber,
    AccountId,
    CampaignId,
    AdGroupId,
    AdId,
    BidMatchType,
    DeliveredMatchType,
    Impressions,
    Clicks,
    Ctr,
    AverageCpc,
    Spend,
    AveragePosition,
    SearchQuery,
    Conversions,
    ConversionRate,
    CostPerConversion,
    Language,
    KeywordId,
    Network,
    TopVsOther,
    DeviceType,
    DeviceOS,
    Assists,
    Revenue,
    ReturnOnAdSpend,
    RevenuePerConversion,
    CustomerId,
    AllConversions,
    AllRevenue,
    AllConversionRate,
    AllReturnOnAdSpend,
    DATE(TimePeriod),
    run_id,
    TO_HEX(SHA256(CONCAT(
      COALESCE(AccountNumber, ''),
      COALESCE(CAST(AccountId AS STRING), ''),
      COALESCE(CAST(CampaignId AS STRING), ''),
      COALESCE(CAST(AdGroupId AS STRING), ''),
      COALESCE(CAST(AdId AS STRING), ''),
      COALESCE(CAST(KeywordId AS STRING), ''),
      COALESCE(SearchQuery, ''),
      COALESCE(DeviceType, ''),
      COALESCE(Network, ''),
      COALESCE(CAST(TimePeriod AS STRING), '')
    ))) AS _gn_id,
    CURRENT_TIMESTAMP() AS _gn_synced
  FROM latest_batch;

COMMIT TRANSACTION;

-- Drop the source table after successful insertion
DROP TABLE IF EXISTS `{{source_dataset}}.{{source_table_id}}`;

END IF;

{% endif %} 