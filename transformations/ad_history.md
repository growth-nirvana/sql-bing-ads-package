# Ad History Table

This table stores Bing Ads ad data using a MERGE operation on the `id` field. The source table is truncated on each run, so all records from the source are upserted into the target table based on the ad `id`.

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

## Data Loading

The table uses a MERGE operation that:
- Matches records based on the `id` field
- Updates all fields when a matching `id` is found
- Inserts a new record when no matching `id` exists

The `_gn_id` field is still generated as a hash of key attributes but is not used for change detection. The source table is truncated on each run by the singer tap, so all records from the source are processed in each ETL run.

## Usage

- **Get ad data**: Query by `id` to retrieve ad information
- **Ad lookup**: Use the `id` field as the primary key for joining with other tables
- **Editorial status**: Monitor `editorial_status` to understand ad approval state
- **Content analysis**: Access ad content including `text`, `title_part1`, `title_part2`, `title_part3`
- **URL tracking**: Access `final_urls` and `final_mobile_urls` for destination information
- **Ad format**: Check `ad_format_preference` and `device_preference` for targeting details

## Notes

- The source table is truncated on each run by the singer tap, so all records are processed in each ETL run
- A guard clause checks for source table existence before running ETL
- The MERGE operation ensures that each ad `id` has only one record in the target table
- The table maintains referential integrity with other Bing Ads tables through the `id` field
- The `_gn_id` field is generated but not used for change detection
- The `editorial_status` field is useful for tracking ad approval state 