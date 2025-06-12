# Ad Extension Detail Report Table

This table contains detailed performance metrics for ad extensions in Bing Ads, with one row per ad extension, date, and account. It provides comprehensive insights into how different types of ad extensions are performing, enabling detailed analysis of extension effectiveness and optimization opportunities.

## Table Structure

| Column                    | Type      | Description                                                                 |
|--------------------------|-----------|-----------------------------------------------------------------------------|
| account_name             | STRING    | The display name of the account                                            |
| account_id               | INT64     | The numeric ID of the account                                              |
| campaign_name            | STRING    | The display name of the campaign                                           |
| campaign_id              | INT64     | The numeric ID of the campaign                                             |
| ad_group_name            | STRING    | The display name of the ad group                                           |
| ad_group_id              | INT64     | The numeric ID of the ad group                                             |
| ad_id                    | INT64     | The numeric ID of the ad                                                   |
| ad_extension_type        | STRING    | The type of ad extension (e.g., Sitelink, Callout)                         |
| ad_extension_type_id     | STRING    | The ID of the extension type                                               |
| ad_extension_id          | STRING    | The unique identifier for the ad extension                                 |
| ad_extension_version     | STRING    | The version of the ad extension                                            |
| ad_extension_property_value | STRING | The value of the extension property                                       |
| impressions              | INT64     | Number of times the extension was shown                                    |
| device_type              | STRING    | The type of device used (e.g., Mobile, Desktop)                            |
| device_os                | STRING    | The operating system of the device                                         |
| clicks                   | INT64     | Number of clicks the extension received                                    |
| ctr                      | FLOAT64   | Click-through rate (clicks/impressions)                                    |
| conversions              | FLOAT64   | Number of conversions attributed to the extension                          |
| cost_per_conversion      | FLOAT64   | Average cost per conversion                                                |
| conversion_rate          | FLOAT64   | Conversion rate (conversions/clicks)                                       |
| spend                    | FLOAT64   | Total amount spent on the extension                                        |
| average_cpc              | FLOAT64   | Average cost per click                                                     |
| bid_match_type           | STRING    | The match type used for bidding                                            |
| delivered_match_type     | STRING    | The actual match type that triggered the ad                                |
| network                  | STRING    | The network where the extension was shown                                  |
| top_vs_other             | STRING    | Indicates if the extension appeared in top or other positions              |
| assists                  | INT64     | Number of assisted conversions                                            |
| revenue                  | FLOAT64   | Total revenue attributed to the extension                                  |
| return_on_ad_spend       | FLOAT64   | Return on ad spend (revenue/spend)                                         |
| cost_per_assist          | FLOAT64   | Average cost per assisted conversion                                       |
| revenue_per_conversion   | FLOAT64   | Average revenue per conversion                                             |
| revenue_per_assist       | FLOAT64   | Average revenue per assisted conversion                                    |
| account_status           | STRING    | The status of the account                                                  |
| campaign_status          | STRING    | The status of the campaign                                                 |
| ad_group_status          | STRING    | The status of the ad group                                                 |
| ad_status                | STRING    | The status of the ad                                                       |
| all_conversions          | STRING    | All conversion types attributed to the extension                           |
| all_revenue              | STRING    | Total revenue from all conversion types                                    |
| all_conversion_rate      | STRING    | Conversion rate for all conversion types                                   |
| all_cost_per_conversion  | STRING    | Cost per conversion for all conversion types                               |
| all_return_on_ad_spend   | STRING    | Return on ad spend for all conversion types                                |
| all_revenue_per_conversion | STRING  | Revenue per conversion for all conversion types                           |
| goal                     | STRING    | The conversion goal being tracked                                          |
| goal_type                | STRING    | The type of conversion goal                                                |
| date                     | DATE      | The reporting date for the record                                          |
| _gn_id                   | STRING    | Hash of key dimensions for deduplication and uniqueness                    |
| _gn_synced               | TIMESTAMP | Timestamp when the record was last synced                                  |

## How to Use This Table

- **Extension Performance Analysis**: Analyze performance by `ad_extension_type` to identify the most effective extension types
- **Property Value Analysis**: Use `ad_extension_property_value` to understand which specific extension content performs best
- **Device Insights**: Analyze performance by `device_type` and `device_os` to optimize extensions for specific platforms
- **Network Performance**: Compare performance across different `network` types
- **Status Analysis**: Monitor `account_status`, `campaign_status`, `ad_group_status`, and `ad_status` for health checks
- **Conversion Analysis**: Analyze both standard and all conversion metrics to understand full funnel performance
- **Revenue Analysis**: Track `revenue`, `return_on_ad_spend`, and revenue per conversion/assist metrics for ROI analysis
- **Goal Tracking**: Use `goal` and `goal_type` to analyze performance against specific conversion objectives

## Notes

- The `_gn_id` column is a deterministic hash of key dimensions (`account_id`, `campaign_id`, `ad_group_id`, `ad_id`, `ad_extension_id`, `TimePeriod`) for uniqueness and deduplication
- All fields used in the hash are cast to STRING for type safety and consistency
- The table is designed for easy joins with other Bing Ads reporting and dimension tables
- Data is updated incrementally, with existing records for the same date range and account being replaced during updates
- The table maintains referential integrity with other Bing Ads tables through the various ID fields 