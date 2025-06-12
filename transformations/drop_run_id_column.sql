-- Drop run_id column from reporting tables
{% assign target_dataset = vars.target_dataset_id %}
{% assign reporting_tables = 'campaign_performance_report,ad_performance_report,ad_group_performance_report,search_query_performance_report,keyword_performance_report,goals_and_funnels_report,ad_extension_detail_report' | split: ',' %}

{% for table in reporting_tables %}
  ALTER TABLE `{{target_dataset}}.{{table}}`
  DROP COLUMN IF EXISTS run_id;
{% endfor %} 