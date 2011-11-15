Ext.define('OpenNoms.widgets.AppPanel', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.opennoms-widgets-apppanel',
    border: false,

    id: 'app-panel',

    initComponent: function () {
        this.mapPanel = new OpenNoms.widgets.MapPanel();
        this.appHeader = new OpenNoms.widgets.AppHeader();

        Ext.apply(this, {
            items: [
                this.appHeader,
                this.mapPanel
            ],
            layout: 'border',
            listeners: {
                'afterlayout': {
                    fn: function () {
                        this.mapPanel.mapReady();
                    },
                    scope: this,
                    single: true
                },
                scope: this
            }
        });

        this.noiseButton = Ext.create('Ext.panel.Panel', {
            frame: true,
            floating: true,
            width: 32,
            height: 32,
            layout: 'fit',
            items: [{
                xtype: 'button',
                iconCls: 'sound',
                enableToggle: true,
                toggleGroup: 'info-panel-controls',
                toggleHandler: function (btn, state) {
                    if (state) {
                        this.infoPanel.show();
                        this.infoPanel.alignTo(this.mapPanel, 'tr-tr', [-50, 10]);
                        this.infoPanel.layout.setActiveItem(0);
                    } else {
                        this.infoPanel.hide();
                    }
                },
                scope: this
            }]
        });

        this.legendButton = Ext.create('Ext.panel.Panel', {
            frame: true,
            floating: true,
            width: 32,
            height: 32,
            layout: 'fit',
            items: [{
                xtype: 'button',
                iconCls: 'map',
                enableToggle: true,
                toggleGroup: 'info-panel-controls',
                toggleHandler: function (btn, state) {
                    if (state) {
                        this.infoPanel.show();
                        this.infoPanel.alignTo(this.mapPanel, 'tr-tr', [-50, 10]);
                        this.infoPanel.layout.setActiveItem(1);
                    } else {
                        this.infoPanel.hide();
                    }
                },
                scope: this
            }]
        });

        this.infoPanel = Ext.create('Ext.panel.Panel', {
            frame: true,
            floating: true,
            width: 375,
            height: 220,
            layout: 'card',
            items: [{
                xtype: 'panel',
                title: 'Noise Event Information',
                html: '',
                tools: [{
                    type: 'close',
                    handler: function (event, toolEl, panel) {
                        this.noiseButton.query('button')[0].toggle();
                    },
                    scope: this
                }]
            }, {
                xtype: 'panel',
                title: 'Legend',
                html: '',
                tools: [{
                    type: 'close',
                    handler: function (event, toolEl, panel) {
                        this.legendButton.query('button')[0].toggle();
                    },
                    scope: this
                }]
            }],
            listeners: {
                'show': function () {
                    this.on({
                        'afterlayout': function () {
                            this.infoPanel.alignTo(this.mapPanel, 'tr-tr', [-50, 10]);
                        },
                        scope: this
                    });
                },
                scope: this,
                single: true
            }
        });

        this.on({
            'activate': function () {
                this.noiseButton.show();
                this.legendButton.show();
                this.on({
                    'afterlayout': function () {
                        this.noiseButton.alignTo(this.mapPanel, 'tr-tr', [-10, 50]);
                        this.legendButton.alignTo(this.mapPanel, 'tr-tr', [-10, 10]);
                    },
                    'activate': function () {
                        this.noiseButton.show();
                        this.legendButton.show();
                    },
                    'deactivate': function () {
                        this.noiseButton.hide();
                        this.legendButton.hide();
                    },
                    scope: this
                });
                this.doLayout();
            },
            single: true,
            scope: this
        });


        this.callParent(arguments);
    }
});