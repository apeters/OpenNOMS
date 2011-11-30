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
    extend: 'Ext.grid.Panel',
    alias: 'widgets.opennoms-widgets-selectflights',

    id: 'select-flights',
    title: 'Select Flights',

    initComponent: function () {
        var url = 'http://localhost:8080/geoserver/opennoms/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=opennoms:advanced_query_choices&maxFeatures=50&outputFormat=json';
        this.store = Ext.create('Ext.data.Store', {
            fields: ['group', 'name', 'value', 'ischecked'],
            groupField: 'group',
            proxy: Ext.create('FGI.data.proxy.GeoserverJsonP', {
                url: url
            }),
            autoLoad: true
        });

        this.columns = [
            { xtype: 'checkcolumn', header: '', dataIndex: 'ischecked', width: 56, listeners: {
                'checkchange': function (column, recIndex, checked) {
                    var record = this.store.getAt(recIndex);
                    record.commit();
                    //                    delete record.modified['ischecked'];
                    //                    this.getView().refresh();
                },
                scope: this
            }
            },
            { header: 'Name', dataIndex: 'name', flex: 1 }
        ];

        this.features = [Ext.create('Ext.grid.feature.CheckGrouping', {
            groupHeaderTpl: '{name} ({rows.length} Item{[values.rows.length > 1 ? "s" : ""]})'
        })];

        this.callParent(arguments);
    }
});

/**
*/
Ext.define('Ext.grid.feature.CheckGrouping', {
    extend: 'Ext.grid.feature.Grouping',
    requires: 'Ext',
    alias: 'feature.brigrouping',

    constructor: function () {
        this.callParent(arguments);

        this.groupHeaderTpl = ['<dl style="height:18px; border:0px !important" class="x-grid-row-checked">',
             '<dd id="groupcheck{name}" class="x-grid-row-checker x-column-header-text" style="width:18px; float:left;" x-grid-group-hd-text="{text}">&nbsp;</dd>',
             '<dd style="float:left; padding:3px 0px 0px 3px;">',
             this.groupHeaderTpl,
             '</dd>',
             '</dl>'
             ].join('');
    },

    onGroupClick: function (view, node, group, e, options) {
        var checkbox = Ext.get('groupcheck' + group);
        if (this.inCheckbox(checkbox, e.getXY())) {
            this.toggleCheckbox(group, node, view);
        } else if (this.isLeftofCheckbox(checkbox, e.getXY())) {
            this.callParent(arguments);
        }
    },

    inCheckbox: function (checkbox, xy) {
        var x = xy[0];
        var y = xy[1];
        if (x >= checkbox.getLeft() &&
            x <= checkbox.getRight() &&
            y >= checkbox.getTop() &&
            y <= checkbox.getBottom()) {
            return true;
        }
        return false;
    },
    isLeftofCheckbox: function (checkbox, xy) {
        if (xy[0] < checkbox.getLeft()) {
            return true;
        }
        return false;
    },
    toggleCheckbox: function (group, node, view) {
        var nodeEl = Ext.get(node).down('dl');
        var classes = nodeEl.dom.classList;
        if (!classes.contains('x-grid-row-checked')) {
            nodeEl.addCls('x-grid-row-checked');
        }
        else {
            nodeEl.removeCls('x-grid-row-checked');
        }
    }
});