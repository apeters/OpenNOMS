Ext.namespace('OpenNoms.config');
OpenNoms.config.URLs = {
    selectFlightsDomainData: 'http://localhost:8080/geoserver/opennoms/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=opennoms:advanced_query_choices&maxFeatures=50&outputFormat=json',
    getNoiseEventData: 'http://localhost:8080/geoserver/opennoms/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=opennoms:getevents&maxFeatures=50&viewparams=opnum:13181255&outputFormat=json',
    geocodeSearch: 'phpscripts/geocode.php'
};