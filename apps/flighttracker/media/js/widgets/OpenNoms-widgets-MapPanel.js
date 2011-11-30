Ext.define('OpenNoms.widgets.MapPanel', {
    extend: 'FGI.widgets.MapPanel',
    alias: 'widgets.opennoms-widgets-mappanel',

    id: 'map-panel',
    region: 'center',
    border: true,

    initComponent: function () {
        this.addEvents({
            'distancemeasurecomplete': true,
            'areameasurecomplete': true
        });

        this.map = new OpenLayers.Map('map', {
            restrictedExtent: new OpenLayers.Bounds(-10470724.958188, 5549098.4316464, -10285900.22382, 5685003.4679186),
            numZoomLevels: 10,
            fallThrough: false,
            controls: [new OpenLayers.Control.Navigation()],
            projection: new OpenLayers.Projection("EPSG:900913"),
            displayProjection: new OpenLayers.Projection("EPSG:4326"),
            maxExtent: new OpenLayers.Bounds(-20037508, -20037508, 20037508, 20037508.34)
        });

        this.bbar = Ext.create('Ext.toolbar.Toolbar', {
            items: [
                '<span style="padding-left:15px;font-size:14px;color:black;">Current Zoom Level: <span id="zoom-level" style="padding-right:20px">0</span></span>',
                '<span style="padding-left:20px;font-size:14px;color:black;">Cursor Position: <span id="cursor-position"></span></span>',
                '->',
                new Ext.Component({
                    html: '<div id="scale-area" style="float:right; padding-right: 15px;"></div>',
                    width: 200
                })
            ],
            height: 34
        });

        this.callParent(arguments);

        this.gmapsStreets = new OpenLayers.Layer.Google(
            "Streets", // the default
            {
            numZoomLevels: 12,
            'sphericalMercator': true,
            MIN_ZOOM_LEVEL: 10,
            projection: new OpenLayers.Projection("EPSG:900913")
        }
        );
        this.gmapsHybrid = new OpenLayers.Layer.Google(
            "Hybrid",
            {
                type: google.maps.MapTypeId.HYBRID,
                numZoomLevels: 12,
                'sphericalMercator': true,
                MIN_ZOOM_LEVEL: 10,
                projection: new OpenLayers.Projection("EPSG:900913")
            }
        );
        this.gmapsAerial = new OpenLayers.Layer.Google(
            "Aerial",
            {
                type: google.maps.MapTypeId.SATELLITE,
                numZoomLevels: 12,
                'sphericalMercator': true,
                MIN_ZOOM_LEVEL: 10,
                projection: new OpenLayers.Projection("EPSG:900913")
            }
        );

        this.zoomPanel = Ext.create('Ext.panel.Panel', {
            frame: true,
            bodyStyle: 'padding-top:3px;padding-left:8px;',
            floating: true,
            width: 49,
            height: 200,
            layout: 'fit',
            items: [{
                xtype: 'slider',
                id: 'zoom-slider',
                hideLabel: true,
                tipText: function(thumb){
                    return Ext.String.format('<b>Zoom Level: {0}</b>', thumb.value);
                },
                vertical: true,
                minValue: 0,
                maxValue: 11,
                listeners: {
                    'change': function (cmp, value) {
                        this.map.zoomTo(value);
                    },
                    scope: this
                }
            }]
        });

        this.zoomPanel.show();

        this.on({
            'afterlayout': function () {
                this.zoomPanel.alignTo(this, 'tl-tl', [10, 10]);
            },
            scope: this
        });

        this.doLayout();

    },

    mapReady: function () {
        this.map.updateSize();

        this.map.addLayers([this.gmapsStreets, this.gmapsHybrid, this.gmapsAerial]);

        var measureStyle = OpenLayers.Util.applyDefaults({
            strokeColor: "#808080",
            strokeOpacity: 1,
            strokeWidth: 3,
            strokeDashstyle: 'dash',
            fillOpacity: 0.1,
            fillColor: "#808080",
            pointRadius: 4,
            graphicName: 'x'
        }, OpenLayers.Feature.Vector.style["default"]);

        this.measureLayer = new OpenLayers.Layer.Vector(
            "MeasureLayer", {
                style: measureStyle
            }
        );

        this.map.addLayers([this.measureLayer]);

        this.drawDistanceMeasureControl = new OpenLayers.Control.DrawFeature(this.measureLayer,
            OpenLayers.Handler.Path, {
                handlerOptions: {
                    style: measureStyle
                },
                eventListeners: {
                    "featureadded": function (e) {
                        this.fireEvent('distancemeasurecomplete', e.feature);
                    },
                    scope: this
                }
            }
        );

        this.drawAreaMeasureControl = new OpenLayers.Control.DrawFeature(this.measureLayer,
            OpenLayers.Handler.Polygon, {
                handlerOptions: {
                    style: measureStyle
                },
                eventListeners: {
                    "featureadded": function (e) {
                        this.fireEvent('areameasurecomplete', e.feature);
                    },
                    scope: this
                }
            }
        );

        this.map.addControls([this.drawAreaMeasureControl, this.drawDistanceMeasureControl]);

        this.map.zoomToMaxExtent();

        this.mousePosition = new OpenLayers.Control.MousePosition({
            element: Ext.get('cursor-position').dom
        });

        this.map.addControl(this.mousePosition);

        this.map.addControl(new OpenLayers.Control.ScaleLine({
            div: Ext.get('scale-area').dom
        }));

        this.map.events.register("zoomend", this, function (event) {
            var zoom = this.map.getZoom();
            Ext.get('zoom-level').dom.innerHTML = zoom;
            var zoomSlider = Ext.getCmp('zoom-slider');
            if (zoomSlider.getValue() != zoom) {
                zoomSlider.setValue(zoom);
            }
            this.doLayout();
        });

        this.doLayout();
    }
});