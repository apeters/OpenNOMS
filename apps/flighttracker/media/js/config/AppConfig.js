var yesterday = new Date();
yesterday.setDate(new Date().getDate() - 1);
Ext.namespace('OpenNoms.config');
OpenNoms.config.AppConfig = {
    // Default map extent
    extent: "472468,4963602,491908,4975474",
    // Default app state
    state: 'static',
    // start date
    date: yesterday.getTime(),
    // start time
    time: '1:00 PM',
    // default length
    length: 600000,
    // truncate tracks?
    truncate: false,
    // default display type
    display: 'altitude',
    // default speed
    speed: 10,
    // display filters
    filter: '',
    // layer visibility
    basemap: true,
    aerial: false,
    contours: false,
    rmts: false
};