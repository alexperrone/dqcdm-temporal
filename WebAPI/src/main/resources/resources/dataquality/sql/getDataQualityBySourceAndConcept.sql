SELECT *
  FROM @results_schema.dqcdm_temporal_summary_subset
WHERE Source_name = '@sourceName'
  and concept_id = @conceptId
order by time_period

