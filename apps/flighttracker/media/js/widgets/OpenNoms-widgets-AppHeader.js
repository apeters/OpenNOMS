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
            'headerresized': true
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
                    xtype: 'button',
                    iconCls: 'icon-center plane',
                    tooltip: 'Select Flights',
                    iconAlign: 'top',
                    text: '',
                    enableToggle: true,
                    toggleGroup: 'expanded-header-controls',
                    toggleHandler: function (btn, state) {
                        if (state) {
                            if (this.getHeight != this.tallHeight) {
                                this.setHeight(this.tallHeight);
                                this.fireEvent('headerresized');
                            } 
                            Ext.getCmp('expanded-header-area').layout.setActiveItem(0);
                        } else {
                            if (this.getHeight != this.smallHeight) {
                                this.setHeight(this.smallHeight);
                                this.fireEvent('headerresized');
                            }
                        }
                    },
                    scope: this,
                    scale: 'medium'
                }, {
                    xtype: 'container',
                    width: 10
                }, {
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
                }, ]
            }, {
                xtype: 'container',
                width: 120
            }]
        }, {
            xtype: 'toolbar',
            height: 30,
            items: [{
                xtype: 'button',
                id: 'flight-track-type-menu',
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
                        handler: function () {
                            this.setFlightTrackToolbarState('static');
                        },
                        scope: this
                    }, {
                        text: 'Real Time Flight Track Replay',
                        handler: function () {
                            this.setFlightTrackToolbarState('realtime');
                        },
                        scope: this
                    }, {
                        text: 'Animated Flight Track Replay',
                        handler: function () {
                            this.setFlightTrackToolbarState('animated');
                        },
                        scope: this
                    }]
                }
            },'-',{
                xtype: 'button',
                id: 'animationplaybutton',
                iconCls: 'pause',
                width: 65,
                hidden: true,
                text: 'Pause',
                scope: this,
                handler: function () {
                    btn = Ext.getCmp('animationplaybutton');
                    if (btn.text == 'Pause') {
                        btn.setText('Play');
                        btn.setIconCls('play');
                    } else {
                        btn.setText('Pause');
                        btn.setIconCls('pause');
                    }
                }
            },{
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
                maxValue: '11:30 PM',
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
                xtype: 'combo',
                id: 'animationspeedcombo',
                name: 'animationspeed',
                hidden: true,
                value: 10,
                labelWidth: 90,
                labelAlign: 'right',
                width: 150,
                fieldLabel: 'Animation Speed',
                store: Ext.create('Ext.data.Store', {
                    fields: ['multiplier', 'text'],
                    data: [
                        { "multiplier": 2, "text": "2 x" },
                        { "multiplier": 4, "text": "4 x" },
                        { "multiplier": 10, "text": "10 x" },
                        { "multiplier": 20, "text": "20 x" },
                        { "multiplier": 30, "text": "30 x" },
                        { "multiplier": 60, "text": "60 x" }
                    ]
                }),
                queryMode: 'local',
                displayField: 'text',
                valueField: 'multiplier'
            },{
                xtype: 'container',
                id: 'realtimemessage',
                html: '(Flight display is delayed by 15 minutes.)',
                style: 'padding-left: 5px;',
                hidden: true
            }]
        },{
            xtype: 'panel', 
            id: 'expanded-header-area',
            border: false,
            height: 128,
            layout: 'card',
            items: [Ext.create('OpenNoms.widgets.SelectFlights'),{ 
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
    },

    setFlightTrackToolbarState: function (state) {
        this.hideFlightTrackControls();
        switch (state) {
            case 'static':
                Ext.getCmp('flight-track-type-menu').setText('<span style="font-weight:bold;">Static Flight Tracks</span>');
                Ext.getCmp('flighttrackstartdatepicker').show();
                Ext.getCmp('flighttrackstarttimepicker').show();
                Ext.getCmp('staticlengthcombo').show();
                break;
            case 'realtime':
                Ext.getCmp('flight-track-type-menu').setText('<span style="font-weight:bold;">Real Time Flight Track Replay</span>');
                Ext.getCmp('realtimemessage').show();
                btn = Ext.getCmp('animationplaybutton');
                btn.setText('Pause');
                btn.setIconCls('pause');
                btn.show();
                break;
            case 'animated':
                Ext.getCmp('flight-track-type-menu').setText('<span style="font-weight:bold;">Animated Flight Track Replay</span>');
                Ext.getCmp('flighttrackstartdatepicker').show();
                Ext.getCmp('flighttrackstarttimepicker').show();
                Ext.getCmp('animationspeedcombo').show();
                btn = Ext.getCmp('animationplaybutton');
                btn.setText('Play');
                btn.setIconCls('play');
                btn.show();
                break;
        }
    },

    hideFlightTrackControls: function () {
        Ext.getCmp('flighttrackstartdatepicker').hide();
        Ext.getCmp('flighttrackstarttimepicker').hide();
        Ext.getCmp('staticlengthcombo').hide();
        Ext.getCmp('realtimemessage').hide();
        Ext.getCmp('animationplaybutton').hide();
        Ext.getCmp('animationspeedcombo').hide();
    }
});