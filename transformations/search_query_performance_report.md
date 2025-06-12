# Search Query Performance Report Table

This table contains detailed performance metrics for search queries in Bing Ads, with one row per search query, date, and account. It provides comprehensive insights into how users are finding and interacting with ads through search queries, enabling detailed analysis of search term performance and optimization opportunities.

## Table Structure

| Column                | Type      | Description                                                                 |
|----------------------|-----------|-----------------------------------------------------------------------------|
| account_number       | STRING    | The account number identifier                                               |
| account_id           | INT64     | The numeric ID of the account                                               |
| campaign_id          | INT64     | The numeric ID of the campaign                                              |
| ad_group_id          | INT64     | The numeric ID of the ad group                                              |
| ad_id                | INT64     | The numeric ID of the ad                                                    |
| keyword_id           | INT64     | The numeric ID of the keyword                                               |
| search_query         | STRING    | The actual search query that triggered the ad                               |
| bid_match_type       | STRING    | The match type used for bidding                                            |
| delivered_match_type | STRING    | The actual match type that triggered the ad                                |
| device_type          | STRING    | The type of device used (e.g., Mobile, Desktop)                            |
| device_os            | STRING    | The operating system of the device                                         |
| network              | STRING    | The network where the ad was shown                                         |
| language             | STRING    | The language of the search query                                           |
| top_vs_other         | STRING    | Indicates if the ad appeared in top or other positions                     |
| impressions          | INT64     | Number of times the ad was shown                                           |
| clicks               | INT64     | Number of clicks the ad received                                           |
| ctr                  | FLOAT64   | Click-through rate (clicks/impressions)                                    |
| average_cpc          | FLOAT64   | Average cost per click                                                     |
| spend                | FLOAT64   | Total amount spent on the search query                                     |
| average_position     | FLOAT64   | Average position of the ad in search results                               |
| conversions          | FLOAT64   | Number of conversions attributed to the search query                       |
| conversion_rate      | FLOAT64   | Conversion rate (conversions/clicks)                                       |
| cost_per_conversion  | FLOAT64   | Average cost per conversion                                                |
| revenue              | FLOAT64   | Total revenue attributed to the search query                               |
| return_on_ad_spend   | FLOAT64   | Return on ad spend (revenue/spend)                                         |
| revenue_per_conversion | FLOAT64 | Average revenue per conversion                                            |
| assists              | INT64     | Number of assisted conversions                                            |
| all_conversions      | STRING    | All conversion types attributed to the search query                        |
| all_revenue          | STRING    | Total revenue from all conversion types                                    |
| all_conversion_rate  | STRING    | Conversion rate for all conversion types                                   |
| all_return_on_ad_spend | STRING  | Return on ad spend for all conversion types                               |
| date                 | DATE      | The reporting date for the record                                          |
| _gn_id               | STRING    | Hash of key dimensions for deduplication and uniqueness                    |
| _gn_synced           | TIMESTAMP | Timestamp when the record was last synced                                  |

## How to Use This Table

- **Search Term Analysis**: Analyze performance by `search_query` to identify high-performing and negative keywords
- **Match Type Performance**: Compare performance across different `bid_match_type` and `delivered_match_type` combinations
- **Device Insights**: Analyze performance by `device_type` and `device_os` to optimize for specific platforms
- **Network Performance**: Compare performance across different `network` types
- **Position Analysis**: Use `average_position` to understand ad placement effectiveness
- **Conversion Analysis**: Analyze both standard and all conversion metrics to understand full funnel performance
- **Revenue Analysis**: Track `revenue`, `return_on_ad_spend`, and `revenue_per_conversion` for ROI analysis

## Notes

- The `_gn_id` column is a deterministic hash of key dimensions (`account_number`, `account_id`, `campaign_id`, `ad_group_id`, `ad_id`, `keyword_id`, `search_query`, `device_type`, `network`, `TimePeriod`) for uniqueness and deduplication
- All fields used in the hash are cast to STRING for type safety and consistency
- The table is designed for easy joins with other Bing Ads reporting and dimension tables
- Data is updated incrementally, with existing records for the same date range and account being replaced during updates
- The table maintains referential integrity with other Bing Ads tables through the various ID fields 