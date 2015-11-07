/*
 * Copyright 2015 Observational Health Data Sciences and Informatics [OHDSI.org].
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
package org.ohdsi.webapi.feasibility;

import java.io.Serializable;
import javax.persistence.Column;
import javax.persistence.Embeddable;

/**
 *
 * @author Chris Knoll <cknoll@ohdsi.org>
 */
@Embeddable
public class StudyGenerationInfoId implements Serializable {
  
  private static final long serialVersionUID = 1L;
  
  public StudyGenerationInfoId() {
  }
  
  public StudyGenerationInfoId(Integer studyId, Integer sourceId) {
    this.studyId = studyId;
    this.sourceId = sourceId;
  }
  
  @Column(name = "study_id", insertable = false, updatable = false)
  private Integer studyId;

  @Column(name = "source_id")
  private Integer sourceId;  

  public Integer getStudyId() {
    return studyId;
  }

  public void setStudyId(Integer studyId) {
    this.studyId = studyId;
  }

  public Integer getSourceId() {
    return sourceId;
  }

  public void setSourceId(Integer sourceId) {
    this.sourceId = sourceId;
  }
  
  public boolean equals(Object o) {
    return ((o instanceof StudyGenerationInfoId) 
            && studyId.equals(((StudyGenerationInfoId) o).getStudyId()) 
            && sourceId == ((StudyGenerationInfoId) o).getSourceId());
  }
  
  public int hashCode() {
    return studyId + sourceId;
  }  
}
