/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.ohdsi.webapi.cohortdefinition;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 *
 * @author cknoll1
 */
public class DateRange {
  @JsonProperty("Value")
  public String value;

  @JsonProperty("Op")
  public String op;

  @JsonProperty("Extent")
  public String extent;
}
