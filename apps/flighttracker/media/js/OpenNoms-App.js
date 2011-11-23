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
            scope: this
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
    },

    /*
    * load the data into the app
    */
    loadData: function () {

    },

    initControllers: function () {

    },

    showApp: function () {
        this.viewport.layout.setActiveItem(1);
    }
};