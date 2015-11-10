define(['knockout', 'text!./search.html', 'knockout.dataTables.binding'], function (ko, view) {
	function search(params) {
		var self = this;
		self.model = params.model;
        self.searchResults = params.model.searchResultsConcepts;
		self.datatables = {};
        self.columns = [{
                            data: 'conceptId',
                            title: 'Concept ID'
                        },
                        {
                            title: 'Concept Name',
                            data: 'conceptName',
                            "fnCreatedCell": function (nTd, sData, oData, iRow, iCol) {
                                $(nTd).html("<a href='#/viewer/"+oData.conceptId+"'>" + oData.conceptName + "</a>")
                            }                            
                            
                        },
                        {
                            title: 'Domain',
                            data: 'domainId'
                        },
                        {
                            title: 'Data Source',
                            data: 'sourceName'
                        },                        
                        {
                            title: 'Increasing Slope',
                            data: 'dqWarningIncreasingSlope'
                        },
                        {
                            title: 'Decreasing Slope',
                            data: 'dqWarningDecreasingSlope'
                        },
                        {
                            title: 'Discontinuity',
                            data: 'dqWarningDiscontinuity'
                        },
                        {
                            title: 'Outlier Months',
                            data: 'dqWarningOutlierMonths'
                        }
                    ];
    }

	var component = {
		viewModel: search,
		template: view
	};

	ko.components.register('search', component);
	return component;
});
