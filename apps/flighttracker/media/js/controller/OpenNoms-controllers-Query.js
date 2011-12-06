Ext.define('OpenNoms.controller.Query', {
    extend: 'Ext.util.Observable',
    alias: 'controller.opennoms-controller-query',

    constructor: function (config) {
        this.addEvents({
            "queryupdated": true
        });

        this.joinString = '\\,';

        // Call our superclass constructor to complete construction process.
        this.callParent(arguments)
    },


    updateLayerWithNewParams: function (layer) {
        // here we'd get the time values for example and update the static flight track
        // for now lets just do this until we understand the time picker better
        layer.mergeNewParams({ viewparams: this.formatParamsForGeoserver() });
    },

    getAniatedFlightData: function () {
        Ext.Ajax.request({

        });
    },

    getFlightParams: function () {
        var flights = Ext.getCmp('select-flights');
        var params = {};
        var airlines, runways, adflags;
        var arr = [];

        // get the selected airlines 
        var airlines = flights.store.queryBy(function (rec, id) { return rec.get('group') == 'Airline' ? true : false; });
        Ext.each(airlines.items, function (item, index, allItems) {
            if (item.data.ischecked) {
                arr.push(item.data.value);
            }
        }, this);

        params.airline = arr.join(this.joinString);
        arr = [];

        // get the selected adflags 
        var adflags = flights.store.queryBy(function (rec, id) { return rec.get('group') == 'Flight Type' ? true : false; });
        Ext.each(adflags.items, function (item, index, allItems) {
            if (item.data.ischecked) {
                arr.push(item.data.value);
            }
        }, this);

        params.adflag = arr.join(this.joinString);
        arr = [];

        // get the selected runways 
        var runways = flights.store.queryBy(function (rec, id) { return rec.get('group').substr(0, 7) == 'Airport' ? true : false; });
        Ext.each(runways.items, function (item, index, allItems) {
            if (item.data.ischecked) {
                arr.push(item.data.value);
            }
        }, this);

        params.runway = arr.join(this.joinString);
        arr = [];

        return params;
    },

    formatParamsForGeoserver: function () {
        var params = this.getFlightParams();
        var ret = "";
        for (var propertyName in params) {
            ret += propertyName + ':' + params[propertyName] + ';';
        }

        return ret;
    }


});