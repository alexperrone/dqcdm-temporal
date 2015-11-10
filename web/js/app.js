define([
	'jquery',
	'knockout',
    'jnj_chart',
    'd3',
	'components/webapi-configuration',
	'bootstrap',
    'facets',
    'databindings',
    'colvis',
    'extenders'
], function ($, ko, jnj_chart, d3) {

	var appModel = function () {
        var self = this;
		this.currentView = ko.observable('home');
		this.appHeading = ko.observable('Data Bound Panel Heading');
		this.appBody = ko.observable('Data Bound Panel Body Content');

		// configure services to include at least one valid OHDSI WebAPI endpoint
		this.services = [
			{
				name: 'CCAE',
                sourceName: 'Truven CCAE',
				url: 'js/json/ccae/',
				dialect: ko.observable('loading'),
				version: ko.observable('loading')
			},
			{
				name: 'OPTUM',
                sourceName: 'Optum',
				url: 'js/json/optum/',
				dialect: ko.observable('loading'),
				version: ko.observable('loading')
			},
			{
				name: 'MDCR',
                sourceName: 'Truven MDCR',
				url: 'js/json/mdcr/',
				dialect: ko.observable('loading'),
				version: ko.observable('loading')
			},
			{
				name: 'MDCD',
                sourceName: 'Truven MDCD',
				url: 'js/json/mdcd/',
				dialect: ko.observable('loading'),
				version: ko.observable('loading')
			},
			{
				name: 'CPRD',
                sourceName: 'CPRD',
				url: 'js/json/cprd/',
				dialect: ko.observable('loading'),
				version: ko.observable('loading')
			},
			{
				name: 'JMDC',
                sourceName: 'JMDC',
				url: 'js/json/jmdc/',
				dialect: ko.observable('loading'),
				version: ko.observable('loading')
			},
			{
				name: 'PREMIER',
                sourceName: 'premier',
				url: 'js/json/premier/',
				dialect: ko.observable('loading'),
				version: ko.observable('loading')
			}
		];

		this.currentServiceUrl = ko.observable(this.services[0].url);
        this.currentService = ko.observable(this.services[0]);
		this.currentSummaryStats = ko.observable();
        this.currentSearch = ko.observable();
        this.currentConceptId = ko.observable();
        this.currentConceptName = ko.observable();
        self.recentSearch = ko.observableArray(null);
        self.searchResultsConcepts = ko.observableArray();

        self.initComplete = function () {
            self.router.init('/');
        }

		this.getSummaryStats = function() {
            // Retrieve the summary stats from the static JSON files
            $.ajax({
                url: self.currentServiceUrl() + 'summary.json',
                success: function (results) {
                    self.currentSummaryStats(results);
                },
                error: function (xhr, message) {
                }
            });
		}
		
        this.currentSummaryStats(this.getSummaryStats());

        this.currentService.subscribe(function (newValue) {
        	if (newValue != undefined) {        		
        		self.getSummaryStats();
        	}
        });
        
        this.viewer = function(conceptid) {
            self.currentView('viewer');
            self.currentConceptId(conceptid);
        }
        
		self.search = function (query) {
			$.ajax({
				url: 'http://localhost:8080/WebAPI/DQCDM/dq/search/' + query,
				success: function (results) {
                    var tempCaption;

                    if (decodeURI(query).length > 20) {
                        tempCaption = decodeURI(query).substring(0, 20) + '...';
                    } else {
                        tempCaption = decodeURI(query);
                    }

                    lastQuery = {
                        query: query,
                        caption: tempCaption,
                        resultLength: results.length
                    };
                    self.currentSearch(query);

                    var exists = false;
                    for (var i = 0; i < self.recentSearch().length; i++) {
                        if (self.recentSearch()[i].query == query)
                            exists = true;
                    }
                    if (!exists) {
                        self.recentSearch.unshift(lastQuery);
                    }
                    if (self.recentSearch().length > 7) {
                        self.recentSearch.pop();
                    }

                    self.searchResultsConcepts(results);
                    self.currentView('search');
				},
				error: function (xhr, message) {
					alert('error while searching ' + message);
				}
			});
		}         
	}

	return appModel;
});
