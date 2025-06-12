# Campaign History Table

This table implements a Slowly Changing Dimension (SCD) Type 2 pattern for Bing Ads campaigns, tracking historical changes to campaign attributes over time. It maintains a complete history of campaign changes while providing an easy way to access the current state of each campaign.

## Table Structure

| Column                      | Type      | Description                                                                 |
|----------------------------|-----------|-----------------------------------------------------------------------------|
| _gn_start                  | TIMESTAMP | Start time of when this version of the record was valid                     |
| id                         | INT64     | The unique identifier for the campaign                                      |
| _gn_active                 | BOOL      | Flag indicating whether this is the current version of the record           |
| _gn_end                    | TIMESTAMP | End time of when this version of the record was valid (NULL for current)    |
| _gn_synced                 | TIMESTAMP | Timestamp when the record was last synced                                   |
| updated_at                 | TIMESTAMP | Timestamp when the campaign was last updated                                |
| audience_ads_bid_adjustment| INT64     | Bid adjustment for audience ads                                             |
| bidding_scheme             | STRING    | The bidding strategy used for the campaign                                  |
| budget_type                | STRING    | The type of budget (e.g., daily, lifetime)                                  |
| daily_budget               | FLOAT64   | The daily budget amount                                                     |
| experiment_id              | INT64     | The ID of any associated experiment                                         |
| name                       | STRING    | The display name of the campaign                                            |
| status                     | STRING    | The current status of the campaign                                          |
| time_zone                  | STRING    | The timezone for the campaign                                               |
| tracking_url_template      | STRING    | Template for tracking URLs                                                  |
| campaign_type              | STRING    | The type of campaign                                                        |
| settings                   | STRING    | Additional campaign settings                                                |
| budget_id                  | INT64     | The ID of the associated budget                                             |
| languages                  | STRING    | The languages targeted by the campaign                                      |
| tenant                     | STRING    | Tenant identifier (for multi-tenant environments)                           |
| _gn_id                     | STRING    | Hash of key attributes used for change detection                            |

## Change Detection

The table uses a hash-based change detection mechanism (`_gn_id`) that includes:
- audience_ads_bid_adjustment
- bidding_scheme
- budget_type
- daily_budget
- experiment_id
- name
- status
- time_zone
- tracking_url_template
- campaign_type
- settings
- budget_id
- languages
- tenant

When any of these attributes change, a new version of the record is created with:
- `_gn_start` set to the current timestamp
- `_gn_active` set to TRUE
- `_gn_end` set to NULL

The previous version is updated with:
- `_gn_active` set to FALSE
- `_gn_end` set to the new version's `_gn_start`

## Usage

- **Get current campaign state**: Filter where `_gn_active = TRUE`
- **Track historical changes**: Query without the `_gn_active` filter to see all versions
- **Point-in-time analysis**: Use `_gn_start` and `_gn_end` to see campaign state at any point in time
- **Change analysis**: Compare different versions of the same campaign to see what changed and when
- **Budget tracking**: Monitor changes in `budget_type` and `daily_budget` over time
- **Status tracking**: Track changes in campaign `status` to understand lifecycle changes
- **Experiment analysis**: Monitor changes in `experiment_id` to track A/B testing history
- **Bidding strategy analysis**: Track changes in `bidding_scheme` and `audience_ads_bid_adjustment`

## Notes

- The table is updated incrementally, only processing new or changed records
- A guard clause checks for source table existence before running ETL
- All fields in the hash are cast to STRING to ensure consistent change detection
- The table maintains referential integrity with other Bing Ads tables through the `id` field
- The `status` field is particularly useful for tracking campaign lifecycle changes 