# Keyword History Table

This table stores Bing Ads keyword data using a MERGE operation on the `id` field. The source table is truncated on each run, so all records from the source are upserted into the target table based on the keyword `id`.

## Table Structure

| Column        | Type      | Description                                                                 |
|---------------|-----------|-----------------------------------------------------------------------------|
| _gn_start     | TIMESTAMP | Start time of when this version of the record was valid                     |
| id            | INT64     | The unique identifier for the keyword                                       |
| _gn_active    | BOOL      | Flag indicating whether this is the current version of the record           |
| _gn_end       | TIMESTAMP | End time of when this version of the record was valid (NULL for current)    |
| _gn_synced    | TIMESTAMP | Timestamp when the record was last synced                                   |
| updated_at    | TIMESTAMP | Timestamp when the keyword was last updated                                 |
| bid           | STRING    | The bid amount for the keyword                                              |
| final_urls    | STRING    | The final URLs for the keyword                                              |
| match_type    | STRING    | The match type for the keyword (e.g., Exact, Phrase, Broad)                 |
| text          | STRING    | The keyword text                                                            |
| tenant        | STRING    | Tenant identifier (for multi-tenant environments)                           |
| _gn_id        | STRING    | Hash of key attributes used for change detection                            |

## Data Loading

The table uses a MERGE operation that:
- Matches records based on the `id` field
- Updates all fields when a matching `id` is found
- Inserts a new record when no matching `id` exists

The `_gn_id` field is still generated as a hash of key attributes but is not used for change detection. The source table is truncated on each run by the singer tap, so all records from the source are processed in each ETL run.

## Usage

- **Get keyword data**: Query by `id` to retrieve keyword information
- **Keyword lookup**: Use the `id` field as the primary key for joining with other tables
- **Bid information**: Access `bid` amounts for keyword bidding analysis
- **Match type**: Check `match_type` to understand keyword targeting (Exact, Phrase, Broad)
- **URL tracking**: Access `final_urls` for destination information
- **Keyword text**: Review `text` field for keyword content

## Notes

- The source table is truncated on each run by the singer tap, so all records are processed in each ETL run
- A guard clause checks for source table existence before running ETL
- The MERGE operation ensures that each keyword `id` has only one record in the target table
- The table maintains referential integrity with other Bing Ads tables through the `id` field
- The `_gn_id` field is generated but not used for change detection
- The `match_type` field is useful for understanding keyword targeting configuration 