define(['knockout', 'text!./viewer.html', 'd3', 'jnj_chart', 'colorbrewer', 'knockout.dataTables.binding'], function (ko, view, d3, jnj_chart, colorbrewer, _) {
    function home(params) {
        var self = this;
        self.model = params.model;

        self.loadData = function () {
            // Get the data for the selected concept and current data source name
            $.ajax({
                url: 'http://localhost:8080/WebAPI/DQCDM/dq/' + self.model.currentService().sourceName + '/concept/' + self.model.currentConceptId(),
                success: function (results) {
                    self.model.currentConceptName(results[0].conceptName);

                    var timePeriod = results.map(function (d, i) {
                        return d.timePeriod;
                    });
                    var prevalence = results.map(function (d, i) {
                        return d.prevalence;
                    });

                    var dataSet = {
                        'timePeriod': timePeriod,
                        'prevalence': prevalence
                    };

                    // prevalence by month
                    var byMonthSeries = self.mapMonthYearDataToSeries(dataSet, {
                        dateField: 'timePeriod',
                        yValue: 'prevalence',
                        yPercent: 'prevalence'
                    });

                    d3.selectAll("#conditioneraPrevalenceByMonth svg").remove();
                    var prevalenceByMonth = new jnj_chart.line();
                    prevalenceByMonth.render(byMonthSeries, "#conditioneraPrevalenceByMonth", 1000, 300, {
                        xScale: d3.time.scale().domain(d3.extent(byMonthSeries[0].values, function (d) {
                            return d.xValue;
                        })),
                        xFormat: d3.time.format("%m/%Y"),
                        tickFormat: d3.time.format("%Y"),
                        xLabel: "Date",
                        yLabel: "Prevalence per 1000 People"
                    });

                    self.circularHeatMap(results);
                },
                error: function (xhr, message) {
                    //alert('Could not find ' + self.currentServiceUrl() + 'summary.json');
                }
            });

        }

        self.mapMonthYearDataToSeries = function (data, options) {
            var defaults = {
                dateField: "x",
                yValue: "y",
                yPercent: "p"
            };

            var options = $.extend({}, defaults, options);

            var series = {};
            series.name = "All Time";
            series.values = [];
            for (var i = 0; i < data[options.dateField].length; i++) {
                var dateInt = data[options.dateField][i];
                series.values.push({
                    xValue: new Date(Math.floor(data[options.dateField][i] / 100), (data[options.dateField][i] % 100) - 1, 1),
                    yValue: data[options.yValue][i],
                    yPercent: data[options.yPercent][i]
                });
            }
            series.values.sort(function (a, b) {
                return a.xValue - b.xValue;
            });

            return [series]; // return series wrapped in an array
        }

        self.circularHeatChart = function () {
            var margin = {
                    top: 20,
                    right: 20,
                    bottom: 20,
                    left: 20
                },
                innerRadius = 50,
                numSegments = 24,
                segmentHeight = 20,
                domain = null,
                range = ["white", "steelblue"],
                accessor = function (d) {
                    return d;
                },
                radialLabels = segmentLabels = [];

            function chart(selection) {
                selection.each(function (data) {
                    var svg = d3.select(this);

                    var offset = innerRadius + Math.ceil(data.length / numSegments) * segmentHeight;
                    g = svg.append("g")
                        .classed("circular-heat", true)
                        .attr("transform", "translate(" + parseInt(margin.left + offset) + "," + parseInt(margin.top + offset) + ")");

                    var autoDomain = false;
                    if (domain === null) {
                        domain = d3.extent(data, accessor);
                        autoDomain = true;
                    }
                    var color = d3.scale.linear().domain(domain).range(range);
                    if (autoDomain)
                        domain = null;

                    g.selectAll("path").data(data)
                        .enter().append("path")
                        .attr("d", d3.svg.arc().innerRadius(ir).outerRadius(or).startAngle(sa).endAngle(ea))
                        .attr("fill", function (d) {
                            return color(accessor(d));
                        });


                    // Unique id so that the text path defs are unique - is there a better way to do this?
                    var id = d3.selectAll(".circular-heat")[0].length;

                    //Radial labels
                    var lsa = 0.01; //Label start angle
                    var labels = svg.append("g")
                        .classed("labels", true)
                        .classed("radial", true)
                        .attr("transform", "translate(" + parseInt(margin.left + offset) + "," + parseInt(margin.top + offset) + ")");

                    labels.selectAll("def")
                        .data(radialLabels).enter()
                        .append("def")
                        .append("path")
                        .attr("id", function (d, i) {
                            return "radial-label-path-" + id + "-" + i;
                        })
                        .attr("d", function (d, i) {
                            var r = innerRadius + ((i + 0.2) * segmentHeight);
                            return "m" + r * Math.sin(lsa) + " -" + r * Math.cos(lsa) +
                                " a" + r + " " + r + " 0 1 1 -1 0";
                        });

                    labels.selectAll("text")
                        .data(radialLabels).enter()
                        .append("text")
                        .append("textPath")
                        .attr("xlink:href", function (d, i) {
                            return "#radial-label-path-" + id + "-" + i;
                        })
                        .style("font-size", 0.6 * segmentHeight + 'px')
                        .text(function (d) {
                            return d;
                        });

                    //Segment labels
                    var segmentLabelOffset = 2;
                    var r = innerRadius + Math.ceil(data.length / numSegments) * segmentHeight + segmentLabelOffset;
                    labels = svg.append("g")
                        .classed("labels", true)
                        .classed("segment", true)
                        .attr("transform", "translate(" + parseInt(margin.left + offset) + "," + parseInt(margin.top + offset) + ")");

                    labels.append("def")
                        .append("path")
                        .attr("id", "segment-label-path-" + id)
                        .attr("d", "m0 -" + r + " a" + r + " " + r + " 0 1 1 -1 0");

                    labels.selectAll("text")
                        .data(segmentLabels).enter()
                        .append("text")
                        .append("textPath")
                        .attr("xlink:href", "#segment-label-path-" + id)
                        .attr("startOffset", function (d, i) {
                            return i * 100 / numSegments + "%";
                        })
                        .text(function (d) {
                            return d;
                        });
                });

            }

            /* Arc functions */
            ir = function (d, i) {
                return innerRadius + Math.floor(i / numSegments) * segmentHeight;
            }
            or = function (d, i) {
                return innerRadius + segmentHeight + Math.floor(i / numSegments) * segmentHeight;
            }
            sa = function (d, i) {
                return (i * 2 * Math.PI) / numSegments;
            }
            ea = function (d, i) {
                return ((i + 1) * 2 * Math.PI) / numSegments;
            }

            /* Configuration getters/setters */
            chart.margin = function (_) {
                if (!arguments.length) return margin;
                margin = _;
                return chart;
            };

            chart.innerRadius = function (_) {
                if (!arguments.length) return innerRadius;
                innerRadius = _;
                return chart;
            };

            chart.numSegments = function (_) {
                if (!arguments.length) return numSegments;
                numSegments = _;
                return chart;
            };

            chart.segmentHeight = function (_) {
                if (!arguments.length) return segmentHeight;
                segmentHeight = _;
                return chart;
            };

            chart.domain = function (_) {
                if (!arguments.length) return domain;
                domain = _;
                return chart;
            };

            chart.range = function (_) {
                if (!arguments.length) return range;
                range = _;
                return chart;
            };

            chart.radialLabels = function (_) {
                if (!arguments.length) return radialLabels;
                if (_ == null) _ = [];
                radialLabels = _;
                return chart;
            };

            chart.segmentLabels = function (_) {
                if (!arguments.length) return segmentLabels;
                if (_ == null) _ = [];
                segmentLabels = _;
                return chart;
            };

            chart.accessor = function (_) {
                if (!arguments.length) return accessor;
                accessor = _;
                return chart;
            };

            return chart;
        }

        self.circularHeatMap = function (results) {
            // Format the data for the chart
            var years = $.unique(results.map(function (d, i) {
                return d.timePeriod.substring(2, 4);
            }));


            /*
            var chart = self.circularHeatChart()
                .segmentHeight(20)
                .innerRadius(20)
                .numSegments(24)
                .radialLabels(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"])
                .segmentLabels(["Midnight", "1am", "2am", "3am", "4am", "5am", "6am", "7am", "8am", "9am", "10am", "11am", "Midday", "1pm", "2pm", "3pm", "4pm", "5pm", "6pm", "7pm", "8pm", "9pm", "10pm", "11pm"])
                .margin({
                    top: 20,
                    right: 0,
                    bottom: 20,
                    left: 280
                });
                */
            var chart = self.circularHeatChart()
                .segmentHeight(20)
                .innerRadius(20)
                .numSegments(12)
                .radialLabels(years)
                .segmentLabels(["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"])
                .margin({
                    top: 20,
                    right: 0,
                    bottom: 20,
                    left: 20
                });

            /* An array of objects */
            data = [];
            for (var i = 0; i < (years.length * 12); i++) {
                if (i > results.length - 1) {
                    break;
                }
                data[i] = {
                    title: "Prevalence " + results[i].timePeriod,
                    value: results[i].prevalence * 100
                };
            }

            chart.accessor(function (d) {
                return d.value;
            });

            d3.select("#chart3 svg").remove();

            d3.select('#chart3')
                .selectAll('svg')
                .data([data])
                .enter()
                .append('svg')
                .attr("width", "100%")
                .call(chart);


            /* Add a mouseover event */
            d3.selectAll("#chart3 path").on('mouseover', function () {
                var d = d3.select(this).data()[0];
                d3.select("#info").text(d.title + ' has value ' + d.value);
            });
            d3.selectAll("#chart3 svg").on('mouseout', function () {
                d3.select("#info").text('');
            });
        }

        self.miniCircularHeatMap = function (results) {
            // Get the data for the selected concept and current data source name
            $.ajax({
                url: 'http://localhost:8080/WebAPI/DQCDM/dq/concept/' + self.model.currentConceptId(),
                success: function (results) {
                    // Format the data for the chart
                    var years = $.unique(results.map(function (d, i) {
                        return d.timePeriod.substring(2, 4);
                    }));

                    var chart = self.circularHeatChart()
                        .segmentHeight(20)
                        .innerRadius(20)
                        .numSegments(12)
                        .margin({
                            top: 20,
                            right: 0,
                            bottom: 20,
                            left: 20
                        });

                    /* An array of objects */
                    data = [];
                    for (var ds = 0; ds < self.model.services.length; ds++) {
                        var currentSourceName = self.model.services[ds].sourceName;
                        data[ds] = []
                            // Now get the data from the results for the selected data source
                        var resultsDataForSource = results.map(function (d, i) {
                            if (d.sourceName == currentSourceName) {
                                return d;
                            }
                        });

                        // Remove the NULL values from the subset
                        var resultsDataForSourceNoNull = $.grep(resultsDataForSource, function (n, i) {
                            return n != null
                        });


                        // Get the data from the data set
                        for (var i = 0; i < resultsDataForSourceNoNull.length; i++) {
                            data[ds][i] = resultsDataForSourceNoNull[i].prevalence * 100;
                        }
                    }

                    d3.select("#chart2 svg").remove();

                    chart.range(["white", "black"]).margin({
                        top: 20,
                        right: 20,
                        bottom: 20,
                        left: 20
                    });
                    d3.select('#chart2')
                        .selectAll('svg')
                        .data(data)
                        .enter()
                        .append('svg')
                        .call(chart);
                }
            });
        }

        if (self.model.currentConceptId() != undefined && self.model.currentConceptId() > 0) {
            self.loadData();
            //self.circularHeatMap();
            self.miniCircularHeatMap();            
        }

        self.model.currentService.subscribe(function (newValue) {
            self.loadData();
        })
    }

    var component = {
        viewModel: home,
        template: view
    };

    ko.components.register('viewer', component);
    return component;
});