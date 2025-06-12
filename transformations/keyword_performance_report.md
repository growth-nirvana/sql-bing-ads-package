# Keyword Performance Report Table

This table contains detailed performance metrics for keywords in Bing Ads campaigns, with one row per keyword, date, and account. It provides comprehensive insights into keyword performance, including quality metrics, match type analysis, and conversion tracking, enabling detailed analysis and optimization opportunities.

## Table Structure

| Column                            | Type      | Description                                                                 |
|----------------------------------|-----------|-----------------------------------------------------------------------------|
| account_id                        | INT64     | The numeric ID of the account                                               |
| campaign_id                       | INT64     | The numeric ID of the campaign                                              |
| ad_group_id                       | INT64     | The numeric ID of the ad group                                              |
| keyword_id                        | INT64     | The numeric ID of the keyword                                               |
| ad_id                            | INT64     | The numeric ID of the ad                                                    |
| current_max_cpc                   | FLOAT64   | Current maximum cost per click bid                                          |
| currency_code                     | STRING    | The currency code for monetary values                                       |
| delivered_match_type              | STRING    | The actual match type that triggered the ads                                |
| ad_distribution                   | STRING    | The distribution settings for the ads                                       |
| impressions                       | INT64     | Number of times ads were shown                                              |
| clicks                           | INT64     | Number of clicks received                                                   |
| ctr                              | FLOAT64   | Click-through rate (clicks/impressions)                                     |
| average_cpc                      | FLOAT64   | Average cost per click                                                      |
| spend                            | FLOAT64   | Total amount spent on the keyword                                           |
| average_position                 | FLOAT64   | Average position of ads in search results                                   |
| conversions                      | FLOAT64   | Number of conversions attributed to the keyword                             |
| conversion_rate                  | FLOAT64   | Conversion rate (conversions/clicks)                                        |
| cost_per_conversion              | FLOAT64   | Average cost per conversion                                                 |
| bid_match_type                   | STRING    | The match type used for bidding                                             |
| device_type                      | STRING    | The type of device used (e.g., Mobile, Desktop)                             |
| quality_score                    | FLOAT64   | Current quality score of the keyword                                        |
| expected_ctr                     | FLOAT64   | Expected click-through rate                                                 |
| ad_relevance                     | FLOAT64   | Ad relevance score                                                          |
| landing_page_experience          | FLOAT64   | Landing page experience score                                               |
| language                         | STRING    | The language of the keyword                                                 |
| historical_quality_score         | STRING    | Historical quality score data                                               |
| historical_expected_ctr          | STRING    | Historical expected CTR data                                                |
| historical_ad_relevance          | STRING    | Historical ad relevance data                                                |
| historical_landing_page_experience | STRING  | Historical landing page experience data                                     |
| quality_impact                   | FLOAT64   | Impact of quality score on ad performance                                   |
| keyword_status                   | STRING    | Current status of the keyword                                               |
| network                          | STRING    | The network where the ads were shown                                        |
| top_vs_other                     | STRING    | Indicates if ads appeared in top or other positions                         |
| device_os                        | STRING    | The operating system of the device                                          |
| assists                          | INT64     | Number of assisted conversions                                              |
| revenue                          | FLOAT64   | Total revenue attributed to the keyword                                     |
| return_on_ad_spend               | FLOAT64   | Return on ad spend (revenue/spend)                                          |
| revenue_per_conversion           | FLOAT64   | Average revenue per conversion                                              |
| all_conversions                  | STRING    | All conversion types attributed to the keyword                              |
| all_revenue                      | STRING    | Total revenue from all conversion types                                     |
| all_conversion_rate              | STRING    | Conversion rate for all conversion types                                    |
| all_cost_per_conversion          | STRING    | Cost per conversion for all conversion types                                |
| all_return_on_ad_spend           | STRING    | Return on ad spend for all conversion types                                 |
| all_revenue_per_conversion       | STRING    | Revenue per conversion for all conversion types                             |
| view_through_conversions         | STRING    | View-through conversions attributed to the keyword                          |
| date                             | DATE      | The reporting date for the record                                           |
| _gn_id                           | STRING    | Hash of key dimensions for deduplication and uniqueness                     |
| _gn_synced                       | TIMESTAMP | Timestamp when the record was last synced                                   |

## How to Use This Table

- **Keyword Performance Analysis**: Compare performance metrics across different keywords to identify top performers
- **Quality Analysis**: Monitor `quality_score`, `expected_ctr`, `ad_relevance`, and `landing_page_experience` to optimize keyword performance
- **Match Type Analysis**: Compare performance across different `bid_match_type` and `delivered_match_type` combinations
- **Device Performance**: Analyze performance by `device_type` and `device_os` to optimize for specific platforms
- **Network Performance**: Compare performance across different `network` types
- **Position Analysis**: Monitor `average_position` and `top_vs_other` to understand ad placement performance
- **Conversion Analysis**: Analyze both standard and all conversion metrics to understand full funnel performance
- **Revenue Analysis**: Track `revenue`, `return_on_ad_spend`, and revenue per conversion metrics for ROI analysis
- **Historical Analysis**: Use historical quality metrics to track performance trends over time

## Notes

- The `_gn_id` column is a deterministic hash of key dimensions (`account_id`, `campaign_id`, `ad_group_id`, `keyword_id`, `ad_id`, `keyword_status`, `device_type`, `network`, `TimePeriod`) for uniqueness and deduplication
- All fields used in the hash are cast to STRING for type safety and consistency
- The table is designed for easy joins with other Bing Ads reporting and dimension tables
- Data is updated incrementally, with existing records for the same date range and account being replaced during updates
- The table maintains referential integrity with other Bing Ads tables through the various ID fields 