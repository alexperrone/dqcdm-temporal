/*
 * Copyright 2015 fdefalco.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.ohdsi.webapi.service;

import java.sql.ResultSet;
import java.sql.SQLException;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import org.ohdsi.sql.SqlRender;
import org.ohdsi.sql.SqlTranslate;
import org.ohdsi.webapi.helper.ResourceHelper;
import org.ohdsi.webapi.person.PersonRecord;
import org.ohdsi.webapi.person.PersonProfile;
import org.ohdsi.webapi.source.Source;
import org.ohdsi.webapi.source.SourceDaimon;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Component;

@Path("{sourceKey}/person/")
@Component
public class PersonService extends AbstractDaoService {
  
  @Path("{personId}")
  @GET
  @Produces(MediaType.APPLICATION_JSON)
  public PersonProfile getPersonProfile(@PathParam("sourceKey") String sourceKey, @PathParam("personId") String personId)  
  {
    final PersonProfile profile = new PersonProfile();
    
    Source source = getSourceRepository().findBySourceKey(sourceKey);
    String tableQualifier = source.getTableQualifier(SourceDaimon.DaimonType.Vocabulary);

    String sql_statement = ResourceHelper.GetResourceAsString("/resources/person/sql/getRecords.sql");
    sql_statement = SqlRender.renderSql(sql_statement, new String[]{"personId", "tableQualifier"}, new String[]{personId, tableQualifier});
    sql_statement = SqlTranslate.translateSql(sql_statement, "sql server", source.getSourceDialect());

    getSourceJdbcTemplate(source).query(sql_statement, new RowMapper<Void>() {
      @Override
      public Void mapRow(ResultSet resultSet, int arg1) throws SQLException {
        PersonRecord item = new PersonRecord();
        item.conceptId = resultSet.getLong("concept_id");
        item.conceptName = resultSet.getString("concept_name");
        item.recordType = resultSet.getString("era_type");
        item.startDate = resultSet.getTimestamp("start_date");
        item.endDate = resultSet.getTimestamp("end_date");
        
        profile.addRecord(item);
        
        return null;
      }
    });
    
    return profile;
  }
  
  
}
