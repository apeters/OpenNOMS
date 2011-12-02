Ext.define('OpenNoms.widgets.AppPanel', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.opennoms-widgets-apppanel',
    border: false,

    id: 'app-panel',

    initComponent: function () {
        this.addEvents({
            'clearmeasureclicked': true
        });

        this.mapPanel = new OpenNoms.widgets.MapPanel();
        this.appHeader = new OpenNoms.widgets.AppHeader();

        Ext.apply(this, {
            items: [
                this.appHeader,
                this.mapPanel
            ],
            layout: 'border'
        });

        this.noiseButton = Ext.create('Ext.panel.Panel', {
            frame: true,
            floating: true,
            width: 40,
            height: 40,
            layout: 'fit',
            items: [{
                xtype: 'button',
                iconCls: 'icon-center sound',
                tooltip: 'View Noise Events',
                iconAlign: 'top',
                text: '',
                scale: 'medium',
                enableToggle: true,
                toggleGroup: 'info-panel-controls',
                toggleHandler: function (btn, state) {
                    if (state) {
                        this.infoPanel.show();
                        this.infoPanel.alignTo(this.mapPanel, 'tr-tr', [-60, 10]);
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
            width: 40,
            height: 40,
            layout: 'fit',
            items: [{
                xtype: 'button',
                iconCls: 'icon-center map',
                tooltip: 'View Legend',
                iconAlign: 'top',
                text: '',
                scale: 'medium',
                enableToggle: true,
                toggleGroup: 'info-panel-controls',
                toggleHandler: function (btn, state) {
                    if (state) {
                        this.infoPanel.show();
                        this.infoPanel.alignTo(this.mapPanel, 'tr-tr', [-60, 10]);
                        this.infoPanel.layout.setActiveItem(1);
                    } else {
                        this.infoPanel.hide();
                    }
                },
                scope: this
            }]
        });

        this.selectFlightsButton = Ext.create('Ext.panel.Panel', {
            frame: true,
            floating: true,
            width: 40,
            height: 40,
            layout: 'fit',
            items: [{
                xtype: 'button',
                iconCls: 'icon-center plane',
                tooltip: 'Select Flights',
                iconAlign: 'top',
                text: '',
                scale: 'medium',
                enableToggle: true,
                toggleGroup: 'info-panel-controls',
                toggleHandler: function (btn, state) {
                    if (state) {
                        this.infoPanel.show();
                        this.infoPanel.alignTo(this.mapPanel, 'tr-tr', [-60, 10]);
                        this.infoPanel.layout.setActiveItem(2);
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
            height: 320,
            layout: 'card',
            items: [Ext.create('OpenNoms.widgets.NoiseEventViewer', {
                tools: [{
                    type: 'close',
                    handler: function (event, toolEl, panel) {
                        this.noiseButton.query('button')[0].toggle();
                    },
                    scope: this
                }]
            }), Ext.create('OpenNoms.widgets.Legend', {
                tools: [{
                    type: 'close',
                    handler: function (event, toolEl, panel) {
                        this.legendButton.query('button')[0].toggle();
                    },
                    scope: this
                }]
            }), Ext.create('OpenNoms.widgets.SelectFlights', {
                tools: [{
                    type: 'close',
                    handler: function (event, toolEl, panel) {
                        this.selectFlightsButton.query('button')[0].toggle();
                    },
                    scope: this
                }]
            })],
            listeners: {
                'show': function () {
                    this.on({
                        'afterlayout': function () {
                            this.infoPanel.alignTo(this.mapPanel, 'tr-tr', [-60, 10]);
                        },
                        scope: this
                    });
                },
                scope: this,
                single: true
            }
        });

        this.measureFeedbackPanel = Ext.create('Ext.panel.Panel', {
            frame: true,
            floating: true,
            width: 200,
            height: 80,
            layout: {
                type: 'vbox',
                padding: '5',
                align: 'stretch'
            },
            items: [{
                xtype: 'container',
                height: 35,
                html: '<div style="font-weight:bold;">Current Measurement: </div><div id="measure-read-out"></div>'
            }, {
                xtype: 'button',
                text: 'Clear Measurement',
                height: 25,
                handler: function () {
                    this.fireEvent('clearmeasureclicked');
                },
                scope: this
            }],
            listeners: {
                'show': function () {
                    this.on({
                        'afterlayout': function () {
                            this.measureFeedbackPanel.alignTo(this.mapPanel, 'tl-tl', [70, 10]);
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
                this.selectFlightsButton.show();
                this.on({
                    'afterlayout': function () {
                        this.noiseButton.alignTo(this.mapPanel, 'tr-tr', [-10, 60]);
                        this.legendButton.alignTo(this.mapPanel, 'tr-tr', [-10, 10]);
                        this.selectFlightsButton.alignTo(this.mapPanel, 'tr-tr', [-10, 110]);
                    },
                    'activate': function () {
                        this.noiseButton.show();
                        this.legendButton.show();
                        this.selectFlightsButton.show();
                    },
                    'deactivate': function () {
                        this.noiseButton.hide();
                        this.legendButton.hide();
                        this.selectFlightsButton.hide();
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