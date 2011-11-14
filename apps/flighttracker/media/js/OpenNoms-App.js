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
        //this.splashPanel = Ext.create('OpenNoms.widgets.SplashPanel');

        this.appPanel = Ext.create('OpenNoms.widgets.AppPanel');

        this.viewport = new Ext.Viewport({
            layout: 'card',
            items: [
                //this.splashPanel,
                this.appPanel
            ]
        });
    },

    /*
    * setup all the listeners
    */
    applyListeners: function () {
//        this.splashPanel.on({
//            'loginstart': function () {
//                this.loadingMask = Ext.Msg.wait('Signing In...');
//            },
//            'logincomplete': function () {
//                this.loadingMask.hide();
//                this.showApp();
//            },
//            'requestaccountclicked': function () {
//                Ext.Msg.alert('Under Construction...', 'This feature is coming soon!');
//            },
//            'exploreclicked': function () {
//                this.showApp();
//            },
//            scope: this
//        });
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
