# Campaign Performance Report Table

This table contains detailed performance metrics for campaigns in Bing Ads, with one row per campaign, date, and account. It provides comprehensive insights into campaign performance, including quality metrics, low-quality traffic analysis, and conversion tracking, enabling detailed analysis and optimization opportunities.

## Table Structure

| Column                            | Type      | Description                                                                 |
|----------------------------------|-----------|-----------------------------------------------------------------------------|
| account_id                        | INT64     | The numeric ID of the account                                               |
| campaign_status                   | STRING    | The current status of the campaign                                          |
| campaign_name                     | STRING    | The display name of the campaign                                            |
| campaign_id                       | INT64     | The numeric ID of the campaign                                              |
| currency_code                     | STRING    | The currency code for monetary values                                       |
| ad_distribution                   | STRING    | The distribution settings for the campaign                                  |
| impressions                       | INT64     | Number of times ads were shown                                              |
| clicks                           | INT64     | Number of clicks received                                                   |
| ctr                              | FLOAT64   | Click-through rate (clicks/impressions)                                     |
| average_cpc                      | FLOAT64   | Average cost per click                                                      |
| spend                            | FLOAT64   | Total amount spent on the campaign                                          |
| average_position                 | FLOAT64   | Average position of ads in search results                                   |
| conversions                      | FLOAT64   | Number of conversions attributed to the campaign                            |
| conversion_rate                  | FLOAT64   | Conversion rate (conversions/clicks)                                        |
| cost_per_conversion              | FLOAT64   | Average cost per conversion                                                 |
| low_quality_clicks               | INT64     | Number of low-quality clicks                                                |
| low_quality_clicks_percent       | FLOAT64   | Percentage of clicks that are low quality                                   |
| low_quality_impressions          | INT64     | Number of low-quality impressions                                           |
| low_quality_impressions_percent  | FLOAT64   | Percentage of impressions that are low quality                              |
| low_quality_conversions          | INT64     | Number of conversions from low-quality traffic                              |
| low_quality_conversion_rate      | FLOAT64   | Conversion rate for low-quality traffic                                     |
| device_type                      | STRING    | The type of device used (e.g., Mobile, Desktop)                             |
| device_os                        | STRING    | The operating system of the device                                          |
| quality_score                    | FLOAT64   | Current quality score of the campaign                                       |
| expected_ctr                     | FLOAT64   | Expected click-through rate                                                 |
| ad_relevance                     | FLOAT64   | Ad relevance score                                                          |
| landing_page_experience          | FLOAT64   | Landing page experience score                                               |
| historical_quality_score         | STRING    | Historical quality score data                                               |
| historical_expected_ctr          | STRING    | Historical expected CTR data                                                |
| historical_ad_relevance          | STRING    | Historical ad relevance data                                                |
| historical_landing_page_experience | STRING  | Historical landing page experience data                                     |
| phone_impressions                | INT64     | Number of phone impression opportunities                                    |
| phone_calls                      | INT64     | Number of phone calls received                                              |
| network                          | STRING    | The network where the ads were shown                                        |
| top_vs_other                     | STRING    | Indicates if ads appeared in top or other positions                         |
| bid_match_type                   | STRING    | The match type used for bidding                                             |
| delivered_match_type             | STRING    | The actual match type that triggered the ads                                |
| assists                          | INT64     | Number of assisted conversions                                              |
| revenue                          | FLOAT64   | Total revenue attributed to the campaign                                    |
| return_on_ad_spend               | FLOAT64   | Return on ad spend (revenue/spend)                                          |
| revenue_per_conversion           | FLOAT64   | Average revenue per conversion                                              |
| budget_association_status        | STRING    | Status of budget association                                                |
| low_quality_general_clicks       | INT64     | Number of general low-quality clicks                                        |
| low_quality_sophisticated_clicks | INT64     | Number of sophisticated low-quality clicks                                  |
| all_conversions                  | STRING    | All conversion types attributed to the campaign                             |
| all_revenue                      | STRING    | Total revenue from all conversion types                                     |
| all_conversion_rate              | STRING    | Conversion rate for all conversion types                                    |
| all_cost_per_conversion          | STRING    | Cost per conversion for all conversion types                                |
| all_return_on_ad_spend           | STRING    | Return on ad spend for all conversion types                                 |
| all_revenue_per_conversion       | STRING    | Revenue per conversion for all conversion types                             |
| view_through_conversions         | STRING    | View-through conversions attributed to the campaign                         |
| average_cpm                      | STRING    | Average cost per thousand impressions                                       |
| date                             | DATE      | The reporting date for the record                                           |
| _gn_id                           | STRING    | Hash of key dimensions for deduplication and uniqueness                     |
| _gn_synced                       | TIMESTAMP | Timestamp when the record was last synced                                   |

## How to Use This Table

- **Campaign Performance Analysis**: Compare performance metrics across different campaigns to identify top performers
- **Quality Analysis**: Monitor `quality_score`, `expected_ctr`, `ad_relevance`, and `landing_page_experience` to optimize campaign performance
- **Low-Quality Traffic Analysis**: Track `low_quality_clicks`, `low_quality_impressions`, and related metrics to identify and address quality issues
- **Device Performance**: Analyze performance by `device_type` and `device_os` to optimize for specific platforms
- **Network Performance**: Compare performance across different `network` types
- **Phone Call Tracking**: Monitor `phone_impressions` and `phone_calls` for call extension performance
- **Conversion Analysis**: Analyze both standard and all conversion metrics to understand full funnel performance
- **Revenue Analysis**: Track `revenue`, `return_on_ad_spend`, and revenue per conversion metrics for ROI analysis
- **Budget Analysis**: Monitor `budget_association_status` and spend metrics to optimize budget allocation

## Notes

- The `_gn_id` column is a deterministic hash of key dimensions (`account_id`, `campaign_id`, `campaign_status`, `device_type`, `network`, `TimePeriod`) for uniqueness and deduplication
- All fields used in the hash are cast to STRING for type safety and consistency
- The table is designed for easy joins with other Bing Ads reporting and dimension tables
- Data is updated incrementally, with existing records for the same date range and account being replaced during updates
- The table maintains referential integrity with other Bing Ads tables through the various ID fields 