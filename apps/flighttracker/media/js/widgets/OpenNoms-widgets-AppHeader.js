Ext.define('OpenNoms.widgets.AppHeader', {
    extend: 'Ext.panel.Panel',
    alias: 'widgets.opennoms-widgets-appheader',

    id: 'app-header',
    height: 90,
    region: 'north',
    layout: 'hbox',
    bodyCls: 'header-area',
    border: false,
    bodyStyle: 'padding: 8px 3px 8px 8px;',

    initComponent: function () {
        this.items = [{
            xtype: 'container',
            layout: 'fit',
            html: '<div style="text-align:center;padding-top:10px;height:36px;background-color:white;color:black;border:1px solid black">{logo}</div>',
            width: 40
        }, {
            xtype: 'container',
            layout: 'fit',
            style: 'padding-left:10px;',
            html: '<div style="font-size:18px;font-weight:bold;">MAC Flight Tracker</div>' +
                            '<div>National Heritage and Documentation System</div>',
            flex: 1
        }, {
            xtype: 'container',
            layout: 'fit',
            html: 'Welcome adalgity@getty.edu',
            autoWidth: true,
            style: 'padding-right:10px;padding-top: 9px;'
        }, {
            xtype: 'container',
            layout: 'hbox',
            items: [{
                xtype: 'button',
                iconCls: 'flagblue',
                handler: function () {
                },
                scope: this
            }, {
                xtype: 'container',
                html: '',
                width: 2
            }, {
                xtype: 'button',
                iconCls: 'film',
                handler: function () {
                },
                scope: this
            }],
            width: 46,
            style: 'padding-top:5px;'
        }];
        this.dockedItems = [{
            xtype: 'toolbar',
            height: 35,
            items: [{
                xtype: 'combo',
                triggerCls: 'x-form-search-trigger',
                name: 'mapsearch',
                store: Ext.create('Ext.data.Store', {
                    fields: ['id', 'name'],
                    data: [
                        { "id": 0, "name": "Entity 1" },
                        { "id": 1, "name": "Entity 2" },
                        { "id": 2, "name": "Entity 3" }
                    ]
                }),
                queryMode: 'local',
                displayField: 'name',
                valueField: 'id',
                emptyText: 'Find an Entity',
                width: 425,
                style: 'padding-left: 6px;'
            }, '<a href="#" style="padding-left: 6px;">Advanced Search</a>', '->', {
                xtype: 'button',
                iconCls: 'disk',
                handler: function () {
                },
                scope: this
            }, {
                xtype: 'button',
                iconCls: 'printer',
                handler: function () {
                },
                scope: this
            }],
            dock: 'bottom'
        }];
        this.callParent(arguments);
    }
});