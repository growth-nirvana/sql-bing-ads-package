# Ad Performance Report Table

This table contains detailed performance metrics for individual ads in Bing Ads, with one row per ad, date, and account. It provides comprehensive insights into ad-level performance, enabling detailed analysis of creative effectiveness and optimization opportunities.

## Table Structure

| Column                    | Type      | Description                                                                 |
|--------------------------|-----------|-----------------------------------------------------------------------------|
| account_id               | INT64     | The numeric ID of the account                                               |
| campaign_id              | INT64     | The numeric ID of the campaign                                              |
| ad_id                    | INT64     | The numeric ID of the ad                                                    |
| ad_group_id              | INT64     | The numeric ID of the ad group                                              |
| currency_code            | STRING    | The currency code for monetary values                                       |
| ad_distribution          | STRING    | The distribution settings for the ad                                        |
| impressions              | INT64     | Number of times the ad was shown                                            |
| clicks                   | INT64     | Number of clicks the ad received                                            |
| ctr                      | FLOAT64   | Click-through rate (clicks/impressions)                                     |
| average_cpc              | FLOAT64   | Average cost per click                                                      |
| spend                    | FLOAT64   | Total amount spent on the ad                                                |
| average_position         | FLOAT64   | Average position of the ad in search results                                |
| conversions              | FLOAT64   | Number of conversions attributed to the ad                                  |
| conversion_rate          | FLOAT64   | Conversion rate (conversions/clicks)                                        |
| cost_per_conversion      | FLOAT64   | Average cost per conversion                                                 |
| device_type              | STRING    | The type of device used (e.g., Mobile, Desktop)                             |
| language                 | STRING    | The language of the ad                                                      |
| network                  | STRING    | The network where the ad was shown                                          |
| top_vs_other             | STRING    | Indicates if the ad appeared in top or other positions                      |
| bid_match_type           | STRING    | The match type used for bidding                                             |
| delivered_match_type     | STRING    | The actual match type that triggered the ad                                 |
| device_os                | STRING    | The operating system of the device                                          |
| assists                  | INT64     | Number of assisted conversions                                              |
| revenue                  | FLOAT64   | Total revenue attributed to the ad                                          |
| return_on_ad_spend       | FLOAT64   | Return on ad spend (revenue/spend)                                          |
| revenue_per_conversion   | FLOAT64   | Average revenue per conversion                                              |
| all_conversions          | STRING    | All conversion types attributed to the ad                                   |
| all_revenue              | STRING    | Total revenue from all conversion types                                     |
| all_conversion_rate      | STRING    | Conversion rate for all conversion types                                    |
| all_cost_per_conversion  | STRING    | Cost per conversion for all conversion types                                |
| all_return_on_ad_spend   | STRING    | Return on ad spend for all conversion types                                 |
| all_revenue_per_conversion | STRING  | Revenue per conversion for all conversion types                            |
| view_through_conversions | STRING    | View-through conversions attributed to the ad                               |
| date                     | DATE      | The reporting date for the record                                           |
| _gn_id                   | STRING    | Hash of key dimensions for deduplication and uniqueness                     |
| _gn_synced               | TIMESTAMP | Timestamp when the record was last synced                                   |

## How to Use This Table

- **Ad Performance Analysis**: Compare performance metrics across different ads to identify top performers
- **Device Performance**: Analyze performance by `device_type` and `device_os` to optimize for specific platforms
- **Network Performance**: Compare performance across different `network` types
- **Match Type Analysis**: Compare performance across different `bid_match_type` and `delivered_match_type` combinations
- **Conversion Analysis**: Analyze both standard and all conversion metrics to understand full funnel performance
- **Revenue Analysis**: Track `revenue`, `return_on_ad_spend`, and revenue per conversion metrics for ROI analysis
- **Position Analysis**: Use `average_position` to understand ad placement effectiveness
- **Language Performance**: Analyze performance by `language` to optimize for different markets

## Notes

- The `_gn_id` column is a deterministic hash of key dimensions (`account_id`, `campaign_id`, `ad_id`, `ad_group_id`, `device_type`, `network`, `TimePeriod`) for uniqueness and deduplication
- All fields used in the hash are cast to STRING for type safety and consistency
- The table is designed for easy joins with other Bing Ads reporting and dimension tables
- Data is updated incrementally, with existing records for the same date range and account being replaced during updates
- The table maintains referential integrity with other Bing Ads tables through the various ID fields 