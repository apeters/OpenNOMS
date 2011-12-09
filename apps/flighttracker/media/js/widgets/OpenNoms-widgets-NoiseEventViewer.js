Ext.define('OpenNoms.widgets.NoiseEventViewer', {
    extend: 'Ext.grid.Panel',
    alias: 'widgets.opennoms-widgets-noiseeventviewer',

    id: 'noise-event-viewer',

    initComponent: function () {
        var url = OpenNoms.config.URLs.ows;
        this.store = Ext.create('Ext.data.Store', {
            fields: [
                { name: 'eventid', type: 'number' },
                { name: 'opnum', type: 'number' },
                { name: 'rmt', type: 'number' },
                { name: 'stime', type: 'date' },
                { name: 'mtime', type: 'date' },
                { name: 'duration', type: 'number' },
                { name: 'leq', type: 'number' },
                { name: 'sel', type: 'number' },
                { name: 'lmax', type: 'number' },
                { name: 'radius', type: 'number' },
                { name: 'wkt', type: 'string' }
            ],
            proxy: Ext.create('FGI.data.proxy.GeoserverJsonP', {
                url: url,
                extraParams: {
                    'service': 'WFS',
                    'version': '1.0.0',
                    'request': 'GetFeature',
                    'typeName': 'opennoms:getevents',
                    'maxFeatures': '50',
                    'outputFormat': 'json'
                }
            })
        });

        this.columns = [
            { header: 'RMT', dataIndex: 'rmt', width: 34 },
            { header: 'LMax (db)', dataIndex: 'lmax', width: 56 },
            { header: 'LEQ (db)', dataIndex: 'leq', width: 50 },
            { header: 'SEL (db)', dataIndex: 'sel', width: 50 },
            { header: 'Max Time', dataIndex: 'mtime', xtype: 'datecolumn', format: 'F j, Y, g:i:s a', flex: 1 },
            { header: 'Duration (s)', dataIndex: 'duration', width: 66 }
        ];

        this.callParent(arguments);
    }
});