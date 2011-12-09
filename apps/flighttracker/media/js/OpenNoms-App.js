Ext.namespace('OpenNoms', 'OpenNoms.app');

OpenNoms.app = {
    init: function () {
        Ext.tip.QuickTipManager.init();
        this.loadingMask = Ext.Msg.wait('Initializing...');

        this.buildUI();
        this.applyListeners();
        this.loadData();
        this.initControllers();

        this.loadingMask.hide();
    },

    /*
    * setup all visual components
    */
    buildUI: function () {
        this.appPanel = Ext.create('OpenNoms.widgets.AppPanel');

        this.viewport = new Ext.Viewport({
            layout: 'card',
            items: [
                this.appPanel
            ]
        });

        this.stateController = Ext.create('OpenNoms.controller.State', {});

        this.queryController = Ext.create('OpenNoms.controller.Query', {});
    },

    /*
    * setup all the listeners
    */
    applyListeners: function () {
        this.appPanel.appHeader.on({
            'measureclicked': function (mode, state) {
                this.appPanel.mapPanel.drawDistanceMeasureControl.deactivate();
                this.appPanel.mapPanel.drawAreaMeasureControl.deactivate();
                if (state) {
                    this.appPanel.mapPanel.measureLayer.removeAllFeatures();
                    this.appPanel.measureFeedbackPanel.hide();
                    if (mode == 'area') {
                        this.appPanel.mapPanel.drawAreaMeasureControl.activate();
                    } else if (mode == 'distance') {
                        this.appPanel.mapPanel.drawDistanceMeasureControl.activate();
                    }
                }
            },
            scope: this
        });

        this.appPanel.appHeader.on({
            'changestate': this.stateController.changeState,
            scope: this.stateController
        });

        this.appPanel.appHeader.on({
            'setdatetimerange': function () {
                this.queryController.updateLayerWithNewParams(this.appPanel.mapPanel.staticflightlayer);
            },
            scope: this
        });

        this.appPanel.mapPanel.on({
            'distancemeasurecomplete': function (measureObj) {
                var measureText = measureObj.measure.toFixed(3) + " " + measureObj.units;
                this.appPanel.mapPanel.drawDistanceMeasureControl.deactivate();
                this.appPanel.measureFeedbackPanel.show();
                this.appPanel.measureFeedbackPanel.alignTo(this.appPanel.mapPanel, 'tl-tl', [70, 10]);
                Ext.get('measure-read-out').dom.innerHTML = measureText;
                Ext.getCmp('measure-button').toggle(false);
            },
            'areameasurecomplete': function (measureObj) {
                var measureText = measureObj.measure.toFixed(3) + " " + measureObj.units + "<sup>2</" + "sup>";
                this.appPanel.mapPanel.drawAreaMeasureControl.deactivate();
                this.appPanel.measureFeedbackPanel.show();
                this.appPanel.measureFeedbackPanel.alignTo(this.appPanel.mapPanel, 'tl-tl', [70, 10]);
                Ext.get('measure-read-out').dom.innerHTML = measureText;
                Ext.getCmp('measure-button').toggle(false);
            },
            'mapclicked': function (e) {
                var loc = this.appPanel.mapPanel.map.getLonLatFromPixel(e.xy);
                Ext.Ajax.request({
                    url: OpenNoms.config.URLs.ows,
                    method: 'GET',
                    params: {
                        'viewparams': this.queryController.formatParamsForGeoserver() +
                            'x:' + loc.lon + 
                            ';y:' + loc.lat + ';' +
                            //TODO: wire up rest of params
                            'airport:MSP\\,STP\\,FCM\\,NONE;optype:;',
                        'service': 'WFS',
                        'version': '1.0.0',
                        'request': 'GetFeature',
                        'typeName': 'opennoms:getclosesttrack',
                        'maxFeatures': '50',
                        'outputFormat': 'json'
                    },
                    success: function (response) {
                        var responseObj = Ext.JSON.decode(response.responseText);
                        if (responseObj.features.length > 0) {
                            this.appPanel.mapPanel.selectedFlightTrackLayer.removeAllFeatures();
                            var feature = this.appPanel.mapPanel.wktFormat.read(responseObj.features[0].properties.wkt);
                            feature.attributes = responseObj.features[0].properties;
                            this.appPanel.mapPanel.selectedFlightTrackLayer.addFeatures([feature]);
                            Ext.getCmp('noise-event-viewer').store.proxy.extraParams.viewparams = 'opnum:' + responseObj.features[0].properties.opnum;
                            Ext.getCmp('noise-event-viewer').store.load();
                        }
                    },
                    scope: this
                });
            },
            scope: this
        });
        this.appPanel.mapPanel.on({
            'mapready': function () {
                Ext.each(this.appPanel.mapPanel.map.layers, function (layer, index, allLayers) {
                    if (layer.showInLegend) {
                        var store = Ext.getCmp('legend-grid').store;
                        store.add({ 'name': layer.name, 'layer': layer, 'isOn': layer.getVisibility() });
                        layer.events.on({
                            'visibilitychanged': function (e) {
                                var store = Ext.getCmp('legend-grid').store;
                                var index = store.findExact('layer', e.object);
                                if (index > -1) {
                                    var rec = store.getAt(index);
                                    if (rec.get('isOn') != layer.getVisibility()) {
                                        rec.set('isOn', layer.getVisibility());
                                        rec.commit();
                                    }
                                }
                            },
                            scope: this
                        });
                    }
                }, this);
                this.appPanel.mapPanel.noiseEventHoverControl.events.on({
                    'featurehighlighted': function (e) {
                        var view = Ext.getCmp('noise-event-viewer').view;
                        view.highlightItem(view.getNode(e.feature.record));
                    },
                    'featureunhighlighted': function (e) {
                        Ext.getCmp('noise-event-viewer').view.clearHighlight();
                    },
                    scope: this
                });
            },
            scope: this,
            single: true
        });

        this.appPanel.on({
            'afterlayout': function () {
                this.appPanel.mapPanel.mapReady();
            },
            scope: this,
            single: true
        });

        this.appPanel.on({
            'clearmeasureclicked': function (feature) {
                this.appPanel.measureFeedbackPanel.hide();
                this.appPanel.mapPanel.measureLayer.removeAllFeatures();
            },
            'afterlayout': function () {
                this.appPanel.mapPanel.map.updateSize();
                this.appPanel.mapPanel.map.baseLayer.redraw();
            },
            scope: this
        });

        Ext.getCmp('noise-event-viewer').store.on({
            'load': function (store, records, success, operation, opts) {
                this.appPanel.noiseButton.query('button')[0].toggle(true);
                var features = [];
                this.appPanel.mapPanel.noiseEventLayer.removeAllFeatures();
                Ext.each(records, function (record, index, allRecords) {
                    var feature = this.appPanel.mapPanel.wktFormat.read(record.get('wkt'));
                    feature.attributes = record.data;
                    features.push(feature);
                    feature.record = record;
                    record.feature = feature;
                }, this);
                this.appPanel.mapPanel.noiseEventLayer.addFeatures(features);
            },
            scope: this
        });

        Ext.getCmp('noise-event-viewer').on({
            'itemmouseenter': function (view, record, item) {
                this.appPanel.mapPanel.noiseEventHoverControl.select(record.feature);
            },
            'itemmouseleave': function (view, record, item) {
                this.appPanel.mapPanel.noiseEventHoverControl.unselect(record.feature);
            },
            scope: this
        });

        Ext.getCmp('legend-grid').on({
            'checkchange': function (grid, index, checked) {
                var layer = grid.store.getAt(index).get('layer');
                if (checked != layer.getVisibility()) {
                    layer.setVisibility(checked);
                }
            },
            scope: this
        });

        Ext.getCmp('select-flights').store.on({
            'load': function (store, record, operation, opts) {
                this.queryController.updateLayerWithNewParams(this.appPanel.mapPanel.staticflightlayer);
                this.appPanel.mapPanel.staticflightlayer.setVisibility(true);
            },
            scope: this
        });

        Ext.getCmp('find-address-combo').on({
            'select': function (combo, records, opts) {
                var geom = new OpenLayers.Geometry.Point(records[0].get('x'), records[0].get('y'));
                var feature = new OpenLayers.Feature.Vector(geom, records[0].data);
                var loc = new OpenLayers.LonLat(records[0].get('x'), records[0].get('y'));
                this.appPanel.mapPanel.addressSearchLayer.removeAllFeatures();
                this.appPanel.mapPanel.addressSearchLayer.addFeatures([feature]);
                this.appPanel.mapPanel.map.setCenter(loc, 5);
            },
            scope: this
        });

        this.viewport.doLayout();
    },

    /*
    * load the data into the app
    */
    loadData: function () {
        Ext.getCmp('select-flights').store.load();
    },

    initControllers: function () {

    },

    showApp: function () {
        this.viewport.layout.setActiveItem(1);
    }
};
