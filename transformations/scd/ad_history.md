# Ad History Table

This table implements a Slowly Changing Dimension (SCD) Type 2 pattern for Bing Ads, tracking historical changes to ad attributes over time. It maintains a complete history of ad changes while providing an easy way to access the current state of each ad.

## Table Structure

| Column                | Type      | Description                                                                 |
|----------------------|-----------|-----------------------------------------------------------------------------|
| _gn_start            | TIMESTAMP | Start time of when this version of the record was valid                     |
| id                   | INT64     | The unique identifier for the ad                                            |
| _gn_active           | BOOL      | Flag indicating whether this is the current version of the record           |
| _gn_end              | TIMESTAMP | End time of when this version of the record was valid (NULL for current)    |
| _gn_synced           | TIMESTAMP | Timestamp when the record was last synced                                   |
| updated_at           | TIMESTAMP | Timestamp when the ad was last updated                                      |
| ad_format_preference | STRING    | The preferred format for the ad                                             |
| device_preference    | INT64     | The device preference for the ad                                            |
| editorial_status     | STRING    | The current editorial status of the ad                                      |
| final_mobile_urls    | STRING    | The final mobile URLs for the ad                                            |
| final_urls           | STRING    | The final URLs for the ad                                                   |
| status               | STRING    | The current status of the ad                                                |
| type                 | STRING    | The type of ad                                                              |
| text                 | STRING    | The main text content of the ad                                             |
| path1                | STRING    | The first path component of the ad                                          |
| path2                | STRING    | The second path component of the ad                                         |
| text_part2           | STRING    | The second part of the ad text                                              |
| domain               | STRING    | The domain for the ad                                                       |
| title_part1          | STRING    | The first part of the ad title                                              |
| title_part2          | STRING    | The second part of the ad title                                             |
| title_part3          | STRING    | The third part of the ad title                                              |
| tenant               | STRING    | Tenant identifier (for multi-tenant environments)                           |
| _gn_id               | STRING    | Hash of key attributes used for change detection                            |

## Change Detection

The table uses a hash-based change detection mechanism (`_gn_id`) that includes:
- ad_format_preference
- device_preference
- editorial_status
- final_mobile_urls
- final_urls
- status
- type
- text
- path1
- path2
- text_part2
- domain
- title_part1
- title_part2
- title_part3
- tenant

When any of these attributes change, a new version of the record is created with:
- `_gn_start` set to the current timestamp
- `_gn_active` set to TRUE
- `_gn_end` set to NULL

The previous version is updated with:
- `_gn_active` set to FALSE
- `_gn_end` set to the new version's `_gn_start`

## Usage

- **Get current ad state**: Filter where `_gn_active = TRUE`
- **Track historical changes**: Query without the `_gn_active` filter to see all versions
- **Point-in-time analysis**: Use `_gn_start` and `_gn_end` to see ad state at any point in time
- **Change analysis**: Compare different versions of the same ad to see what changed and when
- **Editorial status tracking**: Monitor changes in `editorial_status` to understand ad approval history
- **Content analysis**: Track changes in ad content (`text`, `title_part1`, etc.) over time
- **URL tracking**: Monitor changes in `final_urls` and `final_mobile_urls` for destination changes

## Notes

- The table is updated incrementally, only processing new or changed records
- A guard clause checks for source table existence before running ETL
- All fields in the hash are cast to STRING to ensure consistent change detection
- The table maintains referential integrity with other Bing Ads tables through the `id` field
- The `editorial_status` field is particularly useful for tracking ad approval lifecycle changes 