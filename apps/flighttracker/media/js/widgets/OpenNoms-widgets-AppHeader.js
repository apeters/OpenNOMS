Ext.define('OpenNoms.widgets.AppHeader', {
    extend: 'Ext.panel.Panel',
    alias: 'widgets.opennoms-widgets-appheader',

    id: 'app-header',
    height: 64,
    region: 'north',
    layout: 'hbox',
    bodyCls: 'header-area',
    border: false,
    bodyStyle: 'padding: 0px 3px 8px 8px;',

    initComponent: function () {
        this.items = [{
            xtype: 'container',
            layout: 'fit',
            style: 'padding-left:65px;',
            html: '<div style="font-size:18px;font-weight:bold;">MAC Flight Tracker</div>',
            flex: 1
        }, {
            xtype: 'container',
            layout: 'fit',
            html: '<a href="#" style="color: white;">Feedback</a><a style="padding-left: 10px; color: white;" href="#">Help</a>',
            width: 100,
            style: 'padding-right:10px;padding-top: 5px;'
        }];
        this.dockedItems = [{
            xtype: 'container',
            layout: 'hbox',
            height: 37,
            items: [{
                xtype: 'combo',
                triggerCls: 'x-form-search-trigger',
                name: 'mapsearch',
                store: Ext.create('Ext.data.Store', {
                    fields: ['id', 'name'],
                    data: [
                        { "id": 0, "name": "Address 1" },
                        { "id": 1, "name": "Address 2" },
                        { "id": 2, "name": "Address 3" }
                    ]
                }),
                queryMode: 'local',
                displayField: 'name',
                valueField: 'id',
                emptyText: 'Find an Address',
                width: 425,
                style: 'padding-left: 70px; padding-top: 6px;'
            }, {
                xtype: 'container',
                flex: 1
            }, {
                xtype: 'container',
                layout: 'hbox',
                width: 200,
                style: 'padding-top: 2px;',
                items: [{
                    xtype: 'button',
                    iconCls: 'icon-center world',
                    iconAlign: 'top',
                    text: '',
                    handler: function () {
                    },
                    scope: this,
                    scale: 'medium'
                }, {
                    xtype: 'container',
                    width: 10
                }, {
                    xtype: 'button',
                    iconCls: 'icon-center clock',
                    iconAlign: 'top',
                    text: '',
                    handler: function () {
                    },
                    scope: this,
                    scale: 'medium'
                }, {
                    xtype: 'container',
                    width: 10
                }, {
                    xtype: 'button',
                    iconCls: 'icon-center printer',
                    iconAlign: 'top',
                    text: '',
                    handler: function () {
                    },
                    scope: this,
                    scale: 'medium'
                }, {
                    xtype: 'container',
                    width: 10
                }, {
                    xtype: 'button',
                    iconCls: 'icon-center email',
                    iconAlign: 'top',
                    text: '',
                    handler: function () {
                    },
                    scope: this,
                    scale: 'medium'
                }]
            }, {
                xtype: 'container',
                width: 80
            }],
            dock: 'bottom'
        }];

        this.callParent(arguments);

        this.logo = Ext.create('Ext.container.Container', {
            layout: 'fit',
            html: '<div style="text-align:center;padding-top:15px;height:50px;background-color:white;color:black;border:1px solid black">{logo}</div>',
            width: 60,
            height: 50,
            floating: true,
            shadow: false,
            x: 5,
            y: 5
        });

        this.on({
            'afterlayout': function () {
                this.logo.show();
            },
            single: true,
            scope: this
        });
    }
});