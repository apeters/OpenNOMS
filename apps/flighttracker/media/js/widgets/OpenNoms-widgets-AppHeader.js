Ext.define('OpenNoms.widgets.AppHeader', {
    extend: 'Ext.container.Container',
    alias: 'widgets.opennoms-widgets-appheader',

    id: 'app-header',
    height: 72,
    region: 'north',
    layout: {
        type: 'vbox',
        align: 'stretch'
    },
    border: false,


    initComponent: function () {
        this.items = [{
            xtype: 'panel',
            layout: 'hbox',
            bodyCls: 'header-area',
            border: false,
            bodyStyle: 'padding: 2px 3px 8px 8px;',
            height: 34,
            items: [{
                xtype: 'container',
                layout: 'fit',
                style: 'padding-left:71px;',
                html: '<div style="font-size:18px;font-weight:bold;padding-top:3px;">MAC Flight Tracker</div>',
                flex: 1
            }, {
                xtype: 'container',
                layout: 'fit',
                html: '<a href="#" style="color: white;">Feedback</a><a style="padding-left: 10px; color: white;" href="#">Help</a>',
                width: 100,
                style: 'padding-right:10px;padding-top: 5px;'
            }],
        }, {
            xtype: 'container',
            layout: 'hbox',
            height: 38,
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
                style: 'padding-left: 76px; padding-top: 8px;'
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
                    enableToggle: true,
                    toggleGroup: 'expanded-header-controls',
                    toggleHandler: function (btn, state) {
                        if (state) {
                            if (this.getHeight != 200) {
                                this.setHeight(200);
                            } 
                            Ext.getCmp('expanded-header-area').layout.setActiveItem(0);
                        } else {
                            if (this.getHeight != 72) {
                                this.setHeight(72);
                            }
                        }
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
                    enableToggle: true,
                    toggleGroup: 'expanded-header-controls',
                    toggleHandler: function (btn, state) {
                        if (state) {
                            if (this.getHeight != 200) {
                                this.setHeight(200);
                            } 
                            Ext.getCmp('expanded-header-area').layout.setActiveItem(1);
                        } else {
                            if (this.getHeight != 72) {
                                this.setHeight(72);
                            }
                        }
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
            }]
        },{
            xtype: 'panel', 
            id: 'expanded-header-area',
            height: 128,
            layout: 'card',
            items: [{ 
                xtype: 'panel',
                title: 'Flights...'
            },{ 
                xtype: 'panel',
                title: 'Time...'
            }]
        }];

        this.callParent(arguments);

        this.logo = Ext.create('Ext.container.Container', {
            layout: 'fit',
            cls: 'header-logo',
            width: 64,
            height: 64,
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