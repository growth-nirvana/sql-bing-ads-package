-- account_history
-- Account History Transformation
{% assign target_dataset = vars.target_dataset_id %}
{% assign target_table_id = 'account_history' %}

{% assign source_dataset = vars.source_dataset_id %}
{% assign source_table_id = 'accounts' %}

{% if vars.models.switchover_accounts_history.active == false %}
select 1
{% else %}
DECLARE table_exists BOOL DEFAULT FALSE;

-- Check if the source table exists
SET table_exists = (
  SELECT COUNT(*) > 0
  FROM `{{source_dataset}}.INFORMATION_SCHEMA.TABLES`
  WHERE table_name = '{{source_table_id}}'
);

-- Only proceed if the source table exists
IF table_exists THEN

-- Create target table if it doesn't exist
CREATE TABLE IF NOT EXISTS `{{target_dataset}}.{{target_table_id}}` (
  _gn_start TIMESTAMP,
  id INT64,
  _gn_active BOOL,
  _gn_end TIMESTAMP,
  _gn_synced TIMESTAMP,
  updated_at TIMESTAMP,
  bill_to_customer_id INT64,
  currency_code STRING,
  account_financial_status STRING,
  name STRING,
  number STRING,
  parent_customer_id INT64,
  payment_method_id INT64,
  primary_user_id INT64,
  account_life_cycle_status STRING,
  time_stamp STRING,
  time_zone STRING,
  pause_reason INT64,
  linked_agencies STRING,
  back_up_payment_instrument_id INT64,
  business_address STRING,
  auto_tag_type STRING,
  last_modified_time TIMESTAMP,
  tenant STRING,
  _gn_id STRING
);

-- MERGE from source table (source is truncated on each run, so no deduplication needed)
MERGE `{{target_dataset}}.{{target_table_id}}` target
USING (
  SELECT 
    CURRENT_TIMESTAMP() AS _gn_start,
    Id AS id,
    TRUE AS _gn_active,
    CAST(NULL AS TIMESTAMP) AS _gn_end,
    CURRENT_TIMESTAMP() AS _gn_synced,
    LastModifiedTime AS updated_at,
    BillToCustomerId AS bill_to_customer_id,
    CurrencyCode AS currency_code,
    AccountFinancialStatus AS account_financial_status,
    Name AS name,
    Number AS number,
    ParentCustomerId AS parent_customer_id,
    PaymentMethodId AS payment_method_id,
    PrimaryUserId AS primary_user_id,
    AccountLifeCycleStatus AS account_life_cycle_status,
    TimeStamp AS time_stamp,
    TimeZone AS time_zone,
    PauseReason AS pause_reason,
    LinkedAgencies AS linked_agencies,
    BackUpPaymentInstrumentId AS back_up_payment_instrument_id,
    BusinessAddress AS business_address,
    AutoTagType AS auto_tag_type,
    LastModifiedTime AS last_modified_time,
    tenant AS tenant,
    TO_HEX(SHA256(CONCAT(
      COALESCE(CAST(BillToCustomerId AS STRING), ''),
      COALESCE(CurrencyCode, ''),
      COALESCE(AccountFinancialStatus, ''),
      COALESCE(Name, ''),
      COALESCE(Number, ''),
      COALESCE(CAST(ParentCustomerId AS STRING), ''),
      COALESCE(CAST(PaymentMethodId AS STRING), ''),
      COALESCE(CAST(PrimaryUserId AS STRING), ''),
      COALESCE(AccountLifeCycleStatus, ''),
      COALESCE(TimeStamp, ''),
      COALESCE(TimeZone, ''),
      COALESCE(CAST(PauseReason AS STRING), ''),
      COALESCE(LinkedAgencies, ''),
      COALESCE(CAST(BackUpPaymentInstrumentId AS STRING), ''),
      COALESCE(BusinessAddress, ''),
      COALESCE(AutoTagType, ''),
      COALESCE(CAST(LastModifiedTime AS STRING), ''),
      COALESCE(tenant, '')
    ))) AS _gn_id
  FROM `{{source_dataset}}.{{source_table_id}}`
) source
ON target.id = source.id
WHEN MATCHED THEN
  UPDATE SET
    _gn_start = source._gn_start,
    _gn_active = source._gn_active,
    _gn_end = source._gn_end,
    _gn_synced = source._gn_synced,
    updated_at = source.updated_at,
    bill_to_customer_id = source.bill_to_customer_id,
    currency_code = source.currency_code,
    account_financial_status = source.account_financial_status,
    name = source.name,
    number = source.number,
    parent_customer_id = source.parent_customer_id,
    payment_method_id = source.payment_method_id,
    primary_user_id = source.primary_user_id,
    account_life_cycle_status = source.account_life_cycle_status,
    time_stamp = source.time_stamp,
    time_zone = source.time_zone,
    pause_reason = source.pause_reason,
    linked_agencies = source.linked_agencies,
    back_up_payment_instrument_id = source.back_up_payment_instrument_id,
    business_address = source.business_address,
    auto_tag_type = source.auto_tag_type,
    last_modified_time = source.last_modified_time,
    tenant = source.tenant,
    _gn_id = source._gn_id
WHEN NOT MATCHED THEN
  INSERT (
    _gn_start,
    id,
    _gn_active,
    _gn_end,
    _gn_synced,
    updated_at,
    bill_to_customer_id,
    currency_code,
    account_financial_status,
    name,
    number,
    parent_customer_id,
    payment_method_id,
    primary_user_id,
    account_life_cycle_status,
    time_stamp,
    time_zone,
    pause_reason,
    linked_agencies,
    back_up_payment_instrument_id,
    business_address,
    auto_tag_type,
    last_modified_time,
    tenant,
    _gn_id
  )
  VALUES (
    source._gn_start,
    source.id,
    source._gn_active,
    source._gn_end,
    source._gn_synced,
    source.updated_at,
    source.bill_to_customer_id,
    source.currency_code,
    source.account_financial_status,
    source.name,
    source.number,
    source.parent_customer_id,
    source.payment_method_id,
    source.primary_user_id,
    source.account_life_cycle_status,
    source.time_stamp,
    source.time_zone,
    source.pause_reason,
    source.linked_agencies,
    source.back_up_payment_instrument_id,
    source.business_address,
    source.auto_tag_type,
    source.last_modified_time,
    source.tenant,
    source._gn_id
  );

-- Drop the source table after successful insertion
DROP TABLE IF EXISTS `{{source_dataset}}.{{source_table_id}}`;

END IF;

{% endif %} 