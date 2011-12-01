Ext.define('OpenNoms.controller.State', {
    extend: 'Ext.util.Observable',
    alias: 'controller.opennoms-controller-state',
    
    constructor: function (config) {
        this.addEvents({
            "beforestatechange": true,
            "afterstatechange": true
        });

        // Call our superclass constructor to complete construction process.
        this.callParent(arguments)
    },


    changeState:function(state){
        if(this.fireEvent('beforestatechange')){
            Ext.getCmp('flighttrackstartdatepicker').hide();
            Ext.getCmp('flighttrackstarttimepicker').hide();
            Ext.getCmp('staticlengthcombo').hide();
            Ext.getCmp('realtimemessage').hide();
            Ext.getCmp('animationplaybutton').hide();
            Ext.getCmp('animationspeedcombo').hide();
            Ext.getCmp('animationslider').hide();
            Ext.getCmp('gobutton').hide();
            
            switch (state) {
                case 'static':
                    Ext.getCmp('flight-track-type-menu').setText('<span style="font-weight:bold;">Static Flight Tracks</span>');
                    Ext.getCmp('flighttrackstartdatepicker').show();
                    Ext.getCmp('flighttrackstarttimepicker').show();
                    Ext.getCmp('staticlengthcombo').show();
                    Ext.getCmp('gobutton').show();
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
                    Ext.getCmp('animationslider').show();
                    Ext.getCmp('gobutton').show();
                    btn = Ext.getCmp('animationplaybutton');
                    btn.setText('Play');
                    btn.setIconCls('play');
                    btn.show();
                    break;
            }
        }
        this.fireEvent('afterstatechange');
    }

});