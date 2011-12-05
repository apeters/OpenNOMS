Ext.define('OpenNoms.widgets.MapPanel', {
    extend: 'FGI.widgets.MapPanel',
    alias: 'widgets.opennoms-widgets-mappanel',

    id: 'map-panel',
    region: 'center',
    border: true,

    initComponent: function () {
        this.addEvents({
            'distancemeasurecomplete': true,
            'areameasurecomplete': true,
            'mapready': true
        });

        this.wktFormat = new OpenLayers.Format.WKT();

        this.map = new OpenLayers.Map('map', {
            controls: [
	            new OpenLayers.Control.Navigation({ zoomWheelEnabled: false })
	        ],
            center: new OpenLayers.LonLat(482188, 4969538),
            maxExtent: new OpenLayers.Bounds(411482, 4900449, 552143, 5041149),
            projection: new OpenLayers.Projection("EPSG:26915"),
            displayProjection: new OpenLayers.Projection("EPSG:4326"),
            resolutions: [256, 128, 64, 32, 16, 8, 4, 2, 1],
            tileSize: new OpenLayers.Size(512, 512),
            allOverlays: true
        });

        this.supportedProjections = {
            geographic: new OpenLayers.Projection("EPSG:4326"),
            mercator: new OpenLayers.Projection("EPSG:900913"),
            utm: new OpenLayers.Projection("EPSG:26915"),
        };

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

        //tiled version of MAC base layers from MapProxy
        this.tmsbase = new OpenLayers.Layer.TMS('Base Map', 'http://app.macnoise.com/mapproxy/tms/', { 
            layername: 'base_EPSG26915', 
            type: 'png', 
            tileSize: new OpenLayers.Size(512, 512), 
            opacity: 0.7, 
            buffer: 0,
            showInLegend: true
        });

        
        //tiled version of contours from MapProxy
        this.tmscontours = new OpenLayers.Layer.TMS(
	        "2007 Forecast Year Mitigated DNL Contours",
	        "http://app.macnoise.com/mapproxy/tms/",
	        {
                layername:'contours_EPSG26915',
                type:'png',
                tileSize:new OpenLayers.Size(512,512),
                opacity:0.7,
                buffer:0,
                showInLegend: true,
                visibility: false
	        }
        );

        //tiled version of RMTS from MapProxy
        this.tmsrmts = new OpenLayers.Layer.TMS(
	        "Remote Monitoring Towers",
	        "http://app.macnoise.com/mapproxy/tms/",
	        {
                layername:'rmts_EPSG26915',
                type:'png',
                tileSize:new OpenLayers.Size(512,512),
                opacity:0.7,
                buffer:0,
                showInLegend: true,
                visibility: false
	        }
        );

 
        //static flight track layer
        this.staticflightlayer = new OpenLayers.Layer.WMS("Static Flight Tracks", "http://localhost:8080/geoserver/opennoms/wms", { 
            layers: 'opennoms:macnoise', 
            transparent: "true", 
            isodate: '2000-1-1' 
        },{ 
            singleTile: true, 
            projection: this.supportedProjections.utm, 
            maxExtent: new OpenLayers.Bounds(411482, 4900449, 552143, 5041149), 
            maxResolution: 274.8046875, 
            opacity: 0.6, 
            displayInLayerSwitcher: false,
            visibility: false

        });

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

//        var noiseEventStyle = OpenLayers.Util.applyDefaults({
//            strokeColor: "#FFFF00",
//            strokeOpacity: 1,
//            strokeWidth: 4,
//            pointRadius: 10,
//            graphicName: 'circle',
//            fillOpacity: 0
//        }, OpenLayers.Feature.Vector.style["default"]);

        var noiseEventStyle = new OpenLayers.StyleMap({
            "default": new OpenLayers.Style({
                strokeColor: "#FFFF00",
                strokeOpacity: 1,
                strokeWidth: 4,
                pointRadius: 10,
                graphicName: 'circle',
                fillOpacity: 0,
                labelAlign: 'cb',
                labelYOffset: 15,
                label: "${lmax}",
                fontWeight: 'normal'
            }),
            "select": new OpenLayers.Style({
                fillColor: "#66ccff",
                strokeColor: "#3399ff",
                strokeOpacity: 1,
                strokeWidth: 4,
                pointRadius: 10,
                graphicName: 'circle',
                fillOpacity: 0.2,
                labelAlign: 'cb',
                labelYOffset: 15,
                label: "${lmax}",
                fontWeight: 'bold'
            })
        });

        this.noiseEventLayer = new OpenLayers.Layer.Vector(
            "NoiseEventLayer", {
                styleMap: noiseEventStyle
            }
        );

        this.map.addLayers([this.tmsbase, this.tmscontours, this.tmsrmts, this.staticflightlayer, this.noiseEventLayer, this.measureLayer]);

        this.noiseEventHoverControl = new OpenLayers.Control.SelectFeature(this.noiseEventLayer, {
            multiple: false, 
            hover: true
        });

        this.map.addControls([this.noiseEventHoverControl]);

        this.noiseEventHoverControl.activate();

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

        this.map.zoomTo(4);

        this.doLayout();

        this.fireEvent('mapready', this);
    }
});