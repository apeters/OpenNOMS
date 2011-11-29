-- View: macnoms.operations_view

-- DROP VIEW macnoms.operations_view;

CREATE OR REPLACE VIEW opennoms.operations_view AS 
        (        (         SELECT operations.opnum, operations.stime, operations.etime, operations.etime AS runwaytime, operations.actype, actype.mactype, operations.arr_apt AS airport, 'A' AS adflag, 
                                CASE
                                    WHEN operations.dep_apt = operations.arr_apt THEN 'T'::text
                                    WHEN operations.dep_apt IS NOT NULL AND (operations.dep_apt = ANY (ARRAY['MSP'::text, 'FCM'::text, 'STP'::text, '21D'::text, 'MIC'::text, 'ANE'::text, 'LVN'::text])) THEN 'I'::text
                                    ELSE 'A'::text
                                END AS macad, operations.arr_rwy AS runway, operations.airline, operations.beacon, operations.flight_id, operations.etime::time without time zone >= '22:30:00'::time without time zone OR operations.etime::time without time zone < '06:00:00'::time without time zone AS night, operations.etime::time without time zone >= '22:00:00'::time without time zone OR operations.etime::time without time zone < '07:00:00'::time without time zone AS inmnight, mactype.opertype, mactype.stage, mactype.image, mactype.manufactured, mactype.takeoffnoise, mactype.description, operations.dep_apt AS otherport, operations.the_geom AS targets
                           FROM opennoms.operations
                      LEFT JOIN alias.actype USING (actype)
                 LEFT JOIN alias.mactype USING (mactype)
                WHERE (operations.arr_apt = ANY (ARRAY['MSP'::text, 'FCM'::text, 'STP'::text, '21D'::text, 'MIC'::text, 'ANE'::text, 'LVN'::text])) AND (operations.trackinfo::text <> 'G'::text OR operations.trackinfo IS NULL)
                UNION ALL 
                         SELECT operations.opnum, operations.stime, operations.etime, operations.stime AS runwaytime, operations.actype, actype.mactype, operations.dep_apt AS airport, 'D' AS adflag, 
                                CASE
                                    WHEN operations.dep_apt = operations.arr_apt THEN 'T'::text
                                    WHEN operations.arr_apt IS NOT NULL AND (operations.arr_apt = ANY (ARRAY['MSP'::text, 'FCM'::text, 'STP'::text, '21D'::text, 'MIC'::text, 'ANE'::text, 'LVN'::text])) THEN 'I'::text
                                    ELSE 'D'::text
                                END AS macad, operations.dep_rwy AS runway, operations.airline, operations.beacon, operations.flight_id, operations.stime::time without time zone >= '22:30:00'::time without time zone OR operations.stime::time without time zone < '06:00:00'::time without time zone AS night, operations.stime::time without time zone >= '22:00:00'::time without time zone OR operations.stime::time without time zone < '07:00:00'::time without time zone AS inmnight, mactype.opertype, mactype.stage, mactype.image, mactype.manufactured, mactype.takeoffnoise, mactype.description, operations.arr_apt AS otherport, operations.the_geom AS targets
                           FROM opennoms.operations
                      LEFT JOIN alias.actype USING (actype)
                 LEFT JOIN alias.mactype USING (mactype)
                WHERE (operations.dep_apt = ANY (ARRAY['MSP'::text, 'FCM'::text, 'STP'::text, '21D'::text, 'MIC'::text, 'ANE'::text, 'LVN'::text])) AND (operations.trackinfo::text <> 'G'::text OR operations.trackinfo IS NULL))
        UNION ALL 
                 SELECT operations.opnum, operations.stime, operations.etime, operations.etime AS runwaytime, operations.actype, actype.mactype, NULL::text AS airport, 'O' AS adflag, 'O' AS macad, NULL::unknown AS runway, operations.airline, operations.beacon, operations.flight_id, operations.stime::time without time zone >= '22:30:00'::time without time zone OR operations.stime::time without time zone < '06:00:00'::time without time zone AS night, operations.stime::time without time zone >= '22:00:00'::time without time zone OR operations.stime::time without time zone < '07:00:00'::time without time zone AS inmnight, mactype.opertype, mactype.stage, mactype.image, mactype.manufactured, mactype.takeoffnoise, mactype.description, NULL::text AS otherport, operations.the_geom AS targets
                   FROM opennoms.operations
              LEFT JOIN alias.actype USING (actype)
         LEFT JOIN alias.mactype USING (mactype)
        WHERE ((operations.dep_apt <> ALL (ARRAY['MSP'::text, 'FCM'::text, 'STP'::text, '21D'::text, 'MIC'::text, 'ANE'::text, 'LVN'::text])) OR operations.dep_apt IS NULL) AND ((operations.arr_apt <> ALL (ARRAY['MSP'::text, 'FCM'::text, 'STP'::text, '21D'::text, 'MIC'::text, 'ANE'::text, 'LVN'::text])) OR operations.arr_apt IS NULL) AND (operations.trackinfo::text <> 'G'::text OR operations.trackinfo IS NULL))
UNION ALL 
         SELECT realtime_lines_view.opnum, realtime_lines_view.stime, realtime_lines_view.etime, realtime_lines_view.runwaytime, realtime_lines_view.actype, realtime_lines_view.mactype, realtime_lines_view.airport, realtime_lines_view.adflag, realtime_lines_view.macad, realtime_lines_view.runway, realtime_lines_view.airline, realtime_lines_view.beacon, realtime_lines_view.flight_id, realtime_lines_view.night, realtime_lines_view.inmnight, realtime_lines_view.opertype, realtime_lines_view.stage, realtime_lines_view.image, realtime_lines_view.manufactured, realtime_lines_view.takeoffnoise, realtime_lines_view.description, realtime_lines_view.otherport, realtime_lines_view.targets
           FROM opennoms.realtime_lines_view;

ALTER TABLE opennoms.operations_view OWNER TO postgres;



-- View: opennoms.realtime_lines_view

-- DROP VIEW opennoms.realtime_lines_view;

CREATE OR REPLACE VIEW opennoms.realtime_lines_view AS 
        (         SELECT realtime_lines.id AS opnum, realtime_lines.stime, realtime_lines.etime, realtime_lines.etime AS runwaytime, realtime_lines.actype, actype.mactype, "substring"(realtime_lines.destination, '...$'::text) AS airport, 'A' AS adflag, NULL::unknown AS macad, NULL::unknown AS runway, "substring"(realtime_lines.acid, 1, 3) AS airline, realtime_lines.beacon::smallint AS beacon, realtime_lines.acid AS flight_id, realtime_lines.etime::time without time zone >= '22:30:00'::time without time zone OR realtime_lines.etime::time without time zone < '06:00:00'::time without time zone AS night, realtime_lines.etime::time without time zone >= '22:00:00'::time without time zone OR realtime_lines.etime::time without time zone < '07:00:00'::time without time zone AS inmnight, mactype.opertype, mactype.stage, mactype.image, mactype.manufactured, mactype.takeoffnoise, mactype.description, realtime_lines.departure AS otherport, realtime_lines.the_geom AS targets
                   FROM opennoms.realtime_lines
              LEFT JOIN alias.actype USING (actype)
         LEFT JOIN alias.mactype USING (mactype)
        WHERE opennoms.macairport(realtime_lines.destination)
        UNION ALL 
                 SELECT realtime_lines.id AS opnum, realtime_lines.stime, realtime_lines.etime, realtime_lines.stime AS runwaytime, realtime_lines.actype, actype.mactype, "substring"(realtime_lines.departure, '...$'::text) AS airport, 'D' AS adflag, NULL::unknown AS macad, NULL::unknown AS runway, "substring"(realtime_lines.acid, 1, 3) AS airline, realtime_lines.beacon::smallint AS beacon, realtime_lines.acid AS flight_id, realtime_lines.stime::time without time zone >= '22:30:00'::time without time zone OR realtime_lines.stime::time without time zone < '06:00:00'::time without time zone AS night, realtime_lines.stime::time without time zone >= '22:00:00'::time without time zone OR realtime_lines.stime::time without time zone < '07:00:00'::time without time zone AS inmnight, mactype.opertype, mactype.stage, mactype.image, mactype.manufactured, mactype.takeoffnoise, mactype.description, realtime_lines.destination AS otherport, realtime_lines.the_geom AS targets
                   FROM opennoms.realtime_lines
              LEFT JOIN alias.actype USING (actype)
         LEFT JOIN alias.mactype USING (mactype)
        WHERE opennoms.macairport(realtime_lines.departure))
UNION ALL 
         SELECT realtime_lines.id AS opnum, realtime_lines.stime, realtime_lines.etime, realtime_lines.stime AS runwaytime, realtime_lines.actype, actype.mactype, "substring"(realtime_lines.departure, '...$'::text) AS airport, 'O' AS adflag, NULL::unknown AS macad, NULL::unknown AS runway, "substring"(realtime_lines.acid, 1, 3) AS airline, realtime_lines.beacon::smallint AS beacon, realtime_lines.acid AS flight_id, realtime_lines.stime::time without time zone >= '22:30:00'::time without time zone OR realtime_lines.stime::time without time zone < '06:00:00'::time without time zone AS night, realtime_lines.stime::time without time zone >= '22:00:00'::time without time zone OR realtime_lines.stime::time without time zone < '07:00:00'::time without time zone AS inmnight, mactype.opertype, mactype.stage, mactype.image, mactype.manufactured, mactype.takeoffnoise, mactype.description, realtime_lines.destination AS otherport, realtime_lines.the_geom AS targets
           FROM opennoms.realtime_lines
      LEFT JOIN alias.actype USING (actype)
   LEFT JOIN alias.mactype USING (mactype)
  WHERE (realtime_lines.destination IS NULL OR opennoms.macairport(realtime_lines.destination) = false) AND (realtime_lines.departure IS NULL OR opennoms.macairport(realtime_lines.departure) = false);

ALTER TABLE opennoms.realtime_lines_view OWNER TO postgres;



