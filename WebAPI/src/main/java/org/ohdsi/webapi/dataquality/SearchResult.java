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
public class SearchResult {
    @JsonProperty("sourceName")
    public String sourceName;
    
    @JsonProperty("conceptId")
    public String conceptId;

    @JsonProperty("conceptName")
    public String conceptName;

    @JsonProperty("domainId")
    public String domainId;

    @JsonProperty("temporalSlope")
    public double temporalSlope;	

    @JsonProperty("temporalSlopeSig")
    public double temporalSlopeSig;	
    
    @JsonProperty("numOutliers")
    public int numOutliers;	
    
    @JsonProperty("numBreakpoints")
    public int numBreakpoints;	

    @JsonProperty("seasonSig")
    public double seasonSig;	

    @JsonProperty("isNotTrend")
    public int isNotTrend;	

    @JsonProperty("isSeasonal")
    public int isSeasonal;	
    
    @JsonProperty("dqWarningIncreasingSlope")
    public int dqWarningIncreasingSlope;
    
    @JsonProperty("dqWarningDecreasingSlope")
    public int dqWarningDecreasingSlope;
    
    @JsonProperty("dqWarningOutlierMonths")
    public int dqWarningOutlierMonths;
    
    @JsonProperty("dqWarningDiscontinuity")
    public int dqWarningDiscontinuity;
}
