SELECT *
  FROM @results_schema.dqcdm_temporal_summary_subset
WHERE concept_id = @conceptId
order by source_name, time_period


