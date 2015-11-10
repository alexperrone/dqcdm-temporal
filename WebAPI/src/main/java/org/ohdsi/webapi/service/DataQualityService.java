package org.ohdsi.webapi.service;

import java.math.BigDecimal;
import java.util.Collection;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import org.ohdsi.sql.SqlRender;
import org.ohdsi.sql.SqlTranslate;
import org.ohdsi.webapi.dataquality.DataQualityRecord;
import org.ohdsi.webapi.dataquality.SearchResult;
import org.ohdsi.webapi.helper.ResourceHelper;
import org.ohdsi.webapi.source.Source;
import org.ohdsi.webapi.source.SourceDaimon;
import org.springframework.stereotype.Component;


/**
 *
 * @author asena5
 */
@Path("{sourceKey}/dq/")
@Component
public class DataQualityService extends AbstractDaoService {
  
  @GET
  @Path("{sourceName}/concept/{conceptId}")
  @Produces(MediaType.APPLICATION_JSON)
  public Collection<DataQualityRecord> getDataQualityData(@PathParam("sourceKey") String sourceKey, @PathParam("sourceName") String sourceName, @PathParam("conceptId") String conceptId) {
    try {
      Source source = getSourceRepository().findBySourceKey(sourceKey);
      String tableQualifier = source.getTableQualifier(SourceDaimon.DaimonType.Results);

      String sql_statement = ResourceHelper.GetResourceAsString("/resources/dataquality/sql/getDataQualityBySourceAndConcept.sql");
      sql_statement = SqlRender.renderSql(sql_statement, new String[]{"results_schema", "sourceName", "conceptId"}, new String[]{tableQualifier, sourceName, conceptId});
      sql_statement = SqlTranslate.translateSql(sql_statement, "sql server", source.getSourceDialect());
      
      final List<DataQualityRecord> results = new ArrayList<DataQualityRecord>();

        List<Map<String, Object>> rows = getSourceJdbcTemplate(source).queryForList(sql_statement);

        for (Map rs : rows) {
          DataQualityRecord info = new DataQualityRecord();
          info.conceptId = (String) rs.get("concept_id");
          info.conceptName = (String) rs.get("concept_name");
          info.domainId = (String) rs.get("domain_id");
          info.measureId = (Integer) rs.get("measure_id");
          info.prevalence = (Double) rs.get("prevalence");
          info.sourceName = (String) rs.get("source_name");
          info.timePeriod = (String) rs.get("time_period");
          results.add(info);
        }
        return results;
    }
    catch(Exception ex) {
        throw ex;
    }
  }    

  @GET
  @Path("/concept/{conceptId}")
  @Produces(MediaType.APPLICATION_JSON)
  public Collection<DataQualityRecord> getDataQualityDataForConcept(@PathParam("sourceKey") String sourceKey, @PathParam("conceptId") String conceptId) {
    try {
      Source source = getSourceRepository().findBySourceKey(sourceKey);
      String tableQualifier = source.getTableQualifier(SourceDaimon.DaimonType.Results);

      String sql_statement = ResourceHelper.GetResourceAsString("/resources/dataquality/sql/getDataQualityByConcept.sql");
      sql_statement = SqlRender.renderSql(sql_statement, new String[]{"results_schema", "conceptId"}, new String[]{tableQualifier, conceptId});
      sql_statement = SqlTranslate.translateSql(sql_statement, "sql server", source.getSourceDialect());
      
      final List<DataQualityRecord> results = new ArrayList<DataQualityRecord>();

        List<Map<String, Object>> rows = getSourceJdbcTemplate(source).queryForList(sql_statement);

        for (Map rs : rows) {
          DataQualityRecord info = new DataQualityRecord();
          info.conceptId = (String) rs.get("concept_id");
          info.conceptName = (String) rs.get("concept_name");
          info.domainId = (String) rs.get("domain_id");
          info.measureId = (Integer) rs.get("measure_id");
          info.prevalence = (Double) rs.get("prevalence");
          info.sourceName = (String) rs.get("source_name");
          info.timePeriod = (String) rs.get("time_period");
          results.add(info);
        }
        return results;
    }
    catch(Exception ex) {
        throw ex;
    }
  }    

  @GET
  @Path("search/{searchTerm}")
  @Produces(MediaType.APPLICATION_JSON)
  public Collection<SearchResult> searchConcepts(@PathParam("sourceKey") String sourceKey, @PathParam("searchTerm") String searchTerm) {
    try {
      Source source = getSourceRepository().findBySourceKey(sourceKey);
      String tableQualifier = source.getTableQualifier(SourceDaimon.DaimonType.Results);

      String sql_statement = ResourceHelper.GetResourceAsString("/resources/dataquality/sql/searchDataQuality.sql");
      sql_statement = SqlRender.renderSql(sql_statement, new String[]{"results_schema", "searchTerm"}, new String[]{tableQualifier, searchTerm});
      sql_statement = SqlTranslate.translateSql(sql_statement, "sql server", source.getSourceDialect());
      
      final List<SearchResult> results = new ArrayList<SearchResult>();

        List<Map<String, Object>> rows = getSourceJdbcTemplate(source).queryForList(sql_statement);

        for (Map rs : rows) {
          SearchResult info = new SearchResult();
          info.conceptId = (String) rs.get("concept_id");
          info.conceptName = (String) rs.get("concept_name");
          info.domainId = (String) rs.get("domain_id");
          info.dqWarningDecreasingSlope = (int) rs.get("dqwarning_decreasing_slope");
          info.dqWarningDiscontinuity = (int) rs.get("dqwarning_discontinuity");
          info.dqWarningIncreasingSlope = (int) rs.get("dqwarning_increasing_slope");
          info.dqWarningOutlierMonths = (int) rs.get("dqwarning_outlier_months");
          info.isNotTrend = (int) rs.get("is_notrend");
          info.isSeasonal = (int) rs.get("is_seasonal");
          info.numBreakpoints = (int) rs.get("numbreakpoints");
          info.numOutliers = (int) rs.get("numoutliers");
          info.seasonSig = (Double) rs.get("seasonsig");
          info.sourceName = (String) rs.get("source_name");
          info.temporalSlope = (Double) rs.get("temporalslope");
          info.temporalSlopeSig = (Double) rs.get("temporalslopesig");
          
          results.add(info);
        }
        return results;
    }
    catch(Exception ex) {
        throw ex;
    }
      
  }
  
  @GET
  @Path("info")
  @Produces(MediaType.APPLICATION_JSON)
  public String getInfo() {
      return "hello";
  }
}
