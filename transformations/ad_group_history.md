# Ad Group History Table

This table stores Bing Ads ad group data using a MERGE operation on the `id` field. The source table is truncated on each run, so all records from the source are upserted into the target table based on the ad group `id`.

## Table Structure

| Column                | Type      | Description                                                                 |
|----------------------|-----------|-----------------------------------------------------------------------------|
| _gn_start            | TIMESTAMP | Start time of when this version of the record was valid                     |
| id                   | INT64     | The unique identifier for the ad group                                      |
| _gn_active           | BOOL      | Flag indicating whether this is the current version of the record           |
| _gn_end              | TIMESTAMP | End time of when this version of the record was valid (NULL for current)    |
| _gn_synced           | TIMESTAMP | Timestamp when the record was last synced                                   |
| updated_at           | TIMESTAMP | Timestamp when the ad group was last updated                                |
| ad_rotation          | STRING    | The ad rotation settings for the ad group                                   |
| bidding_scheme       | STRING    | The bidding strategy used for the ad group                                  |
| cpc_bid              | STRING    | The cost-per-click bid amount                                               |
| end_date             | STRING    | The end date for the ad group (if scheduled)                                |
| language             | STRING    | The language targeting for the ad group                                     |
| name                 | STRING    | The display name of the ad group                                            |
| network              | STRING    | The network where the ads will be shown                                     |
| settings             | STRING    | Additional settings for the ad group                                        |
| start_date           | STRING    | The start date for the ad group                                             |
| status               | STRING    | The current status of the ad group                                          |
| url_custom_parameters| STRING    | Custom URL parameters for tracking                                          |
| tenant               | STRING    | Tenant identifier (for multi-tenant environments)                           |
| _gn_id               | STRING    | Hash of key attributes used for change detection                            |

## Data Loading

The table uses a MERGE operation that:
- Matches records based on the `id` field
- Updates all fields when a matching `id` is found
- Inserts a new record when no matching `id` exists

The `_gn_id` field is still generated as a hash of key attributes but is not used for change detection. The source table is truncated on each run by the singer tap, so all records from the source are processed in each ETL run.

## Usage

- **Get ad group data**: Query by `id` to retrieve ad group information
- **Ad group lookup**: Use the `id` field as the primary key for joining with other tables
- **Bidding strategy**: Access `bidding_scheme` and `cpc_bid` information
- **Status tracking**: Monitor ad group `status` to understand current state
- **Network settings**: Analyze `network` settings and their configuration
- **Scheduling**: Use `start_date` and `end_date` to understand ad group scheduling

## Notes

- The source table is truncated on each run by the singer tap, so all records are processed in each ETL run
- A guard clause checks for source table existence before running ETL
- The MERGE operation ensures that each ad group `id` has only one record in the target table
- The table maintains referential integrity with other Bing Ads tables through the `id` field
- The `_gn_id` field is generated but not used for change detection
- The `status` field is useful for tracking ad group state 