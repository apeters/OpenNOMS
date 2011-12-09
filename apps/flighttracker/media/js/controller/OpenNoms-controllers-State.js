Ext.define('OpenNoms.controller.State', {
    extend: 'Ext.util.Observable',
    alias: 'controller.opennoms-controller-state',
    state: 'static',

    constructor: function (config) {
        this.addEvents({
            "beforestatechange": true,
            "afterstatechange": true
        });

        // Call our superclass constructor to complete construction process.
        this.callParent(arguments)
    },


    changeState: function (state) {
        if (this.fireEvent('beforestatechange')) {
            Ext.getCmp('flighttrackstartdatepicker').hide();
            Ext.getCmp('flighttrackstarttimepicker').hide();
            Ext.getCmp('staticlengthcombo').hide();
            Ext.getCmp('truncate-flight-tracks-checkbox').hide();
            Ext.getCmp('realtimemessage').hide();
            Ext.getCmp('tabtrackanimator').hide();
            Ext.getCmp('gobutton').hide();
            Ext.getCmp('display-type-combo').hide();
            Ext.getCmp('map-panel').staticflightlayer.setVisibility(false);

            switch (state) {
                case 'static':
                    Ext.getCmp('flight-track-type-menu').setText('<span style="font-weight:bold;">Static Flight Tracks</span>');
                    Ext.getCmp('flighttrackstartdatepicker').show();
                    Ext.getCmp('flighttrackstarttimepicker').show();
                    Ext.getCmp('staticlengthcombo').show();
                    Ext.getCmp('truncate-flight-tracks-checkbox').show();
                    Ext.getCmp('gobutton').show();
                    Ext.getCmp('map-panel').clickControl.activate();
                    Ext.getCmp('map-panel').staticflightlayer.setVisibility(true);
                    Ext.getCmp('map-panel').animatedFlightTracks.removeAllFeatures();
                    this.state = 'static';
                    break;
                case 'realtime':
                    Ext.getCmp('flight-track-type-menu').setText('<span style="font-weight:bold;">Real Time Flight Track Replay</span>');
                    Ext.getCmp('realtimemessage').show();
                    Ext.getCmp('display-type-combo').show();
                    Ext.getCmp('map-panel').clickControl.deactivate();
                    Ext.getCmp('app-panel').noiseButton.query('button')[0].toggle(false);
                    Ext.getCmp('noise-event-viewer').store.removeAll();
                    Ext.getCmp('map-panel').noiseEventLayer.removeAllFeatures();
                    Ext.getCmp('map-panel').selectedFlightTrackLayer.removeAllFeatures();
                    Ext.getCmp('map-panel').animatedFlightTracks.removeAllFeatures();
                    this.state = 'realtime';
                    break;
                case 'animated':
                    Ext.getCmp('flight-track-type-menu').setText('<span style="font-weight:bold;">Animated Flight Track Replay</span>');
                    Ext.getCmp('flighttrackstartdatepicker').show();
                    Ext.getCmp('flighttrackstarttimepicker').show();
                    Ext.getCmp('tabtrackanimator').show();
                    Ext.getCmp('gobutton').show();
                    Ext.getCmp('display-type-combo').show();
                    Ext.getCmp('map-panel').clickControl.deactivate();
                    Ext.getCmp('app-panel').noiseButton.query('button')[0].toggle(false);
                    Ext.getCmp('noise-event-viewer').store.removeAll();
                    Ext.getCmp('map-panel').noiseEventLayer.removeAllFeatures();
                    Ext.getCmp('map-panel').selectedFlightTrackLayer.removeAllFeatures();
                    this.state = 'animated';
                    break;
            }
        }
        this.fireEvent('afterstatechange');
    }

});