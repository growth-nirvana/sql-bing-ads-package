# Keyword History Table

This table implements a Slowly Changing Dimension (SCD) Type 2 pattern for Bing Ads keywords, tracking historical changes to keyword attributes over time. It maintains a complete history of keyword changes while providing an easy way to access the current state of each keyword.

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

## Change Detection

The table uses a hash-based change detection mechanism (`_gn_id`) that includes:
- bid
- final_urls
- match_type
- text
- tenant

When any of these attributes change, a new version of the record is created with:
- `_gn_start` set to the current timestamp
- `_gn_active` set to TRUE
- `_gn_end` set to NULL

The previous version is updated with:
- `_gn_active` set to FALSE
- `_gn_end` set to the new version's `_gn_start`

## Usage

- **Get current keyword state**: Filter where `_gn_active = TRUE`
- **Track historical changes**: Query without the `_gn_active` filter to see all versions
- **Point-in-time analysis**: Use `_gn_start` and `_gn_end` to see keyword state at any point in time
- **Change analysis**: Compare different versions of the same keyword to see what changed and when
- **Bid tracking**: Monitor changes in `bid` amounts over time
- **Match type analysis**: Track changes in `match_type` to understand keyword targeting evolution
- **URL tracking**: Monitor changes in `final_urls` for destination changes
- **Keyword text analysis**: Track changes in `text` to understand keyword modifications

## Notes

- The table is updated incrementally, only processing new or changed records
- A guard clause checks for source table existence before running ETL
- All fields in the hash are cast to STRING to ensure consistent change detection
- The table maintains referential integrity with other Bing Ads tables through the `id` field
- The `match_type` field is particularly useful for tracking keyword targeting changes 