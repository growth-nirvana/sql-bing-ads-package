# Campaign History Table

This table stores Bing Ads campaign data using a MERGE operation on the `id` field. The source table is truncated on each run, so all records from the source are upserted into the target table based on the campaign `id`.

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

## Data Loading

The table uses a MERGE operation that:
- Matches records based on the `id` field
- Updates all fields when a matching `id` is found
- Inserts a new record when no matching `id` exists

The `_gn_id` field is still generated as a hash of key attributes but is not used for change detection. The source table is truncated on each run by the singer tap, so all records from the source are processed in each ETL run.

## Usage

- **Get campaign data**: Query by `id` to retrieve campaign information
- **Campaign lookup**: Use the `id` field as the primary key for joining with other tables
- **Budget information**: Access `budget_type` and `daily_budget` details
- **Status tracking**: Monitor campaign `status` to understand current state
- **Experiment tracking**: Check `experiment_id` for A/B testing associations
- **Bidding strategy**: Access `bidding_scheme` and `audience_ads_bid_adjustment` information
- **Campaign settings**: Review `settings` and `campaign_type` for configuration details

## Notes

- The source table is truncated on each run by the singer tap, so all records are processed in each ETL run
- A guard clause checks for source table existence before running ETL
- The MERGE operation ensures that each campaign `id` has only one record in the target table
- The table maintains referential integrity with other Bing Ads tables through the `id` field
- The `_gn_id` field is generated but not used for change detection
- The `status` field is useful for tracking campaign state 