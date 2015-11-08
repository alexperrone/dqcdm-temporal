SELECT DISTINCT concept_id, concept_name, domain_id
  FROM @results_schema.dqcdm_temporal_summary_subset
WHERE Source_name = '@sourceName'
  and concept_name LIKE '%@searchTerm%'
order by concept_name