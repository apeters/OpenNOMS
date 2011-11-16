Ext.define('OpenNoms.widgets.MapPanel', {
    extend: 'FGI.widgets.MapPanel',
    alias: 'widgets.opennoms-widgets-mappanel',

    id: 'map-panel',
    region: 'center',
    border: true,

    initComponent: function () {
        this.map = new OpenLayers.Map('map', {
            restrictedExtent: new OpenLayers.Bounds(-10470724.958188, 5549098.4316464, -10285900.22382, 5685003.4679186),
            numZoomLevels: 10,
            fallThrough: false,
            controls: [new OpenLayers.Control.Navigation(), new OpenLayers.Control.PanZoomBar()],
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
            numZoomLevels: 10,
            'sphericalMercator': true,
            MIN_ZOOM_LEVEL: 10,
            projection: new OpenLayers.Projection("EPSG:900913")
        }
        );
        this.gmapsHybrid = new OpenLayers.Layer.Google(
            "Hybrid",
            {
                type: google.maps.MapTypeId.HYBRID,
                numZoomLevels: 10,
                'sphericalMercator': true,
                MIN_ZOOM_LEVEL: 10,
                projection: new OpenLayers.Projection("EPSG:900913")
            }
        );
        this.gmapsAerial = new OpenLayers.Layer.Google(
            "Aerial",
            {
                type: google.maps.MapTypeId.SATELLITE,
                numZoomLevels: 10,
                'sphericalMercator': true,
                MIN_ZOOM_LEVEL: 10,
                projection: new OpenLayers.Projection("EPSG:900913")
            }
        );
    },

    mapReady: function () {
        this.map.updateSize();

        this.map.addLayers([this.gmapsStreets, this.gmapsHybrid, this.gmapsAerial]);

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
            this.doLayout();
        });

        this.doLayout();
    }
});