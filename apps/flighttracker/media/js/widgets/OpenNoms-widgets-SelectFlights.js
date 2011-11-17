var data = [{
  name: 'item 1',
  id: 0
}, {
    name: 'item 2',
    id: 1
}, {
    name: 'item 3',
    id: 2
}];

Ext.define('OpenNoms.widgets.SelectFlights', {
    extend: 'Ext.panel.Panel',
    alias: 'widgets.opennoms-widgets-selectflights',

    id: 'select-flights',
    title: 'Select Flights',
    layout: {
        type: 'vbox',
        padding: '5',
        align: 'stretch'
    },

    initComponent: function () {
        this.items = [{
            xtype: 'container',
            layout: {
                type: 'hbox',
                padding: '2',
                align: 'stretch'
            },
            height: 28,
            items: [{
                xtype: 'container',
                flex: 1
            }, {
                xtype: 'button',
                text: 'Flight Types',
                width: 170,
                menu: {
                    width: 170,
                    defaults: {
                        width: 164
                    },
                    items: this.flightTypeFactory(data)
                }
            }, {
                xtype: 'container',
                flex: 1
            }, {
                xtype: 'button',
                text: 'Airlines',
                width: 170,
                menu: {
                    width: 170,
                    defaults: {
                        width: 164
                    },
                    items: this.airlineFactory(data)
                }
            }, {
                xtype: 'container',
                flex: 1
            }, {
                xtype: 'button',
                text: 'Airports',
                width: 170,
                menu: {
                    width: 170,
                    defaults: {
                        width: 164
                    },
                    items: this.airportFactory(data)
                }
            }, {
                xtype: 'container',
                flex: 1
            }, {
                xtype: 'button',
                text: 'Display',
                width: 170,
                menu: {
                    width: 170,
                    defaults: {
                        width: 164
                    },
                    items: this.displayTypeFactory(data)
                }
            }, {
                xtype: 'container',
                flex: 1
            }]
        }, {
            xtype: 'container',
            style: 'font-size:11px;',
            html: '<span style="font-weight:bold;">Flight Types: </span><span id="flight-types-list"></span>',
            height: 16
        }, {
            xtype: 'container',
            style: 'font-size:11px;',
            html: '<span style="font-weight:bold;">Airlines: </span><span id="airlines-list"></span>',
            height: 16
        }, {
            xtype: 'container',
            style: 'font-size:11px;',
            html: '<span style="font-weight:bold;">Airports: </span><span id="airports-list"></span>',
            height: 16
        }, {
            xtype: 'container',
            style: 'font-size:11px;',
            html: '<span style="font-weight:bold;">Readout: </span><span id="display-list"></span>',
            height: 16
        }];

        this.callParent(arguments);
    },

    flightTypeFactory: function (data) {
        var flightTypes = [{
            text: 'All',
            checked: false,
            scope: this,
            handler: function () {

            }
        }];

        Ext.each(data, function (item, index, allItems) {
            flightTypes.push({
                text: item.name,
                checked: false,
                scope: this,
                handler: function () {
                    alert(item.name);
                }
            });
        });

        return flightTypes;
    },

    airlineFactory: function (data) {
        var airlines = [{
            text: 'All',
            checked: false,
            scope: this,
            handler: function () {

            }
        }];

        Ext.each(data, function (item, index, allItems) {
            airlines.push({
                text: item.name,
                checked: false,
                scope: this,
                handler: function () {

                }
            });
        });

        return airlines;
    },

    airportFactory: function (data) {
        var airports = [{
            text: 'All',
            checked: false,
            scope: this,
            handler: function () {

            }
        }];

        Ext.each(data, function (item, index, allItems) {
            airports.push({
                text: item.name,
                checked: false,
                scope: this,
                handler: function () {

                }
            });
        });

        return airports;
    },

    displayTypeFactory: function (data) {
        var displayTypes = [];

        Ext.each(data, function (item, index, allItems) {
            displayTypes.push({
                text: item.name,
                checked: false,
                scope: this,
                handler: function () {

                }
            });
        });

        return displayTypes;
    }
});