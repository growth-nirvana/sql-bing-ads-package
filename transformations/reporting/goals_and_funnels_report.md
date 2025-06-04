# Goals and Funnels Report Table

This table contains detailed conversion and goal tracking metrics for Bing Ads campaigns, with one row per goal, date, and account. It provides comprehensive insights into conversion performance across different goals and funnels, enabling detailed analysis of user journeys and conversion optimization opportunities.

## Table Structure

| Column                    | Type      | Description                                                                 |
|--------------------------|-----------|-----------------------------------------------------------------------------|
| account_id               | INT64     | The numeric ID of the account                                               |
| campaign_id              | INT64     | The numeric ID of the campaign                                              |
| ad_group_id              | INT64     | The numeric ID of the ad group                                              |
| keyword_id               | INT64     | The numeric ID of the keyword                                               |
| goal                     | STRING    | The name of the conversion goal                                             |
| all_conversions          | STRING    | All conversion types attributed to the goal                                 |
| assists                  | INT64     | Number of assisted conversions                                              |
| all_revenue              | STRING    | Total revenue from all conversion types                                     |
| goal_id                  | INT64     | The numeric ID of the goal                                                  |
| device_type              | STRING    | The type of device used (e.g., Mobile, Desktop)                             |
| device_os                | STRING    | The operating system of the device                                          |
| goal_type                | STRING    | The type of conversion goal                                                 |
| view_through_conversions | STRING    | View-through conversions attributed to the goal                             |
| date                     | DATE      | The reporting date for the record                                           |
| _gn_id                   | STRING    | Hash of key dimensions for deduplication and uniqueness                     |
| _gn_synced               | TIMESTAMP | Timestamp when the record was last synced                                   |

## How to Use This Table

- **Goal Performance Analysis**: Compare performance metrics across different goals to identify top performers
- **Funnel Analysis**: Track conversion progression through different stages of the funnel
- **Device Performance**: Analyze goal completion rates by `device_type` and `device_os` to optimize for specific platforms
- **Assisted Conversions**: Monitor `assists` to understand the role of different touchpoints in the conversion path
- **Revenue Analysis**: Track `all_revenue` and conversion metrics to understand the value of different goals
- **View-Through Analysis**: Analyze `view_through_conversions` to understand the impact of display advertising
- **Goal Type Analysis**: Compare performance across different `goal_type` categories
- **Hierarchical Analysis**: Analyze performance at different levels (campaign, ad group, keyword) to identify optimization opportunities

## Notes

- The `_gn_id` column is a deterministic hash of key dimensions (`account_id`, `campaign_id`, `ad_group_id`, `keyword_id`, `goal_id`, `goal`, `device_type`, `TimePeriod`) for uniqueness and deduplication
- All fields used in the hash are cast to STRING for type safety and consistency
- The table is designed for easy joins with other Bing Ads reporting and dimension tables
- Data is updated incrementally, with existing records for the same date range and account being replaced during updates
- The table maintains referential integrity with other Bing Ads tables through the various ID fields 