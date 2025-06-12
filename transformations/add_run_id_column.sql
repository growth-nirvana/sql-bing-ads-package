-- Add run_id column to reporting tables if it doesn't exist
{% assign target_dataset = vars.target_dataset_id %}
{% assign reporting_tables = 'campaign_performance_report,ad_performance_report,ad_group_performance_report,search_query_performance_report,keyword_performance_report,goals_and_funnels_report,ad_extension_detail_report' | split: ',' %}

{% for table in reporting_tables %}
  -- Check if run_id column exists in {{table}}
  IF NOT EXISTS (
    SELECT 1
    FROM `{{target_dataset}}.INFORMATION_SCHEMA.COLUMNS`
    WHERE table_name = '{{table}}'
    AND column_name = 'run_id'
  ) THEN
    ALTER TABLE `{{target_dataset}}.{{table}}`
    ADD COLUMN run_id INT64;
  END IF;
{% endfor %} 