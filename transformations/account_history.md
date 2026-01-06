# Account History Table

This table stores Bing Ads account data using a MERGE operation on the `id` field. The source table is truncated on each run, so all records from the source are upserted into the target table based on the account `id`.

## Table Structure

| Column                      | Type      | Description                                                                 |
|----------------------------|-----------|-----------------------------------------------------------------------------|
| _gn_start                  | TIMESTAMP | Start time of when this version of the record was valid                     |
| id                         | INT64     | The unique identifier for the Bing Ads account                              |
| _gn_active                 | BOOL      | Flag indicating whether this is the current version of the record           |
| _gn_end                    | TIMESTAMP | End time of when this version of the record was valid (NULL for current)    |
| _gn_synced                 | TIMESTAMP | Timestamp when the record was last synced                                   |
| updated_at                 | TIMESTAMP | Timestamp when the account was last updated                                 |
| bill_to_customer_id        | INT64     | The ID of the customer being billed                                         |
| currency_code              | STRING    | The currency code for the account                                           |
| account_financial_status   | STRING    | The current financial status of the account                                 |
| name                       | STRING    | The display name of the account                                             |
| number                     | STRING    | The account number                                                          |
| parent_customer_id         | INT64     | The ID of the parent customer account                                       |
| payment_method_id          | INT64     | The ID of the payment method                                                |
| primary_user_id            | INT64     | The ID of the primary user                                                  |
| account_life_cycle_status  | STRING    | The current lifecycle status of the account                                 |
| time_stamp                 | STRING    | The timestamp of the account record                                         |
| time_zone                  | STRING    | The timezone of the account                                                 |
| pause_reason               | INT64     | The reason code if the account is paused                                    |
| linked_agencies            | STRING    | List of linked agency accounts                                              |
| back_up_payment_instrument_id | INT64  | The ID of the backup payment instrument                                     |
| business_address           | STRING    | The business address associated with the account                            |
| auto_tag_type              | STRING    | The type of auto-tagging enabled                                            |
| last_modified_time         | TIMESTAMP | The last time the account was modified                                      |
| tenant                     | STRING    | Tenant identifier (for multi-tenant environments)                           |
| _gn_id                     | STRING    | Hash of key attributes used for change detection                            |

## Data Loading

The table uses a MERGE operation that:
- Matches records based on the `id` field
- Updates all fields when a matching `id` is found
- Inserts a new record when no matching `id` exists

The `_gn_id` field is still generated as a hash of key attributes but is not used for change detection. The source table is truncated on each run by the singer tap, so all records from the source are processed in each ETL run.

## Usage

- **Get account data**: Query by `id` to retrieve account information
- **Account lookup**: Use the `id` field as the primary key for joining with other tables
- **Financial status**: Monitor `account_financial_status` and `account_life_cycle_status`
- **Hierarchical analysis**: Use `parent_customer_id` to analyze account relationships
- **Account attributes**: Access all account attributes including billing, payment, and lifecycle information

## Notes

- The source table is truncated on each run by the singer tap, so all records are processed in each ETL run
- A guard clause checks for source table existence before running ETL
- The MERGE operation ensures that each account `id` has only one record in the target table
- The table maintains referential integrity with other Bing Ads tables through the `id` field
- The `_gn_id` field is generated but not used for change detection
- The `account_life_cycle_status` field is useful for tracking account lifecycle information 