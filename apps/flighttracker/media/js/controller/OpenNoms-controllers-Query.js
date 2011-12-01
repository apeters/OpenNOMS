Ext.define('OpenNoms.controller.Query', {
    extend: 'Ext.util.Observable',
    alias: 'controller.opennoms-controller-query',
    
    constructor: function (config) {
        this.addEvents({
            "queryupdated": true
        });

        // Call our superclass constructor to complete construction process.
        this.callParent(arguments)
    },


    updateQuery: function (mapPanel) {
        // here we'd get the time values for example and update the static flight track
        // for now lets just do this until we understand the time picker better
        mapPanel.staticflightlayer.mergeNewParams({ viewparams: "" });
    }


});