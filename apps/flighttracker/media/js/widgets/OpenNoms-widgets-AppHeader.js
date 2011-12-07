Ext.define('OpenNoms.widgets.AppHeader', {
    extend: 'Ext.container.Container',
    alias: 'widgets.opennoms-widgets-appheader',

    id: 'app-header',
    smallHeight: 102,
    tallHeight: 230,
    region: 'north',
    layout: {
        type: 'vbox',
        align: 'stretch'
    },
    border: false,


    initComponent: function () {
        this.addEvents({
            'measureclicked': true,
            'headerresized': true,
            'changestate': true,
            'setdatetimerange': true
        });

        this.height = this.smallHeight;

        var yesterday = new Date();
        yesterday.setDate(new Date().getDate() - 1);

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
                width: 220,
                style: 'padding-top: 2px;',
                items: [{
//                    xtype: 'button',
//                    iconCls: 'icon-center plane',
//                    tooltip: 'Select Flights',
//                    iconAlign: 'top',
//                    text: '',
//                    enableToggle: true,
//                    toggleGroup: 'expanded-header-controls',
//                    toggleHandler: function (btn, state) {
//                        if (state) {
//                            if (this.getHeight != this.tallHeight) {
//                                this.setHeight(this.tallHeight);
//                                this.fireEvent('headerresized');
//                            } 
//                            Ext.getCmp('expanded-header-area').layout.setActiveItem(0);
//                        } else {
//                            if (this.getHeight != this.smallHeight) {
//                                this.setHeight(this.smallHeight);
//                                this.fireEvent('headerresized');
//                            }
//                        }
//                    },
//                    scope: this,
//                    scale: 'medium'
//                }, {
//                    xtype: 'container',
//                    width: 10
//                }, {
//                    xtype: 'button',
//                    iconCls: 'icon-center clock',
//                    iconAlign: 'top',
//                    text: '',
//                    enableToggle: true,
//                    toggleGroup: 'expanded-header-controls',
//                    toggleHandler: function (btn, state) {
//                        if (state) {
//                            if (this.getHeight != this.tallHeight) {
//                                this.setHeight(this.tallHeight);
//                                this.fireEvent('headerresized');
//                            } 
//                            Ext.getCmp('expanded-header-area').layout.setActiveItem(1);
//                        } else {
//                            if (this.getHeight != this.smallHeight) {
//                                this.setHeight(this.smallHeight);
//                                this.fireEvent('headerresized');
//                            }
//                        }
//                    },
//                    scope: this,
//                    scale: 'medium'
//                }, {
//                    xtype: 'container',
//                    width: 10
//                }, {
                    xtype: 'button',
                    iconCls: 'icon-center printer',
                    tooltip: 'Print',
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
                    tooltip: 'Email',
                    iconAlign: 'top',
                    text: '',
                    handler: function () {
                    },
                    scope: this,
                    scale: 'medium'
                }, {
                    xtype: 'container',
                    width: 10
                },{
                    xtype: 'splitbutton',
                    id: 'measure-button',
                    tooltip: 'Measure Tool',
                    iconCls: 'icon-center ruler',
                    iconAlign: 'top',
                    text: '',
                    enableToggle: true,
                    toggleHandler: function (btn, state) {
                        var mode = 'distance';
                        if (Ext.getCmp('measure-button').iconCls == 'icon-center rulersquare') {
                            mode = 'area';
                        }
                        this.fireEvent('measureclicked', mode, state);
                    },
                    scope: this,
                    menu: [{
                        text: 'Distance',
                        iconCls: 'ruler',
                        handler: function () {
                            Ext.getCmp('measure-button').setIconCls('icon-center ruler');
                            Ext.getCmp('measure-button').toggle(true);
                        },
                        scope: this
                    },{
                        text: 'Area',
                        iconCls: 'rulersquare',
                        handler: function () {
                            Ext.getCmp('measure-button').setIconCls('icon-center rulersquare');
                            Ext.getCmp('measure-button').toggle(true);
                        },
                        scope: this
                    }],
                    arrowAlign: 'right',
                    scope: this,
                    scale: 'medium'
                }]
            }]
        }, {
            xtype: 'toolbar',
            height: 30,
            items: [{
                xtype: 'button',
                id: 'flight-track-type-menu',
                tooltip: 'Select flight track display type',
                style: 'font-weight: bold;',
                text: '<span style="font-weight:bold;">Static Flight Tracks</span>',
                width: 200,
                menu: {
                    width: 200,
                    defaults: {
                        width: 194
                    },
                    items: [{
                        text: 'Static Flight Tracks',
                        iconCls: 'lineblue',
                        handler: function () {
                            this.fireEvent('changestate', 'static');
                        },
                        scope: this
                    }, {
                        text: 'Animated Flight Track Replay',
                        iconCls: 'coggo',
                        handler: function () {
                            this.fireEvent('changestate', 'animated');
                        },
                        scope: this
                    }, {
                        text: 'Real Time Flight Track Replay',
                        iconCls: 'clockgo',
                        handler: function () {
                            this.fireEvent('changestate', 'realtime');
                        },
                        scope: this
                    }]
                }
            },'-',{
                xtype: 'datefield',
                id: 'flighttrackstartdatepicker',
                fieldLabel: 'Start Date',
                labelWidth: 60,
                labelAlign: 'right',
                width: 170,
                name: 'staticstartdate',
                maxValue: yesterday,
                value: yesterday
            },{
                xtype: 'timefield',
                id: 'flighttrackstarttimepicker',
                name: 'staticstarttime',
                fieldLabel: 'Start Time',
                labelWidth: 60,
                labelAlign: 'right',
                width: 160,
                minValue: '12:00 AM',
                maxValue: '11:55 PM',
                value: '1:00 PM',
                increment: 5
            },{
                xtype: 'combo',
                id: 'staticlengthcombo',
                name: 'staticlength',
                value: 10,
                labelWidth: 45,
                labelAlign: 'right',
                width: 150,
                fieldLabel: 'Length',
                store: Ext.create('Ext.data.Store', {
                    fields: ['length', 'text'],
                    data: [
                        { "length": 1, "text": "1 Minute" },
                        { "length": 5, "text": "5 Minutes" },
                        { "length": 10, "text": "10 Minutes" },
                        { "length": 20, "text": "20 Minutes" },
                        { "length": 30, "text": "30 Minutes" },
                        { "length": 45, "text": "45 Minutes" },
                        { "length": 60, "text": "1 Hour" },
                        { "length": 90, "text": "1.5 Hours" },
                        { "length": 120, "text": "2 Hours" },
                        { "length": 150, "text": "2.5 Hours" },
                        { "length": 180, "text": "3 Hours" },
                        { "length": 210, "text": "3.5 Hours" },
                        { "length": 240, "text": "4 Hours" },
                        { "length": 300, "text": "5 Hours" },
                        { "length": 480, "text": "8 Hours" },
                        { "length": 720, "text": "12 Hours" },
                        { "length": 1080, "text": "18 Hours" },
                        { "length": 1440, "text": "24 Hours" }
                    ]
                }),
                queryMode: 'local',
                displayField: 'text',
                valueField: 'length'
            },{
                xtype: 'button',
                id: 'gobutton',
                tooltip: 'Refresh flight tracks',
                iconCls: 'icon-center refresh',
                scope: this,
                handler: function () {
                    this.fireEvent('setdatetimerange');
                },
                scale: 'small'
            },{
                xtype: 'multislider',
                id: 'staticslider',
                flex: 1,
                minValue: 0,
                hideLabel: false,
                useTips: false,
                maxValue: 1440,
                values: [0,10],
                increment: 5,
                style: 'margin-left: 15px;margin-right: 15px;',
                hidden: true
            },{
                xtype:'opennoms-widgets-trackanimator',
		        id:'tabtrackanimator',
                hidden: true,
                style: 'margin-top: 0px; margin-left: 30px;',
                flex: 1,
                span: 20, // seconds of "tail" to show
                speed: 10, // play at 150x real time
		        frameRate: Ext.isIE?1:4,
                listeners:{
                    'afterrender': function(){
                        this.layer = OpenNoms.app.appPanel.mapPanel.animatedFlightTracks;
                    }
                },
		        url: 'http://localhost:8080/geoserver/opennoms/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=opennoms:realtimetrack&viewparams=airport:MSP;isorange:2011-08-06%2016\\:00\\:00/2011-08-06%2016\\:15\\:00;optype:;x:480956;y:4970848;step:2;&outputFormat=json'
            },
            {
                xtype: 'container',
                id: 'realtimemessage',
                html: '(Flight display is delayed by 15 minutes.)',
                style: 'padding-left: 5px;',
                hidden: true
            }]
//        },{
//            xtype: 'panel', 
//            id: 'expanded-header-area',
//            border: false,
//            height: 128,
//            layout: 'card',
//            items: [Ext.create('OpenNoms.widgets.SelectFlights'),{ 
//                xtype: 'panel',
//                title: 'Time...'
//            }]
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