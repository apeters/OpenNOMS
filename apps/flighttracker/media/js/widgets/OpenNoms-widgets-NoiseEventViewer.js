Ext.define('OpenNoms.widgets.NoiseEventViewer', {
    extend: 'Ext.grid.Panel',
    alias: 'widgets.opennoms-widgets-noiseeventviewer',

    id: 'noise-event-viewer',
    title: 'Noise Event Information',

    initComponent: function () {
        var url = OpenNoms.config.URLs.getNoiseEventData;
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
                url: url
            })
        });

        this.columns = [
            { header: 'RMT', dataIndex: 'rmt', width: 38 },
            { header: 'LMax', dataIndex: 'lmax', width: 38 },
            { header: 'LEQ', dataIndex: 'leq', width: 38 },
            { header: 'SEL', dataIndex: 'sel', width: 38 },
            { header: 'Max Time', dataIndex: 'mtime', xtype: 'datecolumn', format: 'F j, Y, g:i:s a', flex: 1 },
            { header: 'Duration', dataIndex: 'duration', width: 60 }
        ];

        this.callParent(arguments);
    }
});