﻿Ext.namespace('OpenNoms', 'OpenNoms.app');

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
            'headerresized': function () {
                this.appPanel.mapPanel.map.baseLayer.redraw();
            },
            scope: this
        });

        this.appPanel.appHeader.on({
            'changestate': this.stateController.changeState,
            scope: this.stateController
        });

        this.appPanel.appHeader.on({
            'setdatetimerange': function () {
                this.queryController.updateQuery(this.appPanel.mapPanel.staticflightlayer);
            },
            scope: this
        });

        this.appPanel.mapPanel.on({
            'distancemeasurecomplete': function (feature) {
                var measure = feature.geometry.getLength().toFixed(3) + ' ' + this.appPanel.mapPanel.map.getUnits();
                this.appPanel.mapPanel.drawDistanceMeasureControl.deactivate();
                this.appPanel.measureFeedbackPanel.show();
                this.appPanel.measureFeedbackPanel.alignTo(this.appPanel.mapPanel, 'tl-tl', [70, 10]);
                Ext.get('measure-read-out').dom.innerHTML = measure;
                Ext.getCmp('measure-button').toggle(false);
            },
            'areameasurecomplete': function (feature) {
                var measure = feature.geometry.getArea().toFixed(3) + ' sq ' + this.appPanel.mapPanel.map.getUnits();
                this.appPanel.mapPanel.drawAreaMeasureControl.deactivate();
                this.appPanel.measureFeedbackPanel.show();
                this.appPanel.measureFeedbackPanel.alignTo(this.appPanel.mapPanel, 'tl-tl', [70, 10]);
                Ext.get('measure-read-out').dom.innerHTML = measure;
                Ext.getCmp('measure-button').toggle(false);
            },
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
            scope: this
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
                var features = []
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
                this.queryController.updateQuery(this.appPanel.mapPanel.staticflightlayer);
                this.appPanel.mapPanel.staticflightlayer.setVisibility(true);
            },
            scope: this
        });

        this.viewport.doLayout();
    },

    /*
    * load the data into the app
    */
    loadData: function () {
        Ext.getCmp('noise-event-viewer').store.load();
        Ext.getCmp('select-flights').store.load();
    },

    initControllers: function () {

    },

    showApp: function () {
        this.viewport.layout.setActiveItem(1);
    }
};
