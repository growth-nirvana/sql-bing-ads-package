# Ad Group History Table

This table implements a Slowly Changing Dimension (SCD) Type 2 pattern for Bing Ads ad groups, tracking historical changes to ad group attributes over time. It maintains a complete history of ad group changes while providing an easy way to access the current state of each ad group.

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

## Change Detection

The table uses a hash-based change detection mechanism (`_gn_id`) that includes:
- ad_rotation
- bidding_scheme
- cpc_bid
- end_date
- language
- name
- network
- settings
- start_date
- status
- url_custom_parameters
- tenant

When any of these attributes change, a new version of the record is created with:
- `_gn_start` set to the current timestamp
- `_gn_active` set to TRUE
- `_gn_end` set to NULL

The previous version is updated with:
- `_gn_active` set to FALSE
- `_gn_end` set to the new version's `_gn_start`

## Usage

- **Get current ad group state**: Filter where `_gn_active = TRUE`
- **Track historical changes**: Query without the `_gn_active` filter to see all versions
- **Point-in-time analysis**: Use `_gn_start` and `_gn_end` to see ad group state at any point in time
- **Change analysis**: Compare different versions of the same ad group to see what changed and when
- **Bidding strategy analysis**: Monitor changes in `bidding_scheme` and `cpc_bid` over time
- **Status tracking**: Track changes in ad group `status` to understand lifecycle changes
- **Network performance**: Analyze changes in `network` settings and their impact on performance

## Notes

- The table is updated incrementally, only processing new or changed records
- A guard clause checks for source table existence before running ETL
- All fields in the hash are cast to STRING to ensure consistent change detection
- The table maintains referential integrity with other Bing Ads tables through the `id` field
- The `status` field is particularly useful for tracking ad group lifecycle changes 