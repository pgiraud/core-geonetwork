Ext.namespace('cat');

cat.what = function() {
	
	var advancedFields = [];
	
	var createSep = function() {
		return {
			xtype: 'box',
			autoEl: {
				tag:'hr',
				cls: 'search_form_separator'}
		}
	};

	return {
		createCmp : function(services) {
			
			//var catalogueField = GeoNetwork.util.SearchFormTools.getCatalogueField(services.getSources, services.logoUrl, false);
			// Catalogue field is for Sextant the groupPublished
			// TODO : here we have to restrict the list according to index content
			// using autocompletion
			var lang = GeoNetwork.Util.getCatalogueLang(OpenLayers.Lang.getCode());
			
			// if configwhat is set, the groupFieldStore is loaded from data in configwhat
			var mode, groupFieldStore;
			var configwhatInput = Ext.query('input[id*=configwhat]');
			if(configwhatInput && configwhatInput[0] && configwhatInput[0].value) {
				groupFieldStore =  new Ext.data.ArrayStore({
					fields: ['value']
				});
				var data = configwhatInput[0].value.split(',');
				for(i=0;i<data.length;i++) {
					data[i] = [data[i]];
				}
				groupFieldStore.loadData(data);
				mode='local';
			}
			else {
				 groupFieldStore = new GeoNetwork.data.OpenSearchSuggestionStore(
					{
						url : services.opensearchSuggest,
						rootId : 1,
						baseParams : {
							field : '_groupPublished'
						}
					});
				 mode='remote';
			}
	        var catalogueField = new Ext.ux.form.SuperBoxSelect({
	            hideLabel: false,
	            width: 230,
	            minChars: 0,
	            queryParam: 'q',
	            hideTrigger: false,
	            id: 'E__groupPublished',
	            name: 'E__groupPublished',
	            mode: mode,
	            store: groupFieldStore,
	            valueField: 'value',
	            displayField: 'value',
	            valueDelimiter: ' or ',
	            fieldLabel: OpenLayers.i18n('Catalogue')
	        });
			
			var categoryTree = new GeoNetwork.CategoryTree({
				url : services.getCategories,
				rootVisible: false,
				label: OpenLayers.i18n('Themes'),
				autoWidth: true
			});
			
			var sep1 = createSep();
			var sep2 = createSep();
			
			var searchField = new GeoNetwork.form.OpenSearchSuggestionTextField({
				width: 230,
				minChars: 2,
				loadingText: '...',
				fieldLabel: OpenLayers.i18n('fullTextSearch'),
				hideLabel: false,
				hideTrigger: true,
				startwith:true,
				url: services.opensearchSuggest
			});
			advancedFields.push(categoryTree, catalogueField);
			
			return new Ext.Panel({
				title: OpenLayers.i18n('What'),
				autoHeight: true,
				autoWidth: true,
				collapsible: true,
				collapsed: false,
				layout: 'form',
				defaultType: 'checkbox',
				bodyCssClass: 'hidden',
				defaults: {
					itemCls: 'search_label'
				},
				listeners: {
					'afterrender': function(o) {
						o.header.on('click', function() {
							if(o.collapsed) o.expand();
							else o.collapse();
						});
					}
				},
				items: [searchField, sep1, catalogueField, sep2, categoryTree]
			});
		},
		
		getAdvancedFields : function() {
			return advancedFields;
		}
	}
}();