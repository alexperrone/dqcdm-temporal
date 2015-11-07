/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.ohdsi.webapi.dataquality;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.math.BigDecimal;

/**
 *
 * @author asena5
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public class DataQualityRecord {
    @JsonProperty("sourceName")
    public String sourceName;
    
    @JsonProperty("conceptId")
    public String conceptId;

    @JsonProperty("measureId")
    public Integer measureId;

    @JsonProperty("conceptName")
    public String conceptName;

    @JsonProperty("domainId")
    public String domainId;

    @JsonProperty("timePeriod")
    public String timePeriod;	

    @JsonProperty("prevalence")
    public Double prevalence;	
}

