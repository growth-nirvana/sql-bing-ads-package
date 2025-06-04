# Account History Table

This table implements a Slowly Changing Dimension (SCD) Type 2 pattern for Bing Ads accounts, tracking historical changes to account attributes over time. It maintains a complete history of account changes while providing an easy way to access the current state of each account.

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

## Change Detection

The table uses a hash-based change detection mechanism (`_gn_id`) that includes:
- bill_to_customer_id
- currency_code
- account_financial_status
- name
- number
- parent_customer_id
- payment_method_id
- primary_user_id
- account_life_cycle_status
- time_stamp
- time_zone
- pause_reason
- linked_agencies
- back_up_payment_instrument_id
- business_address
- auto_tag_type
- last_modified_time
- tenant

When any of these attributes change, a new version of the record is created with:
- `_gn_start` set to the current timestamp
- `_gn_active` set to TRUE
- `_gn_end` set to NULL

The previous version is updated with:
- `_gn_active` set to FALSE
- `_gn_end` set to the new version's `_gn_start`

## Usage

- **Get current account state**: Filter where `_gn_active = TRUE`
- **Track historical changes**: Query without the `_gn_active` filter to see all versions
- **Point-in-time analysis**: Use `_gn_start` and `_gn_end` to see account state at any point in time
- **Change analysis**: Compare different versions of the same account to see what changed and when
- **Financial status tracking**: Monitor changes in `account_financial_status` and `account_life_cycle_status`
- **Hierarchical analysis**: Use `parent_customer_id` to analyze account relationships

## Notes

- The table is updated incrementally, only processing new or changed records
- A guard clause checks for source table existence before running ETL
- All fields in the hash are cast to STRING to ensure consistent change detection
- The table maintains referential integrity with other Bing Ads tables through the `id` field
- The `account_life_cycle_status` field is particularly useful for tracking account lifecycle changes 