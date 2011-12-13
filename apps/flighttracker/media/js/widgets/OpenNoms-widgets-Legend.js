Ext.define('OpenNoms.widgets.Legend', {
    extend: 'Ext.grid.Panel',
    alias: 'widgets.opennoms-widgets-legend',

    id: 'legend-grid',
    hideHeaders: true,

    initComponent: function () {
        this.addEvents({
            'checkchange': true
        });

        this.store = Ext.create('Ext.data.Store', {
            fields: [
                { name: 'name', type: 'string' },
                { name: 'isOn', type: 'boolean' },
                { name: 'layer' }
            ]
        });

        this.columns = [
            {
                xtype: 'checkcolumn',
                header: '',
                dataIndex: 'isOn',
                width: 22,
                listeners: {
                    'checkchange': function (column, recIndex, checked) {
                        var record = this.store.getAt(recIndex);
                        record.commit();
                        this.fireEvent('checkchange', this, recIndex, checked);
                    },
                    scope: this
                }
            },
            { header: 'Layer Name', dataIndex: 'name', flex: 1 }
        ];

        this.callParent(arguments);
    }
});