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

        //this.legendPanel = Ext.create('OpenNoms.widgets.LegendPanel');

        this.newEntityButton = Ext.create('Ext.panel.Panel', {
            frame: true,
            floating: true,
            width: 150,
            height: 30,
            layout: 'fit',
            items: [{
                xtype: 'button',
                text: 'New Entity'
            }]
        });

        this.selectLayersButton = Ext.create('Ext.panel.Panel', {
            frame: true,
            floating: true,
            width: 150,
            height: 30,
            layout: 'fit',
            items: [{
                xtype: 'button',
                text: 'Select Layers/Maps'
            }]
        });

        this.on({
            'activate': function () {
                //this.legendPanel.show();
                this.newEntityButton.show();
                this.selectLayersButton.show();
                this.on({
                    'afterlayout': function () {
                        //this.legendPanel.alignTo(this.mapPanel, 'tl-tl', [10, 10]);
                        this.newEntityButton.alignTo(this.mapPanel, 'tr-tr', [-220, 10]);
                        this.selectLayersButton.alignTo(this.mapPanel, 'tr-tr', [-60, 10]);
                    },
                    'activate': function () {
                        //this.legendPanel.show();
                        this.newEntityButton.show();
                        this.selectLayersButton.show();
                    },
                    'deactivate': function () {
                        //this.legendPanel.hide();
                        this.newEntityButton.hide();
                        this.selectLayersButton.hide();
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