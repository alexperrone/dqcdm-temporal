select s1.source_name, s1.concept_id, c1.concept_name, c1.domain_id,
	s1.temporalslope, s1.temporalslopesig, s1.numoutliers,s1.numbreakpoints, s1.seasonsig,
	case when seasonsig < 0.05 then 1 else 0 end is_notrend,
	case when seasonsig < 0.05 then 1 else 0 end is_seasonal,
	case when temporalslopesig < 0.05 and temporalslope > 0.0001 then 1 else 0 end dqwarning_increasing_slope,
	case when temporalslopesig < 0.05 and temporalslope < -0.0001 then 1 else 0 end dqwarning_decreasing_slope,
	case when numoutliers > 3 then 1 else 0 end dqwarning_outlier_months,
	case when numbreakpoints > 1 then 1 else 0 end dqwarning_discontinuity	
from @results_schema.dqcdm_temporal_summary_stats s1
inner join cdm_truven_ccae_v5.dbo.concept c1
on s1.concept_id = cast(c1.concept_id as varchar)
WHERE c1.concept_name LIKE '%@searchTerm%'
ORDER BY concept_name
