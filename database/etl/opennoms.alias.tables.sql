--
-- PostgreSQL database dump
--

-- Dumped from database version 9.0.5
-- Dumped by pg_dump version 9.0.5
-- Started on 2011-12-01 14:55:07

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- TOC entry 7 (class 2615 OID 128396)
-- Name: alias; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA alias;


ALTER SCHEMA alias OWNER TO postgres;

SET search_path = alias, pg_catalog;

--
-- TOC entry 1070 (class 1255 OID 128425)
-- Dependencies: 7 1580
-- Name: arr_airport_match(public.geometry); Type: FUNCTION; Schema: alias; Owner: postgres
--

CREATE FUNCTION arr_airport_match(public.geometry) RETURNS text
    LANGUAGE sql
    AS $_$SELECT 
	airport 
FROM
	alias.mac_airport_aoi 
WHERE
	st_dwithin(center,st_endpoint($1),radius) 
	AND
	z(st_endpoint($1))<=ceiling 
ORDER BY
	st_distance(center,st_endpoint($1)) ASC 
LIMIT 1;
$_$;


ALTER FUNCTION alias.arr_airport_match(public.geometry) OWNER TO postgres;

--
-- TOC entry 1071 (class 1255 OID 128426)
-- Dependencies: 7 1580
-- Name: dep_airport_match(public.geometry); Type: FUNCTION; Schema: alias; Owner: postgres
--

CREATE FUNCTION dep_airport_match(public.geometry) RETURNS text
    LANGUAGE sql
    AS $_$SELECT 
	airport 
FROM
	alias.mac_airport_aoi 
WHERE
	st_dwithin(center,st_startpoint($1),radius) 
	AND
	z(st_startpoint($1))<=ceiling 
ORDER BY
	st_distance(center,st_startpoint($1)) ASC 
LIMIT 1;
$_$;


ALTER FUNCTION alias.dep_airport_match(public.geometry) OWNER TO postgres;

--
-- TOC entry 1072 (class 1255 OID 128427)
-- Dependencies: 7
-- Name: fill_actype_airline(timestamp with time zone, timestamp with time zone); Type: FUNCTION; Schema: alias; Owner: postgres
--

CREATE FUNCTION fill_actype_airline(s timestamp with time zone, e timestamp with time zone) RETURNS boolean
    LANGUAGE sql
    AS $_$update operations set actype=a.actype,airline=a.airline from 
(select * from alias.actype_airline_nnumber where actype != 'XXXX') as a
where a.nnumber=operations.flight_id and stime between $1 and $2 and (operations.actype is null or operations.actype='') and (operations.airline is null or operations.airline ='');
select true;$_$;


ALTER FUNCTION alias.fill_actype_airline(s timestamp with time zone, e timestamp with time zone) OWNER TO postgres;

--
-- TOC entry 1073 (class 1255 OID 128428)
-- Dependencies: 7
-- Name: getmactype(text); Type: FUNCTION; Schema: alias; Owner: postgres
--

CREATE FUNCTION getmactype(text) RETURNS text
    LANGUAGE sql
    AS $_$select mactype from alias.actype where actype=$1;$_$;


ALTER FUNCTION alias.getmactype(text) OWNER TO postgres;

--
-- TOC entry 1074 (class 1255 OID 128429)
-- Dependencies: 7
-- Name: getopertype(text); Type: FUNCTION; Schema: alias; Owner: postgres
--

CREATE FUNCTION getopertype(text) RETURNS text
    LANGUAGE sql
    AS $_$select opertype from alias.actype join alias.mactype using (mactype) where actype=$1;$_$;


ALTER FUNCTION alias.getopertype(text) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 162 (class 1259 OID 128498)
-- Dependencies: 3312 7
-- Name: actype; Type: TABLE; Schema: alias; Owner: postgres; Tablespace: 
--

CREATE TABLE actype (
    actype text NOT NULL,
    mactype text DEFAULT 'UKN'::text NOT NULL,
    inmcode text
);


ALTER TABLE alias.actype OWNER TO postgres;

--
-- TOC entry 3373 (class 0 OID 0)
-- Dependencies: 162
-- Name: TABLE actype; Type: COMMENT; Schema: alias; Owner: postgres
--

COMMENT ON TABLE actype IS 'Aliases the actype as it comes from the FAA to MACtype/INMcode';


--
-- TOC entry 3374 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN actype.actype; Type: COMMENT; Schema: alias; Owner: postgres
--

COMMENT ON COLUMN actype.actype IS 'This is the aircraft type as it comes in from the FAA data in the operations table.';


--
-- TOC entry 3375 (class 0 OID 0)
-- Dependencies: 162
-- Name: COLUMN actype.mactype; Type: COMMENT; Schema: alias; Owner: postgres
--

COMMENT ON COLUMN actype.mactype IS 'This is the aircraft type we want to use in our reporting.';


--
-- TOC entry 163 (class 1259 OID 128505)
-- Dependencies: 7
-- Name: mactype; Type: TABLE; Schema: alias; Owner: postgres; Tablespace: 
--

CREATE TABLE mactype (
    mactype text NOT NULL,
    stage text,
    image text,
    takeoffnoise double precision,
    description text,
    manufactured boolean,
    "group" text,
    group_sm text,
    opertype text,
    simpletype character varying
);


ALTER TABLE alias.mactype OWNER TO postgres;

--
-- TOC entry 3376 (class 0 OID 0)
-- Dependencies: 163
-- Name: TABLE mactype; Type: COMMENT; Schema: alias; Owner: postgres
--

COMMENT ON TABLE mactype IS 'Needs to be aliased to operation data through the actype alias table. Contains MACtype and information about the aircraft. MACtypes are unique to our operation and are used in the reports we create.';


--
-- TOC entry 3377 (class 0 OID 0)
-- Dependencies: 163
-- Name: COLUMN mactype.stage; Type: COMMENT; Schema: alias; Owner: postgres
--

COMMENT ON COLUMN mactype.stage IS 'used in reporting to distinguish stage 3 jets from stage 2, props, military, helicopter, etc';


--
-- TOC entry 3378 (class 0 OID 0)
-- Dependencies: 163
-- Name: COLUMN mactype.manufactured; Type: COMMENT; Schema: alias; Owner: postgres
--

COMMENT ON COLUMN mactype.manufactured IS 'Distinguishes planes with manufactured stage 3 engines (TRUE) from those with hush-kitted engines (FALSE). MUST be filled in for any plane with a ''3'' in the stage field, irrelevent for planes are not stage 3.';


--
-- TOC entry 3379 (class 0 OID 0)
-- Dependencies: 163
-- Name: COLUMN mactype.opertype; Type: COMMENT; Schema: alias; Owner: postgres
--

COMMENT ON COLUMN mactype.opertype IS 'Used to filter by type of aircraft: carrier, (turbo)prop, military, helicopter. Important to keep updated as it affects the carrier jet counts in the monthly reports and is used to filter military flights from the report data!';


--
-- TOC entry 3380 (class 0 OID 0)
-- Dependencies: 163
-- Name: COLUMN mactype.simpletype; Type: COMMENT; Schema: alias; Owner: postgres
--

COMMENT ON COLUMN mactype.simpletype IS 'Simplified version of mactype for display in the FlightTracker application. Needs to be updated only for aircraft that we want to display on the FlightTracker.';


--
-- TOC entry 183 (class 1259 OID 128770)
-- Dependencies: 7
-- Name: actype_airline_nnumber; Type: TABLE; Schema: alias; Owner: postgres; Tablespace: 
--

CREATE TABLE actype_airline_nnumber (
    id integer NOT NULL,
    actype text,
    airline text,
    nnumber text
);


ALTER TABLE alias.actype_airline_nnumber OWNER TO postgres;

--
-- TOC entry 184 (class 1259 OID 128776)
-- Dependencies: 7 183
-- Name: actype_airline_nnumber_temp_id_seq; Type: SEQUENCE; Schema: alias; Owner: postgres
--

CREATE SEQUENCE actype_airline_nnumber_temp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE alias.actype_airline_nnumber_temp_id_seq OWNER TO postgres;

--
-- TOC entry 3381 (class 0 OID 0)
-- Dependencies: 184
-- Name: actype_airline_nnumber_temp_id_seq; Type: SEQUENCE OWNED BY; Schema: alias; Owner: postgres
--

ALTER SEQUENCE actype_airline_nnumber_temp_id_seq OWNED BY actype_airline_nnumber.id;


--
-- TOC entry 3382 (class 0 OID 0)
-- Dependencies: 184
-- Name: actype_airline_nnumber_temp_id_seq; Type: SEQUENCE SET; Schema: alias; Owner: postgres
--

SELECT pg_catalog.setval('actype_airline_nnumber_temp_id_seq', 1, false);


--
-- TOC entry 169 (class 1259 OID 128673)
-- Dependencies: 7
-- Name: airline_alias; Type: TABLE; Schema: alias; Owner: postgres; Tablespace: 
--

CREATE TABLE airline_alias (
    iata character varying NOT NULL,
    icao character varying NOT NULL,
    longname character varying,
    shortname character varying
);


ALTER TABLE alias.airline_alias OWNER TO postgres;

--
-- TOC entry 3383 (class 0 OID 0)
-- Dependencies: 169
-- Name: TABLE airline_alias; Type: COMMENT; Schema: alias; Owner: postgres
--

COMMENT ON TABLE airline_alias IS 'Scheduled data comes in with IATA codes, this table aliases them to ICAO or regular text airlines. Also useful for actual flight data to alias ICAO codes to full text.';


--
-- TOC entry 170 (class 1259 OID 128679)
-- Dependencies: 1580 7
-- Name: airportcodes; Type: TABLE; Schema: alias; Owner: postgres; Tablespace: 
--

CREATE TABLE airportcodes (
    code character varying NOT NULL,
    longname character varying,
    name character varying,
    print integer,
    heading smallint,
    geom4326 public.geometry,
    distfrommsp real,
    stagelength smallint
);


ALTER TABLE alias.airportcodes OWNER TO postgres;

--
-- TOC entry 3384 (class 0 OID 0)
-- Dependencies: 170
-- Name: TABLE airportcodes; Type: COMMENT; Schema: alias; Owner: postgres
--

COMMENT ON TABLE airportcodes IS 'Alias airport code to full name. Used mostly for the consolidated schedule and INM analysis (stage length).';


--
-- TOC entry 171 (class 1259 OID 128685)
-- Dependencies: 7
-- Name: alias_scheduled; Type: TABLE; Schema: alias; Owner: postgres; Tablespace: 
--

CREATE TABLE alias_scheduled (
    inpacft character varying NOT NULL,
    actype character varying,
    stage character varying,
    fullname text
);


ALTER TABLE alias.alias_scheduled OWNER TO postgres;

--
-- TOC entry 3385 (class 0 OID 0)
-- Dependencies: 171
-- Name: TABLE alias_scheduled; Type: COMMENT; Schema: alias; Owner: postgres
--

COMMENT ON TABLE alias_scheduled IS 'Aliases aircraft that comes in from OAG to actype';


--
-- TOC entry 185 (class 1259 OID 128778)
-- Dependencies: 7
-- Name: anoms_oag_alias; Type: TABLE; Schema: alias; Owner: postgres; Tablespace: 
--

CREATE TABLE anoms_oag_alias (
    anoms text,
    oag text
);


ALTER TABLE alias.anoms_oag_alias OWNER TO postgres;

--
-- TOC entry 186 (class 1259 OID 128784)
-- Dependencies: 7
-- Name: headinglookup; Type: TABLE; Schema: alias; Owner: postgres; Tablespace: 
--

CREATE TABLE headinglookup (
    otherport text,
    heading smallint
);


ALTER TABLE alias.headinglookup OWNER TO postgres;

--
-- TOC entry 3386 (class 0 OID 0)
-- Dependencies: 186
-- Name: TABLE headinglookup; Type: COMMENT; Schema: alias; Owner: postgres
--

COMMENT ON TABLE headinglookup IS 'Original heading lookup table from ANOMS';


--
-- TOC entry 187 (class 1259 OID 128790)
-- Dependencies: 7
-- Name: icao; Type: TABLE; Schema: alias; Owner: postgres; Tablespace: 
--

CREATE TABLE icao (
    icao text,
    inm_type text,
    cat text,
    stage text,
    "desc" text
);


ALTER TABLE alias.icao OWNER TO postgres;

--
-- TOC entry 188 (class 1259 OID 128796)
-- Dependencies: 7
-- Name: inm_runup_lookup; Type: TABLE; Schema: alias; Owner: postgres; Tablespace: 
--

CREATE TABLE inm_runup_lookup (
    ac text NOT NULL,
    inmcode text
);


ALTER TABLE alias.inm_runup_lookup OWNER TO postgres;

--
-- TOC entry 3387 (class 0 OID 0)
-- Dependencies: 188
-- Name: TABLE inm_runup_lookup; Type: COMMENT; Schema: alias; Owner: postgres
--

COMMENT ON TABLE inm_runup_lookup IS 'Aliases runups for INM';


--
-- TOC entry 189 (class 1259 OID 128802)
-- Dependencies: 7
-- Name: inmcode; Type: TABLE; Schema: alias; Owner: postgres; Tablespace: 
--

CREATE TABLE inmcode (
    inmcode text,
    actype text,
    description text,
    helo text,
    id integer NOT NULL,
    inmgroup text,
    subgroup text,
    reportname text
);


ALTER TABLE alias.inmcode OWNER TO postgres;

--
-- TOC entry 3388 (class 0 OID 0)
-- Dependencies: 189
-- Name: TABLE inmcode; Type: COMMENT; Schema: alias; Owner: postgres
--

COMMENT ON TABLE inmcode IS 'Aliases aircraft for INM';


--
-- TOC entry 190 (class 1259 OID 128808)
-- Dependencies: 7 189
-- Name: inmcode_id_seq; Type: SEQUENCE; Schema: alias; Owner: postgres
--

CREATE SEQUENCE inmcode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE alias.inmcode_id_seq OWNER TO postgres;

--
-- TOC entry 3389 (class 0 OID 0)
-- Dependencies: 190
-- Name: inmcode_id_seq; Type: SEQUENCE OWNED BY; Schema: alias; Owner: postgres
--

ALTER SEQUENCE inmcode_id_seq OWNED BY inmcode.id;


--
-- TOC entry 3390 (class 0 OID 0)
-- Dependencies: 190
-- Name: inmcode_id_seq; Type: SEQUENCE SET; Schema: alias; Owner: postgres
--

SELECT pg_catalog.setval('inmcode_id_seq', 1, false);


--
-- TOC entry 191 (class 1259 OID 128810)
-- Dependencies: 7
-- Name: inmcode_lookup; Type: TABLE; Schema: alias; Owner: postgres; Tablespace: 
--

CREATE TABLE inmcode_lookup (
    inmcode text NOT NULL,
    description text,
    inmgroup text,
    subgroup text,
    reportname text,
    in2009 boolean,
    groupdescrip text
);


ALTER TABLE alias.inmcode_lookup OWNER TO postgres;

--
-- TOC entry 3391 (class 0 OID 0)
-- Dependencies: 191
-- Name: TABLE inmcode_lookup; Type: COMMENT; Schema: alias; Owner: postgres
--

COMMENT ON TABLE inmcode_lookup IS 'Used for aliasing INM data for tables in the annual contour report';


--
-- TOC entry 192 (class 1259 OID 128816)
-- Dependencies: 1580 7
-- Name: mac_airport_aoi; Type: TABLE; Schema: alias; Owner: postgres; Tablespace: 
--

CREATE TABLE mac_airport_aoi (
    id integer NOT NULL,
    airport text NOT NULL,
    radius real NOT NULL,
    ceiling real NOT NULL,
    center public.geometry NOT NULL
);


ALTER TABLE alias.mac_airport_aoi OWNER TO postgres;

--
-- TOC entry 193 (class 1259 OID 128822)
-- Dependencies: 192 7
-- Name: mac_airport_aoi_id_seq; Type: SEQUENCE; Schema: alias; Owner: postgres
--

CREATE SEQUENCE mac_airport_aoi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE alias.mac_airport_aoi_id_seq OWNER TO postgres;

--
-- TOC entry 3392 (class 0 OID 0)
-- Dependencies: 193
-- Name: mac_airport_aoi_id_seq; Type: SEQUENCE OWNED BY; Schema: alias; Owner: postgres
--

ALTER SEQUENCE mac_airport_aoi_id_seq OWNED BY mac_airport_aoi.id;


--
-- TOC entry 3393 (class 0 OID 0)
-- Dependencies: 193
-- Name: mac_airport_aoi_id_seq; Type: SEQUENCE SET; Schema: alias; Owner: postgres
--

SELECT pg_catalog.setval('mac_airport_aoi_id_seq', 1, false);


--
-- TOC entry 194 (class 1259 OID 128824)
-- Dependencies: 7
-- Name: mactype_ft; Type: TABLE; Schema: alias; Owner: postgres; Tablespace: 
--

CREATE TABLE mactype_ft (
    mactype character varying NOT NULL,
    description character varying
);


ALTER TABLE alias.mactype_ft OWNER TO postgres;

--
-- TOC entry 195 (class 1259 OID 128830)
-- Dependencies: 7
-- Name: oag_airline_substitution; Type: TABLE; Schema: alias; Owner: postgres; Tablespace: 
--

CREATE TABLE oag_airline_substitution (
    icao text,
    substitution text[]
);


ALTER TABLE alias.oag_airline_substitution OWNER TO postgres;

--
-- TOC entry 3394 (class 0 OID 0)
-- Dependencies: 195
-- Name: TABLE oag_airline_substitution; Type: COMMENT; Schema: alias; Owner: postgres
--

COMMENT ON TABLE oag_airline_substitution IS 'List of regional carriers that fly for major carriers. Used to compare the scheduled data to the actual data and to add origin/destination information to the actual data.';


--
-- TOC entry 196 (class 1259 OID 128836)
-- Dependencies: 7
-- Name: runup_thrust_lookup; Type: TABLE; Schema: alias; Owner: postgres; Tablespace: 
--

CREATE TABLE runup_thrust_lookup (
    inmcode text,
    low double precision,
    high double precision
);


ALTER TABLE alias.runup_thrust_lookup OWNER TO postgres;

--
-- TOC entry 197 (class 1259 OID 128842)
-- Dependencies: 7
-- Name: tailnumber_lookup; Type: TABLE; Schema: alias; Owner: postgres; Tablespace: 
--

CREATE TABLE tailnumber_lookup (
    id integer NOT NULL,
    operator text,
    oagcode text,
    tailnumber text,
    manufacturer_code text,
    engine_model text,
    engine_type text,
    stage text,
    model text,
    eqgroup text
);


ALTER TABLE alias.tailnumber_lookup OWNER TO postgres;

--
-- TOC entry 198 (class 1259 OID 128848)
-- Dependencies: 7 197
-- Name: tailnumber_lookup_id_seq; Type: SEQUENCE; Schema: alias; Owner: postgres
--

CREATE SEQUENCE tailnumber_lookup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE alias.tailnumber_lookup_id_seq OWNER TO postgres;

--
-- TOC entry 3395 (class 0 OID 0)
-- Dependencies: 198
-- Name: tailnumber_lookup_id_seq; Type: SEQUENCE OWNED BY; Schema: alias; Owner: postgres
--

ALTER SEQUENCE tailnumber_lookup_id_seq OWNED BY tailnumber_lookup.id;


--
-- TOC entry 3396 (class 0 OID 0)
-- Dependencies: 198
-- Name: tailnumber_lookup_id_seq; Type: SEQUENCE SET; Schema: alias; Owner: postgres
--

SELECT pg_catalog.setval('tailnumber_lookup_id_seq', 1, false);


--
-- TOC entry 3313 (class 2604 OID 129100)
-- Dependencies: 184 183
-- Name: id; Type: DEFAULT; Schema: alias; Owner: postgres
--

ALTER TABLE actype_airline_nnumber ALTER COLUMN id SET DEFAULT nextval('actype_airline_nnumber_temp_id_seq'::regclass);


--
-- TOC entry 3314 (class 2604 OID 129101)
-- Dependencies: 190 189
-- Name: id; Type: DEFAULT; Schema: alias; Owner: postgres
--

ALTER TABLE inmcode ALTER COLUMN id SET DEFAULT nextval('inmcode_id_seq'::regclass);


--
-- TOC entry 3315 (class 2604 OID 129102)
-- Dependencies: 193 192
-- Name: id; Type: DEFAULT; Schema: alias; Owner: postgres
--

ALTER TABLE mac_airport_aoi ALTER COLUMN id SET DEFAULT nextval('mac_airport_aoi_id_seq'::regclass);


--
-- TOC entry 3316 (class 2604 OID 129103)
-- Dependencies: 198 197
-- Name: id; Type: DEFAULT; Schema: alias; Owner: postgres
--

ALTER TABLE tailnumber_lookup ALTER COLUMN id SET DEFAULT nextval('tailnumber_lookup_id_seq'::regclass);


--
-- TOC entry 3354 (class 0 OID 128498)
-- Dependencies: 162
-- Data for Name: actype; Type: TABLE DATA; Schema: alias; Owner: postgres
--

INSERT INTO actype VALUES ('', 'UKN', NULL);
INSERT INTO actype VALUES ('002M', 'UKN', NULL);
INSERT INTO actype VALUES ('00AM', 'B222', NULL);
INSERT INTO actype VALUES ('114B', 'AC14', NULL);
INSERT INTO actype VALUES ('2ERQ', 'UKN', NULL);
INSERT INTO actype VALUES ('2F18', 'UKN', 'F-18');
INSERT INTO actype VALUES ('2SR2', 'SR20', 'GASEPV');
INSERT INTO actype VALUES ('2TT6', 'UKN', 'T38');
INSERT INTO actype VALUES ('4MEE', 'UKN', NULL);
INSERT INTO actype VALUES ('4T6S', 'UKN', 'T38');
INSERT INTO actype VALUES ('7ECA', '7ECA', 'GASEPF');
INSERT INTO actype VALUES ('7FCM', 'UKN', 'GASEPV');
INSERT INTO actype VALUES ('8ACB', 'PTS1', NULL);
INSERT INTO actype VALUES ('9FCM', 'UKN', 'GASEPV');
INSERT INTO actype VALUES ('A1', 'UKN', 'GASEPF');
INSERT INTO actype VALUES ('A109', 'A109', 'A109');
INSERT INTO actype VALUES ('A1B', 'UKN', 'GASEPF');
INSERT INTO actype VALUES ('A1D', 'UKN', 'GASEPF');
INSERT INTO actype VALUES ('A2', 'UKN', NULL);
INSERT INTO actype VALUES ('A300', 'A300', 'A300B4-203');
INSERT INTO actype VALUES ('A306', 'A300', 'A300-622R');
INSERT INTO actype VALUES ('A30B', 'A300', 'A300B4-203');
INSERT INTO actype VALUES ('A310', 'A310', 'A310-304');
INSERT INTO actype VALUES ('A318', 'A318', 'A319-131');
INSERT INTO actype VALUES ('A319', 'A319', 'A319-131');
INSERT INTO actype VALUES ('A320', 'A320', 'A320-211');
INSERT INTO actype VALUES ('A321', 'A321', 'A321-232');
INSERT INTO actype VALUES ('A330', 'A330', 'A330-301');
INSERT INTO actype VALUES ('A332', 'A330', 'A330-301');
INSERT INTO actype VALUES ('A333', 'A330', 'A330-301');
INSERT INTO actype VALUES ('A36', 'A36', 'BEC33');
INSERT INTO actype VALUES ('A380', 'A380', '747400');
INSERT INTO actype VALUES ('A388', 'A380', '747400');
INSERT INTO actype VALUES ('A45', 'UKN', 'AA5A');
INSERT INTO actype VALUES ('A700', 'A700', 'CNA510');
INSERT INTO actype VALUES ('AA1', 'AA1', 'CNA152');
INSERT INTO actype VALUES ('AA1B', 'UKN', 'CNA152');
INSERT INTO actype VALUES ('AA24', 'UKN', NULL);
INSERT INTO actype VALUES ('AA36', 'A36', 'BEC33');
INSERT INTO actype VALUES ('AA5', 'AA5', 'AA5A');
INSERT INTO actype VALUES ('AA5A', 'AA5', 'AA5A');
INSERT INTO actype VALUES ('AA5B', 'AA5', 'AA5A');
INSERT INTO actype VALUES ('AA7', 'AA5', 'AA5A');
INSERT INTO actype VALUES ('AC09', 'UKN', NULL);
INSERT INTO actype VALUES ('AC10', 'UKN', 'RWCM12');
INSERT INTO actype VALUES ('AC11', 'AC12', 'RWCM12');
INSERT INTO actype VALUES ('AC12', 'AC12', 'RWCM12');
INSERT INTO actype VALUES ('AC14', 'AC14', 'RWCM14');
INSERT INTO actype VALUES ('AC17', 'AC14', 'RWCM14');
INSERT INTO actype VALUES ('AC20', 'UKN', 'RWCM14');
INSERT INTO actype VALUES ('AC21', 'UKN', 'RWCM14');
INSERT INTO actype VALUES ('AC38', 'DA10', 'FAL10');
INSERT INTO actype VALUES ('AC45', 'UKN', NULL);
INSERT INTO actype VALUES ('AC50', 'AC50', 'BEC58P');
INSERT INTO actype VALUES ('AC51', 'AC50', 'BEC58P');
INSERT INTO actype VALUES ('AC55', 'UKN', 'BEC58P');
INSERT INTO actype VALUES ('AC56', 'AC50', 'BEC58P');
INSERT INTO actype VALUES ('AC58', 'AC50', 'BEC58P');
INSERT INTO actype VALUES ('AC59', 'AC50', NULL);
INSERT INTO actype VALUES ('AC60', 'AC60', 'RWCM69');
INSERT INTO actype VALUES ('AC68', 'AC60', 'RWCM69');
INSERT INTO actype VALUES ('AC69', 'AC60', 'RWCM69');
INSERT INTO actype VALUES ('AC78', 'UKN', 'RWCM69');
INSERT INTO actype VALUES ('AC80', 'AC60', 'RWCM69');
INSERT INTO actype VALUES ('AC90', 'AC90', 'RWCM69');
INSERT INTO actype VALUES ('AC95', 'AC95', 'RWCM69');
INSERT INTO actype VALUES ('ACPE', 'F02', 'GASEPF');
INSERT INTO actype VALUES ('AERO', 'PARO', 'PA28CA');
INSERT INTO actype VALUES ('AEST', 'AEST', 'PA60');
INSERT INTO actype VALUES ('AG5', 'AA5', 'AA5A');
INSERT INTO actype VALUES ('AG5B', 'AG5B', 'AA5A');
INSERT INTO actype VALUES ('AH1', 'UKN', 'B212');
INSERT INTO actype VALUES ('AH60', 'HELO', 'S70');
INSERT INTO actype VALUES ('AMPB', 'UKN', 'CNA336');
INSERT INTO actype VALUES ('AMPH', 'AMPH', 'CNA336');
INSERT INTO actype VALUES ('ANE', 'UKN', 'IL76');
INSERT INTO actype VALUES ('AS55', 'DA42', 'CNA206');
INSERT INTO actype VALUES ('AT38', 'UKN', 'T38');
INSERT INTO actype VALUES ('AT5B', 'AG5B', 'AA5A');
INSERT INTO actype VALUES ('AT6', 'T6', 'T38');
INSERT INTO actype VALUES ('AT8T', 'C177', 'CNA177');
INSERT INTO actype VALUES ('ATME', 'UKN', NULL);
INSERT INTO actype VALUES ('AV8', 'UKN', 'GASEPV');
INSERT INTO actype VALUES ('AVI', 'NAVR', 'PA24');
INSERT INTO actype VALUES ('AVN', 'NAVR', NULL);
INSERT INTO actype VALUES ('B017', 'G21', NULL);
INSERT INTO actype VALUES ('B06', 'B06', 'B206L');
INSERT INTO actype VALUES ('B11', 'CH7', 'GASEPF');
INSERT INTO actype VALUES ('B117', 'B117', 'EC130');
INSERT INTO actype VALUES ('B14A', 'B14A', 'BL14');
INSERT INTO actype VALUES ('B14C', 'B14A', 'BL14');
INSERT INTO actype VALUES ('B17', 'B17', NULL);
INSERT INTO actype VALUES ('B172', 'C172', 'CNA172');
INSERT INTO actype VALUES ('B19', 'BE19', 'BEC24');
INSERT INTO actype VALUES ('B190', 'B190', 'BEC190');
INSERT INTO actype VALUES ('B20', 'BE20', 'BEC200');
INSERT INTO actype VALUES ('B200', 'BE20', 'BEC200');
INSERT INTO actype VALUES ('B206', 'B06', 'B206L');
INSERT INTO actype VALUES ('B222', 'B222', 'B222');
INSERT INTO actype VALUES ('B24', 'B24', 'CNV240');
INSERT INTO actype VALUES ('B25', 'B25', NULL);
INSERT INTO actype VALUES ('B250', 'UKN', NULL);
INSERT INTO actype VALUES ('B269', 'UKN', NULL);
INSERT INTO actype VALUES ('B300', 'BE30', 'BEC300');
INSERT INTO actype VALUES ('B320', 'BE30', 'BEC300');
INSERT INTO actype VALUES ('B35', 'B350', 'BEC30B');
INSERT INTO actype VALUES ('B350', 'B350', 'BEC30B');
INSERT INTO actype VALUES ('B358', 'UKN', 'BEC30B');
INSERT INTO actype VALUES ('B35B', 'B350', 'BEC30B');
INSERT INTO actype VALUES ('B35O', 'B350', 'BEC30B');
INSERT INTO actype VALUES ('B35T', 'BE36', 'BEC33');
INSERT INTO actype VALUES ('B35V', 'BE35', 'BEC33');
INSERT INTO actype VALUES ('B36', 'BE36', 'BEC33');
INSERT INTO actype VALUES ('B36T', 'BE36', 'BEC33');
INSERT INTO actype VALUES ('B39L', 'UKN', NULL);
INSERT INTO actype VALUES ('B430', 'UKN', NULL);
INSERT INTO actype VALUES ('B46T', 'P46T', 'PA46');
INSERT INTO actype VALUES ('B47G', 'B47G', 'B206L');
INSERT INTO actype VALUES ('B55', 'BE55', 'BEC55');
INSERT INTO actype VALUES ('B58', 'BE58', 'BEC58');
INSERT INTO actype VALUES ('B58P', 'B58P', 'BEC58');
INSERT INTO actype VALUES ('B58T', 'BE58', 'BEC58');
INSERT INTO actype VALUES ('B60', 'B60', 'BEC60');
INSERT INTO actype VALUES ('B703', 'B707', '707');
INSERT INTO actype VALUES ('B712', 'B717', '717200');
INSERT INTO actype VALUES ('B717', 'B717', '717ER');
INSERT INTO actype VALUES ('B721', 'B72Q', '727EM1');
INSERT INTO actype VALUES ('B722', 'B72Q', '727EM2');
INSERT INTO actype VALUES ('B727', 'B72Q', '727EM2');
INSERT INTO actype VALUES ('B72F', 'B72Q', '727EM2');
INSERT INTO actype VALUES ('B72Q', 'B72Q', '727EM2');
INSERT INTO actype VALUES ('B732', 'B73Q', '737N9');
INSERT INTO actype VALUES ('B733', 'B733', '737300');
INSERT INTO actype VALUES ('B734', 'B734', '737400');
INSERT INTO actype VALUES ('B735', 'B735', '737500');
INSERT INTO actype VALUES ('B736', 'B736', '737700');
INSERT INTO actype VALUES ('B737', 'B7377', '737700');
INSERT INTO actype VALUES ('B738', 'B738', '737800');
INSERT INTO actype VALUES ('B739', 'B739', NULL);
INSERT INTO actype VALUES ('B73F', 'B737', '737N17');
INSERT INTO actype VALUES ('B73Q', 'B73Q', '737N17');
INSERT INTO actype VALUES ('B741', 'B741', '747100');
INSERT INTO actype VALUES ('B742', 'B742', '747200');
INSERT INTO actype VALUES ('B743', 'B743', '747400');
INSERT INTO actype VALUES ('B744', 'B744', '747400');
INSERT INTO actype VALUES ('B747', 'B744', '747400');
INSERT INTO actype VALUES ('B752', 'B757', '757PW');
INSERT INTO actype VALUES ('B753', 'B757', '757300');
INSERT INTO actype VALUES ('B757', 'B757', '757PW');
INSERT INTO actype VALUES ('B762', 'B767', '767CF6');
INSERT INTO actype VALUES ('B763', 'B767', '767300');
INSERT INTO actype VALUES ('B767', 'B767', '767CF6');
INSERT INTO actype VALUES ('B76F', 'B767', '767CF6');
INSERT INTO actype VALUES ('B772', 'B777', '777200');
INSERT INTO actype VALUES ('B773', 'B777', '777300');
INSERT INTO actype VALUES ('B89L', 'C90', NULL);
INSERT INTO actype VALUES ('B9L', 'BE9L', 'BEC90');
INSERT INTO actype VALUES ('BA10', 'BE10', 'BEC100');
INSERT INTO actype VALUES ('BA11', 'BA11', 'BAC111');
INSERT INTO actype VALUES ('BA20', 'DIAM', 'CNA150');
INSERT INTO actype VALUES ('BA40', 'UKN', 'CNA206');
INSERT INTO actype VALUES ('BA46', 'RJ85', NULL);
INSERT INTO actype VALUES ('BA58', 'BE58', 'BEC58');
INSERT INTO actype VALUES ('BALA', 'UKN', NULL);
INSERT INTO actype VALUES ('BALL', 'UKN', 'BAC111');
INSERT INTO actype VALUES ('BD58', 'BE58', 'BEC58');
INSERT INTO actype VALUES ('BE', 'UKN', 'BEC200');
INSERT INTO actype VALUES ('BE02', 'B190', 'BEC190');
INSERT INTO actype VALUES ('BE10', 'BE10', 'BEC100');
INSERT INTO actype VALUES ('BE15', 'BE23', NULL);
INSERT INTO actype VALUES ('BE17', 'BE17', 'GASEPF');
INSERT INTO actype VALUES ('BE18', 'BE18', 'BEC18');
INSERT INTO actype VALUES ('BE19', 'BE19', 'BEC24');
INSERT INTO actype VALUES ('BE2', 'BE20', 'BEC200');
INSERT INTO actype VALUES ('BE20', 'BE20', 'BEC200');
INSERT INTO actype VALUES ('BE23', 'BE23', 'GASEPF');
INSERT INTO actype VALUES ('BE24', 'BE24', 'BEC24');
INSERT INTO actype VALUES ('BE25', 'M35', 'BEC23');
INSERT INTO actype VALUES ('BE26', 'BE33', 'BEC33');
INSERT INTO actype VALUES ('BE28', 'UKN', 'BEC33');
INSERT INTO actype VALUES ('BE29', 'BE20', 'BEC200');
INSERT INTO actype VALUES ('BE3', 'UKN', NULL);
INSERT INTO actype VALUES ('BE30', 'BE30', 'BEC300');
INSERT INTO actype VALUES ('BE32', 'BE36', 'BEC33');
INSERT INTO actype VALUES ('BE33', 'BE33', 'BEC33');
INSERT INTO actype VALUES ('BE35', 'BE35', 'BEC33');
INSERT INTO actype VALUES ('BE36', 'BE36', 'BEC33');
INSERT INTO actype VALUES ('BE39', 'PA30', 'PA30');
INSERT INTO actype VALUES ('BE3B', 'UKN', 'BEC30B');
INSERT INTO actype VALUES ('BE40', 'BE40', 'BEC400');
INSERT INTO actype VALUES ('BE46', 'PA46', 'PA46');
INSERT INTO actype VALUES ('BE5', 'BE58', 'BEC58');
INSERT INTO actype VALUES ('BE50', 'BE50', 'BEC50');
INSERT INTO actype VALUES ('BE52', 'BE52', 'BEC55');
INSERT INTO actype VALUES ('BE55', 'BE55', 'BEC55');
INSERT INTO actype VALUES ('BE56', 'BE58', 'BEC58');
INSERT INTO actype VALUES ('BE58', 'BE58', 'BEC58');
INSERT INTO actype VALUES ('BE59', 'BE59', 'BEC58');
INSERT INTO actype VALUES ('BE5M', 'BE55', 'BEC55');
INSERT INTO actype VALUES ('BE60', 'BE60', 'BEC60');
INSERT INTO actype VALUES ('BE65', 'BE65', 'BEC65');
INSERT INTO actype VALUES ('BE66', 'BE60', 'BEC60');
INSERT INTO actype VALUES ('BE76', 'BE76', 'BEC76');
INSERT INTO actype VALUES ('BE80', 'BE80', 'BEC80');
INSERT INTO actype VALUES ('BE9', 'BE9L', 'BEC90');
INSERT INTO actype VALUES ('BE90', 'BE9L', 'BEC90');
INSERT INTO actype VALUES ('BE95', 'BE95', 'BEC95');
INSERT INTO actype VALUES ('BE99', 'BE99', 'BEC99');
INSERT INTO actype VALUES ('BE9J', 'C90', 'BEC90');
INSERT INTO actype VALUES ('BE9L', 'BE9L', 'BEC90');
INSERT INTO actype VALUES ('BE9R', 'BE9L', NULL);
INSERT INTO actype VALUES ('BE9T', 'BE9L', 'BEC90');
INSERT INTO actype VALUES ('BEL9', 'BE9L', 'BEC90');
INSERT INTO actype VALUES ('BEST', 'UKN', NULL);
INSERT INTO actype VALUES ('BF36', 'A36', 'BEC33');
INSERT INTO actype VALUES ('BF55', 'BE55', 'BEC55');
INSERT INTO actype VALUES ('BH06', 'B206', 'B206L');
INSERT INTO actype VALUES ('BH20', 'H269', 'H500D');
INSERT INTO actype VALUES ('BH22', 'B222', 'B222');
INSERT INTO actype VALUES ('BH60', 'R44', 'R22');
INSERT INTO actype VALUES ('BK17', 'BK17', 'EC130');
INSERT INTO actype VALUES ('BL17', 'BL17', 'BL26');
INSERT INTO actype VALUES ('BL26', 'BL17', 'BL26');
INSERT INTO actype VALUES ('BL30', 'BL26', 'BL26');
INSERT INTO actype VALUES ('BL7', 'BL7', 'GASEPF');
INSERT INTO actype VALUES ('BL8', 'BL7', 'GASEPF');
INSERT INTO actype VALUES ('BL8D', 'BL7', 'BL14');
INSERT INTO actype VALUES ('BL90', 'BE9L', 'BEC90');
INSERT INTO actype VALUES ('BLMP', 'UKN', NULL);
INSERT INTO actype VALUES ('BR06', 'B06', NULL);
INSERT INTO actype VALUES ('BR20', 'BE20', 'BEC200');
INSERT INTO actype VALUES ('BR40', 'BE40', 'BEC400');
INSERT INTO actype VALUES ('BR90', 'BE9L', 'BEC90');
INSERT INTO actype VALUES ('BS20', 'BS20', 'BEC200');
INSERT INTO actype VALUES ('BT13', 'UKN', NULL);
INSERT INTO actype VALUES ('BT6S', 'BT6S', 'PA28');
INSERT INTO actype VALUES ('BW10', 'BE10', 'BEC100');
INSERT INTO actype VALUES ('BW40', 'UKN', 'BEC400');
INSERT INTO actype VALUES ('BZ35', 'BE35', 'BEC33');
INSERT INTO actype VALUES ('BZ36', 'BE35', 'BEC33');
INSERT INTO actype VALUES ('C0L4', 'LNC4', 'CNA206');
INSERT INTO actype VALUES ('C108', 'C208', 'CNA208');
INSERT INTO actype VALUES ('C10T', 'C210', 'CNA210');
INSERT INTO actype VALUES ('C12', 'C120', 'CNA150');
INSERT INTO actype VALUES ('C120', 'C120', 'CNA150');
INSERT INTO actype VALUES ('C12R', 'C182', 'CNA182');
INSERT INTO actype VALUES ('C130', 'C130', 'C130');
INSERT INTO actype VALUES ('C140', 'C140', 'CNA150');
INSERT INTO actype VALUES ('C141', 'UKN', 'CNA150');
INSERT INTO actype VALUES ('C150', 'C150', 'CNA150');
INSERT INTO actype VALUES ('C152', 'C152', 'CNA152');
INSERT INTO actype VALUES ('C160', 'UKN', 'CNA150');
INSERT INTO actype VALUES ('C17', 'UKN', 'C17');
INSERT INTO actype VALUES ('C170', 'C170', 'CNA170');
INSERT INTO actype VALUES ('C172', 'C172', 'CNA172');
INSERT INTO actype VALUES ('C175', 'C175', 'CNA170');
INSERT INTO actype VALUES ('C177', 'C177', 'CNA177');
INSERT INTO actype VALUES ('C178', 'C172', 'CNA172');
INSERT INTO actype VALUES ('C17A', 'UKN', 'C17');
INSERT INTO actype VALUES ('C180', 'C180', 'CNA180');
INSERT INTO actype VALUES ('C182', 'C182', 'CNA182');
INSERT INTO actype VALUES ('C185', 'C185', 'CNA185');
INSERT INTO actype VALUES ('C188', 'C188', 'CNAWAG');
INSERT INTO actype VALUES ('C18A', 'C182', 'CNA182');
INSERT INTO actype VALUES ('C195', 'C195', 'CNA170');
INSERT INTO actype VALUES ('C205', 'C205', 'CNA205');
INSERT INTO actype VALUES ('C206', 'C206', 'CNA206');
INSERT INTO actype VALUES ('C207', 'C207', 'CNA207');
INSERT INTO actype VALUES ('C208', 'C208', 'CNA208');
INSERT INTO actype VALUES ('C21', 'C210', 'CNA210');
INSERT INTO actype VALUES ('C210', 'C210', 'CNA210');
INSERT INTO actype VALUES ('C218', 'C218', 'CNA172');
INSERT INTO actype VALUES ('C21A', 'C210', 'CNA210');
INSERT INTO actype VALUES ('C21P', 'C21P', 'CNA210');
INSERT INTO actype VALUES ('C21T', 'C21T', 'CNA421');
INSERT INTO actype VALUES ('C231', 'UKN', NULL);
INSERT INTO actype VALUES ('C240', 'C340', 'CNA340');
INSERT INTO actype VALUES ('C25', 'C525', 'CNA525');
INSERT INTO actype VALUES ('C25A', 'C525', 'CNA525');
INSERT INTO actype VALUES ('C25B', 'C25B', 'CNA525');
INSERT INTO actype VALUES ('C26B', 'C525', 'CNA525');
INSERT INTO actype VALUES ('C303', 'C303', 'CNA303');
INSERT INTO actype VALUES ('C307', 'UKN', 'CNA206');
INSERT INTO actype VALUES ('C30J', 'C30J', 'C130');
INSERT INTO actype VALUES ('C31', 'C310', 'CNA310');
INSERT INTO actype VALUES ('C310', 'C310', 'CNA310');
INSERT INTO actype VALUES ('C320', 'C320', 'CNA320');
INSERT INTO actype VALUES ('C33', 'DG15', NULL);
INSERT INTO actype VALUES ('C335', 'C335', 'CNA335');
INSERT INTO actype VALUES ('C336', 'C336', 'CNA182');
INSERT INTO actype VALUES ('C337', 'C337', 'CNA337');
INSERT INTO actype VALUES ('C340', 'C340', 'CNA340');
INSERT INTO actype VALUES ('C360', 'UKN', 'CNA340');
INSERT INTO actype VALUES ('C377', 'C337', 'CNA337');
INSERT INTO actype VALUES ('C400', 'C400', NULL);
INSERT INTO actype VALUES ('C401', 'C401', 'CNA401');
INSERT INTO actype VALUES ('C402', 'C402', 'CNA402');
INSERT INTO actype VALUES ('C404', 'C404', 'CNA404');
INSERT INTO actype VALUES ('C414', 'C414', 'CNA414');
INSERT INTO actype VALUES ('C421', 'C421', 'CNA421');
INSERT INTO actype VALUES ('C425', 'C425', 'CNA425');
INSERT INTO actype VALUES ('C430', 'C340', 'CNA340');
INSERT INTO actype VALUES ('C441', 'C441', 'CNA441');
INSERT INTO actype VALUES ('C442', 'C425', 'CNA425');
INSERT INTO actype VALUES ('C50', 'UKN', 'CNA501');
INSERT INTO actype VALUES ('C500', 'C500', 'CNA501');
INSERT INTO actype VALUES ('C501', 'C501', 'CNA501');
INSERT INTO actype VALUES ('C502', 'C550', 'CNA550');
INSERT INTO actype VALUES ('C510', 'C510', 'CNA510');
INSERT INTO actype VALUES ('C520', 'C550', 'CNA550');
INSERT INTO actype VALUES ('C525', 'C525', 'CNA525');
INSERT INTO actype VALUES ('C526', 'C525', 'CNA525');
INSERT INTO actype VALUES ('C52A', 'C525', 'CNA525');
INSERT INTO actype VALUES ('C550', 'C550', 'CNA550');
INSERT INTO actype VALUES ('C551', 'C551', 'CNA551');
INSERT INTO actype VALUES ('C556', 'C550', 'CNA550');
INSERT INTO actype VALUES ('C55O', 'C550', 'CNA550');
INSERT INTO actype VALUES ('C56', 'C560', 'CNA560');
INSERT INTO actype VALUES ('C560', 'C560', 'CNA560');
INSERT INTO actype VALUES ('C56O', 'C560', NULL);
INSERT INTO actype VALUES ('C56X', 'C56X', 'CNA560');
INSERT INTO actype VALUES ('C650', 'C650', 'CNA650');
INSERT INTO actype VALUES ('C65X', 'C650', 'CNA650');
INSERT INTO actype VALUES ('C660', 'C56X', 'CNA560');
INSERT INTO actype VALUES ('C680', 'C680', 'CNA650');
INSERT INTO actype VALUES ('C712', 'C172', 'CNA172');
INSERT INTO actype VALUES ('C72', 'C172', 'CNA172');
INSERT INTO actype VALUES ('C72R', 'C172', 'CNA172');
INSERT INTO actype VALUES ('C750', 'C750', 'CNA750');
INSERT INTO actype VALUES ('C77', 'C77', 'CNA177');
INSERT INTO actype VALUES ('C77R', 'C177', 'CNA177');
INSERT INTO actype VALUES ('C82', 'C182', 'CNA182');
INSERT INTO actype VALUES ('C82R', 'C182', 'CNA182');
INSERT INTO actype VALUES ('C82T', 'C182', 'CNA182');
INSERT INTO actype VALUES ('C9', 'C9', 'C9A');
INSERT INTO actype VALUES ('C90', 'C90', 'BEC90');
INSERT INTO actype VALUES ('CE15', 'UKN', 'CNA150');
INSERT INTO actype VALUES ('CE20', 'UKN', 'C20');
INSERT INTO actype VALUES ('CE35', 'CE35', NULL);
INSERT INTO actype VALUES ('CE51', 'UKN', 'CNA551');
INSERT INTO actype VALUES ('CE52', 'C152', 'CNA152');
INSERT INTO actype VALUES ('CE55', 'C550', 'CNA550');
INSERT INTO actype VALUES ('CE56', 'C560', 'CNA560');
INSERT INTO actype VALUES ('CESSNA', 'CESSNA', 'CNA172');
INSERT INTO actype VALUES ('CFCM', 'UKN', 'GASEPV');
INSERT INTO actype VALUES ('CH06', '7ECA', 'GASEPF');
INSERT INTO actype VALUES ('CH09', 'UKN', 'C130');
INSERT INTO actype VALUES ('CH10', 'CH7', 'GASEPF');
INSERT INTO actype VALUES ('CH47', 'CH7', 'GASEPF');
INSERT INTO actype VALUES ('CH5', 'CH7', 'GASEPF');
INSERT INTO actype VALUES ('CH60', 'CH60', NULL);
INSERT INTO actype VALUES ('CH7', 'CH7', 'GASEPF');
INSERT INTO actype VALUES ('CH78', 'DECA', 'GASEPF');
INSERT INTO actype VALUES ('CH7A', 'CH7', 'GASEPF');
INSERT INTO actype VALUES ('CH7B', 'CH7', 'GASEPF');
INSERT INTO actype VALUES ('CH8', 'DECA', 'GASEPF');
INSERT INTO actype VALUES ('CH9', 'CH7', 'GASEPF');
INSERT INTO actype VALUES ('CHMP', 'CH7', 'GASEPF');
INSERT INTO actype VALUES ('CHOP', 'HELO', NULL);
INSERT INTO actype VALUES ('CIT', 'CITB', 'CIT3');
INSERT INTO actype VALUES ('CITB', 'CITB', 'CIT3');
INSERT INTO actype VALUES ('CJ3', 'C525', 'CNA525');
INSERT INTO actype VALUES ('CL3', 'CL30', 'CL601');
INSERT INTO actype VALUES ('CL30', 'CL30', 'CL601');
INSERT INTO actype VALUES ('CL4', 'LNC4', NULL);
INSERT INTO actype VALUES ('CL60', 'CL60', 'CL600');
INSERT INTO actype VALUES ('CL64', 'CL60', 'CL600');
INSERT INTO actype VALUES ('CL65', 'CL60', 'CL600');
INSERT INTO actype VALUES ('CL7', 'CL7', 'GASEPF');
INSERT INTO actype VALUES ('CLL', 'LNC4', 'CNA206');
INSERT INTO actype VALUES ('CLL4', 'LNC4', 'CNA206');
INSERT INTO actype VALUES ('CLM4', 'UKN', NULL);
INSERT INTO actype VALUES ('CLMB', 'LNC4', 'CNA206');
INSERT INTO actype VALUES ('CM11', 'AC12', 'RWCM12');
INSERT INTO actype VALUES ('COL', 'COL', 'GASEPV');
INSERT INTO actype VALUES ('COL3', 'COL3', 'GASEPV');
INSERT INTO actype VALUES ('COL4', 'LNC4', 'CNA206');
INSERT INTO actype VALUES ('COP', 'UKN', NULL);
INSERT INTO actype VALUES ('COPT', 'HELO', NULL);
INSERT INTO actype VALUES ('COS4', 'LNC4', 'CNA206');
INSERT INTO actype VALUES ('COUG', 'C210', 'CNA210');
INSERT INTO actype VALUES ('COUP', 'UKN', NULL);
INSERT INTO actype VALUES ('COUR', 'COUR', 'GASEPF');
INSERT INTO actype VALUES ('CPTR', 'HELO', NULL);
INSERT INTO actype VALUES ('CRJ', 'CRJ', 'CLREGJ');
INSERT INTO actype VALUES ('CRJ1', 'CRJ', 'CLREGJ');
INSERT INTO actype VALUES ('CRJ2', 'CRJ', 'CLREGJ');
INSERT INTO actype VALUES ('CRJ7', 'CRJ', 'CLREGJ');
INSERT INTO actype VALUES ('CRJ9', 'CRJ', 'CLREGJ');
INSERT INTO actype VALUES ('CRSR', 'P68', NULL);
INSERT INTO actype VALUES ('CT23', 'UKN', 'CNA336');
INSERT INTO actype VALUES ('CUB', 'CUB', 'PA18');
INSERT INTO actype VALUES ('CUBS', 'CUBS', 'PA18');
INSERT INTO actype VALUES ('CUR', 'CUR', NULL);
INSERT INTO actype VALUES ('CY1', 'PA31', NULL);
INSERT INTO actype VALUES ('D140', 'BE23', 'BEC23');
INSERT INTO actype VALUES ('D310', 'C310', 'CNA310');
INSERT INTO actype VALUES ('D328', 'D328', 'DO328');
INSERT INTO actype VALUES ('D40', 'DA40', 'CNA206');
INSERT INTO actype VALUES ('D550', 'C550', 'CNA550');
INSERT INTO actype VALUES ('D60', 'UKN', 'LEAR35');
INSERT INTO actype VALUES ('DA04', 'DA40', 'CNA206');
INSERT INTO actype VALUES ('DA05', 'UKN', 'FAL20');
INSERT INTO actype VALUES ('DA10', 'DA10', 'FAL10');
INSERT INTO actype VALUES ('DA20', 'DA20', 'CNA150');
INSERT INTO actype VALUES ('DA22', 'DIAM', 'CNA150');
INSERT INTO actype VALUES ('DA28', 'UKN', 'CNA150');
INSERT INTO actype VALUES ('DA4', 'DA20', 'CNA150');
INSERT INTO actype VALUES ('DA40', 'DA40', 'CNA206');
INSERT INTO actype VALUES ('DA42', 'DA42', 'CNA206');
INSERT INTO actype VALUES ('DA45', 'DA42', 'CNA206');
INSERT INTO actype VALUES ('DA46', 'DA40', 'CNA206');
INSERT INTO actype VALUES ('DA50', 'FA50', 'LEAR35');
INSERT INTO actype VALUES ('DA90', 'F900', 'LEAR35');
INSERT INTO actype VALUES ('DB40', 'DA40', 'CNA206');
INSERT INTO actype VALUES ('DC10', 'DC10', 'DC1010');
INSERT INTO actype VALUES ('DC11', 'AC14', 'RWCM14');
INSERT INTO actype VALUES ('DC3', 'DC3', 'DC3');
INSERT INTO actype VALUES ('DC8', 'DC8Q', 'DC820');
INSERT INTO actype VALUES ('DC83', 'DC8Q', 'DC820');
INSERT INTO actype VALUES ('DC86', 'DC8Q', 'DC860');
INSERT INTO actype VALUES ('DC87', 'DC8Q', 'DC870');
INSERT INTO actype VALUES ('DC8F', 'DC8Q', 'DC820');
INSERT INTO actype VALUES ('DC8Q', 'DC8Q', 'DC8QN');
INSERT INTO actype VALUES ('DC9', 'DC9Q', 'DC9Q9');
INSERT INTO actype VALUES ('DC91', 'DC9Q', 'DC93LW');
INSERT INTO actype VALUES ('DC93', 'DC9Q', 'DC93LW');
INSERT INTO actype VALUES ('DC94', 'DC9Q', 'DC95HW');
INSERT INTO actype VALUES ('DC95', 'DC9Q', 'DC95HW');
INSERT INTO actype VALUES ('DC9F', 'DC9Q', 'DC9Q9');
INSERT INTO actype VALUES ('DC9Q', 'DC9Q', 'DC9Q9');
INSERT INTO actype VALUES ('DE40', 'DA40', 'CNA206');
INSERT INTO actype VALUES ('DE99', 'BE99', 'BEC99');
INSERT INTO actype VALUES ('DEC', 'DECA', 'GASEPF');
INSERT INTO actype VALUES ('DECA', 'DECA', 'GASEPF');
INSERT INTO actype VALUES ('DECH', 'UKN', NULL);
INSERT INTO actype VALUES ('DECT', 'DECA', NULL);
INSERT INTO actype VALUES ('DEFI', 'UKN', 'GASEPV');
INSERT INTO actype VALUES ('DG15', 'DG15', 'CNA172');
INSERT INTO actype VALUES ('DH10', 'DHC2', 'DHC2');
INSERT INTO actype VALUES ('DH2', 'DA20', 'CNA150');
INSERT INTO actype VALUES ('DH21', 'UKN', NULL);
INSERT INTO actype VALUES ('DH2T', 'DHC2', 'DHC2');
INSERT INTO actype VALUES ('DH40', 'DA40', 'CNA206');
INSERT INTO actype VALUES ('DH6', 'DH6', 'DHC6');
INSERT INTO actype VALUES ('DHC2', 'DHC2', 'DHC2');
INSERT INTO actype VALUES ('DHC6', 'DHC6', 'DHC6');
INSERT INTO actype VALUES ('DIAM', 'DIAM', 'CNA150');
INSERT INTO actype VALUES ('DL30', 'UKN', NULL);
INSERT INTO actype VALUES ('DL8', 'DECA', 'GASEPF');
INSERT INTO actype VALUES ('DS40', 'DA40', 'CNA206');
INSERT INTO actype VALUES ('DSTR', 'DA40', 'CNA206');
INSERT INTO actype VALUES ('DV20', 'DA20', 'CNA150');
INSERT INTO actype VALUES ('DV22', 'DIAM', 'CNA150');
INSERT INTO actype VALUES ('DV40', 'DA40', 'CNA206');
INSERT INTO actype VALUES ('DV42', 'DA42', NULL);
INSERT INTO actype VALUES ('DVS', 'DA40', 'CNA206');
INSERT INTO actype VALUES ('E110', 'E110', 'EMB110');
INSERT INTO actype VALUES ('E135', 'E135', 'EMB135');
INSERT INTO actype VALUES ('E140', 'E145', 'EMB145');
INSERT INTO actype VALUES ('E145', 'E145', 'EMB145');
INSERT INTO actype VALUES ('E170', 'E170', 'EMB170');
INSERT INTO actype VALUES ('E175', 'E170', 'EMB170');
INSERT INTO actype VALUES ('E190', 'E190', 'EMB190');
INSERT INTO actype VALUES ('E23', 'BE23', 'BEC23');
INSERT INTO actype VALUES ('E40', 'UKN', 'CNA500');
INSERT INTO actype VALUES ('E400', 'E400', 'CNA500');
INSERT INTO actype VALUES ('E45X', 'E145', 'EMB145');
INSERT INTO actype VALUES ('E500', 'EA50', 'CNA510');
INSERT INTO actype VALUES ('E58', 'BE58', 'BEC58');
INSERT INTO actype VALUES ('E60', 'BE60', 'BEC60');
INSERT INTO actype VALUES ('E90', 'E90', 'BEC90');
INSERT INTO actype VALUES ('EA23', 'EA23', 'CNA500');
INSERT INTO actype VALUES ('EA40', 'EA40', 'CNA500');
INSERT INTO actype VALUES ('EA50', 'EA50', 'CNA510');
INSERT INTO actype VALUES ('EC35', 'EC35', 'EC130');
INSERT INTO actype VALUES ('EC90', 'AC60', NULL);
INSERT INTO actype VALUES ('ECL5', 'UKN', 'CNA55B');
INSERT INTO actype VALUES ('EPIC', 'EXPR', 'GASEPV');
INSERT INTO actype VALUES ('ERCO', 'ERCO', 'GASEPF');
INSERT INTO actype VALUES ('EXA', 'EXPR', 'GASEPV');
INSERT INTO actype VALUES ('EXP', 'EXPR', 'GASEPV');
INSERT INTO actype VALUES ('EXP1', 'EXPR', 'GASEPV');
INSERT INTO actype VALUES ('EXPA', 'EXPR', 'GASEPV');
INSERT INTO actype VALUES ('EXPC', 'EXPR', 'GASEPV');
INSERT INTO actype VALUES ('EXPJ', 'EXPR', 'GASEPV');
INSERT INTO actype VALUES ('EXPM', 'EXPR', 'GASEPV');
INSERT INTO actype VALUES ('EXPO', 'EXPR', 'GASEPV');
INSERT INTO actype VALUES ('EXPP', 'EXPR', 'GASEPV');
INSERT INTO actype VALUES ('EXPQ', 'EXPR', 'GASEPV');
INSERT INTO actype VALUES ('EXPR', 'EXPR', 'GASEPV');
INSERT INTO actype VALUES ('EXTA', 'UKN', 'CNA500');
INSERT INTO actype VALUES ('EXXP', 'EXPR', 'GASEPV');
INSERT INTO actype VALUES ('F02', 'F02', 'GASEPF');
INSERT INTO actype VALUES ('F100', 'F100', 'F10062');
INSERT INTO actype VALUES ('F15', 'UKN', 'F15A');
INSERT INTO actype VALUES ('F16', 'UKN', 'F16GE');
INSERT INTO actype VALUES ('F18', 'UKN', 'F-18');
INSERT INTO actype VALUES ('F260', 'SF20', 'SF260M');
INSERT INTO actype VALUES ('F27', 'UKN', 'FH27');
INSERT INTO actype VALUES ('F28', 'F28', 'F28MK2');
INSERT INTO actype VALUES ('F2PH', 'UKN', 'FAL20A');
INSERT INTO actype VALUES ('F2TH', 'F2TH', 'FAL20A');
INSERT INTO actype VALUES ('F33', 'UKN', 'BEC33');
INSERT INTO actype VALUES ('F33A', 'F33A', 'BEC33');
INSERT INTO actype VALUES ('F5', 'UKN', 'F5E');
INSERT INTO actype VALUES ('F50', 'FA50', 'LEAR35');
INSERT INTO actype VALUES ('F8L', 'UKN', NULL);
INSERT INTO actype VALUES ('F90', 'F900', 'LEAR35');
INSERT INTO actype VALUES ('F900', 'F900', 'LEAR35');
INSERT INTO actype VALUES ('FA10', 'DA10', 'FAL10');
INSERT INTO actype VALUES ('FA20', 'FA20', 'FAL200');
INSERT INTO actype VALUES ('FA2T', 'UKN', 'FAL20A');
INSERT INTO actype VALUES ('FA32', 'P32R', NULL);
INSERT INTO actype VALUES ('FA50', 'FA50', 'LEAR35');
INSERT INTO actype VALUES ('FA5O', 'FA50', 'LEAR35');
INSERT INTO actype VALUES ('FA90', 'F900', 'LEAR35');
INSERT INTO actype VALUES ('FCM', 'UKN', 'GASEPV');
INSERT INTO actype VALUES ('FDCT', 'CTSW', 'CNA152');
INSERT INTO actype VALUES ('FFF', 'UKN', NULL);
INSERT INTO actype VALUES ('FOTO', 'UKN', NULL);
INSERT INTO actype VALUES ('FTCD', 'CTSW', 'CNA152');
INSERT INTO actype VALUES ('FZ50', 'FA50', 'LEAR35');
INSERT INTO actype VALUES ('G111', 'UKN', 'GULF3');
INSERT INTO actype VALUES ('G115', 'G115', 'BIIB');
INSERT INTO actype VALUES ('G150', 'G150', 'GULF1');
INSERT INTO actype VALUES ('G164', 'G164', 'G164AG');
INSERT INTO actype VALUES ('G2', 'G159', 'GULF2');
INSERT INTO actype VALUES ('G2T1', 'G2T1', 'PA30');
INSERT INTO actype VALUES ('G3', 'GLF3', 'GULF3');
INSERT INTO actype VALUES ('G35', 'BE35', 'BEC33');
INSERT INTO actype VALUES ('G4', 'GLF4', 'GIV');
INSERT INTO actype VALUES ('G5', 'GLF5', 'GV');
INSERT INTO actype VALUES ('G550', 'GLF5', 'GV');
INSERT INTO actype VALUES ('G58', 'BE58', 'BEC58');
INSERT INTO actype VALUES ('GA7', 'GA7', 'GA7');
INSERT INTO actype VALUES ('GA8', 'UKN', 'CNA206');
INSERT INTO actype VALUES ('GALX', 'GALX', 'GII');
INSERT INTO actype VALUES ('GC1', 'GC1', 'CNA172');
INSERT INTO actype VALUES ('GC1B', 'GC1B', 'CNA172');
INSERT INTO actype VALUES ('GETT', 'UKN', NULL);
INSERT INTO actype VALUES ('GL5', 'GLF5', 'GV');
INSERT INTO actype VALUES ('GL5T', 'GL5T', 'GV');
INSERT INTO actype VALUES ('GLAS', 'GLAS', 'GASEPV');
INSERT INTO actype VALUES ('GLEX', 'GL5T', 'GII');
INSERT INTO actype VALUES ('GLF', 'GLF5', 'GV');
INSERT INTO actype VALUES ('GLF2', 'GLF2', 'GULF2');
INSERT INTO actype VALUES ('GLF3', 'GLF3', 'GULF3');
INSERT INTO actype VALUES ('GLF4', 'GLF4', 'GIV');
INSERT INTO actype VALUES ('GLF5', 'GLF5', 'GV');
INSERT INTO actype VALUES ('GLS2', 'UKN', 'GII');
INSERT INTO actype VALUES ('GLST', 'GLST', 'GASEPV');
INSERT INTO actype VALUES ('GOV1', 'GOV1', 'OV1');
INSERT INTO actype VALUES ('GR8', 'UKN', 'CNA206');
INSERT INTO actype VALUES ('GR85', 'AA5', NULL);
INSERT INTO actype VALUES ('GUF4', 'GLF4', 'GIV');
INSERT INTO actype VALUES ('GULF', 'GLF4', 'GIV');
INSERT INTO actype VALUES ('GVB', 'C208', 'CNA208');
INSERT INTO actype VALUES ('GYL', 'PA28', 'PA28CH');
INSERT INTO actype VALUES ('H206', 'B06', 'B206L');
INSERT INTO actype VALUES ('H230', 'H269', 'H500D');
INSERT INTO actype VALUES ('H25', 'H25B', 'HS125');
INSERT INTO actype VALUES ('H25A', 'H25B', 'HS125');
INSERT INTO actype VALUES ('H25B', 'H25B', 'HS125');
INSERT INTO actype VALUES ('H25C', 'H25B', 'HS125');
INSERT INTO actype VALUES ('H26', 'H269', 'H500D');
INSERT INTO actype VALUES ('H269', 'H269', 'H500D');
INSERT INTO actype VALUES ('H47', 'HELO', NULL);
INSERT INTO actype VALUES ('H500', 'H500', NULL);
INSERT INTO actype VALUES ('H58', 'BE58', NULL);
INSERT INTO actype VALUES ('H60', 'UKN', 'S70');
INSERT INTO actype VALUES ('H69G', 'UKN', NULL);
INSERT INTO actype VALUES ('HA1B', 'HA1B', NULL);
INSERT INTO actype VALUES ('HBX', 'UKN', NULL);
INSERT INTO actype VALUES ('HBXG', 'UKN', NULL);
INSERT INTO actype VALUES ('HCB', 'EXPR', 'GASEPV');
INSERT INTO actype VALUES ('HCB2', 'PA46', 'PA46');
INSERT INTO actype VALUES ('HEL', 'HELO', NULL);
INSERT INTO actype VALUES ('HEL0', 'HELO', NULL);
INSERT INTO actype VALUES ('HELI', 'HELO', NULL);
INSERT INTO actype VALUES ('HELO', 'HELO', NULL);
INSERT INTO actype VALUES ('HH60', 'UKN', 'S70');
INSERT INTO actype VALUES ('HODS', 'UKN', NULL);
INSERT INTO actype VALUES ('HS25', 'H25B', 'HS125');
INSERT INTO actype VALUES ('HSK', 'HSKY', 'GASEPF');
INSERT INTO actype VALUES ('HSKY', 'HSKY', 'GASEPF');
INSERT INTO actype VALUES ('HU1B', 'HU1B', NULL);
INSERT INTO actype VALUES ('HU30', 'H269', 'H500D');
INSERT INTO actype VALUES ('HUF', 'HSKY', NULL);
INSERT INTO actype VALUES ('HUKY', 'HSKY', 'GASEPF');
INSERT INTO actype VALUES ('HUSK', 'HSKY', 'GASEPF');
INSERT INTO actype VALUES ('HXA', 'UKN', 'GASEPV');
INSERT INTO actype VALUES ('HXB', 'EXPR', 'GASEPV');
INSERT INTO actype VALUES ('HXB1', 'UKN', 'GASEPV');
INSERT INTO actype VALUES ('HXC', 'UKN', 'GASEPV');
INSERT INTO actype VALUES ('HXP', 'UKN', 'GASEPV');
INSERT INTO actype VALUES ('IE60', 'BE60', 'BEC60');
INSERT INTO actype VALUES ('IOUS', 'UKN', NULL);
INSERT INTO actype VALUES ('J328', 'J328', 'DO328');
INSERT INTO actype VALUES ('JAB4', 'JAB4', NULL);
INSERT INTO actype VALUES ('JABI', 'UKN', NULL);
INSERT INTO actype VALUES ('JCOM', 'JCOM', NULL);
INSERT INTO actype VALUES ('JETS', 'UKN', NULL);
INSERT INTO actype VALUES ('JS41', 'JS41', 'BAEJ41');
INSERT INTO actype VALUES ('K35', 'UKN', 'KC135');
INSERT INTO actype VALUES ('K35R', 'UKN', 'KC135');
INSERT INTO actype VALUES ('KA28', 'UKN', NULL);
INSERT INTO actype VALUES ('KELO', 'H269', 'H500D');
INSERT INTO actype VALUES ('L101', 'L101', 'L1011');
INSERT INTO actype VALUES ('L18', 'DG15', 'CNA172');
INSERT INTO actype VALUES ('L222', 'UKN', NULL);
INSERT INTO actype VALUES ('L29', 'UKN', NULL);
INSERT INTO actype VALUES ('L35', 'LJ35', 'LEAR35');
INSERT INTO actype VALUES ('L37', 'UKN', 'GASEPV');
INSERT INTO actype VALUES ('L39', 'UKN', NULL);
INSERT INTO actype VALUES ('L8', 'L8', 'GASEPF');
INSERT INTO actype VALUES ('LA25', 'LA25', NULL);
INSERT INTO actype VALUES ('LA4', 'LA4', 'LA42');
INSERT INTO actype VALUES ('LA42', 'LA42', 'LA42');
INSERT INTO actype VALUES ('LAC4', 'LNC4', 'CNA206');
INSERT INTO actype VALUES ('LAIR', 'COL', 'GASEPV');
INSERT INTO actype VALUES ('LAN', 'LAN', 'GASEPV');
INSERT INTO actype VALUES ('LAN4', 'LNC4', 'CNA206');
INSERT INTO actype VALUES ('LANC', 'LANC', 'GASEPV');
INSERT INTO actype VALUES ('LANCAIR', 'COL', 'GASEPV');
INSERT INTO actype VALUES ('LATR', 'UKN', 'ATR42');
INSERT INTO actype VALUES ('LC30', 'COL3', 'GASEPV');
INSERT INTO actype VALUES ('LC4', 'LNC4', 'CNA206');
INSERT INTO actype VALUES ('LC40', 'LANC', 'GASEPV');
INSERT INTO actype VALUES ('LC41', 'LNC4', 'CNA206');
INSERT INTO actype VALUES ('LC42', 'LNC4', 'CNA206');
INSERT INTO actype VALUES ('LCN4', 'LNC4', NULL);
INSERT INTO actype VALUES ('LGEZ', 'EXPR', 'GASEPV');
INSERT INTO actype VALUES ('LINE', 'UKN', NULL);
INSERT INTO actype VALUES ('LJ24', 'LJ24', 'LEAR24');
INSERT INTO actype VALUES ('LJ25', 'LJ25', 'LEAR25');
INSERT INTO actype VALUES ('LJ28', 'LJ28', 'LEAR25');
INSERT INTO actype VALUES ('LJ29', 'LJ29', 'LEAR25');
INSERT INTO actype VALUES ('LJ31', 'LJ31', 'LEAR31');
INSERT INTO actype VALUES ('LJ35', 'LJ35', 'LEAR35');
INSERT INTO actype VALUES ('LJ36', 'LJ36', 'LEAR36');
INSERT INTO actype VALUES ('LJ40', 'LR45', 'LEAR45');
INSERT INTO actype VALUES ('LJ45', 'LR45', 'LEAR45');
INSERT INTO actype VALUES ('LJ55', 'LJ55', 'LEAR55');
INSERT INTO actype VALUES ('LJ60', 'LR60', 'LEAR60');
INSERT INTO actype VALUES ('LMC4', 'LNC4', 'CNA206');
INSERT INTO actype VALUES ('LN34', 'LANC', 'GASEPV');
INSERT INTO actype VALUES ('LN4', 'LNC4', 'CNA206');
INSERT INTO actype VALUES ('LNC', 'LANC', 'GASEPV');
INSERT INTO actype VALUES ('LNC2', 'COL', 'GASEPV');
INSERT INTO actype VALUES ('LNC4', 'LNC4', 'CNA206');
INSERT INTO actype VALUES ('LNC5', 'LNC4', 'CNA206');
INSERT INTO actype VALUES ('LNCE', 'LANC', 'GASEPV');
INSERT INTO actype VALUES ('LNS2', 'LNS2', 'GASEPV');
INSERT INTO actype VALUES ('LNS4', 'LNC4', 'CNA206');
INSERT INTO actype VALUES ('LR24', 'LJ24', 'LEAR24');
INSERT INTO actype VALUES ('LR25', 'LJ25', 'LEAR25');
INSERT INTO actype VALUES ('LR31', 'LR31', 'LEAR31');
INSERT INTO actype VALUES ('LR35', 'LJ35', 'LEAR35');
INSERT INTO actype VALUES ('LR45', 'LR45', 'LEAR45');
INSERT INTO actype VALUES ('LR55', 'LJ55', 'LEAR55');
INSERT INTO actype VALUES ('LR60', 'LR60', 'LEAR60');
INSERT INTO actype VALUES ('LR65', 'LJ35', 'LEAR35');
INSERT INTO actype VALUES ('M020', 'MO20', 'M20J');
INSERT INTO actype VALUES ('M021', 'MO20', 'M20J');
INSERT INTO actype VALUES ('M02K', 'M20K', 'M20J');
INSERT INTO actype VALUES ('M20', 'MO20', 'M20J');
INSERT INTO actype VALUES ('M200', 'MO20', 'M20J');
INSERT INTO actype VALUES ('M201', 'MO20', NULL);
INSERT INTO actype VALUES ('M20A', 'M20A', 'M20J');
INSERT INTO actype VALUES ('M20B', 'MO20', 'M20J');
INSERT INTO actype VALUES ('M20C', 'M20C', 'M20J');
INSERT INTO actype VALUES ('M20E', 'M20E', 'M20J');
INSERT INTO actype VALUES ('M20F', 'M20F', 'M20J');
INSERT INTO actype VALUES ('M20G', 'M20G', 'M20J');
INSERT INTO actype VALUES ('M20J', 'M20J', 'M20J');
INSERT INTO actype VALUES ('M20K', 'M20K', 'M20J');
INSERT INTO actype VALUES ('M20L', 'M20L', 'M20J');
INSERT INTO actype VALUES ('M20M', 'M20M', 'M20J');
INSERT INTO actype VALUES ('M20P', 'M20P', 'M20J');
INSERT INTO actype VALUES ('M20R', 'M20R', 'M20J');
INSERT INTO actype VALUES ('M20S', 'M20S', 'M20J');
INSERT INTO actype VALUES ('M20T', 'M20T', 'M20J');
INSERT INTO actype VALUES ('M21', 'MO20', 'M20J');
INSERT INTO actype VALUES ('M21P', 'M20P', NULL);
INSERT INTO actype VALUES ('M28R', 'M20R', 'M20J');
INSERT INTO actype VALUES ('M29P', 'M20R', 'M20J');
INSERT INTO actype VALUES ('M2OP', 'M20P', 'M20J');
INSERT INTO actype VALUES ('M2OS', 'M20S', 'M20J');
INSERT INTO actype VALUES ('M2OT', 'M20T', 'M20J');
INSERT INTO actype VALUES ('M2P', 'M20P', 'M20J');
INSERT INTO actype VALUES ('M32S', 'UKN', NULL);
INSERT INTO actype VALUES ('M35', 'BE35', 'BEC33');
INSERT INTO actype VALUES ('M6', 'MAUL', 'GASEPV');
INSERT INTO actype VALUES ('M7', 'MAUL', 'GASEPV');
INSERT INTO actype VALUES ('MA07', 'MAUL', 'GASEPV');
INSERT INTO actype VALUES ('MALL', 'MAUL', 'GASEPV');
INSERT INTO actype VALUES ('MARO', 'UKN', 'PA60');
INSERT INTO actype VALUES ('MAUL', 'MAUL', 'GASEPV');
INSERT INTO actype VALUES ('MD10', 'DC10', 'DC1010');
INSERT INTO actype VALUES ('MD11', 'MD11', 'MD11GE');
INSERT INTO actype VALUES ('MD80', 'MD80', 'MD81');
INSERT INTO actype VALUES ('MD81', 'MD80', 'MD81');
INSERT INTO actype VALUES ('MD82', 'MD80', 'MD81');
INSERT INTO actype VALUES ('MD83', 'MD80', 'MD81');
INSERT INTO actype VALUES ('MD87', 'MD80', 'MD81');
INSERT INTO actype VALUES ('MD88', 'MD80', 'MD81');
INSERT INTO actype VALUES ('MD90', 'MD90', 'MD9025');
INSERT INTO actype VALUES ('ME', 'UKN', NULL);
INSERT INTO actype VALUES ('MEEE', 'UKN', NULL);
INSERT INTO actype VALUES ('ML4', 'MAUL', 'GASEPV');
INSERT INTO actype VALUES ('ML5', 'MAUL', 'GASEPV');
INSERT INTO actype VALUES ('ML6', 'MAUL', NULL);
INSERT INTO actype VALUES ('ML7', 'MAUL', 'GASEPV');
INSERT INTO actype VALUES ('MO2', 'MO20', 'M20J');
INSERT INTO actype VALUES ('MO20', 'MO20', 'M20J');
INSERT INTO actype VALUES ('MO21', 'MO20', 'M20J');
INSERT INTO actype VALUES ('MO28', 'M20K', 'M20J');
INSERT INTO actype VALUES ('MO2J', 'MO20', 'M20J');
INSERT INTO actype VALUES ('MO2P', 'M20P', 'M20J');
INSERT INTO actype VALUES ('MO2T', 'M20T', 'M20J');
INSERT INTO actype VALUES ('MS76', 'MS76', 'GASEPV');
INSERT INTO actype VALUES ('MU2', 'MU2', 'MU2');
INSERT INTO actype VALUES ('MU20', 'MO20', 'GASEPF');
INSERT INTO actype VALUES ('MU3', 'MU30', 'MU300');
INSERT INTO actype VALUES ('MU30', 'MU30', 'MU300');
INSERT INTO actype VALUES ('MU3Q', 'MU30', 'MU300');
INSERT INTO actype VALUES ('MUSK', 'BE23', NULL);
INSERT INTO actype VALUES ('MUST', 'P51', 'GASEPV');
INSERT INTO actype VALUES ('N262', 'N262', 'FK27');
INSERT INTO actype VALUES ('N425', 'C425', 'CNA425');
INSERT INTO actype VALUES ('NA1', 'NAVI', 'PA24');
INSERT INTO actype VALUES ('NA18', 'NAVI', 'PA24');
INSERT INTO actype VALUES ('NA20', 'BE35', 'BEC33');
INSERT INTO actype VALUES ('NA28', 'T28', 'T6');
INSERT INTO actype VALUES ('NA3', 'NAVI', 'PA24');
INSERT INTO actype VALUES ('NA51', 'P51', 'GASEPV');
INSERT INTO actype VALUES ('NAV', 'NAVI', 'PA24');
INSERT INTO actype VALUES ('NAV1', 'NAVR', 'PA24');
INSERT INTO actype VALUES ('NAVI', 'NAVR', 'PA24');
INSERT INTO actype VALUES ('NC4', 'LNC4', 'CNA206');
INSERT INTO actype VALUES ('OH58', 'P68', 'GASEPV');
INSERT INTO actype VALUES ('OTT', 'UKN', NULL);
INSERT INTO actype VALUES ('P168', 'P68', 'GASEPV');
INSERT INTO actype VALUES ('P180', 'P180', 'CNA208');
INSERT INTO actype VALUES ('P200', 'P200', NULL);
INSERT INTO actype VALUES ('P206', 'C206', 'CNA206');
INSERT INTO actype VALUES ('P210', 'P210', 'CNA210');
INSERT INTO actype VALUES ('P21O', 'C210', 'CNA210');
INSERT INTO actype VALUES ('P23', 'PA23', 'PA23AP');
INSERT INTO actype VALUES ('P26R', 'PA28', 'PA28CH');
INSERT INTO actype VALUES ('P28', 'PA28', 'PA28CH');
INSERT INTO actype VALUES ('P284', 'P284', 'PA28CA');
INSERT INTO actype VALUES ('P28A', 'P28A', 'PA28WA');
INSERT INTO actype VALUES ('P28B', 'P28B', 'PA28DK');
INSERT INTO actype VALUES ('P28C', 'PA28', 'PA28CH');
INSERT INTO actype VALUES ('P28P', 'PA28', NULL);
INSERT INTO actype VALUES ('P28R', 'PARO', 'PA28CA');
INSERT INTO actype VALUES ('P28T', 'PARO', 'PA28CA');
INSERT INTO actype VALUES ('P3', 'UKN', 'P3A');
INSERT INTO actype VALUES ('P31', 'PA31', 'PA31');
INSERT INTO actype VALUES ('P31A', 'PA31', 'PA31');
INSERT INTO actype VALUES ('P32', 'P32R', 'PA32LA');
INSERT INTO actype VALUES ('P32A', 'PA32', 'PA32C6');
INSERT INTO actype VALUES ('P32R', 'P32R', 'PA32LA');
INSERT INTO actype VALUES ('P32T', 'P32R', 'PA32LA');
INSERT INTO actype VALUES ('P337', 'C337', 'CNA337');
INSERT INTO actype VALUES ('P34', 'PA44', 'PA44');
INSERT INTO actype VALUES ('P34R', 'P32R', 'PA32LA');
INSERT INTO actype VALUES ('P34T', 'PASE', 'PA34');
INSERT INTO actype VALUES ('P35', 'BE35', 'BEC33');
INSERT INTO actype VALUES ('P36T', 'P36T', 'PA25');
INSERT INTO actype VALUES ('P38', 'P68', 'GASEPV');
INSERT INTO actype VALUES ('P3C', 'UKN', 'P3C');
INSERT INTO actype VALUES ('P416', 'PA46', 'PA46');
INSERT INTO actype VALUES ('P44', 'PA44', 'PA44');
INSERT INTO actype VALUES ('P44A', 'PA44', 'PA44');
INSERT INTO actype VALUES ('P46', 'PA46', 'PA46');
INSERT INTO actype VALUES ('P46A', 'PA46', 'PA46');
INSERT INTO actype VALUES ('P46P', 'PA46', 'PA46');
INSERT INTO actype VALUES ('P46T', 'P46T', 'PA46');
INSERT INTO actype VALUES ('P51', 'P51', 'GASEPV');
INSERT INTO actype VALUES ('P51B', 'P51', 'GASEPV');
INSERT INTO actype VALUES ('P51D', 'P51', 'GASEPV');
INSERT INTO actype VALUES ('P601', 'P68', 'GASEPV');
INSERT INTO actype VALUES ('P68', 'P68', 'GASEPV');
INSERT INTO actype VALUES ('P68N', 'P68', 'GASEPV');
INSERT INTO actype VALUES ('PA12', 'PC12', 'GASEPV');
INSERT INTO actype VALUES ('PA17', 'PA17', 'PA17');
INSERT INTO actype VALUES ('PA18', 'CUBS', 'PA18');
INSERT INTO actype VALUES ('PA20', 'PA20', 'PA22TR');
INSERT INTO actype VALUES ('PA21', 'PA20', 'PA22TR');
INSERT INTO actype VALUES ('PA22', 'PA22', 'PA22TR');
INSERT INTO actype VALUES ('PA23', 'PA23', 'PA23AP');
INSERT INTO actype VALUES ('PA24', 'PA24', 'PA24');
INSERT INTO actype VALUES ('PA25', 'PA25', 'PA25');
INSERT INTO actype VALUES ('PA27', 'PAZT', 'PA23AZ');
INSERT INTO actype VALUES ('PA28', 'PA28', 'PA28CH');
INSERT INTO actype VALUES ('PA30', 'PA30', 'PA30');
INSERT INTO actype VALUES ('PA31', 'PA31', 'PA31');
INSERT INTO actype VALUES ('PA32', 'PA32', 'PA32C6');
INSERT INTO actype VALUES ('PA32R', 'P32R', 'PA32LA');
INSERT INTO actype VALUES ('PA34', 'PASE', 'PA34');
INSERT INTO actype VALUES ('PA36', 'PA36', 'PA25');
INSERT INTO actype VALUES ('PA38', 'PA38', 'PA38');
INSERT INTO actype VALUES ('PA40', 'PA44', 'PA44');
INSERT INTO actype VALUES ('PA42', 'PA46', 'PA46');
INSERT INTO actype VALUES ('PA43', 'PASE', 'PA34');
INSERT INTO actype VALUES ('PA44', 'PA44', 'PA44');
INSERT INTO actype VALUES ('PA45', 'PA46', 'PA46');
INSERT INTO actype VALUES ('PA46', 'PA46', 'PA46');
INSERT INTO actype VALUES ('PA60', 'PA60', 'PA60');
INSERT INTO actype VALUES ('PA68', 'P68', 'GASEPV');
INSERT INTO actype VALUES ('PA81', 'CUBS', 'PA18');
INSERT INTO actype VALUES ('PAR0', 'PARO', 'PA28CA');
INSERT INTO actype VALUES ('PARO', 'PARO', 'PA28CA');
INSERT INTO actype VALUES ('PART', 'UKN', 'CNA172');
INSERT INTO actype VALUES ('PASE', 'PASE', 'PA34');
INSERT INTO actype VALUES ('PAY1', 'PAY2', 'PA31T');
INSERT INTO actype VALUES ('PAY2', 'PAY2', 'PA31T');
INSERT INTO actype VALUES ('PAY3', 'PAY3', 'PA42');
INSERT INTO actype VALUES ('PAY4', 'PAY4', 'PA31T');
INSERT INTO actype VALUES ('PAYE', 'PAYE', 'PA42');
INSERT INTO actype VALUES ('PAZT', 'PAZT', 'PA23AZ');
INSERT INTO actype VALUES ('PB28', 'PA28', 'PA28CH');
INSERT INTO actype VALUES ('PB7', 'TBM', 'GASEPV');
INSERT INTO actype VALUES ('PBM7', 'TBM7', 'GASEPV');
INSERT INTO actype VALUES ('PC12', 'PC12', 'GASEPV');
INSERT INTO actype VALUES ('PC6P', 'PC6P', 'GASEPV');
INSERT INTO actype VALUES ('PC6T', 'PC6T', 'GASEPV');
INSERT INTO actype VALUES ('PC95', 'UKN', NULL);
INSERT INTO actype VALUES ('PE19', 'BE19', 'BEC24');
INSERT INTO actype VALUES ('PHTO', 'UKN', NULL);
INSERT INTO actype VALUES ('PIP', 'C177', 'CNA177');
INSERT INTO actype VALUES ('PIPE', 'UKN', 'PA31');
INSERT INTO actype VALUES ('PITZ', 'PITZ', 'PITTS1');
INSERT INTO actype VALUES ('PL', 'UKN', NULL);
INSERT INTO actype VALUES ('PLTS', 'PC12', 'GASEPV');
INSERT INTO actype VALUES ('PN6', 'P68', 'GASEPV');
INSERT INTO actype VALUES ('PN68', 'P68', 'GASEPV');
INSERT INTO actype VALUES ('PN71', 'P68', 'GASEPV');
INSERT INTO actype VALUES ('PNAV', 'PA31', 'PA31');
INSERT INTO actype VALUES ('PP51', 'UKN', NULL);
INSERT INTO actype VALUES ('PP68', 'P68', NULL);
INSERT INTO actype VALUES ('PRE1', 'PRE1', 'CNA500');
INSERT INTO actype VALUES ('PRM1', 'PRM1', 'CNA500');
INSERT INTO actype VALUES ('PRMR', 'PRE1', 'CNA500');
INSERT INTO actype VALUES ('PT46', 'P46T', 'PA46');
INSERT INTO actype VALUES ('PTS1', 'PTS1', 'PITTS1');
INSERT INTO actype VALUES ('PUSH', 'PUSH', NULL);
INSERT INTO actype VALUES ('Q100', 'Q100', NULL);
INSERT INTO actype VALUES ('R080', 'UKN', NULL);
INSERT INTO actype VALUES ('R182', 'C182', 'CNA182');
INSERT INTO actype VALUES ('R22', 'R22', 'R22');
INSERT INTO actype VALUES ('R28A', 'UKN', NULL);
INSERT INTO actype VALUES ('R44', 'R44', 'R22');
INSERT INTO actype VALUES ('R44A', 'R44', 'R22');
INSERT INTO actype VALUES ('R44G', 'R44', 'R22');
INSERT INTO actype VALUES ('RA39', 'PRE1', 'CNA500');
INSERT INTO actype VALUES ('RALL', 'RALL', 'GASEPV');
INSERT INTO actype VALUES ('RANG', 'RANG', 'PA28');
INSERT INTO actype VALUES ('RC70', 'RC70', 'PA60/PA61');
INSERT INTO actype VALUES ('REMO', 'UKN', NULL);
INSERT INTO actype VALUES ('RH6', 'R44', 'R22');
INSERT INTO actype VALUES ('RJ85', 'RJ85', 'BAE146');
INSERT INTO actype VALUES ('RO80', 'UKN', NULL);
INSERT INTO actype VALUES ('RS22', 'SR22', 'GASEPF');
INSERT INTO actype VALUES ('RULE', 'R44', 'R22');
INSERT INTO actype VALUES ('RV', 'RV', 'GASEPF');
INSERT INTO actype VALUES ('RV10', 'RV10', 'GASEPF');
INSERT INTO actype VALUES ('RV4', 'RV4', 'GASEPF');
INSERT INTO actype VALUES ('RV6', 'RV6', 'GASEPF');
INSERT INTO actype VALUES ('RV6A', 'RV6', 'GASEPF');
INSERT INTO actype VALUES ('RV7', 'RV7A', 'GASEPF');
INSERT INTO actype VALUES ('RV7A', 'RV7A', 'GASEPF');
INSERT INTO actype VALUES ('RV8', 'RV8', 'GASEPF');
INSERT INTO actype VALUES ('RV8A', 'RV8', NULL);
INSERT INTO actype VALUES ('RV9', 'RV9', 'GASEPF');
INSERT INTO actype VALUES ('RV9A', 'RV9', 'GASEPF');
INSERT INTO actype VALUES ('S05R', 'SF20', 'SF260M');
INSERT INTO actype VALUES ('S108', 'S108', NULL);
INSERT INTO actype VALUES ('S205', 'SF20', 'SF260M');
INSERT INTO actype VALUES ('S22', 'SR22', 'GASEPF');
INSERT INTO actype VALUES ('S269', 'H269', 'H500D');
INSERT INTO actype VALUES ('S300', 'UKN', NULL);
INSERT INTO actype VALUES ('S330', 'EXP', NULL);
INSERT INTO actype VALUES ('S38', 'S38', NULL);
INSERT INTO actype VALUES ('S550', 'UKN', 'CNA550');
INSERT INTO actype VALUES ('SBR1', 'SBR1', 'SABR65');
INSERT INTO actype VALUES ('SBR2', 'SBR2', 'SABR75');
INSERT INTO actype VALUES ('SCUB', 'SCUB', 'GASEPF');
INSERT INTO actype VALUES ('SF20', 'SF20', 'SF260M');
INSERT INTO actype VALUES ('SF22', 'SR22', 'GASEPF');
INSERT INTO actype VALUES ('SF34', 'SF34', 'SF340');
INSERT INTO actype VALUES ('SH3', 'UKN', 'SD330');
INSERT INTO actype VALUES ('SH33', 'SH33', 'SD330');
INSERT INTO actype VALUES ('SH36', 'SH36', 'SD330');
INSERT INTO actype VALUES ('SHIP', 'UKN', 'SD330');
INSERT INTO actype VALUES ('SIRA', 'SIRA', 'CNA172');
INSERT INTO actype VALUES ('SK58', 'UKN', NULL);
INSERT INTO actype VALUES ('SK75', 'SK75', 'S76');
INSERT INTO actype VALUES ('SK76', 'SK76', 'S76');
INSERT INTO actype VALUES ('SR2', 'SR22', 'GASEPF');
INSERT INTO actype VALUES ('SR20', 'SR20', 'GASEPV');
INSERT INTO actype VALUES ('SR21', 'SR22', 'GASEPF');
INSERT INTO actype VALUES ('SR22', 'SR22', 'GASEPF');
INSERT INTO actype VALUES ('SR34', 'SF34', 'SF340');
INSERT INTO actype VALUES ('SRR', 'SR22', 'GASEPF');
INSERT INTO actype VALUES ('SRR2', 'SR22', 'GASEPF');
INSERT INTO actype VALUES ('SS2P', 'SS2P', 'RWCMTH');
INSERT INTO actype VALUES ('SSI', 'PA28', 'PA28CH');
INSERT INTO actype VALUES ('SSII', 'PA28', 'PA28CH');
INSERT INTO actype VALUES ('ST75', 'ST75', NULL);
INSERT INTO actype VALUES ('STAR', 'STAR', 'BEC20A');
INSERT INTO actype VALUES ('STIL', 'STIL', 'PA28');
INSERT INTO actype VALUES ('STP', 'UKN', NULL);
INSERT INTO actype VALUES ('SW2', 'SW2', 'SAMER2');
INSERT INTO actype VALUES ('SW3', 'SW3', 'SAMER3');
INSERT INTO actype VALUES ('SW4', 'SW4', 'SAMER4');
INSERT INTO actype VALUES ('SW5', 'UKN', NULL);
INSERT INTO actype VALUES ('T1', 'UKN', 'T1');
INSERT INTO actype VALUES ('T182', 'C182', 'CNA182');
INSERT INTO actype VALUES ('T206', 'C206', 'CNA206');
INSERT INTO actype VALUES ('T21', 'C210', NULL);
INSERT INTO actype VALUES ('T210', 'T210', 'CNA210');
INSERT INTO actype VALUES ('T28', 'T28', NULL);
INSERT INTO actype VALUES ('T30', 'T30', NULL);
INSERT INTO actype VALUES ('T303', 'T30', NULL);
INSERT INTO actype VALUES ('T310', 'T310', 'CNA310');
INSERT INTO actype VALUES ('T34', 'T34', 'T34');
INSERT INTO actype VALUES ('T34B', 'T34', 'T34');
INSERT INTO actype VALUES ('T34P', 'T34', 'T34');
INSERT INTO actype VALUES ('T34T', 'T34T', 'T34');
INSERT INTO actype VALUES ('T37', 'T37', 'T37B');
INSERT INTO actype VALUES ('T38', 'UKN', 'T38');
INSERT INTO actype VALUES ('T45', 'T45', NULL);
INSERT INTO actype VALUES ('T56X', 'C56X', 'CNA560');
INSERT INTO actype VALUES ('T6', 'T6', 'T38');
INSERT INTO actype VALUES ('TALK', 'UKN', NULL);
INSERT INTO actype VALUES ('TB10', 'TOBA', 'GASEPF');
INSERT INTO actype VALUES ('TB20', 'TB20', 'GASEPF');
INSERT INTO actype VALUES ('TB7', 'TBM7', 'GASEPV');
INSERT INTO actype VALUES ('TB70', 'TBM7', 'GASEPV');
INSERT INTO actype VALUES ('TBM', 'TBM', 'GASEPV');
INSERT INTO actype VALUES ('TBM2', 'TBM7', 'GASEPV');
INSERT INTO actype VALUES ('TBM7', 'TBM7', 'GASEPV');
INSERT INTO actype VALUES ('TBM8', 'TBM7', 'GASEPV');
INSERT INTO actype VALUES ('TBML', 'TBM7', 'GASEPV');
INSERT INTO actype VALUES ('TBN7', 'TBM7', 'GASEPV');
INSERT INTO actype VALUES ('TC12', 'UKN', 'CNA441');
INSERT INTO actype VALUES ('TEX2', 'UKN', 'U21');
INSERT INTO actype VALUES ('TMB7', 'TBM7', 'GASEPV');
INSERT INTO actype VALUES ('TNAV', 'TNAV', 'PA44');
INSERT INTO actype VALUES ('TOBA', 'TOBA', 'GASEPF');
INSERT INTO actype VALUES ('TRF', 'UKN', 'C130');
INSERT INTO actype VALUES ('TRF1', 'UKN', 'C130');
INSERT INTO actype VALUES ('TRIN', 'TRIN', 'GASEPF');
INSERT INTO actype VALUES ('TRN', 'TRIN', 'GASEPF');
INSERT INTO actype VALUES ('TSW4', 'UKN', 'SAMER4');
INSERT INTO actype VALUES ('TVM7', 'TBM7', 'GASEPV');
INSERT INTO actype VALUES ('UH01', 'UKN', 'B212');
INSERT INTO actype VALUES ('UH1', 'UKN', 'B212');
INSERT INTO actype VALUES ('UH44', 'UKN', NULL);
INSERT INTO actype VALUES ('UH60', 'UKN', 'S70');
INSERT INTO actype VALUES ('UH61', 'UKN', 'S70');
INSERT INTO actype VALUES ('V1', 'GOV1', NULL);
INSERT INTO actype VALUES ('V35', 'BE35', NULL);
INSERT INTO actype VALUES ('V35B', 'BE35', NULL);
INSERT INTO actype VALUES ('VC10', 'VC10', NULL);
INSERT INTO actype VALUES ('VELO', 'EXPR', NULL);
INSERT INTO actype VALUES ('VIOL', 'C152', NULL);
INSERT INTO actype VALUES ('VOTR', 'UKN', NULL);
INSERT INTO actype VALUES ('VR8', 'UKN', NULL);
INSERT INTO actype VALUES ('W300', 'UKN', NULL);
INSERT INTO actype VALUES ('WW23', 'WW23', 'IA1124');
INSERT INTO actype VALUES ('WW24', 'WW24', 'IA1124');
INSERT INTO actype VALUES ('X02S', 'X02S', NULL);
INSERT INTO actype VALUES ('X300', 'E400', NULL);
INSERT INTO actype VALUES ('X50A', 'X50A', 'R22');
INSERT INTO actype VALUES ('X58U', 'X58U', NULL);
INSERT INTO actype VALUES ('X701', 'P68', 'GASEPV');
INSERT INTO actype VALUES ('XB', 'LJ55', 'LEAR55');
INSERT INTO actype VALUES ('XTRA', 'EA23', 'CNA500');
INSERT INTO actype VALUES ('XXPR', 'EXPR', 'GASEPV');
INSERT INTO actype VALUES ('Y52', 'Y52', NULL);
INSERT INTO actype VALUES ('M5', 'MAUL', 'GASEPV');
INSERT INTO actype VALUES ('KODI', 'KODI', 'GASEPV');
INSERT INTO actype VALUES ('E55P', 'E55P', NULL);
INSERT INTO actype VALUES ('BD100', 'BD100', NULL);
INSERT INTO actype VALUES ('DF7X', 'DF7X', NULL);
INSERT INTO actype VALUES ('XXXX', 'UKN', NULL);
INSERT INTO actype VALUES ('B407', 'B407', NULL);
INSERT INTO actype VALUES ('ASTR', 'G100', 'IA1125');
INSERT INTO actype VALUES ('G200', 'G200', NULL);
INSERT INTO actype VALUES ('112L', 'UKN', '');
INSERT INTO actype VALUES ('12RS', 'UKN', '');
INSERT INTO actype VALUES ('1G2L', 'UKN', '');
INSERT INTO actype VALUES ('1G2R', 'UKN', '');
INSERT INTO actype VALUES ('1V35', 'UKN', '');
INSERT INTO actype VALUES ('30LM', 'UKN', '');
INSERT INTO actype VALUES ('30LN', 'UKN', '');
INSERT INTO actype VALUES ('30RN', 'UKN', '');
INSERT INTO actype VALUES ('360R', 'UKN', '');
INSERT INTO actype VALUES ('390L', 'UKN', '');
INSERT INTO actype VALUES ('912R', 'UKN', '');
INSERT INTO actype VALUES ('A10', 'UKN', '');
INSERT INTO actype VALUES ('A346', 'UKN', '');
INSERT INTO actype VALUES ('A6', 'UKN', '');
INSERT INTO actype VALUES ('A984', 'UKN', '');
INSERT INTO actype VALUES ('B380', 'UKN', '');
INSERT INTO actype VALUES ('BE320', 'UKN', '');
INSERT INTO actype VALUES ('BE70', 'UKN', '');
INSERT INTO actype VALUES ('BE8', 'UKN', '');
INSERT INTO actype VALUES ('BE88', 'UKN', '');
INSERT INTO actype VALUES ('C25C', 'UKN', '');
INSERT INTO actype VALUES ('C2A', 'UKN', '');
INSERT INTO actype VALUES ('C5', 'UKN', '');
INSERT INTO actype VALUES ('CF60', 'UKN', '');
INSERT INTO actype VALUES ('CN35', 'UKN', '');
INSERT INTO actype VALUES ('CR9', 'UKN', '');
INSERT INTO actype VALUES ('CVLT', 'UKN', '');
INSERT INTO actype VALUES ('D45X', 'UKN', '');
INSERT INTO actype VALUES ('D934', 'UKN', '');
INSERT INTO actype VALUES ('E300', 'UKN', '');
INSERT INTO actype VALUES ('E30R', 'UKN', '');
INSERT INTO actype VALUES ('E50P', 'UKN', '');
INSERT INTO actype VALUES ('E6', 'UKN', '');
INSERT INTO actype VALUES ('EA55', 'UKN', '');
INSERT INTO actype VALUES ('EA6B', 'UKN', '');
INSERT INTO actype VALUES ('EC45', 'UKN', '');
INSERT INTO actype VALUES ('EXRV', 'UKN', '');
INSERT INTO actype VALUES ('F16C', 'UKN', '');
INSERT INTO actype VALUES ('FA18', 'UKN', '');
INSERT INTO actype VALUES ('GLX5', 'UKN', '');
INSERT INTO actype VALUES ('H3', 'UKN', '');
INSERT INTO actype VALUES ('HB25', 'UKN', '');
INSERT INTO actype VALUES ('HE6', 'UKN', '');
INSERT INTO actype VALUES ('HK35', 'UKN', '');
INSERT INTO actype VALUES ('HPYO', 'UKN', '');
INSERT INTO actype VALUES ('I354', 'UKN', '');
INSERT INTO actype VALUES ('I356', 'UKN', '');
INSERT INTO actype VALUES ('I358', 'UKN', '');
INSERT INTO actype VALUES ('IP35', 'UKN', '');
INSERT INTO actype VALUES ('JS31', 'UKN', '');
INSERT INTO actype VALUES ('JS32', 'UKN', '');
INSERT INTO actype VALUES ('JSSS', 'UKN', '');
INSERT INTO actype VALUES ('L25', 'UKN', '');
INSERT INTO actype VALUES ('LAN1', 'UKN', '');
INSERT INTO actype VALUES ('LEG2', 'UKN', '');
INSERT INTO actype VALUES ('MB82', 'UKN', '');
INSERT INTO actype VALUES ('N753', 'UKN', '');
INSERT INTO actype VALUES ('P31T', 'UKN', '');
INSERT INTO actype VALUES ('PAT4', 'UKN', '');
INSERT INTO actype VALUES ('R722', 'UKN', '');
INSERT INTO actype VALUES ('RK4C', 'UKN', '');
INSERT INTO actype VALUES ('SF35', 'UKN', '');
INSERT INTO actype VALUES ('DC9A', 'DC9Q', '');
INSERT INTO actype VALUES ('E179', 'E170', '');
INSERT INTO actype VALUES ('C75O', 'C750', '');
INSERT INTO actype VALUES ('HAWK', 'H25B', '');
INSERT INTO actype VALUES ('G100', 'G100', NULL);
INSERT INTO actype VALUES ('B378', 'B738', '');
INSERT INTO actype VALUES ('B754', 'B757', '');
INSERT INTO actype VALUES ('B764', 'B767', '');
INSERT INTO actype VALUES ('B777', 'B777', '');
INSERT INTO actype VALUES ('B77L', 'B777', '');
INSERT INTO actype VALUES ('B272', 'B72Q', '');
INSERT INTO actype VALUES ('C13O', 'C130', '');
INSERT INTO actype VALUES ('CRJR', 'CRJ', '');
INSERT INTO actype VALUES ('CRJX', 'CRJ', '');
INSERT INTO actype VALUES ('AT43', 'ATR', '');
INSERT INTO actype VALUES ('B100', 'BE10', '');
INSERT INTO actype VALUES ('DH8', 'DH8', '');
INSERT INTO actype VALUES ('DH8A', 'DH8', '');
INSERT INTO actype VALUES ('DH8C', 'DH8', '');
INSERT INTO actype VALUES ('DH8D', 'DH8', '');
INSERT INTO actype VALUES ('E120', 'E120', '');
INSERT INTO actype VALUES ('B77W', 'B777', '');
INSERT INTO actype VALUES ('MD93', 'MD90', '');
INSERT INTO actype VALUES ('KC35', 'KC35', '');
INSERT INTO actype VALUES ('HA4T', 'HA4T', '');
INSERT INTO actype VALUES ('A124', 'A124', '');
INSERT INTO actype VALUES ('T33', 'T33', 'T33A');
INSERT INTO actype VALUES ('SI35', 'UKN', '');
INSERT INTO actype VALUES ('SJ30', 'UKN', '');
INSERT INTO actype VALUES ('SR25', 'UKN', '');
INSERT INTO actype VALUES ('STIN', 'UKN', '');
INSERT INTO actype VALUES ('T38C', 'UKN', '');
INSERT INTO actype VALUES ('V117', 'UKN', '');
INSERT INTO actype VALUES ('V12L', 'UKN', '');
INSERT INTO actype VALUES ('V17N', 'UKN', '');
INSERT INTO actype VALUES ('V235', 'UKN', '');
INSERT INTO actype VALUES ('V354', 'UKN', '');
INSERT INTO actype VALUES ('V358', 'UKN', '');
INSERT INTO actype VALUES ('V365', 'UKN', '');
INSERT INTO actype VALUES ('VH10', 'UKN', '');
INSERT INTO actype VALUES ('VL17', 'UKN', '');
INSERT INTO actype VALUES ('VLS3', 'UKN', '');
INSERT INTO actype VALUES ('VRJ2', 'UKN', '');
INSERT INTO actype VALUES ('VVL3', 'UKN', '');
INSERT INTO actype VALUES ('VVOO', 'UKN', '');
INSERT INTO actype VALUES ('VVR3', 'UKN', '');
INSERT INTO actype VALUES ('VW35', 'UKN', '');
INSERT INTO actype VALUES ('ZZZZ', 'UKN', '');
INSERT INTO actype VALUES ('B74S', 'B744', '747400');
INSERT INTO actype VALUES ('YI35', 'UKN', '"');
INSERT INTO actype VALUES ('F20', 'FAL2', 'FAL200');
INSERT INTO actype VALUES ('WW25', 'WW25', NULL);
INSERT INTO actype VALUES ('B7377', 'B7377', '737700');
INSERT INTO actype VALUES ('UNK', 'UKN', NULL);
INSERT INTO actype VALUES ('UKN', 'UKN', NULL);
INSERT INTO actype VALUES ('G500', 'GLF5', 'GV');
INSERT INTO actype VALUES ('J250', 'J250', NULL);
INSERT INTO actype VALUES ('P750', 'P750', NULL);
INSERT INTO actype VALUES ('CTLS', 'CTLS', NULL);
INSERT INTO actype VALUES ('SA20', 'FA20', NULL);
INSERT INTO actype VALUES ('B360', 'BE60', NULL);
INSERT INTO actype VALUES ('EP50', 'UKN', NULL);
INSERT INTO actype VALUES ('CJR9', 'CRJ', NULL);
INSERT INTO actype VALUES ('DC3T', 'DC3', NULL);
INSERT INTO actype VALUES ('SWF4', 'SW4', NULL);
INSERT INTO actype VALUES ('AT4', 'ATR', '');
INSERT INTO actype VALUES ('AT3', 'ATR', '');
INSERT INTO actype VALUES ('AT5', 'ATR', '');
INSERT INTO actype VALUES ('ATR', 'ATR', '');
INSERT INTO actype VALUES ('AT7', 'ATR', '');
INSERT INTO actype VALUES ('AB3', 'A300', '');
INSERT INTO actype VALUES ('ABX', 'A300', '');
INSERT INTO actype VALUES ('AB6', 'A300', '');
INSERT INTO actype VALUES ('312', 'A310', '');
INSERT INTO actype VALUES ('31X', 'A310', '');
INSERT INTO actype VALUES ('313', 'A310', '');
INSERT INTO actype VALUES ('31Y', 'A310', '');
INSERT INTO actype VALUES ('318', 'A318', '');
INSERT INTO actype VALUES ('319', 'A319', '');
INSERT INTO actype VALUES ('320', 'A320', '');
INSERT INTO actype VALUES ('321', 'A321', '');
INSERT INTO actype VALUES ('332', 'A330', '');
INSERT INTO actype VALUES ('333', 'A330', '');
INSERT INTO actype VALUES ('342', 'A340', '');
INSERT INTO actype VALUES ('343', 'A340', '');
INSERT INTO actype VALUES ('345', 'A340', '');
INSERT INTO actype VALUES ('346', 'A340', '');
INSERT INTO actype VALUES ('380', 'A380', '');
INSERT INTO actype VALUES ('B14', 'BA11', '');
INSERT INTO actype VALUES ('B15', 'BA11', '');
INSERT INTO actype VALUES ('J31', 'JS31', '');
INSERT INTO actype VALUES ('J32', 'JS31', '');
INSERT INTO actype VALUES ('J41', 'JS41', '');
INSERT INTO actype VALUES ('BE1', 'B190', '');
INSERT INTO actype VALUES ('BEH', 'B190', '');
INSERT INTO actype VALUES ('BNI', 'BN2P', '');
INSERT INTO actype VALUES ('BNT', 'BN2P', '');
INSERT INTO actype VALUES ('37F', 'B377', '');
INSERT INTO actype VALUES ('707', 'B707', '');
INSERT INTO actype VALUES ('703', 'B707', '');
INSERT INTO actype VALUES ('717', 'B717', '');
INSERT INTO actype VALUES ('B72', 'B720', '');
INSERT INTO actype VALUES ('721', 'B72Q', '');
INSERT INTO actype VALUES ('72F', 'B72Q', '');
INSERT INTO actype VALUES ('722', 'B72Q', '');
INSERT INTO actype VALUES ('732', 'B73Q', '');
INSERT INTO actype VALUES ('73X', 'B73Q', '');
INSERT INTO actype VALUES ('733', 'B733', '');
INSERT INTO actype VALUES ('73F', 'B733', '');
INSERT INTO actype VALUES ('734', 'B734', '');
INSERT INTO actype VALUES ('73P', 'B734', '');
INSERT INTO actype VALUES ('735', 'B735', '');
INSERT INTO actype VALUES ('736', 'B736', '');
INSERT INTO actype VALUES ('73G', 'B7377', '');
INSERT INTO actype VALUES ('738', 'B738', '');
INSERT INTO actype VALUES ('73H', 'B738', '');
INSERT INTO actype VALUES ('739', 'B739', '');
INSERT INTO actype VALUES ('73J', 'B739', '');
INSERT INTO actype VALUES ('741', 'B741', '');
INSERT INTO actype VALUES ('74T', 'B741', '');
INSERT INTO actype VALUES ('742', 'B742', '');
INSERT INTO actype VALUES ('74C', 'B742', '');
INSERT INTO actype VALUES ('74F', 'B742', '');
INSERT INTO actype VALUES ('743', 'B743', '');
INSERT INTO actype VALUES ('74D', 'B743', '');
INSERT INTO actype VALUES ('744', 'B744', '');
INSERT INTO actype VALUES ('74E', 'B744', '');
INSERT INTO actype VALUES ('74Y', 'B744', '');
INSERT INTO actype VALUES ('74L', 'B744', '');
INSERT INTO actype VALUES ('74R', 'B744', '');
INSERT INTO actype VALUES ('752', 'B757', '');
INSERT INTO actype VALUES ('75F', 'B757', '');
INSERT INTO actype VALUES ('753', 'B757', '');
INSERT INTO actype VALUES ('762', 'B767', '');
INSERT INTO actype VALUES ('76X', 'B767', '');
INSERT INTO actype VALUES ('763', 'B767', '');
INSERT INTO actype VALUES ('76Y', 'B767', '');
INSERT INTO actype VALUES ('764', 'B767', '');
INSERT INTO actype VALUES ('772', 'B777', '');
INSERT INTO actype VALUES ('77L', 'B777', '');
INSERT INTO actype VALUES ('773', 'B777', '');
INSERT INTO actype VALUES ('77W', 'B777', '');
INSERT INTO actype VALUES ('CR7', 'CRJ', '');
INSERT INTO actype VALUES ('CRK', 'CRJ', '');
INSERT INTO actype VALUES ('CRA', 'CRJ', '');
INSERT INTO actype VALUES ('ATP', 'ATP', '');
INSERT INTO actype VALUES ('141', 'B463', '');
INSERT INTO actype VALUES ('142', 'B463', '');
INSERT INTO actype VALUES ('143', 'B463', '');
INSERT INTO actype VALUES ('AR1', 'B463', '');
INSERT INTO actype VALUES ('AR7', 'B463', '');
INSERT INTO actype VALUES ('AR8', 'B463', '');
INSERT INTO actype VALUES ('CS2', 'C212', '');
INSERT INTO actype VALUES ('CS5', 'CN35', '');
INSERT INTO actype VALUES ('CNC', 'C208', '');
INSERT INTO actype VALUES ('CV4', 'CVLT', '');
INSERT INTO actype VALUES ('CVF', 'CVLT', '');
INSERT INTO actype VALUES ('CVT', 'CVLT', '');
INSERT INTO actype VALUES ('CV6', 'CVLT', '');
INSERT INTO actype VALUES ('CWC', 'CW46', '');
INSERT INTO actype VALUES ('DHH', 'DHC6', '');
INSERT INTO actype VALUES ('DHT', 'DHC6', '');
INSERT INTO actype VALUES ('DH7', 'DHC6', '');
INSERT INTO actype VALUES ('DH1', 'DHC6', '');
INSERT INTO actype VALUES ('DH3', 'DHC6', '');
INSERT INTO actype VALUES ('DH4', 'DHC6', '');
INSERT INTO actype VALUES ('FRJ', 'J328', '');
INSERT INTO actype VALUES ('DO8', 'D328', '');
INSERT INTO actype VALUES ('D28', 'D328', '');
INSERT INTO actype VALUES ('D38', 'D328', '');
INSERT INTO actype VALUES ('D11', 'DC10', '');
INSERT INTO actype VALUES ('D1X', 'DC10', '');
INSERT INTO actype VALUES ('D1C', 'DC10', '');
INSERT INTO actype VALUES ('D1M', 'DC10', '');
INSERT INTO actype VALUES ('D1Y', 'DC10', '');
INSERT INTO actype VALUES ('DC4', 'DC4', '');
INSERT INTO actype VALUES ('DC6', 'DC6', '');
INSERT INTO actype VALUES ('D6F', 'DC6', '');
INSERT INTO actype VALUES ('D8F', 'DC8Q', '');
INSERT INTO actype VALUES ('D8L', 'DC8Q', '');
INSERT INTO actype VALUES ('D8Y', 'DC8Q', '');
INSERT INTO actype VALUES ('D91', 'DC9Q', '');
INSERT INTO actype VALUES ('D9F', 'DC9Q', '');
INSERT INTO actype VALUES ('D92', 'DC9Q', '');
INSERT INTO actype VALUES ('D93', 'DC9Q', '');
INSERT INTO actype VALUES ('D94', 'DC9Q', '');
INSERT INTO actype VALUES ('D95', 'DC9Q', '');
INSERT INTO actype VALUES ('M11', 'MD11', '');
INSERT INTO actype VALUES ('M1M', 'MD11', '');
INSERT INTO actype VALUES ('M81', 'MD80', '');
INSERT INTO actype VALUES ('M82', 'MD80', '');
INSERT INTO actype VALUES ('M83', 'MD80', '');
INSERT INTO actype VALUES ('M87', 'MD80', '');
INSERT INTO actype VALUES ('M88', 'MD80', '');
INSERT INTO actype VALUES ('M90', 'MD90', '');
INSERT INTO actype VALUES ('E70', 'E170', '');
INSERT INTO actype VALUES ('E75', 'E170', '');
INSERT INTO actype VALUES ('E95', 'E190', '');
INSERT INTO actype VALUES ('EMB', 'E110', '');
INSERT INTO actype VALUES ('EM2', 'E120', '');
INSERT INTO actype VALUES ('ER3', 'E135', '');
INSERT INTO actype VALUES ('ERD', 'E135', '');
INSERT INTO actype VALUES ('FKF', 'F27', '');
INSERT INTO actype VALUES ('FK7', 'F27', '');
INSERT INTO actype VALUES ('100', 'F100', '');
INSERT INTO actype VALUES ('F70', 'F100', '');
INSERT INTO actype VALUES ('F21', 'F28', '');
INSERT INTO actype VALUES ('F22', 'F28', '');
INSERT INTO actype VALUES ('F23', 'F28', '');
INSERT INTO actype VALUES ('F24', 'F28', '');
INSERT INTO actype VALUES ('CD2', 'GAF', '');
INSERT INTO actype VALUES ('GRS', 'G159', '');
INSERT INTO actype VALUES ('HPJ', 'JS41', '');
INSERT INTO actype VALUES ('HS7', 'A748', '');
INSERT INTO actype VALUES ('RV1', 'IAIA', '');
INSERT INTO actype VALUES ('LOH', 'C130', '');
INSERT INTO actype VALUES ('L49', 'L49', '');
INSERT INTO actype VALUES ('L10', 'L101', '');
INSERT INTO actype VALUES ('L1F', 'L101', '');
INSERT INTO actype VALUES ('L15', 'L101', '');
INSERT INTO actype VALUES ('LOE', 'L188', '');
INSERT INTO actype VALUES ('LOF', 'L188', '');
INSERT INTO actype VALUES ('YS1', 'YS11', '');
INSERT INTO actype VALUES ('ND2', 'N262', '');
INSERT INTO actype VALUES ('PL2', 'PC6T', '');
INSERT INTO actype VALUES ('S20', 'SB20', '');
INSERT INTO actype VALUES ('SF3', 'SF34', '');
INSERT INTO actype VALUES ('SFF', 'SF34', '');
INSERT INTO actype VALUES ('SHB', 'SH5B', '');
INSERT INTO actype VALUES ('SHP', 'SH33', '');
INSERT INTO actype VALUES ('SHS', 'SH33', '');
INSERT INTO actype VALUES ('SH6', 'SH36', '');
INSERT INTO actype VALUES ('SU9', 'SSJ9', '');
INSERT INTO actype VALUES ('FSM', 'SW4', '');
INSERT INTO actype VALUES ('SWM', 'SW4', '');
INSERT INTO actype VALUES ('VF6', 'VFW6', '');
INSERT INTO actype VALUES ('VCX', 'VC10', '');
INSERT INTO actype VALUES ('ER4', 'E145', '');
INSERT INTO actype VALUES ('BD10', 'BD100', NULL);
INSERT INTO actype VALUES ('H800', 'HWK8', NULL);
INSERT INTO actype VALUES ('R400', 'UKN', NULL);
INSERT INTO actype VALUES ('767', 'B767', NULL);
INSERT INTO actype VALUES ('C450', 'C550', NULL);
INSERT INTO actype VALUES ('HWK8', 'HWK8', NULL);
INSERT INTO actype VALUES ('L29B', 'LJ29', NULL);
INSERT INTO actype VALUES ('170', 'C170', NULL);
INSERT INTO actype VALUES ('G450', 'GLF4', NULL);
INSERT INTO actype VALUES ('E50', 'EA50', NULL);
INSERT INTO actype VALUES ('CH2T', 'CH2T', NULL);
INSERT INTO actype VALUES ('BD70', 'BD700', NULL);
INSERT INTO actype VALUES ('KOBI', 'KODI', NULL);
INSERT INTO actype VALUES ('B23', 'BE23', NULL);
INSERT INTO actype VALUES ('HWK9', 'HWK9', NULL);
INSERT INTO actype VALUES ('AT72', 'ATR', NULL);
INSERT INTO actype VALUES ('C187', 'UKN', NULL);
INSERT INTO actype VALUES ('SA22', 'SW4', NULL);
INSERT INTO actype VALUES ('G109', 'G109', NULL);
INSERT INTO actype VALUES ('H900', 'HWK9', NULL);
INSERT INTO actype VALUES ('B748', 'B748', '747800');
INSERT INTO actype VALUES ('LP38', 'LP38', NULL);
INSERT INTO actype VALUES ('LZN7', 'LZN7', NULL);
INSERT INTO actype VALUES ('EA30', 'EA30', NULL);
INSERT INTO actype VALUES ('EC20', 'EC20', NULL);
INSERT INTO actype VALUES ('F200', 'F2TH', NULL);
INSERT INTO actype VALUES ('GLS5', 'UKN', NULL);
INSERT INTO actype VALUES ('FURY', 'UKN', NULL);
INSERT INTO actype VALUES ('CA6', 'UKN', NULL);
INSERT INTO actype VALUES ('M29T', 'M20M', 'M20J');
INSERT INTO actype VALUES ('BASS', 'BASS', '');
INSERT INTO actype VALUES ('LNP4', 'LNC4', NULL);
INSERT INTO actype VALUES ('XL2', 'LXL2', NULL);
INSERT INTO actype VALUES ('SABR', 'SBR1', NULL);
INSERT INTO actype VALUES ('BD20', 'BE20', NULL);
INSERT INTO actype VALUES ('CRJ8', 'CRJ', NULL);
INSERT INTO actype VALUES ('B73G', 'B7377', NULL);
INSERT INTO actype VALUES ('MD-11CR', 'MD11', NULL);
INSERT INTO actype VALUES ('P136', 'P136', NULL);
INSERT INTO actype VALUES ('FA7X', 'FA7X', '');
INSERT INTO actype VALUES ('C55', 'BE55', 'BEC55');
INSERT INTO actype VALUES ('CLF5', 'GLF5', 'GV');
INSERT INTO actype VALUES ('A100', 'BE10', NULL);


--
-- TOC entry 3359 (class 0 OID 128770)
-- Dependencies: 183
-- Data for Name: actype_airline_nnumber; Type: TABLE DATA; Schema: alias; Owner: postgres
--



--
-- TOC entry 3356 (class 0 OID 128673)
-- Dependencies: 169
-- Data for Name: airline_alias; Type: TABLE DATA; Schema: alias; Owner: postgres
--

INSERT INTO airline_alias VALUES ('9N', 'NSE', 'SATENA (Colombia)', 'SATENA (Colombia)');
INSERT INTO airline_alias VALUES ('9Q', 'PBA', 'PB Air (Thailand)', 'PB Air (Thailand)');
INSERT INTO airline_alias VALUES ('9R', 'VAP', 'Phuket Airlines (Thailand)', 'Phuket Airlines (Thailand)');
INSERT INTO airline_alias VALUES ('9S', 'SOO', 'Southern Air (USA)', 'Southern Air (USA)');
INSERT INTO airline_alias VALUES ('9T', 'ABS', 'Athabaska Airlines (Canada)', 'Athabaska Airlines (Canada)');
INSERT INTO airline_alias VALUES ('9U', 'MLD', 'Air Moldova', 'Air Moldova');
INSERT INTO airline_alias VALUES ('9V', 'ALS', 'Atlantis Airlines (Senegal)', 'Atlantis Airlines (Senegal)');
INSERT INTO airline_alias VALUES ('9V', 'ROI', 'Avior Express/Aviones del Oriente (Venezuela)', 'Avior Express/Aviones del Oriente (Venezuela)');
INSERT INTO airline_alias VALUES ('9W', 'JAI', 'Jet Airways (India)', 'Jet Airways (India)');
INSERT INTO airline_alias VALUES ('9X', 'ACL', 'Itali Airlines (Italy)', 'Itali Airlines (Italy)');
INSERT INTO airline_alias VALUES ('9Y', 'KZK', 'Air Kazakstan', 'Air Kazakstan');
INSERT INTO airline_alias VALUES ('AA', 'AAL', 'American Airlines (USA)', 'American');
INSERT INTO airline_alias VALUES ('AQ', 'AAH', 'Aloha Airlines (USA)', 'Aloha');
INSERT INTO airline_alias VALUES ('AS', 'ASA', 'Alaska Airlines (USA)', 'Alaska');
INSERT INTO airline_alias VALUES ('HP', 'AWE', 'America West Airlines (USA)', 'America West');
INSERT INTO airline_alias VALUES ('MG', 'CCP', 'Champion Air (USA)', 'Champion');
INSERT INTO airline_alias VALUES ('DL', 'DAL', 'Delta Air Lines (USA)', 'Delta');
INSERT INTO airline_alias VALUES ('ER', 'DHL', 'DHL Worldwide Express (Belgium)', 'DHL');
INSERT INTO airline_alias VALUES ('MQ', 'EGF', 'American Eagle (USA)', 'American Eagle');
INSERT INTO airline_alias VALUES ('FX', 'FDX', 'FedEx Express/Federal Express (USA)', 'FedEx');
INSERT INTO airline_alias VALUES ('9E', 'FLG', 'Northwest Airlink/Pinnacle Airlines (USA)', 'Pinnacle');
INSERT INTO airline_alias VALUES ('KR', 'KHA', 'Kitty Hawk Air Cargo (USA)', 'Kitty Hawk');
INSERT INTO airline_alias VALUES ('XJ', 'MES', 'Mesaba Airlines (USA)', 'Mesaba');
INSERT INTO airline_alias VALUES ('NW', 'NWA', 'Northwest Airlines (USA)', 'Northwest');
INSERT INTO airline_alias VALUES ('SY', 'SCX', 'Sun Country Airlines (USA)', 'Sun Country');
INSERT INTO airline_alias VALUES ('UA', 'UAL', 'United Airlines (USA)', 'United');
INSERT INTO airline_alias VALUES ('5X', 'UPS', 'United Parcel Service (USA)', 'UPS');
INSERT INTO airline_alias VALUES ('ZW', 'AWI', 'United Express/Air Wisconsin (USA)', 'Air Wisconsin');
INSERT INTO airline_alias VALUES ('YX', 'MEP', 'Midwest Airlines (USA)', 'Midwest Airlines');
INSERT INTO airline_alias VALUES ('PO', 'PAC', 'Polar Air Cargo (USA)', 'Polar Air Cargo');
INSERT INTO airline_alias VALUES ('PC', 'PCE', 'Pace Airlines/Piedmont Aviation (USA)', 'Pace Airlines/Piedmont Aviation');
INSERT INTO airline_alias VALUES ('QX', 'QXE', 'Horizon Air (USA)', 'Horizon Air');
INSERT INTO airline_alias VALUES ('OO', 'SKW', 'Delta Connection/United Express/Skywest Airlines (USA)', 'Skywest Airlines');
INSERT INTO airline_alias VALUES ('S5', 'TCF', 'US Airways Express/Shuttle America (USA)', 'Shuttle America');
INSERT INTO airline_alias VALUES ('EV', 'ASQ', 'Atlantic Southeast Airlines (USA)', 'Atlantic Southeast Airlines');
INSERT INTO airline_alias VALUES ('EV', 'ACY', 'Atlantic Southeast Airlines (USA)', 'Atlantic Southeast Airlines');
INSERT INTO airline_alias VALUES ('WO', 'WOA', 'World Airways (USA)', 'World Airways');
INSERT INTO airline_alias VALUES ('FL', 'TRS', 'Airtran (USA)', 'Airtran');
INSERT INTO airline_alias VALUES ('SO', 'HKA', 'Superior Aviation (USA)', 'Superior Aviation');
INSERT INTO airline_alias VALUES ('6K', 'RIT', 'Asian Spirit (Philippines)', 'Asian Spirit (Philippines)');
INSERT INTO airline_alias VALUES ('6L', 'AKK', 'Aklak Air (Canada)', 'Aklak Air (Canada)');
INSERT INTO airline_alias VALUES ('6M', 'EUP', 'Euroair (Greece)', 'Euroair (Greece)');
INSERT INTO airline_alias VALUES ('6M', 'MJC', 'Majestic Air (Zimbabwe)', 'Majestic Air (Zimbabwe)');
INSERT INTO airline_alias VALUES ('6N', 'NRD', 'Nordic Regional (Sweden)', 'Nordic Regional (Sweden)');
INSERT INTO airline_alias VALUES ('6N', 'TRQ', 'Trans Travel Airlines (Netherlands)', 'Trans Travel Airlines (Netherlands)');
INSERT INTO airline_alias VALUES ('6P', 'ISG', 'Clubair Sixgo (Italy)', 'Clubair Sixgo (Italy)');
INSERT INTO airline_alias VALUES ('6R', 'TNO', 'Aerotransporte de Carga Union (Mexico)', 'Aerotransporte de Carga Union (Mexico)');
INSERT INTO airline_alias VALUES ('6S', 'KAT', 'Kato Air (Norway)', 'Kato Air (Norway)');
INSERT INTO airline_alias VALUES ('6T', 'LMT', 'Almaty Aviation (Kazakhstan)', 'Almaty Aviation (Kazakhstan)');
INSERT INTO airline_alias VALUES ('6U', 'UKR', 'Air Ukraine', 'Air Ukraine');
INSERT INTO airline_alias VALUES ('6V', 'AXY', 'Axis Airways (France)', 'Axis Airways (France)');
INSERT INTO airline_alias VALUES ('6V', 'VGA', 'Air Vegas (USA)', 'Air Vegas (USA)');
INSERT INTO airline_alias VALUES ('6W', 'SOV', 'Saravia Saratov Airlines (Russian Federation)', 'Saravia Saratov Airlines (Russian Federation)');
INSERT INTO airline_alias VALUES ('6Y', 'LTC', 'Latcharter (Latvia)', 'Latcharter (Latvia)');
INSERT INTO airline_alias VALUES ('6Z', 'PNV', 'Panavia (Panama)', 'Panavia (Panama)');
INSERT INTO airline_alias VALUES ('6Z', 'UKS', 'Ukrainian Cargo Airways', 'Ukrainian Cargo Airways');
INSERT INTO airline_alias VALUES ('7A', 'AFF', 'Afric''Air Charter (Benin)', 'Afric''Air Charter (Benin)');
INSERT INTO airline_alias VALUES ('7B', 'KJC', 'Kras Air/Krasnojarsky Airlines (Russian Federation)', 'Kras Air/Krasnojarsky Airlines (Russian Federation)');
INSERT INTO airline_alias VALUES ('7C', 'COY', 'Coyne Airways (UK)', 'Coyne Airways (UK)');
INSERT INTO airline_alias VALUES ('7D', 'UDC', 'Utility Enterprise DonbassAero Airline (Ukraine)', 'Utility Enterprise DonbassAero Airline (Ukraine)');
INSERT INTO airline_alias VALUES ('7E', 'AWU', 'Aeroline (Germany)', 'Aeroline (Germany)');
INSERT INTO airline_alias VALUES ('7F', 'FAB', 'First Air (Canada)', 'First Air (Canada)');
INSERT INTO airline_alias VALUES ('7G', 'MKA', 'MK Airlines (UK)', 'MK Airlines (UK)');
INSERT INTO airline_alias VALUES ('7H', 'ERH', 'ERA Aviation (USA)', 'ERA Aviation (USA)');
INSERT INTO airline_alias VALUES ('7I', 'CSV', 'Coastal Travel Limited (United Rep. of Tanzania)', 'Coastal Travel Limited (United Rep. of Tanzania)');
INSERT INTO airline_alias VALUES ('7J', 'TJK', 'Tajik Air (Tajikistan)', 'Tajik Air (Tajikistan)');
INSERT INTO airline_alias VALUES ('7K', 'KGL', 'Kolavia (Russian Federation)', 'Kolavia (Russian Federation)');
INSERT INTO airline_alias VALUES ('7L', 'CRN', 'Aerocaribbean (Cuba)', 'Aerocaribbean (Cuba)');
INSERT INTO airline_alias VALUES ('7L', 'ERO', 'Sun d''Or International Airlines (Israel)', 'Sun d''Or International Airlines (Israel)');
INSERT INTO airline_alias VALUES ('TP', 'TAP', 'TAP Air Portugal', 'TAP Air Portugal');
INSERT INTO airline_alias VALUES ('7M', 'TYM', 'Tyumen Airlines (Russian Federation)', 'Tyumen Airlines (Russian Federation)');
INSERT INTO airline_alias VALUES ('7P', 'BTV', 'Metro Batavia (Indonesia)', 'Metro Batavia (Indonesia)');
INSERT INTO airline_alias VALUES ('7Q', 'TLR', 'Tibesti Air Libya', 'Tibesti Air Libya');
INSERT INTO airline_alias VALUES ('7Q', 'VZA', 'Air Venezuela', 'Air Venezuela');
INSERT INTO airline_alias VALUES ('7S', 'RYA', 'Arctic Transportation Services (USA)', 'Arctic Transportation Services (USA)');
INSERT INTO airline_alias VALUES ('7T', 'AGV', 'Air-Glaciers (Switzerland)', 'Air-Glaciers (Switzerland)');
INSERT INTO airline_alias VALUES ('7T', 'RTM', 'Aero Express Del Ecuador', 'Aero Express Del Ecuador');
INSERT INTO airline_alias VALUES ('7U', 'ERG', 'Avianergo (Russian Federation)', 'Avianergo (Russian Federation)');
INSERT INTO airline_alias VALUES ('7V', 'PDF', 'Pelican Air Services (South Africa)', 'Pelican Air Services (South Africa)');
INSERT INTO airline_alias VALUES ('7Y', 'NYL', 'Mid Airlines (Sudan)', 'Mid Airlines (Sudan)');
INSERT INTO airline_alias VALUES ('7Z', 'LBH', 'Laker Airways Bahamas/L.B. Limited (USA)', 'Laker Airways Bahamas/L.B. Limited (USA)');
INSERT INTO airline_alias VALUES ('8A', 'AKR', 'Arctic Air (Norway)', 'Arctic Air (Norway)');
INSERT INTO airline_alias VALUES ('8A', 'BMM', 'Atlas Blue (Morocco)', 'Atlas Blue (Morocco)');
INSERT INTO airline_alias VALUES ('8B', 'GFI', 'Caribbean Star Airlines (Antigua and Barbuda)', 'Caribbean Star Airlines (Antigua and Barbuda)');
INSERT INTO airline_alias VALUES ('8D', 'EXV', 'Expo Aviation (Sri Lanka)', 'Expo Aviation (Sri Lanka)');
INSERT INTO airline_alias VALUES ('8D', 'SUW', 'Astair (Russian Federation)', 'Astair (Russian Federation)');
INSERT INTO airline_alias VALUES ('8E', 'BRG', 'Bering Air (USA)', 'Bering Air (USA)');
INSERT INTO airline_alias VALUES ('8F', 'FFR', 'Fischer Air (Czech Republic)', 'Fischer Air (Czech Republic)');
INSERT INTO airline_alias VALUES ('8G', 'NGE', 'Angel Airlines (Thailand)', 'Angel Airlines (Thailand)');
INSERT INTO airline_alias VALUES ('8J', 'KMV', 'Komiinteravia (Russian Federation)', 'Komiinteravia (Russian Federation)');
INSERT INTO airline_alias VALUES ('8K', 'KOZ', 'Angel Airlines (Romania)', 'Angel Airlines (Romania)');
INSERT INTO airline_alias VALUES ('8L', 'RHC', 'Redhill Aviation (UK)', 'Redhill Aviation (UK)');
INSERT INTO airline_alias VALUES ('8M', 'MXL', 'Maxair (Sweden)', 'Maxair (Sweden)');
INSERT INTO airline_alias VALUES ('8M', 'UBA', 'Myanmar International Airlines', 'Myanmar International Airlines');
INSERT INTO airline_alias VALUES ('8N', 'NKF', 'Nordkalottflyg (Sweden)', 'Nordkalottflyg (Sweden)');
INSERT INTO airline_alias VALUES ('8P', 'PCO', 'Pacific Coastal Airlines (Canada)', 'Pacific Coastal Airlines (Canada)');
INSERT INTO airline_alias VALUES ('8Q', 'BAJ', 'Baker Aviation (USA)', 'Baker Aviation (USA)');
INSERT INTO airline_alias VALUES ('8Q', 'OHY', 'Onur Air (Turkey)', 'Onur Air (Turkey)');
INSERT INTO airline_alias VALUES ('8R', 'EDW', 'Edelweiss Air (Switzerland)', 'Edelweiss Air (Switzerland)');
INSERT INTO airline_alias VALUES ('8S', 'SCP', 'Scorpio Aviation (Egypt)', 'Scorpio Aviation (Egypt)');
INSERT INTO airline_alias VALUES ('8U', 'AAW', 'Afriqiyah Airways (Libyan Arab Jamahiriya)', 'Afriqiyah Airways (Libyan Arab Jamahiriya)');
INSERT INTO airline_alias VALUES ('8V', 'WRT', 'Wright Air Service (USA)', 'Wright Air Service (USA)');
INSERT INTO airline_alias VALUES ('8Y', 'PBU', 'Air Burundi', 'Air Burundi');
INSERT INTO airline_alias VALUES ('8Z', 'LER', 'LASER (Venezuela)', 'LASER (Venezuela)');
INSERT INTO airline_alias VALUES ('9H', 'DEI', 'Eco Air International (Algeria)', 'Eco Air International (Algeria)');
INSERT INTO airline_alias VALUES ('9J', 'PSA', 'Pacific Island Aviation (USA)', 'Pacific Island Aviation (USA)');
INSERT INTO airline_alias VALUES ('9K', 'KAP', 'Cape Air (USA)', 'Cape Air (USA)');
INSERT INTO airline_alias VALUES ('9L', 'CJC', 'Colgan Air (USA)', 'Colgan Air (USA)');
INSERT INTO airline_alias VALUES ('9M', 'GLR', 'Central Mountain Air (Canada)', 'Central Mountain Air (Canada)');
INSERT INTO airline_alias VALUES ('3W', 'EMX', 'Euromanx (UK)', 'Euromanx (UK)');
INSERT INTO airline_alias VALUES ('3W', 'VNR', 'Wanair (French Polynesia)', 'Wanair (French Polynesia)');
INSERT INTO airline_alias VALUES ('3X', 'JAC', 'Japan Air Commuter', 'Japan Air Commuter');
INSERT INTO airline_alias VALUES ('3Y', 'XBO', 'Baseops International (USA)', 'Baseops International (USA)');
INSERT INTO airline_alias VALUES ('3Z', 'NEC', 'Necon Air (Nepal)', 'Necon Air (Nepal)');
INSERT INTO airline_alias VALUES ('4A', 'EYE', 'F.S. Air Service (USA)', 'F.S. Air Service (USA)');
INSERT INTO airline_alias VALUES ('4C', 'CTP', 'Tashkent Aircraft Production Corporation (Uzbekistan)', 'Tashkent Aircraft Production Corporation (Uzbekistan)');
INSERT INTO airline_alias VALUES ('4D', 'ASD', 'Air Sinai (Egypt)', 'Air Sinai (Egypt)');
INSERT INTO airline_alias VALUES ('4E', 'TNR', 'Tanana Air Service (USA)', 'Tanana Air Service (USA)');
INSERT INTO airline_alias VALUES ('4F', 'ECE', 'Air City (Germany)', 'Air City (Germany)');
INSERT INTO airline_alias VALUES ('4G', 'CSZ', 'Shenzhen Airlines (China)', 'Shenzhen Airlines (China)');
INSERT INTO airline_alias VALUES ('4G', 'GZP', 'Gazpromavia (Russian Federation)', 'Gazpromavia (Russian Federation)');
INSERT INTO airline_alias VALUES ('4H', 'FLB', 'Fly Linhas Aereas (Brazil)', 'Fly Linhas Aereas (Brazil)');
INSERT INTO airline_alias VALUES ('4I', 'KNX', 'Knighthawk Air Express (Canada)', 'Knighthawk Air Express (Canada)');
INSERT INTO airline_alias VALUES ('4J', 'NWZ', 'Nationwide Airlines (Zambia)', 'Nationwide Airlines (Zambia)');
INSERT INTO airline_alias VALUES ('4K', 'KBA', 'Kenn Borek Air (Canada)', 'Kenn Borek Air (Canada)');
INSERT INTO airline_alias VALUES ('4L', 'KZR', 'Air Astana (Kazakhstan)', 'Air Astana (Kazakhstan)');
INSERT INTO airline_alias VALUES ('4M', 'ASG', 'African Star Airways (South Africa)', 'African Star Airways (South Africa)');
INSERT INTO airline_alias VALUES ('4M', 'LNC', 'Lan Dominicana (Dominican Republic)', 'Lan Dominicana (Dominican Republic)');
INSERT INTO airline_alias VALUES ('4O', 'KMO', 'Ocean Airlines (Comoros)', 'Ocean Airlines (Comoros)');
INSERT INTO airline_alias VALUES ('4R', 'HHI', 'Hamburg International Airlines (Germany)', 'Hamburg International Airlines (Germany)');
INSERT INTO airline_alias VALUES ('4R', 'OEG', 'Orient Eagle Airways (Kazakhstan)', 'Orient Eagle Airways (Kazakhstan)');
INSERT INTO airline_alias VALUES ('4T', 'BHP', 'Belair Airlines (Switzerland)', 'Belair Airlines (Switzerland)');
INSERT INTO airline_alias VALUES ('4U', 'GWI', 'Germanwings', 'Germanwings');
INSERT INTO airline_alias VALUES ('4U', 'TVJ', 'Tavaj Transportes Aereos Regulares (Brazil)', 'Tavaj Transportes Aereos Regulares (Brazil)');
INSERT INTO airline_alias VALUES ('4V', 'BDY', 'Birdy Airlines (Belgium)', 'Birdy Airlines (Belgium)');
INSERT INTO airline_alias VALUES ('4W', 'WAV', 'Warbelow''s Air Ventures (USA)', 'Warbelow''s Air Ventures (USA)');
INSERT INTO airline_alias VALUES ('4X', 'MEC', 'Air Mercury (USA)', 'Air Mercury (USA)');
INSERT INTO airline_alias VALUES ('4Y', 'UYA', 'Yute Air Alaska (USA)', 'Yute Air Alaska (USA)');
INSERT INTO airline_alias VALUES ('4Z', 'LNK', 'South African Airlink (South Africa)', 'South African Airlink (South Africa)');
INSERT INTO airline_alias VALUES ('5A', 'AIP', 'Alpine Aviation (USA)', 'Alpine Aviation (USA)');
INSERT INTO airline_alias VALUES ('5A', 'EUK', 'Air Atlanta Europe (UK)', 'Air Atlanta Europe (UK)');
INSERT INTO airline_alias VALUES ('5B', 'EAK', 'Euro Asia International (Kazakhstan)', 'Euro Asia International (Kazakhstan)');
INSERT INTO airline_alias VALUES ('5C', 'ICL', 'CAL Cargo Airlines/Cavei Avir Levitanim (Israel)', 'CAL Cargo Airlines/Cavei Avir Levitanim (Israel)');
INSERT INTO airline_alias VALUES ('5D', 'DBR', 'Dutchbird (Netherlands)', 'Dutchbird (Netherlands)');
INSERT INTO airline_alias VALUES ('5D', 'SLI', 'Aerolitoral (Mexico)', 'Aerolitoral (Mexico)');
INSERT INTO airline_alias VALUES ('5D', 'UDD', 'Dombass Airlines (Ukraine)', 'Dombass Airlines (Ukraine)');
INSERT INTO airline_alias VALUES ('5E', 'EKA', 'Equaflight Service (Congo)', 'Equaflight Service (Congo)');
INSERT INTO airline_alias VALUES ('5F', 'CIR', 'Arctic Circle Air Service (USA)', 'Arctic Circle Air Service (USA)');
INSERT INTO airline_alias VALUES ('5G', 'SSV', 'Skyservice Airlines (Canada)', 'Skyservice Airlines (Canada)');
INSERT INTO airline_alias VALUES ('5H', 'STQ', 'Star Air (Indonesia)', 'Star Air (Indonesia)');
INSERT INTO airline_alias VALUES ('5J', 'CEB', 'Cebu Pacific Air (Philippines)', 'Cebu Pacific Air (Philippines)');
INSERT INTO airline_alias VALUES ('5K', 'ODS', 'Odessa Airlines (Ukraine)', 'Odessa Airlines (Ukraine)');
INSERT INTO airline_alias VALUES ('5L', 'ASU', 'Aerosur (Bolivia)', 'Aerosur (Bolivia)');
INSERT INTO airline_alias VALUES ('5M', 'SIB', 'SIAT Sibaviatrans (Russian Federation)', 'SIAT Sibaviatrans (Russian Federation)');
INSERT INTO airline_alias VALUES ('5N', 'OAO', 'Arkhangelsk Airlines  (Russian Federation)', 'Arkhangelsk Airlines  (Russian Federation)');
INSERT INTO airline_alias VALUES ('5P', 'HSK', 'Sky Europe Airlines (Hungary)', 'Sky Europe Airlines (Hungary)');
INSERT INTO airline_alias VALUES ('5R', 'CTT', 'Custom Air Transport (USA)', 'Custom Air Transport (USA)');
INSERT INTO airline_alias VALUES ('5R', 'KAJ', 'Karthago Airlines (Tunisia)', 'Karthago Airlines (Tunisia)');
INSERT INTO airline_alias VALUES ('5S', 'PSV', 'Servicios Aereos Profesionales (Dominican Republic)', 'Servicios Aereos Profesionales (Dominican Republic)');
INSERT INTO airline_alias VALUES ('5T', 'MPE', 'Canadian North/Air NorTerra Inc', 'Canadian North/Air NorTerra Inc');
INSERT INTO airline_alias VALUES ('5U', 'LDE', 'LADE Lineas Aereas del Estado (Argentina)', 'LADE Lineas Aereas del Estado (Argentina)');
INSERT INTO airline_alias VALUES ('5V', 'UKW', 'Lviv/Lvov Airlines (Ukraine)', 'Lviv/Lvov Airlines (Ukraine)');
INSERT INTO airline_alias VALUES ('5W', 'AEU', 'Astraeus (UK)', 'Astraeus (UK)');
INSERT INTO airline_alias VALUES ('5W', 'ITM', 'Itapermirim Transportes Aereos (Brazil)', 'Itapermirim Transportes Aereos (Brazil)');
INSERT INTO airline_alias VALUES ('5Y', 'GTI', 'Atlas Air (USA)', 'Atlas Air (USA)');
INSERT INTO airline_alias VALUES ('5Y', 'IOS', 'Isles of Scilly Skybus (UK)', 'Isles of Scilly Skybus (UK)');
INSERT INTO airline_alias VALUES ('5Z', 'BML', 'Bismillah Airlines (Bangladesh)', 'Bismillah Airlines (Bangladesh)');
INSERT INTO airline_alias VALUES ('6A', 'CHP', 'Aviacsa (Mexico)', 'Aviacsa (Mexico)');
INSERT INTO airline_alias VALUES ('6B', 'BLX', 'Britannia Airways Sverige (Sweden)', 'Britannia Airways Sverige (Sweden)');
INSERT INTO airline_alias VALUES ('6C', 'CMY', 'Cape Smythe Air Services (USA)', 'Cape Smythe Air Services (USA)');
INSERT INTO airline_alias VALUES ('6D', 'PAS', 'Pelita Air (Indonesia)', 'Pelita Air (Indonesia)');
INSERT INTO airline_alias VALUES ('6E', 'CIP', 'City Air Germany', 'City Air Germany');
INSERT INTO airline_alias VALUES ('6F', 'PFO', 'Aerotrans Airlines (Cyprus)', 'Aerotrans Airlines (Cyprus)');
INSERT INTO airline_alias VALUES ('6G', 'AWW', 'Air Wales (UK)', 'Air Wales (UK)');
INSERT INTO airline_alias VALUES ('6H', 'ISR', 'Israir (Israel)', 'Israir (Israel)');
INSERT INTO airline_alias VALUES ('6J', 'SNJ', 'Skynet Asia Airways (Japan)', 'Skynet Asia Airways (Japan)');
INSERT INTO airline_alias VALUES ('6K', 'INX', 'Inter Express Hava Tasimacilik (Turkey)', 'Inter Express Hava Tasimacilik (Turkey)');
INSERT INTO airline_alias VALUES ('Z8', 'MTZ', 'Mali Airways', 'Mali Airways');
INSERT INTO airline_alias VALUES ('Z9', 'RZL', 'Aero Zambia', 'Aero Zambia');
INSERT INTO airline_alias VALUES ('ZB', 'MON', 'Monarch Airlines (UK)', 'Monarch Airlines (UK)');
INSERT INTO airline_alias VALUES ('ZC', 'RSN', 'Royal Swazi National Airways (Swaziland)', 'Royal Swazi National Airways (Swaziland)');
INSERT INTO airline_alias VALUES ('ZD', 'DDD', 'Air Net 21/Flying Dandy (Bulgaria)', 'Air Net 21/Flying Dandy (Bulgaria)');
INSERT INTO airline_alias VALUES ('ZE', 'AZE', 'Cosmos Air (Germany)', 'Cosmos Air (Germany)');
INSERT INTO airline_alias VALUES ('ZE', 'LCD', 'Lineas Aereas Azteca (Mexico)', 'Lineas Aereas Azteca (Mexico)');
INSERT INTO airline_alias VALUES ('ZF', 'HHA', 'Atlantic Airlines de Honduas', 'Atlantic Airlines de Honduas');
INSERT INTO airline_alias VALUES ('ZG', 'AEJ', 'Air Express Limited (United Rep. of Tanzania)', 'Air Express Limited (United Rep. of Tanzania)');
INSERT INTO airline_alias VALUES ('ZI', 'AAF', 'Aigle Azur (France)', 'Aigle Azur (France)');
INSERT INTO airline_alias VALUES ('ZJ', 'ARC', 'Air Routing International (USA)', 'Air Routing International (USA)');
INSERT INTO airline_alias VALUES ('ZK', 'GLA', 'Great Lakes Aviation (USA)', 'Great Lakes Aviation (USA)');
INSERT INTO airline_alias VALUES ('ZL', 'HZL', 'Regional Express/Hazelton Airlines (Australia)', 'Regional Express/Hazelton Airlines (Australia)');
INSERT INTO airline_alias VALUES ('ZO', 'OZR', 'Great Plans Airlines/Ozark Air Lines (USA)', 'Great Plans Airlines/Ozark Air Lines (USA)');
INSERT INTO airline_alias VALUES ('ZP', 'AZQ', 'Silk Way Airlines (Azerbaijan)', 'Silk Way Airlines (Azerbaijan)');
INSERT INTO airline_alias VALUES ('ZP', 'STT', 'Air St. Thomas (USA)', 'Air St. Thomas (USA)');
INSERT INTO airline_alias VALUES ('ZR', 'AZS', 'Aviacon Zitotrans (Russian Federation)', 'Aviacon Zitotrans (Russian Federation)');
INSERT INTO airline_alias VALUES ('ZS', 'AZI', 'Azzura Air (Italy)', 'Azzura Air (Italy)');
INSERT INTO airline_alias VALUES ('ZT', 'TZT', 'Air Zambezi (Zimbabwe)', 'Air Zambezi (Zimbabwe)');
INSERT INTO airline_alias VALUES ('ZT', 'VRN', 'Voronezhavia (Russian Federation)', 'Voronezhavia (Russian Federation)');
INSERT INTO airline_alias VALUES ('ZU', 'HCY', 'Helios Airways (Cyprus)', 'Helios Airways (Cyprus)');
INSERT INTO airline_alias VALUES ('ZV', 'AMW', 'Air Midwest (USA)', 'Air Midwest (USA)');
INSERT INTO airline_alias VALUES ('ZX', 'GGN', 'Air Alliance/Air Georgian (Canada)', 'Air Alliance/Air Georgian (Canada)');
INSERT INTO airline_alias VALUES ('ZY', 'ADE', 'ADA Air (Albania)', 'ADA Air (Albania)');
INSERT INTO airline_alias VALUES ('1I', 'AMB', 'Deutsche Rettungsflugwacht/Civil Air Ambulance (Germany)', 'Deutsche Rettungsflugwacht/Civil Air Ambulance (Germany)');
INSERT INTO airline_alias VALUES ('1I', 'EJA', 'Netjets Aviation (USA)', 'Netjets Aviation (USA)');
INSERT INTO airline_alias VALUES ('1I', 'NVR', 'Novair (Sweden)', 'Novair (Sweden)');
INSERT INTO airline_alias VALUES ('1I', 'PGT', 'Pegasus Hava Tasimaciligi (Turkey)', 'Pegasus Hava Tasimaciligi (Turkey)');
INSERT INTO airline_alias VALUES ('1I', 'PZR', 'Sky Trek International Airlines (USA)', 'Sky Trek International Airlines (USA)');
INSERT INTO airline_alias VALUES ('RV', 'AFI', 'Redair (Gambia)', 'Redair (Gambia)');
INSERT INTO airline_alias VALUES ('2A', 'DBB', 'Deutsche Bahn (Germany)', 'Deutsche Bahn (Germany)');
INSERT INTO airline_alias VALUES ('2B', 'ARD', 'ATA Aerocondor (Portugal)', 'ATA Aerocondor (Portugal)');
INSERT INTO airline_alias VALUES ('2C', 'TGV', 'SNCF (France)', 'SNCF (France)');
INSERT INTO airline_alias VALUES ('2D', 'AOG', 'Aero VIP (Argentina)', 'Aero VIP (Argentina)');
INSERT INTO airline_alias VALUES ('2F', 'FTA', 'Frontier Flying Service (USA)', 'Frontier Flying Service (USA)');
INSERT INTO airline_alias VALUES ('2F', 'IRP', 'Payam/IPTAS (Iran)', 'Payam/IPTAS (Iran)');
INSERT INTO airline_alias VALUES ('2G', 'MRR', 'Northwest Seaplanes (USA)', 'Northwest Seaplanes (USA)');
INSERT INTO airline_alias VALUES ('2J', 'VBW', 'Air Burkina', 'Air Burkina');
INSERT INTO airline_alias VALUES ('2K', 'GLG', 'Aerogal Aerolineas Galapagos (Ecuador)', 'Aerogal Aerolineas Galapagos (Ecuador)');
INSERT INTO airline_alias VALUES ('2L', 'OAW', 'Helvetic Airways (Switzerland)', 'Helvetic Airways (Switzerland)');
INSERT INTO airline_alias VALUES ('2M', 'MDV', 'Moldavian Airlines', 'Moldavian Airlines');
INSERT INTO airline_alias VALUES ('2N', 'UMK', 'Yuzmashavia (Ukraine)', 'Yuzmashavia (Ukraine)');
INSERT INTO airline_alias VALUES ('2P', 'GAP', 'Air Philippines', 'Air Philippines');
INSERT INTO airline_alias VALUES ('2Q', 'SNC', 'Air Cargo Carriers (USA)', 'Air Cargo Carriers (USA)');
INSERT INTO airline_alias VALUES ('2R', 'VRR', 'VIA Rail Canada', 'VIA Rail Canada');
INSERT INTO airline_alias VALUES ('2S', 'SDY', 'Island Express (USA)', 'Island Express (USA)');
INSERT INTO airline_alias VALUES ('2T', 'HAM', 'Haiti Ambassador Airlines', 'Haiti Ambassador Airlines');
INSERT INTO airline_alias VALUES ('2T', 'TUX', 'Tulpar Air Service (Kazakhstan)', 'Tulpar Air Service (Kazakhstan)');
INSERT INTO airline_alias VALUES ('2U', 'GIP', 'Air Guinee Express (Guinea)', 'Air Guinee Express (Guinea)');
INSERT INTO airline_alias VALUES ('2W', 'WLC', 'Welcome Air (Austria)', 'Welcome Air (Austria)');
INSERT INTO airline_alias VALUES ('2Z', 'CGN', 'Changan Airlines (China)', 'Changan Airlines (China)');
INSERT INTO airline_alias VALUES ('3A', 'AFJ', 'Alliance Airlines (USA)', 'Alliance Airlines (USA)');
INSERT INTO airline_alias VALUES ('3B', 'BFR', 'Burkina Airlines', 'Burkina Airlines');
INSERT INTO airline_alias VALUES ('3C', 'CEA', 'Corporate Airlines (USA)', 'Corporate Airlines (USA)');
INSERT INTO airline_alias VALUES ('3D', 'APG', 'Air People International (Thailand)', 'Air People International (Thailand)');
INSERT INTO airline_alias VALUES ('3D', 'DNM', 'Denim Air (Netherlands)', 'Denim Air (Netherlands)');
INSERT INTO airline_alias VALUES ('3E', 'EMU', 'East Asia Airlines (Macau)', 'East Asia Airlines (Macau)');
INSERT INTO airline_alias VALUES ('3G', 'AYZ', 'Atlant-Soyuz Airlines (Russian Federation)', 'Atlant-Soyuz Airlines (Russian Federation)');
INSERT INTO airline_alias VALUES ('3H', 'AIE', 'Air Inuit (Canada)', 'Air Inuit (Canada)');
INSERT INTO airline_alias VALUES ('3K', 'VTS', 'Evers Air Alaska (USA)', 'Evers Air Alaska (USA)');
INSERT INTO airline_alias VALUES ('3L', 'ISK', 'Intersky (Austria)', 'Intersky (Austria)');
INSERT INTO airline_alias VALUES ('3M', 'GFT', 'Gulfstream International Airlines (USA)', 'Gulfstream International Airlines (USA)');
INSERT INTO airline_alias VALUES ('3N', 'URG', 'Air Urga (Ukraine)', 'Air Urga (Ukraine)');
INSERT INTO airline_alias VALUES ('3P', 'TCU', 'Inter Tropical Aviation (Suriname)', 'Inter Tropical Aviation (Suriname)');
INSERT INTO airline_alias VALUES ('3P', 'TPV', 'Thai Pacific Airlines Business Company', 'Thai Pacific Airlines Business Company');
INSERT INTO airline_alias VALUES ('3Q', 'CYH', 'China Yunnan Airlines', 'China Yunnan Airlines');
INSERT INTO airline_alias VALUES ('3R', 'ARB', 'Avia Air (Aruba)', 'Avia Air (Aruba)');
INSERT INTO airline_alias VALUES ('3T', 'URN', 'Turan Air (Azerbaijan)', 'Turan Air (Azerbaijan)');
INSERT INTO airline_alias VALUES ('3U', 'CSC', 'Sichuan Airlines (China)', 'Sichuan Airlines (China)');
INSERT INTO airline_alias VALUES ('3U', 'NCH', 'Chanchangi Airlines Nigeria', 'Chanchangi Airlines Nigeria');
INSERT INTO airline_alias VALUES ('3V', 'TAY', 'TNT Airways (Belgium)', 'TNT Airways (Belgium)');
INSERT INTO airline_alias VALUES ('WT', 'NGA', 'Nigeria Airways', 'Nigeria Airways');
INSERT INTO airline_alias VALUES ('WU', 'CWU', 'Wuhan Airlines (China)', 'Wuhan Airlines (China)');
INSERT INTO airline_alias VALUES ('WU', 'TKC', 'Tikal Jets (Guatemala)', 'Tikal Jets (Guatemala)');
INSERT INTO airline_alias VALUES ('WV', 'SWV', 'Swe Fly (Sweden)', 'Swe Fly (Sweden)');
INSERT INTO airline_alias VALUES ('WW', 'BMI', 'bmibaby (UK)', 'bmibaby (UK)');
INSERT INTO airline_alias VALUES ('WX', 'BCY', 'CityJet (Ireland)', 'CityJet (Ireland)');
INSERT INTO airline_alias VALUES ('WY', 'OMA', 'Oman Air', 'Oman Air');
INSERT INTO airline_alias VALUES ('WZ', 'RMM', 'Acvila Air Romanian Carrier', 'Acvila Air Romanian Carrier');
INSERT INTO airline_alias VALUES ('WZ', 'WSF', 'West African Airlines (Benin)', 'West African Airlines (Benin)');
INSERT INTO airline_alias VALUES ('X3', 'HLX', 'Hapag-Lloyd Express (Germany)', 'Hapag-Lloyd Express (Germany)');
INSERT INTO airline_alias VALUES ('X5', 'FBN', 'Afrique Airlines (Benin)', 'Afrique Airlines (Benin)');
INSERT INTO airline_alias VALUES ('X7', 'ZAK', 'Zambia Skyways (Zambia)', 'Zambia Skyways (Zambia)');
INSERT INTO airline_alias VALUES ('X9', 'KHO', 'Khors Aircompany (Ukraine)', 'Khors Aircompany (Ukraine)');
INSERT INTO airline_alias VALUES ('XA', 'XAA', 'ARINC/Aeronautical Radio Inc. (USA)', 'ARINC/Aeronautical Radio Inc. (USA)');
INSERT INTO airline_alias VALUES ('XB', 'IAT', 'IATA/Int''l Air Transport Association (Canada)', 'IATA/Int''l Air Transport Association (Canada)');
INSERT INTO airline_alias VALUES ('XC', 'KDC', 'KD Air (Canada)', 'KD Air (Canada)');
INSERT INTO airline_alias VALUES ('XD', 'ATA', 'ATA/Air Transport Association (USA)', 'ATA/Air Transport Association (USA)');
INSERT INTO airline_alias VALUES ('XD', 'XXD', 'OAG/Official Airline Guides (USA)', 'OAG/Official Airline Guides (USA)');
INSERT INTO airline_alias VALUES ('XE', 'ALT', 'SBS Aircraft (Kazakhstan)', 'SBS Aircraft (Kazakhstan)');
INSERT INTO airline_alias VALUES ('XF', 'VLK', 'Vladivostok Air (Russian Federation)', 'Vladivostok Air (Russian Federation)');
INSERT INTO airline_alias VALUES ('XG', 'KLB', 'Air Mali International', 'Air Mali International');
INSERT INTO airline_alias VALUES ('XH', 'XXH', 'Special Ground Handling Service (USA)', 'Special Ground Handling Service (USA)');
INSERT INTO airline_alias VALUES ('XI', 'XXI', 'AEROTEL/Aeronautical Telecommunications (Jamaica)', 'AEROTEL/Aeronautical Telecommunications (Jamaica)');
INSERT INTO airline_alias VALUES ('YV', 'ASH', 'Mesa Airlines (USA)', 'Mesa Airlines');
INSERT INTO airline_alias VALUES ('XK', 'CCM', 'CCM Compagnie Corse Mediterrannee (France)', 'CCM Compagnie Corse Mediterrannee (France)');
INSERT INTO airline_alias VALUES ('XL', '---', 'Lan Ecuador', 'Lan Ecuador');
INSERT INTO airline_alias VALUES ('XM', 'SMX', 'Alitalia Express (Italy)', 'Alitalia Express (Italy)');
INSERT INTO airline_alias VALUES ('XM', 'XME', 'Australian Air Express', 'Australian Air Express');
INSERT INTO airline_alias VALUES ('XO', 'CXJ', 'China Xinjiang Airlines', 'China Xinjiang Airlines');
INSERT INTO airline_alias VALUES ('PY', 'SLM', 'Surinam Airways', 'Surinam Airways');
INSERT INTO airline_alias VALUES ('XO', 'LTE', 'LTE International Airways (Spain)', 'LTE International Airways (Spain)');
INSERT INTO airline_alias VALUES ('XP', 'CXP', 'Casino Express (USA)', 'Casino Express (USA)');
INSERT INTO airline_alias VALUES ('XQ', 'SXS', 'Sun Express (Turkey)', 'Sun Express (Turkey)');
INSERT INTO airline_alias VALUES ('XS', 'SIT', 'SITA (Belgium)', 'SITA (Belgium)');
INSERT INTO airline_alias VALUES ('XT', 'AXL', 'Air Exel (Netherlands)', 'Air Exel (Netherlands)');
INSERT INTO airline_alias VALUES ('XU', 'AXK', 'African Express Airways (Kenya)', 'African Express Airways (Kenya)');
INSERT INTO airline_alias VALUES ('XV', 'IVW', 'Ivoire Airways (Cote d''Ivoire)', 'Ivoire Airways (Cote d''Ivoire)');
INSERT INTO airline_alias VALUES ('XW', 'CXH', 'China Xinhua Airlines', 'China Xinhua Airlines');
INSERT INTO airline_alias VALUES ('Y4', 'EQA', 'Eagle Aviation (Kenya)', 'Eagle Aviation (Kenya)');
INSERT INTO airline_alias VALUES ('Y6', 'KHM', 'Cambodia Airlines', 'Cambodia Airlines');
INSERT INTO airline_alias VALUES ('Y7', 'TNB', 'Trans Air Benin', 'Trans Air Benin');
INSERT INTO airline_alias VALUES ('Y8', 'SYL', 'Sayany Airlines (Russian Federation)', 'Sayany Airlines (Russian Federation)');
INSERT INTO airline_alias VALUES ('Y8', 'YZR', 'Yangtze River Express Airlines (China)', 'Yangtze River Express Airlines (China)');
INSERT INTO airline_alias VALUES ('Y9', 'IRK', 'Kish Air (Iran)', 'Kish Air (Iran)');
INSERT INTO airline_alias VALUES ('YB', 'EXY', 'South African Express', 'South African Express');
INSERT INTO airline_alias VALUES ('YD', 'GOM', 'Gomelavia (Belarus)', 'Gomelavia (Belarus)');
INSERT INTO airline_alias VALUES ('YF', 'CFC', 'Canadian Armed Forces', 'Canadian Armed Forces');
INSERT INTO airline_alias VALUES ('YG', 'OTL', 'South Airlines (Ukraine)', 'South Airlines (Ukraine)');
INSERT INTO airline_alias VALUES ('YH', 'WCW', 'West Caribbean Airways (Colombia)', 'West Caribbean Airways (Colombia)');
INSERT INTO airline_alias VALUES ('YI', 'RSI', 'Air Sunshine (USA)', 'Air Sunshine (USA)');
INSERT INTO airline_alias VALUES ('YJ', 'NTN', 'National Airlines (South Africa)', 'National Airlines (South Africa)');
INSERT INTO airline_alias VALUES ('YK', 'KYV', 'TKHY Kibris Turkish Airlines (Cyprus)', 'TKHY Kibris Turkish Airlines (Cyprus)');
INSERT INTO airline_alias VALUES ('YL', 'LLM', 'Yamal Airlines (Russian Federation)', 'Yamal Airlines (Russian Federation)');
INSERT INTO airline_alias VALUES ('YM', 'MGX', 'Montenegro Airlines (Yugoslavia)', 'Montenegro Airlines (Yugoslavia)');
INSERT INTO airline_alias VALUES ('YN', 'CRQ', 'Air Creebec (Canada)', 'Air Creebec (Canada)');
INSERT INTO airline_alias VALUES ('YO', 'MCM', 'Heli Air Monaco', 'Heli Air Monaco');
INSERT INTO airline_alias VALUES ('YQ', 'SCO', 'Helikopterservice Euro Air (Sweden)', 'Helikopterservice Euro Air (Sweden)');
INSERT INTO airline_alias VALUES ('YR', 'EGJ', 'Eagle Canyon Airlines (USA)', 'Eagle Canyon Airlines (USA)');
INSERT INTO airline_alias VALUES ('YS', 'RAE', 'Regional Compagnie Aerienne Europeenne (France)', 'Regional Compagnie Aerienne Europeenne (France)');
INSERT INTO airline_alias VALUES ('YT', 'TGA', 'Air Togo', 'Air Togo');
INSERT INTO airline_alias VALUES ('YW', 'ANS', 'Air Nostrum (Spain)', 'Air Nostrum (Spain)');
INSERT INTO airline_alias VALUES ('YZ', 'HXL', 'ATR Leasing/Holland Exel (Netherlands)', 'ATR Leasing/Holland Exel (Netherlands)');
INSERT INTO airline_alias VALUES ('Z2', 'CYN', 'Zhongyuan Airlines (China)', 'Zhongyuan Airlines (China)');
INSERT INTO airline_alias VALUES ('Z2', 'STY', 'Styrian Airways (Austria)', 'Styrian Airways (Austria)');
INSERT INTO airline_alias VALUES ('Z4', 'BZW', 'Zircon Airways (Benin)', 'Zircon Airways (Benin)');
INSERT INTO airline_alias VALUES ('Z4', 'OOM', 'Zoom Airlines (Canada)', 'Zoom Airlines (Canada)');
INSERT INTO airline_alias VALUES ('Z6', 'UDN', 'Dnieproavia (Ukraine)', 'Dnieproavia (Ukraine)');
INSERT INTO airline_alias VALUES ('Z7', 'ADK', 'Aviation Development Company (Nigeria)', 'Aviation Development Company (Nigeria)');
INSERT INTO airline_alias VALUES ('UT', 'ORT', 'Air Orient (France)', 'Air Orient (France)');
INSERT INTO airline_alias VALUES ('UU', 'REU', 'Air Austral (France)', 'Air Austral (France)');
INSERT INTO airline_alias VALUES ('UV', 'HSE', 'Helisureste (Spain)', 'Helisureste (Spain)');
INSERT INTO airline_alias VALUES ('UV', 'UVA', 'Universal Airways (USA)', 'Universal Airways (USA)');
INSERT INTO airline_alias VALUES ('UW', 'UVG', 'Universal Airlines (Guyana)', 'Universal Airlines (Guyana)');
INSERT INTO airline_alias VALUES ('UX', 'AEA', 'Air Europa (Spain)', 'Air Europa (Spain)');
INSERT INTO airline_alias VALUES ('UY', 'UYC', 'Cameroon Airlines', 'Cameroon Airlines');
INSERT INTO airline_alias VALUES ('UZ', 'BRQ', 'Buraq Air Transport (Libyan Arab Jamahiriya)', 'Buraq Air Transport (Libyan Arab Jamahiriya)');
INSERT INTO airline_alias VALUES ('UZ', 'TIS', 'Tezis (Russian Federation)', 'Tezis (Russian Federation)');
INSERT INTO airline_alias VALUES ('V2', 'AKT', 'Karat (Russian Federation)', 'Karat (Russian Federation)');
INSERT INTO airline_alias VALUES ('V3', 'KRP', 'Carpatair (Romania)', 'Carpatair (Romania)');
INSERT INTO airline_alias VALUES ('V5', 'RYL', 'Royal Aruban Airlines', 'Royal Aruban Airlines');
INSERT INTO airline_alias VALUES ('V7', 'SNG', 'Air Senegal International', 'Air Senegal International');
INSERT INTO airline_alias VALUES ('V8', 'IAR', 'Iliamna Air Taxi (USA)', 'Iliamna Air Taxi (USA)');
INSERT INTO airline_alias VALUES ('V8', 'TPS', 'Tapsa (Argentina)', 'Tapsa (Argentina)');
INSERT INTO airline_alias VALUES ('V8', 'VAS', 'ATRAN Aviatrans Cargo Airlines (Russian Federation)', 'ATRAN Aviatrans Cargo Airlines (Russian Federation)');
INSERT INTO airline_alias VALUES ('V9', 'BTC', 'Bashkir Airlines (Russian Federation)', 'Bashkir Airlines (Russian Federation)');
INSERT INTO airline_alias VALUES ('VA', 'VLE', 'Volare Airlines (Italy)', 'Volare Airlines (Italy)');
INSERT INTO airline_alias VALUES ('VC', 'SVV', 'Servivensa (Venezuela)', 'Servivensa (Venezuela)');
INSERT INTO airline_alias VALUES ('VD', 'BBB', 'Swedjet Airways (Sweden)', 'Swedjet Airways (Sweden)');
INSERT INTO airline_alias VALUES ('VE', 'AVE', 'Avensa (Venezuela)', 'Avensa (Venezuela)');
INSERT INTO airline_alias VALUES ('VE', 'EUJ', 'EU Jet (Ireland)', 'EU Jet (Ireland)');
INSERT INTO airline_alias VALUES ('VF', 'VLU', 'Valuair (Singapore)', 'Valuair (Singapore)');
INSERT INTO airline_alias VALUES ('VG', 'VLM', 'VLM (Belgium)', 'VLM (Belgium)');
INSERT INTO airline_alias VALUES ('VH', 'LAV', 'Aeropostal (Venezuela)', 'Aeropostal (Venezuela)');
INSERT INTO airline_alias VALUES ('VI', 'VDA', 'Volga-Dnepr Airlines (Russian Federation)', 'Volga-Dnepr Airlines (Russian Federation)');
INSERT INTO airline_alias VALUES ('VJ', 'JTY', 'Jatayu Gelang Sejahtera (Indonesia)', 'Jatayu Gelang Sejahtera (Indonesia)');
INSERT INTO airline_alias VALUES ('VK', 'ZAN', 'Zantop International Airlines (USA)', 'Zantop International Airlines (USA)');
INSERT INTO airline_alias VALUES ('VL', 'VIM', 'Air VIA Bulgarian Airways', 'Air VIA Bulgarian Airways');
INSERT INTO airline_alias VALUES ('VM', 'VOA', 'Viaggio Air (Bulgaria)', 'Viaggio Air (Bulgaria)');
INSERT INTO airline_alias VALUES ('VN', 'HVN', 'Vietnam Airlines', 'Vietnam Airlines');
INSERT INTO airline_alias VALUES ('VO', 'TYR', 'Tyrolean Airways (Austria)', 'Tyrolean Airways (Austria)');
INSERT INTO airline_alias VALUES ('VP', 'VSP', 'VASP (Brazil)', 'VASP (Brazil)');
INSERT INTO airline_alias VALUES ('VR', 'TCV', 'TACV Cabo Verde Airlines', 'TACV Cabo Verde Airlines');
INSERT INTO airline_alias VALUES ('VS', 'VIR', 'Virgin Atlantic Airways (UK)', 'Virgin Atlantic Airways (UK)');
INSERT INTO airline_alias VALUES ('VT', 'VTA', 'Air Tahiti (French Polynesia)', 'Air Tahiti (French Polynesia)');
INSERT INTO airline_alias VALUES ('VU', 'VUN', 'Societe Nouvelle Air Ivoire (Cote d''Ivoire)', 'Societe Nouvelle Air Ivoire (Cote d''Ivoire)');
INSERT INTO airline_alias VALUES ('VV', 'AEW', 'Aerosvit/Aerosweet Airlines (Ukraine)', 'Aerosvit/Aerosweet Airlines (Ukraine)');
INSERT INTO airline_alias VALUES ('VW', 'TAO', 'Transportes Aeromar (Mexico)', 'Transportes Aeromar (Mexico)');
INSERT INTO airline_alias VALUES ('VX', 'VBS', 'V Bird Airlines (Netherlands)', 'V Bird Airlines (Netherlands)');
INSERT INTO airline_alias VALUES ('G2', 'VXG', 'Avirex (Gabon)', 'Avirex (Gabon)');
INSERT INTO airline_alias VALUES ('VY', 'VLG', 'Vueling Airlines (Spain)', 'Vueling Airlines (Spain)');
INSERT INTO airline_alias VALUES ('VZ', 'MYT', 'MyTravel Airways (UK)', 'MyTravel Airways (UK)');
INSERT INTO airline_alias VALUES ('W4', 'BES', 'Aero Services Executive (France)', 'Aero Services Executive (France)');
INSERT INTO airline_alias VALUES ('W5', 'IRM', 'Mahan Air (Iran)', 'Mahan Air (Iran)');
INSERT INTO airline_alias VALUES ('W6', 'WIL', 'West Isle Air (USA)', 'West Isle Air (USA)');
INSERT INTO airline_alias VALUES ('W6', 'WZZ', 'Wizz Air (Hungary)', 'Wizz Air (Hungary)');
INSERT INTO airline_alias VALUES ('W7', 'SAH', 'Sayakhat (Kazakhstan)', 'Sayakhat (Kazakhstan)');
INSERT INTO airline_alias VALUES ('W8', 'CJT', 'CargoJet Airways (Canada)', 'CargoJet Airways (Canada)');
INSERT INTO airline_alias VALUES ('WA', 'KLC', 'KLM CityHopper (Netherlands)', 'KLM CityHopper (Netherlands)');
INSERT INTO airline_alias VALUES ('PU', 'PUA', 'Pluna (Uruguay)', 'Pluna (Uruguay)');
INSERT INTO airline_alias VALUES ('WB', 'RWD', 'Rwandair Express (Rwanda)', 'Rwandair Express (Rwanda)');
INSERT INTO airline_alias VALUES ('WB', 'SAN', 'Servicios Aereos Nacionales (Ecuador)', 'Servicios Aereos Nacionales (Ecuador)');
INSERT INTO airline_alias VALUES ('WC', 'ISV', 'Islena Airlines (Honduras)', 'Islena Airlines (Honduras)');
INSERT INTO airline_alias VALUES ('WD', 'DAZ', 'DAS Air Limited (Kenya)', 'DAS Air Limited (Kenya)');
INSERT INTO airline_alias VALUES ('WE', 'CWC', 'Centurion Air Cargo (USA)', 'Centurion Air Cargo (USA)');
INSERT INTO airline_alias VALUES ('WE', 'RTL', 'Rheintalflug (Austria)', 'Rheintalflug (Austria)');
INSERT INTO airline_alias VALUES ('WF', 'WIF', 'Wideroe (Norway)', 'Wideroe (Norway)');
INSERT INTO airline_alias VALUES ('WG', 'WSG', 'Wasaya Airways (Canada)', 'Wasaya Airways (Canada)');
INSERT INTO airline_alias VALUES ('WH', 'CNW', 'China Northwest Airlines', 'China Northwest Airlines');
INSERT INTO airline_alias VALUES ('WJ', 'LAL', 'Air Labrador (Canada)', 'Air Labrador (Canada)');
INSERT INTO airline_alias VALUES ('WK', 'AFB', 'American Falcon (Argentina)', 'American Falcon (Argentina)');
INSERT INTO airline_alias VALUES ('WL', 'APP', 'AeroPerlas (Panama)', 'AeroPerlas (Panama)');
INSERT INTO airline_alias VALUES ('WM', 'WIA', 'Winair/Windward Islands Airways (Netherland Antilles)', 'Winair/Windward Islands Airways (Netherland Antilles)');
INSERT INTO airline_alias VALUES ('WP', 'MKU', 'Aloha Island Air (USA)', 'Aloha Island Air (USA)');
INSERT INTO airline_alias VALUES ('WQ', 'RMV', 'Romavia/Romanian Aviation Company', 'Romavia/Romanian Aviation Company');
INSERT INTO airline_alias VALUES ('WR', 'HRH', 'Royal Tongan Airlines', 'Royal Tongan Airlines');
INSERT INTO airline_alias VALUES ('WS', 'WJA', 'WestJet (Canada)', 'WestJet (Canada)');
INSERT INTO airline_alias VALUES ('SU', 'AFL', 'Aeroflot Russian Airlines', 'Aeroflot Russian Airlines');
INSERT INTO airline_alias VALUES ('SV', 'SVA', 'Saudi Arabian Airlines', 'Saudi Arabian Airlines');
INSERT INTO airline_alias VALUES ('SW', 'NMB', 'Air Namibia', 'Air Namibia');
INSERT INTO airline_alias VALUES ('SX', 'AJO', 'Aeroejecutivo (Mexico)', 'Aeroejecutivo (Mexico)');
INSERT INTO airline_alias VALUES ('TZ', 'AMT', 'ATA/American Trans Air (USA)', 'ATA/American Trans Air');
INSERT INTO airline_alias VALUES ('SZ', 'CXN', 'China Southwest Airlines', 'China Southwest Airlines');
INSERT INTO airline_alias VALUES ('T2', 'TCG', 'Thai Air Cargo', 'Thai Air Cargo');
INSERT INTO airline_alias VALUES ('T4', 'HEJ', 'Hellas Jet (Greece)', 'Hellas Jet (Greece)');
INSERT INTO airline_alias VALUES ('T4', 'TRL', 'Transeast Airlines (Latvia)', 'Transeast Airlines (Latvia)');
INSERT INTO airline_alias VALUES ('T5', 'TUA', 'Turkmenistan Airlines', 'Turkmenistan Airlines');
INSERT INTO airline_alias VALUES ('T6', 'TVR', 'Tavrey/Tavria Aviakompania (Ukraine)', 'Tavrey/Tavria Aviakompania (Ukraine)');
INSERT INTO airline_alias VALUES ('T7', 'SRT', 'Trans Asian Airlines (Kazakhstan)', 'Trans Asian Airlines (Kazakhstan)');
INSERT INTO airline_alias VALUES ('T7', 'TJT', 'Twin Jet (France)', 'Twin Jet (France)');
INSERT INTO airline_alias VALUES ('T8', 'NQN', 'Transportes Aereos Neuquen (Argentina)', 'Transportes Aereos Neuquen (Argentina)');
INSERT INTO airline_alias VALUES ('TA', 'TAI', 'Taca International Airlines (El Salvador)', 'Taca International Airlines (El Salvador)');
INSERT INTO airline_alias VALUES ('TB', 'TUB', 'Jetair/TUI Airlines Belgium', 'Jetair/TUI Airlines Belgium');
INSERT INTO airline_alias VALUES ('TC', 'ATC', 'Air Tanzania', 'Air Tanzania');
INSERT INTO airline_alias VALUES ('TD', 'LUR', 'Atlantis European Airlines (Armenia)', 'Atlantis European Airlines (Armenia)');
INSERT INTO airline_alias VALUES ('TD', 'TLP', 'Tulip Air (Netherlands)', 'Tulip Air (Netherlands)');
INSERT INTO airline_alias VALUES ('TE', 'LIL', 'Lithuanian Airlines', 'Lithuanian Airlines');
INSERT INTO airline_alias VALUES ('TF', 'SCW', 'Malmo Aviation/Malmoe Aviation (Sweden)', 'Malmo Aviation/Malmoe Aviation (Sweden)');
INSERT INTO airline_alias VALUES ('TG', 'THA', 'Thai Airways International (Thailand)', 'Thai Airways International (Thailand)');
INSERT INTO airline_alias VALUES ('TH', 'BRT', 'British Airways CitiExpress', 'British Airways CitiExpress');
INSERT INTO airline_alias VALUES ('TH', 'TSE', 'Transmile Air Services (Malaysia)', 'Transmile Air Services (Malaysia)');
INSERT INTO airline_alias VALUES ('TI', 'TOL', 'TolAir Services (Puerto Rico)', 'TolAir Services (Puerto Rico)');
INSERT INTO airline_alias VALUES ('TJ', 'ELV', 'TANS (Peru)', 'TANS (Peru)');
INSERT INTO airline_alias VALUES ('TK', 'THY', 'Turkish Airlines', 'Turkish Airlines');
INSERT INTO airline_alias VALUES ('TL', 'ANO', 'Airnorth Regional (Australia)', 'Airnorth Regional (Australia)');
INSERT INTO airline_alias VALUES ('TL', 'TMA', 'Trans Mediterranean Airlines (Lebanon)', 'Trans Mediterranean Airlines (Lebanon)');
INSERT INTO airline_alias VALUES ('TM', 'LAM', 'LAM (Mozambique)', 'LAM (Mozambique)');
INSERT INTO airline_alias VALUES ('TN', 'THT', 'Air Tahiti Nui (French Polynesia)', 'Air Tahiti Nui (French Polynesia)');
INSERT INTO airline_alias VALUES ('TO', 'PSD', 'President Airlines (Cambodia)', 'President Airlines (Cambodia)');
INSERT INTO airline_alias VALUES ('TQ', 'TDM', 'Tandem Aereo (Moldova)', 'Tandem Aereo (Moldova)');
INSERT INTO airline_alias VALUES ('TR', 'TGW', 'Tiger Airways (Singapore)', 'Tiger Airways (Singapore)');
INSERT INTO airline_alias VALUES ('TS', 'TSC', 'Air Transat (Canada)', 'Air Transat (Canada)');
INSERT INTO airline_alias VALUES ('TT', 'KLA', 'Air Lithuania', 'Air Lithuania');
INSERT INTO airline_alias VALUES ('TU', 'TAR', 'Tunisair (Tunisia)', 'Tunisair (Tunisia)');
INSERT INTO airline_alias VALUES ('TV', 'VEX', 'Virgin Express (Belgium)', 'Virgin Express (Belgium)');
INSERT INTO airline_alias VALUES ('TX', 'FWI', 'Air Caraibes (France)', 'Air Caraibes (France)');
INSERT INTO airline_alias VALUES ('TY', 'IWD', 'Iberworld (Spain)', 'Iberworld (Spain)');
INSERT INTO airline_alias VALUES ('TY', 'TPC', 'Air Caledonie (France)', 'Air Caledonie (France)');
INSERT INTO airline_alias VALUES ('U3', 'AIA', 'Avies (Estonia)', 'Avies (Estonia)');
INSERT INTO airline_alias VALUES ('U4', 'PMT', 'Progress Multitrade (Cambodia)', 'Progress Multitrade (Cambodia)');
INSERT INTO airline_alias VALUES ('U5', 'GWY', 'USA 3000 Airlines/Brendan Airways', 'USA 3000 Airlines/Brendan Airways');
INSERT INTO airline_alias VALUES ('U5', 'IBZ', 'International Business Air (Sweden)', 'International Business Air (Sweden)');
INSERT INTO airline_alias VALUES ('U6', 'SVR', 'Ural Airlines (Russian Federation)', 'Ural Airlines (Russian Federation)');
INSERT INTO airline_alias VALUES ('U7', 'NKA', 'Northern Dene Airways (Canada)', 'Northern Dene Airways (Canada)');
INSERT INTO airline_alias VALUES ('U8', 'RNV', 'Armavia (Aermenia)', 'Armavia (Aermenia)');
INSERT INTO airline_alias VALUES ('U9', 'KAZ', 'Tatarstan Joint Stock Aircompany (Russian Federation)', 'Tatarstan Joint Stock Aircompany (Russian Federation)');
INSERT INTO airline_alias VALUES ('T9', 'TRZ', 'Transmeridian Airlines/Prime Air (USA)', 'Transmeridian Airlines');
INSERT INTO airline_alias VALUES ('UC', 'LCO', 'Lan Express/Ladeco (Chile)', 'Lan Express/Ladeco (Chile)');
INSERT INTO airline_alias VALUES ('UD', 'HER', 'Hex''Air (France)', 'Hex''Air (France)');
INSERT INTO airline_alias VALUES ('UE', 'TEP', 'Transeuropean Airlines (Russian Federation)', 'Transeuropean Airlines (Russian Federation)');
INSERT INTO airline_alias VALUES ('UF', 'UKM', 'UM Air (Ukraine)', 'UM Air (Ukraine)');
INSERT INTO airline_alias VALUES ('UG', 'TUI', 'Tuninter (Tunisia)', 'Tuninter (Tunisia)');
INSERT INTO airline_alias VALUES ('UH', 'EUS', 'Eurasia Aircompany (Russian Federation)', 'Eurasia Aircompany (Russian Federation)');
INSERT INTO airline_alias VALUES ('UI', 'ECA', 'Eurocypria (Cyprus)', 'Eurocypria (Cyprus)');
INSERT INTO airline_alias VALUES ('UL', 'ALK', 'SriLankan Airlines', 'SriLankan Airlines');
INSERT INTO airline_alias VALUES ('UM', 'AZW', 'Air Zimbabwe', 'Air Zimbabwe');
INSERT INTO airline_alias VALUES ('UN', 'TSO', 'Transaero Airlines (Russian Federation)', 'Transaero Airlines (Russian Federation)');
INSERT INTO airline_alias VALUES ('UP', 'BHS', 'Bahamasair', 'Bahamasair');
INSERT INTO airline_alias VALUES ('UQ', 'OCM', 'O''Connor-Mt. Gambier''s Airline (Australia)', 'O''Connor-Mt. Gambier''s Airline (Australia)');
INSERT INTO airline_alias VALUES ('QQ', 'QQA', 'Alliance Airlines (Australia)', 'Alliance Airlines (Australia)');
INSERT INTO airline_alias VALUES ('QR', 'QTR', 'Qatar Airways', 'Qatar Airways');
INSERT INTO airline_alias VALUES ('QS', 'TTR', 'Tatra Air (Slovakia)', 'Tatra Air (Slovakia)');
INSERT INTO airline_alias VALUES ('QS', 'TVS', 'Travel Service (Czech Republic)', 'Travel Service (Czech Republic)');
INSERT INTO airline_alias VALUES ('QT', 'TPA', 'Tampa (Colombia)', 'Tampa (Colombia)');
INSERT INTO airline_alias VALUES ('QU', 'UGX', 'East African Airlines (Uganda)', 'East African Airlines (Uganda)');
INSERT INTO airline_alias VALUES ('QV', 'LAO', 'Lao Aviation', 'Lao Aviation');
INSERT INTO airline_alias VALUES ('QW', 'BWG', 'Blue Wings (Germany)', 'Blue Wings (Germany)');
INSERT INTO airline_alias VALUES ('QW', 'TCI', 'Turks and Caicos Airways', 'Turks and Caicos Airways');
INSERT INTO airline_alias VALUES ('QY', 'BCS', 'European Air Transport (Belgium)', 'European Air Transport (Belgium)');
INSERT INTO airline_alias VALUES ('R2', 'ORB', 'Orenburg Airlines (Russian Federation)', 'Orenburg Airlines (Russian Federation)');
INSERT INTO airline_alias VALUES ('OF', 'FIF', 'Air Finland', 'Air Finland');
INSERT INTO airline_alias VALUES ('R4', 'SDM', 'Russia State Transport Company', 'Russia State Transport Company');
INSERT INTO airline_alias VALUES ('R5', 'MAC', 'Malta Air Charter', 'Malta Air Charter');
INSERT INTO airline_alias VALUES ('R6', 'SBK', 'Air Sprska (Bosnia-Herzegovina)', 'Air Sprska (Bosnia-Herzegovina)');
INSERT INTO airline_alias VALUES ('R7', 'OCA', 'Aserca Airlines (Venezuela)', 'Aserca Airlines (Venezuela)');
INSERT INTO airline_alias VALUES ('R8', 'KGA', 'Kyrghyzstan Airlines', 'Kyrghyzstan Airlines');
INSERT INTO airline_alias VALUES ('R9', 'CAM', 'Camai Air/Village Aviation (USA)', 'Camai Air/Village Aviation (USA)');
INSERT INTO airline_alias VALUES ('RA', 'RNA', 'Royal Nepal Airlines', 'Royal Nepal Airlines');
INSERT INTO airline_alias VALUES ('RB', 'SYR', 'Syrian Arab Airlines', 'Syrian Arab Airlines');
INSERT INTO airline_alias VALUES ('RC', 'FLI', 'Atlantic Airways (Denmark)', 'Atlantic Airways (Denmark)');
INSERT INTO airline_alias VALUES ('RE', 'REA', 'Aer Arann Express (Ireland)', 'Aer Arann Express (Ireland)');
INSERT INTO airline_alias VALUES ('RF', 'FWL', 'Florida West International Airways (USA)', 'Florida West International Airways (USA)');
INSERT INTO airline_alias VALUES ('RH', 'RPH', 'Republic Express Airlines (Indonesia)', 'Republic Express Airlines (Indonesia)');
INSERT INTO airline_alias VALUES ('RI', 'MDL', 'Mandala Airlines (Indonesia)', 'Mandala Airlines (Indonesia)');
INSERT INTO airline_alias VALUES ('RJ', 'RJA', 'Royal Jordanian', 'Royal Jordanian');
INSERT INTO airline_alias VALUES ('RK', 'RKH', 'Royal Khmer Airlines (Cambodia)', 'Royal Khmer Airlines (Cambodia)');
INSERT INTO airline_alias VALUES ('RL', 'PPW', 'Royal Phnom Penh Airways (Cambodia)', 'Royal Phnom Penh Airways (Cambodia)');
INSERT INTO airline_alias VALUES ('RN', 'ERL', 'Euralair (France)', 'Euralair (France)');
INSERT INTO airline_alias VALUES ('RO', 'ROT', 'Tarom (Romania)', 'Tarom (Romania)');
INSERT INTO airline_alias VALUES ('RQ', 'KMR', 'Kam Air (Afghanistan)', 'Kam Air (Afghanistan)');
INSERT INTO airline_alias VALUES ('RR', 'RFR', 'Royal Air Force (UK)', 'Royal Air Force (UK)');
INSERT INTO airline_alias VALUES ('RS', 'ICT', 'Intercontinental de Aviacion (Colombia)', 'Intercontinental de Aviacion (Colombia)');
INSERT INTO airline_alias VALUES ('RS', 'ORF', 'Oman Royal Flight', 'Oman Royal Flight');
INSERT INTO airline_alias VALUES ('RT', 'LRT', 'Airlines of South Australia', 'Airlines of South Australia');
INSERT INTO airline_alias VALUES ('RU', 'SKI', 'TCI Skyking (Turks and Caicos Is.)', 'TCI Skyking (Turks and Caicos Is.)');
INSERT INTO airline_alias VALUES ('RV', 'CPN', 'Caspian Airlines Service Company (Iran)', 'Caspian Airlines Service Company (Iran)');
INSERT INTO airline_alias VALUES ('RX', 'AEH', 'Aviaexpress (Hungary)', 'Aviaexpress (Hungary)');
INSERT INTO airline_alias VALUES ('RY', 'EXC', 'Euro Exec Express (Sweden)', 'Euro Exec Express (Sweden)');
INSERT INTO airline_alias VALUES ('RZ', 'LRS', 'Sansa (Costa Rica)', 'Sansa (Costa Rica)');
INSERT INTO airline_alias VALUES ('S2', 'SHD', 'Sahara Airlines (India)', 'Sahara Airlines (India)');
INSERT INTO airline_alias VALUES ('S3', 'BBR', 'Santa Barbara Airlines (Venezuela)', 'Santa Barbara Airlines (Venezuela)');
INSERT INTO airline_alias VALUES ('S4', 'RZO', 'Sata International (Portugal)', 'Sata International (Portugal)');
INSERT INTO airline_alias VALUES ('S7', 'SBI', 'Sibir/Siberia Airlines (Russian Federation)', 'Sibir/Siberia Airlines (Russian Federation)');
INSERT INTO airline_alias VALUES ('S8', 'CAH', 'Chari Aviation Services (South Africa)', 'Chari Aviation Services (South Africa)');
INSERT INTO airline_alias VALUES ('S8', 'SWW', 'Shovkoviy Shlyah Airlines (Ukraine)', 'Shovkoviy Shlyah Airlines (Ukraine)');
INSERT INTO airline_alias VALUES ('S9', 'HSA', 'East African Safari Air (Kenya)', 'East African Safari Air (Kenya)');
INSERT INTO airline_alias VALUES ('SA', 'SAA', 'South African Airways', 'South African Airways');
INSERT INTO airline_alias VALUES ('SB', 'ACI', 'Aircalin/Air Caledonie International (France)', 'Aircalin/Air Caledonie International (France)');
INSERT INTO airline_alias VALUES ('SC', 'CDG', 'Shandong Airlines (China)', 'Shandong Airlines (China)');
INSERT INTO airline_alias VALUES ('SD', 'SUD', 'Sudan Airways', 'Sudan Airways');
INSERT INTO airline_alias VALUES ('SE', 'SEU', 'Star Airlines (France)', 'Star Airlines (France)');
INSERT INTO airline_alias VALUES ('SF', 'DTH', 'Tassili Airlines (Algeria)', 'Tassili Airlines (Algeria)');
INSERT INTO airline_alias VALUES ('SG', 'JGO', 'JetsGo (Canada)', 'JetsGo (Canada)');
INSERT INTO airline_alias VALUES ('SG', 'SSR', 'Sempati Air (Indonesia)', 'Sempati Air (Indonesia)');
INSERT INTO airline_alias VALUES ('SI', 'SIH', 'Skynet Airlines (Ireland)', 'Skynet Airlines (Ireland)');
INSERT INTO airline_alias VALUES ('SJ', 'FOM', 'Freedom Air International (New Zealand)', 'Freedom Air International (New Zealand)');
INSERT INTO airline_alias VALUES ('SK', 'SAS', 'Scandinavian Airlines (Denmark/Norway/Sweden)', 'Scandinavian Airlines (Denmark/Norway/Sweden)');
INSERT INTO airline_alias VALUES ('SL', 'RSL', 'Rio Sul (Brazil)', 'Rio Sul (Brazil)');
INSERT INTO airline_alias VALUES ('SM', 'SRL', 'Swedline Express (Sweden)', 'Swedline Express (Sweden)');
INSERT INTO airline_alias VALUES ('SN', 'SAB', 'SN Brussels Airlines (Belgium)', 'SN Brussels Airlines (Belgium)');
INSERT INTO airline_alias VALUES ('SP', 'SAT', 'SATA Air Acores (Portugal)', 'SATA Air Acores (Portugal)');
INSERT INTO airline_alias VALUES ('SQ', 'SIA', 'Singapore Airlines', 'Singapore Airlines');
INSERT INTO airline_alias VALUES ('SS', 'CRL', 'Corsair/Corse Air International (France)', 'Corsair/Corse Air International (France)');
INSERT INTO airline_alias VALUES ('ST', 'GMI', 'Germania (Germany)', 'Germania (Germany)');
INSERT INTO airline_alias VALUES ('OM', 'MGL', 'MIAT Mongolian Airlines', 'MIAT Mongolian Airlines');
INSERT INTO airline_alias VALUES ('OP', 'CHK', 'Chalk''s International Airlines (USA)', 'Chalk''s International Airlines (USA)');
INSERT INTO airline_alias VALUES ('OQ', 'QNA', 'Aeronaves Queen/Queen Air (Dominican Republic)', 'Aeronaves Queen/Queen Air (Dominican Republic)');
INSERT INTO airline_alias VALUES ('OS', 'AUA', 'Austrian Airlines', 'Austrian Airlines');
INSERT INTO airline_alias VALUES ('OT', 'PEL', 'Aeropelican Air Services (Austrlalia)', 'Aeropelican Air Services (Austrlalia)');
INSERT INTO airline_alias VALUES ('OU', 'CTN', 'Croatia Airlines', 'Croatia Airlines');
INSERT INTO airline_alias VALUES ('OV', 'ELL', 'Estonian Air', 'Estonian Air');
INSERT INTO airline_alias VALUES ('OW', 'EXW', 'Executive Airlines (USA)', 'Executive Airlines (USA)');
INSERT INTO airline_alias VALUES ('OX', 'OEA', 'Orient Thai Airlines', 'Orient Thai Airlines');
INSERT INTO airline_alias VALUES ('OY', 'SDE', 'Soder Air (Finland)', 'Soder Air (Finland)');
INSERT INTO airline_alias VALUES ('OZ', 'AAR', 'Asiana Airlines (South Korea)', 'Asiana Airlines (South Korea)');
INSERT INTO airline_alias VALUES ('P2', 'TMN', 'Tyumenaviatrans (Russian Federation)', 'Tyumenaviatrans (Russian Federation)');
INSERT INTO airline_alias VALUES ('P5', 'RPB', 'Aerorepublica (Colombia)', 'Aerorepublica (Colombia)');
INSERT INTO airline_alias VALUES ('P8', 'PTN', 'Pantanal Linhas Aereas Sul-Matogrossenses (Brazil)', 'Pantanal Linhas Aereas Sul-Matogrossenses (Brazil)');
INSERT INTO airline_alias VALUES ('P9', 'NCM', 'Nas Air (Mali)', 'Nas Air (Mali)');
INSERT INTO airline_alias VALUES ('PA', 'FCL', 'Florida Coastal Airlines (USA)', 'Florida Coastal Airlines (USA)');
INSERT INTO airline_alias VALUES ('PC', 'FAJ', 'Air Fiji/PacificLink', 'Air Fiji/PacificLink');
INSERT INTO airline_alias VALUES ('PC', 'PVV', 'Continental Airways (Russian Federation)', 'Continental Airways (Russian Federation)');
INSERT INTO airline_alias VALUES ('PD', 'PEM', 'PemAir (Canada)', 'PemAir (Canada)');
INSERT INTO airline_alias VALUES ('PE', 'AEL', 'Air Europe Italy', 'Air Europe Italy');
INSERT INTO airline_alias VALUES ('PF', 'PNW', 'Palestinian Airlines', 'Palestinian Airlines');
INSERT INTO airline_alias VALUES ('PG', 'BKP', 'Bangkok Airlines (Thailand)', 'Bangkok Airlines (Thailand)');
INSERT INTO airline_alias VALUES ('PH', 'PAO', 'Polynesian Airline of Samoa', 'Polynesian Airline of Samoa');
INSERT INTO airline_alias VALUES ('PI', 'SUF', 'Sun Air/Sunflower Airlines (Fiji)', 'Sun Air/Sunflower Airlines (Fiji)');
INSERT INTO airline_alias VALUES ('PJ', 'SPM', 'Air Saint-Pierre (France)', 'Air Saint-Pierre (France)');
INSERT INTO airline_alias VALUES ('PK', 'PIA', 'Pakistan International Airlines', 'Pakistan International Airlines');
INSERT INTO airline_alias VALUES ('PL', 'ASE', 'Airstars (Russian Federation)', 'Airstars (Russian Federation)');
INSERT INTO airline_alias VALUES ('PM', 'TOS', 'Tropic Air (Belize)', 'Tropic Air (Belize)');
INSERT INTO airline_alias VALUES ('PN', 'PAA', 'Pan American Airways (USA)', 'Pan American Airways (USA)');
INSERT INTO airline_alias VALUES ('PP', 'PJS', 'Jet Aviation Business Jets (Switzerland)', 'Jet Aviation Business Jets (Switzerland)');
INSERT INTO airline_alias VALUES ('PQ', 'KST', 'PTL Luftfahrunternehmen (Germany)', 'PTL Luftfahrunternehmen (Germany)');
INSERT INTO airline_alias VALUES ('PQ', 'PNF', 'Panafrican Airways (Cote d''Ivoire)', 'Panafrican Airways (Cote d''Ivoire)');
INSERT INTO airline_alias VALUES ('PR', 'PAL', 'Philippine Airlines', 'Philippine Airlines');
INSERT INTO airline_alias VALUES ('PS', 'AUI', 'Ukraine International Airlines', 'Ukraine International Airlines');
INSERT INTO airline_alias VALUES ('PT', 'SWN', 'West Air Sweden', 'West Air Sweden');
INSERT INTO airline_alias VALUES ('PV', 'PNR', 'Pan Air Lineas Aereas (Spain)', 'Pan Air Lineas Aereas (Spain)');
INSERT INTO airline_alias VALUES ('PW', 'PRF', 'Precision Air Services (United Rep. of Tanzania)', 'Precision Air Services (United Rep. of Tanzania)');
INSERT INTO airline_alias VALUES ('PX', 'ANG', 'Air Niugini (Papua New Guinea)', 'Air Niugini (Papua New Guinea)');
INSERT INTO airline_alias VALUES ('PZ', 'LAP', 'TAM Paraguay', 'TAM Paraguay');
INSERT INTO airline_alias VALUES ('Q3', 'MBN', 'Zambian Airways', 'Zambian Airways');
INSERT INTO airline_alias VALUES ('Q4', 'MAW', 'Mustique Airways (St. Vincent and the Grenadines)', 'Mustique Airways (St. Vincent and the Grenadines)');
INSERT INTO airline_alias VALUES ('Q4', 'SWX', 'Swazi Express Airways', 'Swazi Express Airways');
INSERT INTO airline_alias VALUES ('Q5', 'MLA', '40-Mile Air (USA)', '40-Mile Air (USA)');
INSERT INTO airline_alias VALUES ('Q6', 'CDP', 'Aero Condor (Peru)', 'Aero Condor (Peru)');
INSERT INTO airline_alias VALUES ('Q8', 'PEC', 'Pacific East Asia Cargo Airlines (Philippines)', 'Pacific East Asia Cargo Airlines (Philippines)');
INSERT INTO airline_alias VALUES ('Q8', 'TSG', 'Trans Air Congo', 'Trans Air Congo');
INSERT INTO airline_alias VALUES ('Q9', 'AFU', 'Afrinat International Airlines (Ghana)', 'Afrinat International Airlines (Ghana)');
INSERT INTO airline_alias VALUES ('QA', 'CBE', 'Aerocaribe (Mexico)', 'Aerocaribe (Mexico)');
INSERT INTO airline_alias VALUES ('QC', 'CRD', 'Air Corridor (Mozambique)', 'Air Corridor (Mozambique)');
INSERT INTO airline_alias VALUES ('QC', 'QLA', 'Aviation Quebec Labrador (Canada)', 'Aviation Quebec Labrador (Canada)');
INSERT INTO airline_alias VALUES ('QD', 'QCL', 'Air Class Lineas Aereas/AeroVIP Ltda. (Uruguay)', 'Air Class Lineas Aereas/AeroVIP Ltda. (Uruguay)');
INSERT INTO airline_alias VALUES ('QE', 'ECC', 'Crossair Europe/ECA Europe Continental Airways (Switzerland)', 'Crossair Europe/ECA Europe Continental Airways (Switzerland)');
INSERT INTO airline_alias VALUES ('QF', 'QFA', 'Qantas (Australia)', 'Qantas (Australia)');
INSERT INTO airline_alias VALUES ('QH', 'LYN', 'Altyn Air Airlines (Kyrgyzstan)', 'Altyn Air Airlines (Kyrgyzstan)');
INSERT INTO airline_alias VALUES ('QI', 'CIM', 'Team Lufthansa/Cimber Air (Denmark)', 'Team Lufthansa/Cimber Air (Denmark)');
INSERT INTO airline_alias VALUES ('QJ', 'LTP', 'Latpass Airlines (Latvia)', 'Latpass Airlines (Latvia)');
INSERT INTO airline_alias VALUES ('QK', 'JZA', 'Air Canada Jazz', 'Air Canada Jazz');
INSERT INTO airline_alias VALUES ('QL', 'RNL', 'Serendib Express (Sri Lanka)', 'Serendib Express (Sri Lanka)');
INSERT INTO airline_alias VALUES ('QM', 'AML', 'Air Malawi', 'Air Malawi');
INSERT INTO airline_alias VALUES ('QO', 'MPX', 'Aeromexpress SA de CV (Mexico)', 'Aeromexpress SA de CV (Mexico)');
INSERT INTO airline_alias VALUES ('QO', 'OGN', 'Origin Pacific Airways (New Zealand)', 'Origin Pacific Airways (New Zealand)');
INSERT INTO airline_alias VALUES ('OY', 'OAE', 'Omni Air Express (USA)', 'Omni Air Express');
INSERT INTO airline_alias VALUES ('MB', 'MNB', 'MNG Cargo Airlines (Turkey)', 'MNG Cargo Airlines (Turkey)');
INSERT INTO airline_alias VALUES ('MC', 'RCH', 'MAC Military Aircraft Command (USA)', 'MAC Military Aircraft Command (USA)');
INSERT INTO airline_alias VALUES ('MC', 'MCS', 'Macedonian Airlines (Greece)', 'Macedonian Airlines (Greece)');
INSERT INTO airline_alias VALUES ('MD', 'MDG', 'Air Madagascar', 'Air Madagascar');
INSERT INTO airline_alias VALUES ('ME', 'MEA', 'MEA Middle East Airlines Airliban (Lebanon)', 'MEA Middle East Airlines Airliban (Lebanon)');
INSERT INTO airline_alias VALUES ('MF', 'CXA', 'Xiamen Airlines (China)', 'Xiamen Airlines (China)');
INSERT INTO airline_alias VALUES ('MH', 'MAS', 'Malaysia Airlines', 'Malaysia Airlines');
INSERT INTO airline_alias VALUES ('MI', 'SLK', 'SilkAir (Singapore)', 'SilkAir (Singapore)');
INSERT INTO airline_alias VALUES ('MJ', 'LPR', 'LAPA (Argentina)', 'LAPA (Argentina)');
INSERT INTO airline_alias VALUES ('MK', 'MAU', 'Air Mauritius', 'Air Mauritius');
INSERT INTO airline_alias VALUES ('MM', 'MMZ', 'Euroatlantic Airways (Portugal)', 'Euroatlantic Airways (Portugal)');
INSERT INTO airline_alias VALUES ('MN', 'CAW', 'Comair Commercial Airlines/kulula.com (South Africa)', 'Comair Commercial Airlines/kulula.com (South Africa)');
INSERT INTO airline_alias VALUES ('MO', 'AUH', 'Abu Dhabi Amiri Flight (United Arab Emirates)', 'Abu Dhabi Amiri Flight (United Arab Emirates)');
INSERT INTO airline_alias VALUES ('MO', 'CAV', 'Calm Air (Canada)', 'Calm Air (Canada)');
INSERT INTO airline_alias VALUES ('MP', 'MPH', 'Martinair (Netherlands)', 'Martinair (Netherlands)');
INSERT INTO airline_alias VALUES ('OH', 'COM', 'Delta Connection/Comair (USA)', 'Comair');
INSERT INTO airline_alias VALUES ('MR', 'MRT', 'Air Mauritanie (Mauritania)', 'Air Mauritanie (Mauritania)');
INSERT INTO airline_alias VALUES ('MS', 'MSR', 'EgyptAir', 'EgyptAir');
INSERT INTO airline_alias VALUES ('MT', 'TCX', 'Thomas Cook Airlines (UK)', 'Thomas Cook Airlines (UK)');
INSERT INTO airline_alias VALUES ('MU', 'CES', 'China Eastern Airlines', 'China Eastern Airlines');
INSERT INTO airline_alias VALUES ('MV', 'RML', 'Armenian International Airlines', 'Armenian International Airlines');
INSERT INTO airline_alias VALUES ('MW', 'MYD', 'Maya Island Air (Belize)', 'Maya Island Air (Belize)');
INSERT INTO airline_alias VALUES ('MX', 'MXA', 'Mexicana Airlines (Mexico)', 'Mexicana Airlines (Mexico)');
INSERT INTO airline_alias VALUES ('MY', 'MWA', 'Midwest Airlines (Egypt)', 'Midwest Airlines (Egypt)');
INSERT INTO airline_alias VALUES ('MY', 'MAA', 'MasCarga (Mexico)', 'MasCarga (Mexico)');
INSERT INTO airline_alias VALUES ('MZ', 'MNA', 'Merpati Nusantara Airlines (Indonesia)', 'Merpati Nusantara Airlines (Indonesia)');
INSERT INTO airline_alias VALUES ('N2', 'LNT', 'Aerolineas Internacionales SA de CV (Mexico)', 'Aerolineas Internacionales SA de CV (Mexico)');
INSERT INTO airline_alias VALUES ('N3', 'OMS', 'Omskavia Airline (Russian Federation)', 'Omskavia Airline (Russian Federation)');
INSERT INTO airline_alias VALUES ('N4', 'MTC', 'Minerva Airlines (Italy)', 'Minerva Airlines (Italy)');
INSERT INTO airline_alias VALUES ('N5', 'KYL', 'Kyrgyz International Airlines', 'Kyrgyz International Airlines');
INSERT INTO airline_alias VALUES ('N5', 'SGY', 'Skagway Air Service (USA)', 'Skagway Air Service (USA)');
INSERT INTO airline_alias VALUES ('N6', 'ACQ', 'Nuevo Continente (Peru)', 'Nuevo Continente (Peru)');
INSERT INTO airline_alias VALUES ('N7', 'JEV', 'Lagun Air (Spain)', 'Lagun Air (Spain)');
INSERT INTO airline_alias VALUES ('N8', 'CRK', 'CR Airways (China-Hong Kong)', 'CR Airways (China-Hong Kong)');
INSERT INTO airline_alias VALUES ('N8', 'SEK', 'Salaam Express Air Services (Kenya)', 'Salaam Express Air Services (Kenya)');
INSERT INTO airline_alias VALUES ('NA', 'NAO', 'North American Airlines (USA)', 'North American Airlines (USA)');
INSERT INTO airline_alias VALUES ('NB', 'SNB', 'Sterling European Airlines (Denmark)', 'Sterling European Airlines (Denmark)');
INSERT INTO airline_alias VALUES ('NC', 'NAC', 'Northern Air Cargo (USA)', 'Northern Air Cargo (USA)');
INSERT INTO airline_alias VALUES ('NC', 'NJS', 'National Jet Systems (Australia)', 'National Jet Systems (Australia)');
INSERT INTO airline_alias VALUES ('NE', 'ESK', 'SkyEurope Airlines (Slovakia)', 'SkyEurope Airlines (Slovakia)');
INSERT INTO airline_alias VALUES ('NF', 'AVN', 'Air Vanuatu', 'Air Vanuatu');
INSERT INTO airline_alias VALUES ('NG', 'LDA', 'Lauda Air (Austria)', 'Lauda Air (Austria)');
INSERT INTO airline_alias VALUES ('NH', 'ANA', 'ANA All-Nippon Airways (Japan)', 'ANA All-Nippon Airways (Japan)');
INSERT INTO airline_alias VALUES ('NI', 'PGA', 'Portugalia (Portugal)', 'Portugalia (Portugal)');
INSERT INTO airline_alias VALUES ('NK', 'NKS', 'Spirit Airlines (USA)', 'Spirit Airlines (USA)');
INSERT INTO airline_alias VALUES ('NL', 'SAI', 'Shaheen Air (Pakistan)', 'Shaheen Air (Pakistan)');
INSERT INTO airline_alias VALUES ('NM', 'DRI', 'Air Madrid (USA)', 'Air Madrid (USA)');
INSERT INTO airline_alias VALUES ('NM', 'NZM', 'Mount Cook Airlines (New Zealand)', 'Mount Cook Airlines (New Zealand)');
INSERT INTO airline_alias VALUES ('NN', 'MOV', 'Vim Airlines', 'Vim Airlines');
INSERT INTO airline_alias VALUES ('NO', 'NOS', 'Neos (Italy)', 'Neos (Italy)');
INSERT INTO airline_alias VALUES ('NQ', 'AJX', 'Air Japan', 'Air Japan');
INSERT INTO airline_alias VALUES ('NR', 'PIR', 'Pamir Air (Afghanistan)', 'Pamir Air (Afghanistan)');
INSERT INTO airline_alias VALUES ('NS', 'SRJ', 'Caucasus Airlines (Georgia)', 'Caucasus Airlines (Georgia)');
INSERT INTO airline_alias VALUES ('NT', 'IBB', 'Binter Canarias (Spain)', 'Binter Canarias (Spain)');
INSERT INTO airline_alias VALUES ('NU', 'JTA', 'Japan Transocean Air', 'Japan Transocean Air');
INSERT INTO airline_alias VALUES ('NX', 'AMU', 'Air Macau', 'Air Macau');
INSERT INTO airline_alias VALUES ('NY', 'FNA', 'Air Iceland/Flugfelag Islands', 'Air Iceland/Flugfelag Islands');
INSERT INTO airline_alias VALUES ('NZ', 'ANZ', 'Air New Zealand', 'Air New Zealand');
INSERT INTO airline_alias VALUES ('OA', 'OAL', 'Olympic Airlines (Greece)', 'Olympic Airlines (Greece)');
INSERT INTO airline_alias VALUES ('OB', 'ASZ', 'Astrakhan Airlines (Russian Federation)', 'Astrakhan Airlines (Russian Federation)');
INSERT INTO airline_alias VALUES ('OC', 'OAV', 'Omni Aviacao and Tecnologia/PGA Express (Portugal)', 'Omni Aviacao and Tecnologia/PGA Express (Portugal)');
INSERT INTO airline_alias VALUES ('OE', 'AOT', 'Asia Overnight Express Corporation (Philippines)', 'Asia Overnight Express Corporation (Philippines)');
INSERT INTO airline_alias VALUES ('OF', 'TML', 'Transports et Travaux Aeriens de Madagascar', 'Transports et Travaux Aeriens de Madagascar');
INSERT INTO airline_alias VALUES ('OJ', 'OLA', 'Overland Airways (Nigeria)', 'Overland Airways (Nigeria)');
INSERT INTO airline_alias VALUES ('OK', 'CSA', 'CSA Czech Airlines', 'CSA Czech Airlines');
INSERT INTO airline_alias VALUES ('OL', 'OLT', 'OLT Ostfriesische Lufttransport (Germany)', 'OLT Ostfriesische Lufttransport (Germany)');
INSERT INTO airline_alias VALUES ('K5', 'WAK', 'Wings of Alaska (USA)', 'Wings of Alaska (USA)');
INSERT INTO airline_alias VALUES ('K7', 'IKT', 'Sakha Airlines (Russian Federation)', 'Sakha Airlines (Russian Federation)');
INSERT INTO airline_alias VALUES ('K7', 'TMP', 'Arizona Express Airlines (USA)', 'Arizona Express Airlines (USA)');
INSERT INTO airline_alias VALUES ('K8', 'DCE', 'Dutch Caribbean Airlines (Netherlands Antilles)', 'Dutch Caribbean Airlines (Netherlands Antilles)');
INSERT INTO airline_alias VALUES ('K9', 'KRI', 'Krylo Aviakompania (Russian Federation)', 'Krylo Aviakompania (Russian Federation)');
INSERT INTO airline_alias VALUES ('K9', 'SGK', 'Skyward Aviation (Canada)', 'Skyward Aviation (Canada)');
INSERT INTO airline_alias VALUES ('KA', 'HDA', 'Dragonair/Hong Kong Dragon Airlines (China-Hong Kong)', 'Dragonair/Hong Kong Dragon Airlines (China-Hong Kong)');
INSERT INTO airline_alias VALUES ('KB', 'DRK', 'Druk Air (Bhutan)', 'Druk Air (Bhutan)');
INSERT INTO airline_alias VALUES ('KD', 'KNI', 'Kaliningradavia Open Joint Stock Company (Russian Federation)', 'Kaliningradavia Open Joint Stock Company (Russian Federation)');
INSERT INTO airline_alias VALUES ('KE', 'KAL', 'Korean Air', 'Korean Air');
INSERT INTO airline_alias VALUES ('KF', 'BLF', 'Blue1 (Finland)', 'Blue1 (Finland)');
INSERT INTO airline_alias VALUES ('KG', 'BNX', 'Linea Aerea IAACA-LAI (Venezuela)', 'Linea Aerea IAACA-LAI (Venezuela)');
INSERT INTO airline_alias VALUES ('KJ', 'LAJ', 'British Mediterranean Airways', 'British Mediterranean Airways');
INSERT INTO airline_alias VALUES ('KK', 'OGE', 'AtlasJet (Turkey)', 'AtlasJet (Turkey)');
INSERT INTO airline_alias VALUES ('KL', 'KLM', 'KLM Royal Dutch Airlines', 'KLM Royal Dutch Airlines');
INSERT INTO airline_alias VALUES ('KO', 'AER', 'Alaska Central Express (USA)', 'Alaska Central Express (USA)');
INSERT INTO airline_alias VALUES ('KQ', 'KQA', 'Kenya Airways', 'Kenya Airways');
INSERT INTO airline_alias VALUES ('K4', 'CKS', 'Kalitta Air (USA)', 'Kalitta Air');
INSERT INTO airline_alias VALUES ('KS', 'PEN', 'Penair/Peninsula Airways (USA)', 'Penair/Peninsula Airways (USA)');
INSERT INTO airline_alias VALUES ('KT', 'KAF', 'Kyrgyz Air (Kyrgyzstan)', 'Kyrgyz Air (Kyrgyzstan)');
INSERT INTO airline_alias VALUES ('KU', 'KAC', 'Kuwait Airways', 'Kuwait Airways');
INSERT INTO airline_alias VALUES ('KV', 'MVD', 'Kavminvodyavia (Russian Federation)', 'Kavminvodyavia (Russian Federation)');
INSERT INTO airline_alias VALUES ('KW', 'KSD', 'Kas Air (Kazakhstan)', 'Kas Air (Kazakhstan)');
INSERT INTO airline_alias VALUES ('KX', 'CAY', 'Cayman Airways', 'Cayman Airways');
INSERT INTO airline_alias VALUES ('KY', 'EQL', 'Air Sao Tome e Principe', 'Air Sao Tome e Principe');
INSERT INTO airline_alias VALUES ('KZ', 'NCA', 'Nippon Cargo Airlines (Japan)', 'Nippon Cargo Airlines (Japan)');
INSERT INTO airline_alias VALUES ('L2', 'LYC', 'Lynden Air Cargo (USA)', 'Lynden Air Cargo (USA)');
INSERT INTO airline_alias VALUES ('L3', 'JOS', 'DHL de Guatemala', 'DHL de Guatemala');
INSERT INTO airline_alias VALUES ('L3', 'LTO', 'LTU Billa (Austria)', 'LTU Billa (Austria)');
INSERT INTO airline_alias VALUES ('L4', 'LDI', 'Lauda Air Italy', 'Lauda Air Italy');
INSERT INTO airline_alias VALUES ('L5', 'HKS', 'Helikopter Service (Norway)', 'Helikopter Service (Norway)');
INSERT INTO airline_alias VALUES ('L6', 'VNZ', 'Tbilaviamsheni (Georgia)', 'Tbilaviamsheni (Georgia)');
INSERT INTO airline_alias VALUES ('L7', 'LPN', 'Laoag International Airlines (Philippines)', 'Laoag International Airlines (Philippines)');
INSERT INTO airline_alias VALUES ('L8', 'LXG', 'Air Luxor (Guinea-Bissau)', 'Air Luxor (Guinea-Bissau)');
INSERT INTO airline_alias VALUES ('L9', 'TLW', 'Teamline Air Luftfahrt (Austria)', 'Teamline Air Luftfahrt (Austria)');
INSERT INTO airline_alias VALUES ('LA', 'LAN', 'LAN (Chile)', 'LAN (Chile)');
INSERT INTO airline_alias VALUES ('LB', 'LLB', 'LAB Airlines (Bolivia)', 'LAB Airlines (Bolivia)');
INSERT INTO airline_alias VALUES ('LC', 'VLO', 'Varig Log (Brazil)', 'Varig Log (Brazil)');
INSERT INTO airline_alias VALUES ('LD', 'AHK', 'Air Hong Kong (China-Hong Kong)', 'Air Hong Kong (China-Hong Kong)');
INSERT INTO airline_alias VALUES ('LD', 'TUY', 'Linea Turistica Aerotuy (Venezuela)', 'Linea Turistica Aerotuy (Venezuela)');
INSERT INTO airline_alias VALUES ('LF', 'NDC', 'Nordic East Airlink (Sweden)', 'Nordic East Airlink (Sweden)');
INSERT INTO airline_alias VALUES ('LG', 'LGL', 'Luxair (Luxembourg)', 'Luxair (Luxembourg)');
INSERT INTO airline_alias VALUES ('LH', 'DLH', 'Lufthansa (Germany)', 'Lufthansa (Germany)');
INSERT INTO airline_alias VALUES ('LI', 'LIA', 'LIAT (Antigua and Barbuda)', 'LIAT (Antigua and Barbuda)');
INSERT INTO airline_alias VALUES ('LJ', 'SLA', 'Sierra National Airlines (Sierra Leone)', 'Sierra National Airlines (Sierra Leone)');
INSERT INTO airline_alias VALUES ('LK', 'LXR', 'Air Luxor (Portugal)', 'Air Luxor (Portugal)');
INSERT INTO airline_alias VALUES ('LL', 'GRO', 'Allegro Air (Mexico)', 'Allegro Air (Mexico)');
INSERT INTO airline_alias VALUES ('LM', 'LVG', 'Livingston (Italy)', 'Livingston (Italy)');
INSERT INTO airline_alias VALUES ('LN', 'LAA', 'Jamahiriya Lybian Arab Airlines', 'Jamahiriya Lybian Arab Airlines');
INSERT INTO airline_alias VALUES ('LO', 'LOT', 'LOT Polish Airlines', 'LOT Polish Airlines');
INSERT INTO airline_alias VALUES ('LR', 'LRC', 'Lacsa (Costa Rica)', 'Lacsa (Costa Rica)');
INSERT INTO airline_alias VALUES ('LS', 'EXS', 'Channel Express (UK)', 'Channel Express (UK)');
INSERT INTO airline_alias VALUES ('LT', 'LTU', 'LTU International Airways (Germany)', 'LTU International Airways (Germany)');
INSERT INTO airline_alias VALUES ('LU', 'TAS', 'Lotus Air (Egypt)', 'Lotus Air (Egypt)');
INSERT INTO airline_alias VALUES ('LV', 'LBC', 'Albanian Airlines', 'Albanian Airlines');
INSERT INTO airline_alias VALUES ('LW', 'ANV', 'Pacific Wings (USA)', 'Pacific Wings (USA)');
INSERT INTO airline_alias VALUES ('LX', 'SWR', 'Swiss International Air Lines', 'Swiss International Air Lines');
INSERT INTO airline_alias VALUES ('LY', 'ELY', 'El Al (Israel)', 'El Al (Israel)');
INSERT INTO airline_alias VALUES ('M2', 'MZS', 'Mahfooz Aviation (Gambia)', 'Mahfooz Aviation (Gambia)');
INSERT INTO airline_alias VALUES ('M3', 'NFA', 'North Flying (Denmark)', 'North Flying (Denmark)');
INSERT INTO airline_alias VALUES ('M3', 'SPJ', 'Air Service (Macedonia)', 'Air Service (Macedonia)');
INSERT INTO airline_alias VALUES ('M3', 'TUS', 'ABSA Aerolinhas Brasileiras (Brazil)', 'ABSA Aerolinhas Brasileiras (Brazil)');
INSERT INTO airline_alias VALUES ('M4', 'AXX', 'Avioimpex (Macedonia)', 'Avioimpex (Macedonia)');
INSERT INTO airline_alias VALUES ('M6', 'AJT', 'Amerijet International (USA)', 'Amerijet International (USA)');
INSERT INTO airline_alias VALUES ('M7', 'SUK', 'Superior Aviation Services (Kenya)', 'Superior Aviation Services (Kenya)');
INSERT INTO airline_alias VALUES ('M7', 'TBG', 'Tropical Airlines D''Haiti', 'Tropical Airlines D''Haiti');
INSERT INTO airline_alias VALUES ('M8', 'MKN', 'Mekong Airlines (Cambodia)', 'Mekong Airlines (Cambodia)');
INSERT INTO airline_alias VALUES ('M9', 'MSI', 'Motor Sich Aviakompania (Ukraine)', 'Motor Sich Aviakompania (Ukraine)');
INSERT INTO airline_alias VALUES ('MA', 'MAH', 'Malev (Hungary)', 'Malev (Hungary)');
INSERT INTO airline_alias VALUES ('MB', 'EXA', 'Execaire (Canada)', 'Execaire (Canada)');
INSERT INTO airline_alias VALUES ('HG', 'NLY', 'flyniki (Austria)', 'flyniki (Austria)');
INSERT INTO airline_alias VALUES ('HH', 'ICB', 'Icebird/Islandsflug (Iceland)', 'Icebird/Islandsflug (Iceland)');
INSERT INTO airline_alias VALUES ('HJ', 'AXF', 'Asian Express Airlines (Australia)', 'Asian Express Airlines (Australia)');
INSERT INTO airline_alias VALUES ('HK', 'FSC', 'Four Star Aviation (US Virgin Is.)', 'Four Star Aviation (US Virgin Is.)');
INSERT INTO airline_alias VALUES ('HM', 'SEY', 'Air Seychelles', 'Air Seychelles');
INSERT INTO airline_alias VALUES ('HN', 'HVY', 'Heavylift Cargo Airlines (Australia)', 'Heavylift Cargo Airlines (Australia)');
INSERT INTO airline_alias VALUES ('HN', 'PTH', 'Proteus Helicopters (France)', 'Proteus Helicopters (France)');
INSERT INTO airline_alias VALUES ('HO', 'DJA', 'Antinea Airlines (Algeria)', 'Antinea Airlines (Algeria)');
INSERT INTO airline_alias VALUES ('HQ', 'HMY', 'Harmony Airways/HMY Airways (Canada)', 'Harmony Airways/HMY Airways (Canada)');
INSERT INTO airline_alias VALUES ('HR', 'HHN', 'Hahn Air Lines (Germany)', 'Hahn Air Lines (Germany)');
INSERT INTO airline_alias VALUES ('HS', 'HSV', 'Svenska Direktflyg (Sweden)', 'Svenska Direktflyg (Sweden)');
INSERT INTO airline_alias VALUES ('HT', 'AHW', 'Aeromist/Kharkiv (Ukraine)', 'Aeromist/Kharkiv (Ukraine)');
INSERT INTO airline_alias VALUES ('HT', 'MOD', 'Modiluft (India)', 'Modiluft (India)');
INSERT INTO airline_alias VALUES ('HU', 'CHH', 'Hainan Airlines (China)', 'Hainan Airlines (China)');
INSERT INTO airline_alias VALUES ('HV', 'TRA', 'Transavia/Basiq Air (Netherlands)', 'Transavia/Basiq Air (Netherlands)');
INSERT INTO airline_alias VALUES ('HW', 'NWL', 'North-Wright Airways (Canada)', 'North-Wright Airways (Canada)');
INSERT INTO airline_alias VALUES ('HY', 'UZB', 'Uzbekistan Airways', 'Uzbekistan Airways');
INSERT INTO airline_alias VALUES ('HZ', 'SHU', 'SAT Sakhalin Airlines (Russian Federation)', 'SAT Sakhalin Airlines (Russian Federation)');
INSERT INTO airline_alias VALUES ('I9', 'IBU', 'Indigo (USA)', 'Indigo (USA)');
INSERT INTO airline_alias VALUES ('IA', 'IAW', 'Iraqi Airways', 'Iraqi Airways');
INSERT INTO airline_alias VALUES ('IB', 'IBE', 'Iberia (Spain)', 'Iberia (Spain)');
INSERT INTO airline_alias VALUES ('IC', 'IAC', 'Indian Airlines', 'Indian Airlines');
INSERT INTO airline_alias VALUES ('ID', 'ITK', 'Interlink Airlines (South Africa)', 'Interlink Airlines (South Africa)');
INSERT INTO airline_alias VALUES ('IE', 'SOL', 'Solomon Airlines', 'Solomon Airlines');
INSERT INTO airline_alias VALUES ('IF', 'ISW', 'Islas Airways (Spain)', 'Islas Airways (Spain)');
INSERT INTO airline_alias VALUES ('IG', 'ISS', 'Meridiana (Italy)', 'Meridiana (Italy)');
INSERT INTO airline_alias VALUES ('IH', 'FCN', 'Falcon Aviation (Sweden)', 'Falcon Aviation (Sweden)');
INSERT INTO airline_alias VALUES ('II', 'CSQ', 'IBC Airways (USA)', 'IBC Airways (USA)');
INSERT INTO airline_alias VALUES ('IK', 'ITX', 'IMAIR (Azerbaijan)', 'IMAIR (Azerbaijan)');
INSERT INTO airline_alias VALUES ('IL', 'LKN', 'Lankair Private (Sri Lanka)', 'Lankair Private (Sri Lanka)');
INSERT INTO airline_alias VALUES ('IN', 'MAK', 'MAT Macedonian Airlines (F.Y.R. Macedonia)', 'MAT Macedonian Airlines (F.Y.R. Macedonia)');
INSERT INTO airline_alias VALUES ('IO', 'IAA', 'Indonesian Airlines Aviapatria', 'Indonesian Airlines Aviapatria');
INSERT INTO airline_alias VALUES ('IP', 'JOL', 'AAW Atyrau Air Ways (Kazakhstan)', 'AAW Atyrau Air Ways (Kazakhstan)');
INSERT INTO airline_alias VALUES ('IQ', 'AUB', 'Lufthansa Regional/Augsburg Airways (Germany)', 'Lufthansa Regional/Augsburg Airways (Germany)');
INSERT INTO airline_alias VALUES ('IS', 'ISA', 'Island Airlines (USA)', 'Island Airlines (USA)');
INSERT INTO airline_alias VALUES ('IS', 'ISL', 'Eagle Air/Arnaflug (Iceland)', 'Eagle Air/Arnaflug (Iceland)');
INSERT INTO airline_alias VALUES ('IT', 'IRT', 'Irtysh-Avia (Kazakhstan)', 'Irtysh-Avia (Kazakhstan)');
INSERT INTO airline_alias VALUES ('IV', 'JET', 'Wind Jet (Italy)', 'Wind Jet (Italy)');
INSERT INTO airline_alias VALUES ('IY', 'IYE', 'Yemenia (Yemen)', 'Yemenia (Yemen)');
INSERT INTO airline_alias VALUES ('IZ', 'AIZ', 'Arkia (Israel)', 'Arkia (Israel)');
INSERT INTO airline_alias VALUES ('J2', 'AHY', 'AZAL Azerbaijan Airlines/AHY', 'AZAL Azerbaijan Airlines/AHY');
INSERT INTO airline_alias VALUES ('J3', 'PLR', 'Northwestern Air Lease (Canada)', 'Northwestern Air Lease (Canada)');
INSERT INTO airline_alias VALUES ('J4', 'BFL', 'Buffalo Airways (Canada)', 'Buffalo Airways (Canada)');
INSERT INTO airline_alias VALUES ('J6', 'AOC', 'Avcom Aviation (Russian Federation)', 'Avcom Aviation (Russian Federation)');
INSERT INTO airline_alias VALUES ('J7', 'CVC', 'Centre-Avia Airlines (Russian Federation)', 'Centre-Avia Airlines (Russian Federation)');
INSERT INTO airline_alias VALUES ('J8', 'BVT', 'Berjaya Air (Malaysia)', 'Berjaya Air (Malaysia)');
INSERT INTO airline_alias VALUES ('J9', 'GIF', 'Guinee Airlines (Guinea)', 'Guinee Airlines (Guinea)');
INSERT INTO airline_alias VALUES ('JB', 'JBA', 'Helijet Airways (Canada)', 'Helijet Airways (Canada)');
INSERT INTO airline_alias VALUES ('JC', 'JEX', 'JAL Express (Japan)', 'JAL Express (Japan)');
INSERT INTO airline_alias VALUES ('JF', 'LAB', 'LAB Flying Service (USA)', 'LAB Flying Service (USA)');
INSERT INTO airline_alias VALUES ('JH', 'HLQ', 'Harlequin Air (Japan)', 'Harlequin Air (Japan)');
INSERT INTO airline_alias VALUES ('JH', 'NES', 'Nordeste-Linhas Aereas Regionais (Brazil)', 'Nordeste-Linhas Aereas Regionais (Brazil)');
INSERT INTO airline_alias VALUES ('JJ', 'BLC', 'TAM-Transportes Aereos Meridionais (Brazil)', 'TAM-Transportes Aereos Meridionais (Brazil)');
INSERT INTO airline_alias VALUES ('JK', 'JKK', 'Spanair (Spain)', 'Spanair (Spain)');
INSERT INTO airline_alias VALUES ('JL', 'JAL', 'Japan Airlines International Company', 'Japan Airlines International Company');
INSERT INTO airline_alias VALUES ('JM', 'AJM', 'Air Jamaica', 'Air Jamaica');
INSERT INTO airline_alias VALUES ('JN', 'XLA', 'Excel Airways (UK)', 'Excel Airways (UK)');
INSERT INTO airline_alias VALUES ('JO', 'JAZ', 'JALWays (Japan)', 'JALWays (Japan)');
INSERT INTO airline_alias VALUES ('JP', 'ADR', 'Adria Airways (Slovenia)', 'Adria Airways (Slovenia)');
INSERT INTO airline_alias VALUES ('JQ', 'JMX', 'Air Jamaica Express', 'Air Jamaica Express');
INSERT INTO airline_alias VALUES ('JQ', 'JST', 'Impulse Airlines/Jetstar Airways', 'Impulse Airlines/Jetstar Airways');
INSERT INTO airline_alias VALUES ('JR', 'SER', 'Aero California (Mexico)', 'Aero California (Mexico)');
INSERT INTO airline_alias VALUES ('JS', 'KOR', 'Air Koryo (North Korea)', 'Air Koryo (North Korea)');
INSERT INTO airline_alias VALUES ('JT', 'LNI', 'Lion Airlines/Lion Mentari Air (Indonesia)', 'Lion Airlines/Lion Mentari Air (Indonesia)');
INSERT INTO airline_alias VALUES ('JU', 'JAT', 'JAT Yugoslav Airlines', 'JAT Yugoslav Airlines');
INSERT INTO airline_alias VALUES ('JV', 'BLS', 'Bearskin Airlines (Canada)', 'Bearskin Airlines (Canada)');
INSERT INTO airline_alias VALUES ('JW', 'APW', 'Arrow Air (USA)', 'Arrow Air (USA)');
INSERT INTO airline_alias VALUES ('JY', 'IWY', 'Interisland Airways (Turks and Caicos Is.)', 'Interisland Airways (Turks and Caicos Is.)');
INSERT INTO airline_alias VALUES ('JZ', 'SKX', 'Skyways (Sweden)', 'Skyways (Sweden)');
INSERT INTO airline_alias VALUES ('K2', 'ELO', 'Eurolot (Poland)', 'Eurolot (Poland)');
INSERT INTO airline_alias VALUES ('FI', 'ICE', 'Icelandair', 'Icelandair');
INSERT INTO airline_alias VALUES ('FJ', 'FJI', 'Air Pacific (Fiji)', 'Air Pacific (Fiji)');
INSERT INTO airline_alias VALUES ('FK', 'WTA', 'Africa West (Togo)', 'Africa West (Togo)');
INSERT INTO airline_alias VALUES ('FM', 'CSH', 'Shanghai Airlines (China)', 'Shanghai Airlines (China)');
INSERT INTO airline_alias VALUES ('FN', 'RGL', 'Regional Airlines (Morocco)', 'Regional Airlines (Morocco)');
INSERT INTO airline_alias VALUES ('FO', 'ATM', 'Airlines of Tasmania (Australia)', 'Airlines of Tasmania (Australia)');
INSERT INTO airline_alias VALUES ('FP', 'FPG', 'TAG Aviation (Switzerland)', 'TAG Aviation (Switzerland)');
INSERT INTO airline_alias VALUES ('FP', 'FRE', 'Freedom Air (USA)', 'Freedom Air (USA)');
INSERT INTO airline_alias VALUES ('FQ', 'TCW', 'Thomas Cook Airlines (Belgium)', 'Thomas Cook Airlines (Belgium)');
INSERT INTO airline_alias VALUES ('FR', 'RYR', 'Ryanair (Ireland)', 'Ryanair (Ireland)');
INSERT INTO airline_alias VALUES ('FS', 'STU', 'STAF Airlines (Argentina)', 'STAF Airlines (Argentina)');
INSERT INTO airline_alias VALUES ('FT', 'SRH', 'Siem Reap Airways International (Cambodia)', 'Siem Reap Airways International (Cambodia)');
INSERT INTO airline_alias VALUES ('FV', 'PLK', 'Pulkovo Aviation Enterprise (Russian Federation)', 'Pulkovo Aviation Enterprise (Russian Federation)');
INSERT INTO airline_alias VALUES ('FW', 'FRI', 'Fair (Japan)', 'Fair (Japan)');
INSERT INTO airline_alias VALUES ('G4', 'AAY', 'Allegiant Air (USA)', 'Allegiant Air');
INSERT INTO airline_alias VALUES ('FY', 'NWR', 'Northwest Regional Airlines (Australia)', 'Northwest Regional Airlines (Australia)');
INSERT INTO airline_alias VALUES ('FZ', 'BBG', 'Alisea Airlines (Italy)', 'Alisea Airlines (Italy)');
INSERT INTO airline_alias VALUES ('G2', 'DOB', 'Dobrolet Airlines (Russian Federation)', 'Dobrolet Airlines (Russian Federation)');
INSERT INTO airline_alias VALUES ('G4', 'CGH', 'Air Guizhou (China)', 'Air Guizhou (China)');
INSERT INTO airline_alias VALUES ('G5', 'ENK', 'Enkor (Russian Federation)', 'Enkor (Russian Federation)');
INSERT INTO airline_alias VALUES ('G6', 'BSR', 'Guine Bissau Airlines', 'Guine Bissau Airlines');
INSERT INTO airline_alias VALUES ('G7', 'GNF', 'Gandalf Airlines (Italy)', 'Gandalf Airlines (Italy)');
INSERT INTO airline_alias VALUES ('G8', 'CGW', 'Air Great Wall (China)', 'Air Great Wall (China)');
INSERT INTO airline_alias VALUES ('G8', 'GUJ', 'Gujarat Airways (India)', 'Gujarat Airways (India)');
INSERT INTO airline_alias VALUES ('G9', 'CWG', 'Continental Wings (Gambia)', 'Continental Wings (Gambia)');
INSERT INTO airline_alias VALUES ('G9', 'GLO', 'GOL Transportes Aereos (Brazil)', 'GOL Transportes Aereos (Brazil)');
INSERT INTO airline_alias VALUES ('GA', 'GIA', 'Garuda Indonesia', 'Garuda Indonesia');
INSERT INTO airline_alias VALUES ('GC', 'GNR', 'Gambia International Airlines', 'Gambia International Airlines');
INSERT INTO airline_alias VALUES ('GD', 'AHA', 'Air Alpha Greenland', 'Air Alpha Greenland');
INSERT INTO airline_alias VALUES ('GE', 'TNA', 'Trans Asia Airways (Taiwan)', 'Trans Asia Airways (Taiwan)');
INSERT INTO airline_alias VALUES ('GF', 'GFA', 'Gulf Air (Bahrain/UAE/Oman/Qatar)', 'Gulf Air (Bahrain/UAE/Oman/Qatar)');
INSERT INTO airline_alias VALUES ('GG', 'GUY', 'Air Guyane (French Guiana)', 'Air Guyane (French Guiana)');
INSERT INTO airline_alias VALUES ('GH', 'GHA', 'Ghana Airways', 'Ghana Airways');
INSERT INTO airline_alias VALUES ('GI', 'IKA', 'Air Company Itek-Air (Kyrgyzstan)', 'Air Company Itek-Air (Kyrgyzstan)');
INSERT INTO airline_alias VALUES ('GJ', 'EEZ', 'Eurofly (Italy)', 'Eurofly (Italy)');
INSERT INTO airline_alias VALUES ('GL', 'GRL', 'Air Greenland (Denmark)', 'Air Greenland (Denmark)');
INSERT INTO airline_alias VALUES ('GL', 'BSK', 'Miami Air (USA)', 'Miami Air (USA)');
INSERT INTO airline_alias VALUES ('GM', 'SVK', 'Air Slovakia', 'Air Slovakia');
INSERT INTO airline_alias VALUES ('GN', 'AGN', 'Air Gabon', 'Air Gabon');
INSERT INTO airline_alias VALUES ('GP', 'CTH', 'China General Aviation', 'China General Aviation');
INSERT INTO airline_alias VALUES ('GP', 'GES', 'Gestair (Spain)', 'Gestair (Spain)');
INSERT INTO airline_alias VALUES ('GQ', 'BSY', 'Big Sky Airlines (USA)', 'Big Sky Airlines (USA)');
INSERT INTO airline_alias VALUES ('GR', 'AUR', 'Aurigny Air Services (UK)', 'Aurigny Air Services (UK)');
INSERT INTO airline_alias VALUES ('GR', 'GCO', 'Gemini Air Cargo (USA)', 'Gemini Air Cargo (USA)');
INSERT INTO airline_alias VALUES ('GS', 'UPA', 'Airfoyle (UK)', 'Airfoyle (UK)');
INSERT INTO airline_alias VALUES ('GT', 'GBL', 'GB Airways (UK)', 'GB Airways (UK)');
INSERT INTO airline_alias VALUES ('GW', 'KIL', 'Kuban Airlines (Russian Federation)', 'Kuban Airlines (Russian Federation)');
INSERT INTO airline_alias VALUES ('GX', 'PFR', 'Pacificair (Philippines)', 'Pacificair (Philippines)');
INSERT INTO airline_alias VALUES ('GY', 'GYA', 'Guyana Airlines 2000', 'Guyana Airlines 2000');
INSERT INTO airline_alias VALUES ('CY', 'CYP', 'Cyprus Airways', 'Cyprus Airways');
INSERT INTO airline_alias VALUES ('GY', 'TMG', 'Tri-MG Intra Asia Airlines (Indonesia)', 'Tri-MG Intra Asia Airlines (Indonesia)');
INSERT INTO airline_alias VALUES ('H2', 'SKU', 'Sky Service (Chile)', 'Sky Service (Chile)');
INSERT INTO airline_alias VALUES ('H4', 'HLI', 'Heli Securite Helicopter Airlines (France)', 'Heli Securite Helicopter Airlines (France)');
INSERT INTO airline_alias VALUES ('H4', 'IIN', 'Inter Islands Airlines (Cape Verde)', 'Inter Islands Airlines (Cape Verde)');
INSERT INTO airline_alias VALUES ('H5', 'MVL', 'MAVIAL Magadan Airlines (Russian Federation)', 'MAVIAL Magadan Airlines (Russian Federation)');
INSERT INTO airline_alias VALUES ('H6', 'HAG', 'Hageland Aviation Services (USA)', 'Hageland Aviation Services (USA)');
INSERT INTO airline_alias VALUES ('H7', 'EGU', 'Eagle Air (Uganda)', 'Eagle Air (Uganda)');
INSERT INTO airline_alias VALUES ('H8', 'KHB', 'Dalavia Far East Airways (Russian Federation)', 'Dalavia Far East Airways (Russian Federation)');
INSERT INTO airline_alias VALUES ('H9', 'HAD', 'Air D''Ayiti/Haiti Aviation', 'Air D''Ayiti/Haiti Aviation');
INSERT INTO airline_alias VALUES ('H9', 'SUL', 'TAM Express (Brazil)', 'TAM Express (Brazil)');
INSERT INTO airline_alias VALUES ('HA', 'HAL', 'Hawaiian Airlines (USA)', 'Hawaiian Airlines (USA)');
INSERT INTO airline_alias VALUES ('HB', 'HAR', 'Harbor Airlines (USA)', 'Harbor Airlines (USA)');
INSERT INTO airline_alias VALUES ('HC', 'ATI', 'Aero Tropics Air Services (Australia)', 'Aero Tropics Air Services (Australia)');
INSERT INTO airline_alias VALUES ('HD', 'ADO', 'Hokkaido International Airlines/Air Do (Japan)', 'Hokkaido International Airlines/Air Do (Japan)');
INSERT INTO airline_alias VALUES ('HE', 'LGW', 'LGW Luftfahrtgesellschaft Walter (Germany)', 'LGW Luftfahrtgesellschaft Walter (Germany)');
INSERT INTO airline_alias VALUES ('HF', 'HLF', 'Hapag-Lloyd Flug (Germany)', 'Hapag-Lloyd Flug (Germany)');
INSERT INTO airline_alias VALUES ('HG', 'HRB', 'Haiti International Airline', 'Haiti International Airline');
INSERT INTO airline_alias VALUES ('GB', 'ABX', 'ABX Air (USA)', 'ABX Air');
INSERT INTO airline_alias VALUES ('DK', 'VKG', 'MyTravel Airways (Denmark)', 'MyTravel Airways (Denmark)');
INSERT INTO airline_alias VALUES ('F9', 'FFT', 'Frontier Airlines (USA)', 'Frontier Airlines');
INSERT INTO airline_alias VALUES ('DM', 'DAN', 'Maersk Air (Denmark)', 'Maersk Air (Denmark)');
INSERT INTO airline_alias VALUES ('DN', 'MPS', 'Metropolis Noord (Netherlands)', 'Metropolis Noord (Netherlands)');
INSERT INTO airline_alias VALUES ('DN', 'DKN', 'Air Deccan (India)', 'Air Deccan (India)');
INSERT INTO airline_alias VALUES ('DO', 'RVL', 'Air Vallee (Italy)', 'Air Vallee (Italy)');
INSERT INTO airline_alias VALUES ('DP', 'FCA', 'First Choice Airways (UK)', 'First Choice Airways (UK)');
INSERT INTO airline_alias VALUES ('DQ', 'CXT', 'Coastal Air Transport (USA)', 'Coastal Air Transport (USA)');
INSERT INTO airline_alias VALUES ('DS', 'EZS', 'EasyJet Switzerland', 'EasyJet Switzerland');
INSERT INTO airline_alias VALUES ('DT', 'DTA', 'TAAG Angola Airlines', 'TAAG Angola Airlines');
INSERT INTO airline_alias VALUES ('DU', 'HMS', 'Hemus Air (Bulgaria)', 'Hemus Air (Bulgaria)');
INSERT INTO airline_alias VALUES ('DV', 'LTF', 'Lufttaxi (Germany)', 'Lufttaxi (Germany)');
INSERT INTO airline_alias VALUES ('DV', 'VSV', 'PLL Scat Aircompany (Kazakhstan)', 'PLL Scat Aircompany (Kazakhstan)');
INSERT INTO airline_alias VALUES ('DW', 'UCR', 'Aero-Charter Ukraine', 'Aero-Charter Ukraine');
INSERT INTO airline_alias VALUES ('DX', 'DTR', 'DAT Danish Air Transport', 'DAT Danish Air Transport');
INSERT INTO airline_alias VALUES ('DY', 'DJU', 'Air Djibouti', 'Air Djibouti');
INSERT INTO airline_alias VALUES ('DY', 'NAX', 'Norwegian Air Shuttle', 'Norwegian Air Shuttle');
INSERT INTO airline_alias VALUES ('DZ', 'NOE', 'Transcaraibes Air International (Guadeloupe)', 'Transcaraibes Air International (Guadeloupe)');
INSERT INTO airline_alias VALUES ('E2', 'GRN', 'Rio Grande Air (USA)', 'Rio Grande Air (USA)');
INSERT INTO airline_alias VALUES ('E3', 'DMO', 'Domodedovo Airlines (Russian Federation)', 'Domodedovo Airlines (Russian Federation)');
INSERT INTO airline_alias VALUES ('E4', 'RSO', 'Aero Asia International (Pakistan)', 'Aero Asia International (Pakistan)');
INSERT INTO airline_alias VALUES ('E5', 'BRZ', 'Samara Airlines (Russian Federation)', 'Samara Airlines (Russian Federation)');
INSERT INTO airline_alias VALUES ('E7', 'EAF', 'European Aviation Air Charter (UK)', 'European Aviation Air Charter (UK)');
INSERT INTO airline_alias VALUES ('E7', 'ESF', 'Estafeta Carga Aerea (Mexico)', 'Estafeta Carga Aerea (Mexico)');
INSERT INTO airline_alias VALUES ('E8', 'ELG', 'Alpi Eagles (Italy)', 'Alpi Eagles (Italy)');
INSERT INTO airline_alias VALUES ('E9', 'CXS', 'Pan Am Clipper Connection/Boston-Maine Airways (USA)', 'Pan Am Clipper Connection/Boston-Maine Airways (USA)');
INSERT INTO airline_alias VALUES ('EA', 'EAE', 'European Air Express (Germany)', 'European Air Express (Germany)');
INSERT INTO airline_alias VALUES ('EC', 'TWN', 'Avialeasing Aviation Company (Uzbekistan)', 'Avialeasing Aviation Company (Uzbekistan)');
INSERT INTO airline_alias VALUES ('ED', 'ABQ', 'Airblue (Pakistan)', 'Airblue (Pakistan)');
INSERT INTO airline_alias VALUES ('ED', 'CDL', 'US Airways Express/CCAir', 'US Airways Express/CCAir');
INSERT INTO airline_alias VALUES ('EE', 'EAY', 'Aero Airlines (Estonia)', 'Aero Airlines (Estonia)');
INSERT INTO airline_alias VALUES ('EF', 'FEA', 'Far East Air Transport (Taiwan)', 'Far East Air Transport (Taiwan)');
INSERT INTO airline_alias VALUES ('EG', 'JAA', 'Japan Asia Airways', 'Japan Asia Airways');
INSERT INTO airline_alias VALUES ('EH', 'AKX', 'Air Nippon Network (Japan)', 'Air Nippon Network (Japan)');
INSERT INTO airline_alias VALUES ('EH', 'SET', 'SAETA (Ecuador)', 'SAETA (Ecuador)');
INSERT INTO airline_alias VALUES ('EI', 'EIN', 'Aer Lingus (Ireland)', 'Aer Lingus (Ireland)');
INSERT INTO airline_alias VALUES ('EJ', 'NEA', 'New England Airlines (USA)', 'New England Airlines (USA)');
INSERT INTO airline_alias VALUES ('EK', 'UAE', 'Emirates (United Arab Emirates)', 'Emirates (United Arab Emirates)');
INSERT INTO airline_alias VALUES ('EL', 'ANK', 'Air Nippon (Japan)', 'Air Nippon (Japan)');
INSERT INTO airline_alias VALUES ('EM', 'AEB', 'Aero Benin', 'Aero Benin');
INSERT INTO airline_alias VALUES ('EM', 'CFS', 'Empire Airlines (USA)', 'Empire Airlines (USA)');
INSERT INTO airline_alias VALUES ('EN', 'DLA', 'Air Dolomiti (Italy)', 'Air Dolomiti (Italy)');
INSERT INTO airline_alias VALUES ('EO', 'ALX', 'Hewa Bora Airlines (Democratic Rep. of Congo)', 'Hewa Bora Airlines (Democratic Rep. of Congo)');
INSERT INTO airline_alias VALUES ('EO', 'LHN', 'Express One International (USA)', 'Express One International (USA)');
INSERT INTO airline_alias VALUES ('EP', 'IRC', 'Iran Asseman Airlines', 'Iran Asseman Airlines');
INSERT INTO airline_alias VALUES ('EQ', 'TAE', 'TAME (Ecuador)', 'TAME (Ecuador)');
INSERT INTO airline_alias VALUES ('EV', 'CAA', 'Atlantic Southeast Airlines (USA)', 'Atlantic Southeast Airlines');
INSERT INTO airline_alias VALUES ('ES', 'DHX', 'DHL Aviation (Bahrain)', 'DHL Aviation (Bahrain)');
INSERT INTO airline_alias VALUES ('ET', 'ETH', 'Ethiopian Airlines', 'Ethiopian Airlines');
INSERT INTO airline_alias VALUES ('EU', 'EEA', 'Ecuatoriana (Ecuador)', 'Ecuatoriana (Ecuador)');
INSERT INTO airline_alias VALUES ('CZ', 'CSN', 'China Southern Airlines', 'China Southern Airlines');
INSERT INTO airline_alias VALUES ('EW', 'EWG', 'Lufthansa Regional/Eurowings (Germany)', 'Lufthansa Regional/Eurowings (Germany)');
INSERT INTO airline_alias VALUES ('EX', 'SDO', 'Air Santo Domingo (Dominican Republic)', 'Air Santo Domingo (Dominican Republic)');
INSERT INTO airline_alias VALUES ('EY', 'EFL', 'Eagle Air (Tanzania)', 'Eagle Air (Tanzania)');
INSERT INTO airline_alias VALUES ('EY', 'ETD', 'Etihad Airways (United Arab Emirates)', 'Etihad Airways (United Arab Emirates)');
INSERT INTO airline_alias VALUES ('EZ', 'EIA', 'Evergreen International Airlines (USA)', 'Evergreen International Airlines (USA)');
INSERT INTO airline_alias VALUES ('EZ', 'SUS', 'Sun-Air of Scandinavia (Denmark)', 'Sun-Air of Scandinavia (Denmark)');
INSERT INTO airline_alias VALUES ('F2', 'FLM', 'Fly Havayolu Tasimacilik (Turkey)', 'Fly Havayolu Tasimacilik (Turkey)');
INSERT INTO airline_alias VALUES ('F3', 'FSW', 'Faso Airways (Burkina Faso)', 'Faso Airways (Burkina Faso)');
INSERT INTO airline_alias VALUES ('F4', 'NBK', 'Albarka Air (Nigeria)', 'Albarka Air (Nigeria)');
INSERT INTO airline_alias VALUES ('F5', 'COZ', 'Cosmic Air (Nepal)', 'Cosmic Air (Nepal)');
INSERT INTO airline_alias VALUES ('F6', 'CAG', 'CNAC Zheijang Airlines (China)', 'CNAC Zheijang Airlines (China)');
INSERT INTO airline_alias VALUES ('F6', 'FCC', 'First Cambodia Airlines', 'First Cambodia Airlines');
INSERT INTO airline_alias VALUES ('F7', 'BBO', 'Flybaboo (Switzerland)', 'Flybaboo (Switzerland)');
INSERT INTO airline_alias VALUES ('F8', 'FDM', 'Freedom Airlines (USA)', 'Freedom Airlines (USA)');
INSERT INTO airline_alias VALUES ('FA', 'SFR', 'Safair (South Africa)', 'Safair (South Africa)');
INSERT INTO airline_alias VALUES ('FB', 'LZB', 'Balkan Air Tours (Bulgaria)', 'Balkan Air Tours (Bulgaria)');
INSERT INTO airline_alias VALUES ('FG', 'AFG', 'Ariana Afghan Airlines', 'Ariana Afghan Airlines');
INSERT INTO airline_alias VALUES ('FH', 'FUA', 'Futura International Airlines (Spain)', 'Futura International Airlines (Spain)');
INSERT INTO airline_alias VALUES ('BC', 'SKY', 'Skymark Airlines (Japan)', 'Skymark Airlines (Japan)');
INSERT INTO airline_alias VALUES ('BD', 'BMA', 'bmi British Midland', 'bmi British Midland');
INSERT INTO airline_alias VALUES ('BE', 'BEE', 'flybe/British European Airways (UK)', 'flybe/British European Airways (UK)');
INSERT INTO airline_alias VALUES ('BF', 'BBD', 'Bluebird Cargo (Iceland)', 'Bluebird Cargo (Iceland)');
INSERT INTO airline_alias VALUES ('BF', 'RSR', 'Aero Service (Congo)', 'Aero Service (Congo)');
INSERT INTO airline_alias VALUES ('BG', 'BBC', 'Biman Bangladesh', 'Biman Bangladesh');
INSERT INTO airline_alias VALUES ('BI', 'RBA', 'Royal Brunei Airlines', 'Royal Brunei Airlines');
INSERT INTO airline_alias VALUES ('BJ', 'LBT', 'Nouvelair Tunisie (Tunisia)', 'Nouvelair Tunisie (Tunisia)');
INSERT INTO airline_alias VALUES ('CO', 'COA', 'Continental Airlines (USA)', 'Continental');
INSERT INTO airline_alias VALUES ('BL', 'PIC', 'Pacific Airlines (USA)', 'Pacific Airlines (USA)');
INSERT INTO airline_alias VALUES ('BM', 'BYU', 'Bayu Indonesia Air', 'Bayu Indonesia Air');
INSERT INTO airline_alias VALUES ('BM', 'SIC', 'Air Sicilia (Italy)', 'Air Sicilia (Italy)');
INSERT INTO airline_alias VALUES ('BO', 'BOU', 'Bouraq Indonesia', 'Bouraq Indonesia');
INSERT INTO airline_alias VALUES ('BP', 'BOT', 'Air Botswana', 'Air Botswana');
INSERT INTO airline_alias VALUES ('BQ', 'ROM', 'Aeromar (Dominican Republic)', 'Aeromar (Dominican Republic)');
INSERT INTO airline_alias VALUES ('BR', 'EVA', 'EVA Airways Corporation (Taiwan)', 'EVA Airways Corporation (Taiwan)');
INSERT INTO airline_alias VALUES ('BS', 'BIH', 'British International Helicopters', 'British International Helicopters');
INSERT INTO airline_alias VALUES ('BT', 'BTI', 'Air Baltic (Latvia)', 'Air Baltic (Latvia)');
INSERT INTO airline_alias VALUES ('BV', 'BPA', 'Blue Panorama Airlines (Italy)', 'Blue Panorama Airlines (Italy)');
INSERT INTO airline_alias VALUES ('BW', 'BWA', 'BWIA West Indies Airways (Trinidad and Tobago)', 'BWIA West Indies Airways (Trinidad and Tobago)');
INSERT INTO airline_alias VALUES ('BX', 'CST', 'Coast Air (Norway)', 'Coast Air (Norway)');
INSERT INTO airline_alias VALUES ('BY', 'BAL', 'Britannia Airways (UK)', 'Britannia Airways (UK)');
INSERT INTO airline_alias VALUES ('BZ', 'KEE', 'Keystone Air Service (Canada)', 'Keystone Air Service (Canada)');
INSERT INTO airline_alias VALUES ('C2', 'ALU', 'Air Luxor (Sao Tome and Principe)', 'Air Luxor (Sao Tome and Principe)');
INSERT INTO airline_alias VALUES ('C3', 'IPR', 'Icar Airlines/Independent Carrier (Ukraine)', 'Icar Airlines/Independent Carrier (Ukraine)');
INSERT INTO airline_alias VALUES ('C4', 'IMX', 'Zimex Aviation (Switzerland)', 'Zimex Aviation (Switzerland)');
INSERT INTO airline_alias VALUES ('C5', 'UCA', 'Continental Connection/Commutair (USA)', 'Continental Connection/Commutair (USA)');
INSERT INTO airline_alias VALUES ('C6', 'CJA', 'CanJet (Canada)', 'CanJet (Canada)');
INSERT INTO airline_alias VALUES ('C8', 'WDY', 'ATA Connection/Chicago Express Airlines (USA)', 'ATA Connection/Chicago Express Airlines (USA)');
INSERT INTO airline_alias VALUES ('C9', 'RUS', 'Team Lufthansa/Cirrus Airlines (Germany)', 'Team Lufthansa/Cirrus Airlines (Germany)');
INSERT INTO airline_alias VALUES ('CA', 'CCA', 'Air China', 'Air China');
INSERT INTO airline_alias VALUES ('CB', 'SAY', 'Scot Airways/Suckling Airways (UK)', 'Scot Airways/Suckling Airways (UK)');
INSERT INTO airline_alias VALUES ('CC', 'ABD', 'Air Atlanta Icelandic (Iceland)', 'Air Atlanta Icelandic (Iceland)');
INSERT INTO airline_alias VALUES ('CC', 'MCK', 'Macair (Australia)', 'Macair (Australia)');
INSERT INTO airline_alias VALUES ('CD', 'LLR', 'Alliance Air (India)', 'Alliance Air (India)');
INSERT INTO airline_alias VALUES ('CE', 'NTW', 'Nationwide Airlines (South Africa)', 'Nationwide Airlines (South Africa)');
INSERT INTO airline_alias VALUES ('CF', 'SDR', 'City Airline (Sweden)', 'City Airline (Sweden)');
INSERT INTO airline_alias VALUES ('CI', 'CAL', 'China Airlines (Taiwan)', 'China Airlines (Taiwan)');
INSERT INTO airline_alias VALUES ('CJ', 'CBF', 'China Northern Airlines', 'China Northern Airlines');
INSERT INTO airline_alias VALUES ('CK', 'CKK', 'China Cargo Airlines', 'China Cargo Airlines');
INSERT INTO airline_alias VALUES ('CL', 'CLH', 'Lufthansa Regional/Cityline (Germany)', 'Lufthansa Regional/Cityline (Germany)');
INSERT INTO airline_alias VALUES ('CM', 'CMP', 'Copa Airlines (Panama)', 'Copa Airlines (Panama)');
INSERT INTO airline_alias VALUES ('CH', 'BMJ', 'Bemidji Airlines (USA)', 'Bemidji Airlines');
INSERT INTO airline_alias VALUES ('CQ', 'EXL', 'Sunshine Express Airlines (Australia)', 'Sunshine Express Airlines (Australia)');
INSERT INTO airline_alias VALUES ('CS', 'CMI', 'Continental Micronesia (USA)', 'Continental Micronesia (USA)');
INSERT INTO airline_alias VALUES ('CT', 'SFB', 'Air Sofia (Bulgaria)', 'Air Sofia (Bulgaria)');
INSERT INTO airline_alias VALUES ('CU', 'CUB', 'Cubana de Aviacion (Cuba)', 'Cubana de Aviacion (Cuba)');
INSERT INTO airline_alias VALUES ('CV', 'CLX', 'Cargolux (Luxembourg)', 'Cargolux (Luxembourg)');
INSERT INTO airline_alias VALUES ('CV', 'CVA', 'Air Chathams (New Zealand)', 'Air Chathams (New Zealand)');
INSERT INTO airline_alias VALUES ('CW', 'MRS', 'Air Marshall Islands', 'Air Marshall Islands');
INSERT INTO airline_alias VALUES ('CX', 'CPA', 'Cathay Pacific (China-Hong Kong)', 'Cathay Pacific (China-Hong Kong)');
INSERT INTO airline_alias VALUES ('D3', 'DAO', 'Daallo Airlines (Djibouti/Somalia)', 'Daallo Airlines (Djibouti/Somalia)');
INSERT INTO airline_alias VALUES ('D4', 'LID', 'Alidauni (Italy)', 'Alidauni (Italy)');
INSERT INTO airline_alias VALUES ('D5', 'DAE', 'DHL Aero Expreso (Panama)', 'DHL Aero Expreso (Panama)');
INSERT INTO airline_alias VALUES ('D6', 'ILN', 'Inter Air (South Africa)', 'Inter Air (South Africa)');
INSERT INTO airline_alias VALUES ('D8', 'DJB', 'Djibouti Airlines', 'Djibouti Airlines');
INSERT INTO airline_alias VALUES ('D9', 'DNV', 'Aeroflot-Don/Donavia (Russian Federation)', 'Aeroflot-Don/Donavia (Russian Federation)');
INSERT INTO airline_alias VALUES ('DB', 'BZH', 'Brit Air (France)', 'Brit Air (France)');
INSERT INTO airline_alias VALUES ('DC', 'GAO', 'Golden Air (Sweden)', 'Golden Air (Sweden)');
INSERT INTO airline_alias VALUES ('DE', 'CFG', 'Condor Flugdienst (Germany)', 'Condor Flugdienst (Germany)');
INSERT INTO airline_alias VALUES ('DF', 'ABH', 'Aebal Aerolineas de Baleares (Spain)', 'Aebal Aerolineas de Baleares (Spain)');
INSERT INTO airline_alias VALUES ('DG', 'SRQ', 'South East Asian Airlines (Philippines)', 'South East Asian Airlines (Philippines)');
INSERT INTO airline_alias VALUES ('DH', 'IDE', 'Independence Air (USA)', 'Independence Air (USA)');
INSERT INTO airline_alias VALUES ('DI', 'BAG', 'dba Deutsche BA (Germany)', 'dba Deutsche BA (Germany)');
INSERT INTO airline_alias VALUES ('DJ', 'VOZ', 'Virgin Blue Airways (Australia)', 'Virgin Blue Airways (Australia)');
INSERT INTO airline_alias VALUES ('DK', 'ELA', 'Eastland Air (Australia)', 'Eastland Air (Australia)');
INSERT INTO airline_alias VALUES ('BK', 'PDC', 'US Airways Express/Potomac Air', 'US Airways Exp');
INSERT INTO airline_alias VALUES ('B4', 'BKA', 'Bankair (USA)', 'Bankair');
INSERT INTO airline_alias VALUES ('B6', 'JBU', 'JetBlue Airways (USA)', 'JetBlue Airways');
INSERT INTO airline_alias VALUES ('AX', 'LOF', 'American Connection/Trans States Airlines (USA)', 'American Connection');
INSERT INTO airline_alias VALUES ('IR', 'IRA', 'Iran Air', 'Iran Air');
INSERT INTO airline_alias VALUES ('P6', 'MUI', 'Trans Air (USA)', 'Trans Air (USA)');
INSERT INTO airline_alias VALUES ('U2', 'EZY', 'easyJet (UK)', 'easyJet (UK)');
INSERT INTO airline_alias VALUES ('4N', 'ANT', 'Air North Chrater (Canada)', 'Air North Chrater (Canada)');
INSERT INTO airline_alias VALUES ('GJ', 'MXC', 'Mexicargo', 'Mexicargo');
INSERT INTO airline_alias VALUES ('LQ', 'LAQ', 'Lebanese AIr Transport', 'Lebanese AIr Transport');
INSERT INTO airline_alias VALUES ('SH', 'FLY', 'FlyMe Sweden', 'FlyMe Sweden');
INSERT INTO airline_alias VALUES ('F2', 'FAO', 'Falcon Air Express (USA)', 'Falcon Air Express (USA)');
INSERT INTO airline_alias VALUES ('BU', 'BRA', 'SAS Braathens (Norway)', 'SAS Braathens (Norway)');
INSERT INTO airline_alias VALUES ('KM', 'AMC', 'Air Malta', 'Air Malta');
INSERT INTO airline_alias VALUES ('MM', 'SAM', 'SAM (Colombia)', 'SAM (Colombia)');
INSERT INTO airline_alias VALUES ('P2', 'PIT', 'Panair (Italy)', 'Panair (Italy)');
INSERT INTO airline_alias VALUES ('RG', 'VRG', 'Varig (Brazil)', 'Varig (Brazil)');
INSERT INTO airline_alias VALUES ('T3', 'EZE', 'Eastern Airways (UK)', 'Eastern Airways (UK)');
INSERT INTO airline_alias VALUES ('4C', 'ARE', 'Aires (Colombia)', 'Aires (Colombia)');
INSERT INTO airline_alias VALUES ('6Q', 'SLL', 'Slovak Airlines', 'Slovak Airlines');
INSERT INTO airline_alias VALUES ('ON', 'RON', 'Air Nauru', 'Air Nauru');
INSERT INTO airline_alias VALUES ('A2', 'CIU', 'Cielos del Peru', 'Cielos del Peru');
INSERT INTO airline_alias VALUES ('A3', 'AEE', 'Aegean Cronus Airlines (Greece)', 'Aegean Cronus Airlines (Greece)');
INSERT INTO airline_alias VALUES ('A4', 'SWD', 'Southern Winds (Argentina)', 'Southern Winds (Argentina)');
INSERT INTO airline_alias VALUES ('A5', 'RLA', 'Airlinair (France)', 'Airlinair (France)');
INSERT INTO airline_alias VALUES ('A6', 'LPV', 'Air Alps (Austria)', 'Air Alps (Austria)');
INSERT INTO airline_alias VALUES ('A7', 'MPD', 'Air Comet (Spain)', 'Air Comet (Spain)');
INSERT INTO airline_alias VALUES ('A8', 'BGL', 'Benin Golf Air', 'Benin Golf Air');
INSERT INTO airline_alias VALUES ('A9', 'TGZ', 'Air Zena Georgian Airlines', 'Air Zena Georgian Airlines');
INSERT INTO airline_alias VALUES ('AB', 'BER', 'Air Berlin (Germany)', 'Air Berlin (Germany)');
INSERT INTO airline_alias VALUES ('AC', 'ACA', 'Air Canada', 'Air Canada');
INSERT INTO airline_alias VALUES ('AD', 'PRZ', 'Air Paradise International (Indonesia)', 'Air Paradise International (Indonesia)');
INSERT INTO airline_alias VALUES ('AE', 'MDA', 'Mandarin Airlines (Taiwan)', 'Mandarin Airlines (Taiwan)');
INSERT INTO airline_alias VALUES ('AF', 'AFR', 'Air France', 'Air France');
INSERT INTO airline_alias VALUES ('AG', 'ABR', 'Air Contractors (Ireland)', 'Air Contractors (Ireland)');
INSERT INTO airline_alias VALUES ('AH', 'DAH', 'Air Algerie (Algeria)', 'Air Algerie (Algeria)');
INSERT INTO airline_alias VALUES ('AI', 'AIC', 'Air India', 'Air India');
INSERT INTO airline_alias VALUES ('AJ', 'NIG', 'Aero Contractors (Nigeria)', 'Aero Contractors (Nigeria)');
INSERT INTO airline_alias VALUES ('AK', 'AXM', 'Air Asia (Malaysia)', 'Air Asia (Malaysia)');
INSERT INTO airline_alias VALUES ('AL', 'SXY', 'Skyway Airlines/Astral Aviation (USA)', 'Skyway Airlines/Astral Aviation (USA)');
INSERT INTO airline_alias VALUES ('AL', 'TXC', 'Transaviaexport Cargo Airline (Belarus)', 'Transaviaexport Cargo Airline (Belarus)');
INSERT INTO airline_alias VALUES ('AM', 'AMX', 'Aeromexico', 'Aeromexico');
INSERT INTO airline_alias VALUES ('AO', 'AUZ', 'Australian Airlines', 'Australian Airlines');
INSERT INTO airline_alias VALUES ('AP', 'ADH', 'Air One (Italy)', 'Air One (Italy)');
INSERT INTO airline_alias VALUES ('AR', 'ARG', 'Aerolineas Argentinas', 'Aerolineas Argentinas');
INSERT INTO airline_alias VALUES ('AT', 'RAM', 'Royal Air Maroc (Morocco)', 'Royal Air Maroc (Morocco)');
INSERT INTO airline_alias VALUES ('AU', 'AUT', 'Austral/Cielos del Sur (Argentina)', 'Austral/Cielos del Sur (Argentina)');
INSERT INTO airline_alias VALUES ('AV', 'AVA', 'Avianca (Colombia)', 'Avianca (Colombia)');
INSERT INTO airline_alias VALUES ('AW', 'SCH', 'Schreiner Airways (Netherlands)', 'Schreiner Airways (Netherlands)');
INSERT INTO airline_alias VALUES ('AW', 'DIR', 'Dirgantara Air Services (Indonesia)', 'Dirgantara Air Services (Indonesia)');
INSERT INTO airline_alias VALUES ('AY', 'FIN', 'Finnair (Finland)', 'Finnair (Finland)');
INSERT INTO airline_alias VALUES ('AZ', 'AZA', 'Alitalia (Italy)', 'Alitalia (Italy)');
INSERT INTO airline_alias VALUES ('B2', 'BRU', 'Belavia (Belarus)', 'Belavia (Belarus)');
INSERT INTO airline_alias VALUES ('B3', 'BLV', 'Bellview Airlines (Nigeria)', 'Bellview Airlines (Nigeria)');
INSERT INTO airline_alias VALUES ('B5', 'FLT', 'FlightLine (UK)', 'FlightLine (UK)');
INSERT INTO airline_alias VALUES ('B7', 'UIA', 'Uni Air (Taiwan)', 'Uni Air (Taiwan)');
INSERT INTO airline_alias VALUES ('B8', 'ERT', 'Eritrean Airlines', 'Eritrean Airlines');
INSERT INTO airline_alias VALUES ('B9', 'IRB', 'Iran Air Tours', 'Iran Air Tours');
INSERT INTO airline_alias VALUES ('BA', 'BAW', 'British Airways', 'British Airways');
INSERT INTO airline_alias VALUES ('8H', 'HFR', 'Heli France', 'Heli France');
INSERT INTO airline_alias VALUES ('5Q', 'JFK', 'Keenair Charter (UK)', 'Keenair Charter (UK)');
INSERT INTO airline_alias VALUES ('LP', 'LPE', 'LAN Peru', 'LAN Peru');
INSERT INTO airline_alias VALUES ('RW', 'RPA', 'Republic Airlines', 'Republic Airlines');
INSERT INTO airline_alias VALUES ('PT', 'CCI', 'Capital Cargo International Airlines (USA)', 'Capital Cargo Intl.');
INSERT INTO airline_alias VALUES ('US', 'USA', 'US Airways (USA)', 'US Airways');
INSERT INTO airline_alias VALUES ('CP', 'CPZ', 'Compass Airlines', 'Compass');
INSERT INTO airline_alias VALUES ('78W', '78W', 'BAX Global', 'BAX');
INSERT INTO airline_alias VALUES ('RD', 'RYN', 'Ryan International Airlines', 'Ryan Air');
INSERT INTO airline_alias VALUES ('XE', 'BTA', 'Express Jet operated as Continental Express', 'Continental Exp.');
INSERT INTO airline_alias VALUES ('WN', 'SWA', 'Southwest Airlines (USA)', 'Southwest');
INSERT INTO airline_alias VALUES ('ATE', 'ATE', 'Atlantis Transportation Services', 'Atlantis Transportation');
INSERT INTO airline_alias VALUES ('8C', 'ATN', 'Air Transport International ATI (USA)', 'Air Transport Intl');
INSERT INTO airline_alias VALUES ('GZ', 'RAX', 'Royal Air Freight', 'Royal Air Freight
');
INSERT INTO airline_alias VALUES ('FA', 'SGB', 'Sky King, Inc', 'Sky King, Inc.');
INSERT INTO airline_alias VALUES ('ECJ_icao', 'ECJ', 'East Coast Jets (USA)', 'East Coast Jets (USA)');
INSERT INTO airline_alias VALUES ('PG', 'PWA', 'Priester Aviation', 'Priester Aviation');
INSERT INTO airline_alias VALUES ('N4', 'MTN', 'Mountain Air Cargo', 'Mountain Air Cargo');
INSERT INTO airline_alias VALUES ('MY', 'MWT', 'Midwest Aviation Division', 'Midwest Aviation Division');
INSERT INTO airline_alias VALUES ('LF', 'OPT', 'Flight Options', 'Flight Options');
INSERT INTO airline_alias VALUES ('KM', 'AMF', 'Ameriflight', 'Ameriflight');
INSERT INTO airline_alias VALUES ('EZ', 'EJM', 'Executive Jet Management', 'Executive Jet Management');
INSERT INTO airline_alias VALUES ('EZ', 'LXJ', 'Bombardier Busienss Jet Solutions', 'Bombardier Busienss Jet Solutions
');
INSERT INTO airline_alias VALUES ('EZ', 'FIV', 'Citation Shares', 'Citation Shares');
INSERT INTO airline_alias VALUES ('DH', 'IFL', 'IFL Group', 'IFL Group');
INSERT INTO airline_alias VALUES ('GTH_icao', 'GTH', 'General Aviation Flying Services (USA)', 'General Aviation Flying Services (USA)');
INSERT INTO airline_alias VALUES ('BJS_icao', 'BJS', 'Business Jet Solutions (USA)', 'Business Jet Solutions (USA)');
INSERT INTO airline_alias VALUES ('SWQ_icao', 'SWQ', 'Swift Air (USA)', 'Swift Air (USA)');
INSERT INTO airline_alias VALUES ('PAG_icao', 'PAG', 'Perimeter Aviation (Canada)', 'Perimeter Aviation (Canada)');
INSERT INTO airline_alias VALUES ('LJY_icao', 'LJY', 'L J Aviation (USA)', 'L J Aviation (USA)');
INSERT INTO airline_alias VALUES ('V2', 'RBY', 'Vision Airlines (USA)', 'Vision Airlines (USA)');
INSERT INTO airline_alias VALUES ('WWI_icao', 'WWI', 'Worldwide Jet Charter (USA)', 'Worldwide Jet Charter (USA)');
INSERT INTO airline_alias VALUES ('FJS_icao', 'FJS', 'Florida Jet Service (USA)', 'Florida Jet Service (USA)');
INSERT INTO airline_alias VALUES ('ADB_icao', 'ADB', 'Antonov Airlines (Ukraine)', 'Antonov Airlines (Ukraine)');
INSERT INTO airline_alias VALUES ('KEY_icao', 'KEY', 'Key Airlines (USA)', 'Key Airlines (USA)');
INSERT INTO airline_alias VALUES ('FWK_icao', 'FWK', 'Flightworks (USA)', 'Flightworks (USA)');
INSERT INTO airline_alias VALUES ('FRG_icao', 'FRG', 'Freight Runners Express (USA)', 'Freight Runners Express (USA)');
INSERT INTO airline_alias VALUES ('FSR_icao', 'FSR', 'Flightstar Corporation (USA)', 'Flightstar Corporation (USA)');
INSERT INTO airline_alias VALUES ('GA', 'XSR', 'Executive Airshare Corporation', 'Executive Airshare Corporation');
INSERT INTO airline_alias VALUES ('GA', 'DKT', 'Business Aviation Courier', 'Business Aviation Courier');
INSERT INTO airline_alias VALUES ('GA', 'SRY', 'Charter Air Transport', 'Charter Air Transport');
INSERT INTO airline_alias VALUES ('GA', 'SSH', 'Heritage Flight', 'Heritage Flight');
INSERT INTO airline_alias VALUES ('GA', 'SBE', 'World Class Automotive Operations', 'World Class Automotive Operations');
INSERT INTO airline_alias VALUES ('GA', 'JNH', 'M and N Avition Inc', 'M and N Avition Inc');
INSERT INTO airline_alias VALUES ('GA', 'HTL', 'Jet Linx Aviation', 'Jet Linx Aviation');
INSERT INTO airline_alias VALUES ('GA', 'KCR', 'Kolob Canyons Air Services', 'Kolob Canyons Air Services');
INSERT INTO airline_alias VALUES ('U7', 'JUS', 'USA Jet Airlines', 'USA Jet Airlines');
INSERT INTO airline_alias VALUES ('1Z', 'LBQ', 'Quest Diagnostics, Inc.', 'Quest Diagnostics, Inc.');
INSERT INTO airline_alias VALUES ('CB', 'KFS', 'Kalitta Charters', 'Kalitta Charters');
INSERT INTO airline_alias VALUES ('2Z', 'TSU', 'Gulf & Caribbean Cargo', 'Gulf & Caribbean Cargo');
INSERT INTO airline_alias VALUES ('3Z', 'UJT', 'Universal Jet Aviation Inc.', 'Universal Jet Aviation Inc.');
INSERT INTO airline_alias VALUES ('4Z', 'JLG', 'Jet Logistics Inc.', 'Jet Logistics Inc.');
INSERT INTO airline_alias VALUES ('5Z', 'HPJ', 'Uruguayan Navy', 'Uruguayan Navy');
INSERT INTO airline_alias VALUES ('6Z', 'BMG', 'Image Air Charter', 'Image Air Charter');
INSERT INTO airline_alias VALUES ('7Z', 'CNK', 'Sunwest Aviation', 'Sunwest Aviation');
INSERT INTO airline_alias VALUES ('8Z', 'UJC', 'Ultimate Jetcharters', 'Ultimate Jetcharters');
INSERT INTO airline_alias VALUES ('9Z', 'AJI', 'Ameristar Jet Charter Inc.', 'Ameristar Jet Charter Inc.');
INSERT INTO airline_alias VALUES ('0Z', 'FEX', 'CEC FlightExec', 'CEC FlightExec');
INSERT INTO airline_alias VALUES ('1Y', 'TFF', 'Talon Air Inc.', 'Talon Air Inc.');
INSERT INTO airline_alias VALUES ('2Y', 'USC', 'Airnet Systems Inc.', 'Airnet Systems Inc.');
INSERT INTO airline_alias VALUES ('   ', '1AI', 'AIRBUS                                                ', 'AIRBUS                                                ');
INSERT INTO airline_alias VALUES ('   ', '1AL', 'ALENIA                                                ', 'ALENIA                                                ');
INSERT INTO airline_alias VALUES ('   ', '1BD', 'BOMBARDIER INC.                                       ', 'BOMBARDIER INC.                                       ');
INSERT INTO airline_alias VALUES ('   ', '1BO', 'BOEING COMPANY                                        ', 'BOEING COMPANY                                        ');
INSERT INTO airline_alias VALUES ('   ', '1PC', 'PILATUS FLUGZEUGWERKE AG                              ', 'PILATUS FLUGZEUGWERKE AG                              ');
INSERT INTO airline_alias VALUES ('   ', '1PI', 'PIAGGIO AERO INDUSTRIES                               ', 'PIAGGIO AERO INDUSTRIES                               ');
INSERT INTO airline_alias VALUES ('   ', '21Q', 'AVIATION CAPITAL GROUP (ALL ENTRIES)                  ', 'AVIATION CAPITAL GROUP (ALL ENTRIES)                  ');
INSERT INTO airline_alias VALUES ('   ', '271', 'INTREPID AVIATION PARTNERS LLC (ALL ENTRIES)          ', 'INTREPID AVIATION PARTNERS LLC (ALL ENTRIES)          ');
INSERT INTO airline_alias VALUES ('   ', '272', 'GLOBAL AIRCRAFT LEASING (ALL ENTRIES)                 ', 'GLOBAL AIRCRAFT LEASING (ALL ENTRIES)                 ');
INSERT INTO airline_alias VALUES ('   ', '2AB', 'AIRBUS (ALL ENTRIES)                                  ', 'AIRBUS (ALL ENTRIES)                                  ');
INSERT INTO airline_alias VALUES ('   ', '2AN', 'AWAS (ALL ENTRIES)                                    ', 'AWAS (ALL ENTRIES)                                    ');
INSERT INTO airline_alias VALUES ('   ', '2BO', 'BOEING COMPANY (ALL ENTRIES)                          ', 'BOEING COMPANY (ALL ENTRIES)                          ');
INSERT INTO airline_alias VALUES ('   ', '2DL', 'MITSUBISHI CORPORATION (ALL ENTRIES)                  ', 'MITSUBISHI CORPORATION (ALL ENTRIES)                  ');
INSERT INTO airline_alias VALUES ('   ', '2GE', 'GENERAL ELECTRIC CAPITAL CORPORATION (ALL ENTRIES)    ', 'GENERAL ELECTRIC CAPITAL CORPORATION (ALL ENTRIES)    ');
INSERT INTO airline_alias VALUES ('   ', '2I9', 'CIT AEROSPACE CORPORATION (ALL ENTRIES)               ', 'CIT AEROSPACE CORPORATION (ALL ENTRIES)               ');
INSERT INTO airline_alias VALUES ('   ', '2IL', 'INTERNATIONAL LEASE FINANCE CORPORATION (ALL ENTRIES) ', 'INTERNATIONAL LEASE FINANCE CORPORATION (ALL ENTRIES) ');
INSERT INTO airline_alias VALUES ('   ', '2KB', 'BABCOCK & BROWN AIRCRAFT MANAGEMENT INC. (ALL ENTRIES)', 'BABCOCK & BROWN AIRCRAFT MANAGEMENT INC. (ALL ENTRIES)');
INSERT INTO airline_alias VALUES ('   ', '2KU', 'BOC AVIATION PTE LTD. (ALL ENTRIES)                   ', 'BOC AVIATION PTE LTD. (ALL ENTRIES)                   ');
INSERT INTO airline_alias VALUES ('   ', '2R7', 'RUSSIAN TECHNOLOGIES CORPORATION                      ', 'RUSSIAN TECHNOLOGIES CORPORATION                      ');
INSERT INTO airline_alias VALUES ('   ', '2RA', 'ROYAL BANK OF SCOTLAND PLC (ALL ENTRIES)              ', 'ROYAL BANK OF SCOTLAND PLC (ALL ENTRIES)              ');
INSERT INTO airline_alias VALUES ('   ', '2VV', 'VIETNAM AIRCRAFT LEASING COMPANY                      ', 'VIETNAM AIRCRAFT LEASING COMPANY                      ');
INSERT INTO airline_alias VALUES ('   ', '2XX', 'SUNSET AVIATION INC.                                  ', 'SUNSET AVIATION INC.                                  ');
INSERT INTO airline_alias VALUES ('   ', '2YW', 'WORLDWIDE AIRCRAFT FERRYING LTD.                      ', 'WORLDWIDE AIRCRAFT FERRYING LTD.                      ');
INSERT INTO airline_alias VALUES ('   ', '34V', 'AVITRADE (ALL ENTRIES)                                ', 'AVITRADE (ALL ENTRIES)                                ');
INSERT INTO airline_alias VALUES ('   ', '35V', 'AVIALEASING                                           ', 'AVIALEASING                                           ');
INSERT INTO airline_alias VALUES ('   ', '38E', 'EMIRATES ADVANCED INVESTMENTS                         ', 'EMIRATES ADVANCED INVESTMENTS                         ');
INSERT INTO airline_alias VALUES ('   ', '3DA', 'DUBAI AEROSPACE ENTERPRISES (ALL ENTRIES)             ', 'DUBAI AEROSPACE ENTERPRISES (ALL ENTRIES)             ');
INSERT INTO airline_alias VALUES ('   ', '3DC', 'CDB LEASING COMPANY LTD.                              ', 'CDB LEASING COMPANY LTD.                              ');
INSERT INTO airline_alias VALUES ('   ', '3FD', 'FIELD AVIATION COMPANY INC. (ALL ENTRIES)             ', 'FIELD AVIATION COMPANY INC. (ALL ENTRIES)             ');
INSERT INTO airline_alias VALUES ('   ', '3G8', 'GLOBAL AEROSPACE LOGISTICS                            ', 'GLOBAL AEROSPACE LOGISTICS                            ');
INSERT INTO airline_alias VALUES ('   ', '3HU', 'EXECUTIVE TURBINE CC (ALL ENTRIES)                    ', 'EXECUTIVE TURBINE CC (ALL ENTRIES)                    ');
INSERT INTO airline_alias VALUES ('   ', '3I5', 'INTERNATIONAL AIRCRAFT SALES LLC (ALL ENTRIES)        ', 'INTERNATIONAL AIRCRAFT SALES LLC (ALL ENTRIES)        ');
INSERT INTO airline_alias VALUES ('   ', '3LF', 'FINANCIAL LEASING COMPANY                             ', 'FINANCIAL LEASING COMPANY                             ');
INSERT INTO airline_alias VALUES ('   ', '3M0', 'M1 TRAVEL LTD. (ALL ENTRIES)                          ', 'M1 TRAVEL LTD. (ALL ENTRIES)                          ');
INSERT INTO airline_alias VALUES ('   ', '3PM', 'MATLINPATTERSON GLOBAL ADVISORS LLC                   ', 'MATLINPATTERSON GLOBAL ADVISORS LLC                   ');
INSERT INTO airline_alias VALUES ('   ', '3TV', 'TIME VALUE PROPERTY EXCHANGE INC. (ALL ENTRIES)       ', 'TIME VALUE PROPERTY EXCHANGE INC. (ALL ENTRIES)       ');
INSERT INTO airline_alias VALUES ('   ', '3UH', 'AIR LEASE CORPORATION (ALL ENTRIES)                   ', 'AIR LEASE CORPORATION (ALL ENTRIES)                   ');
INSERT INTO airline_alias VALUES ('   ', '3XL', 'LOCH ARD OTTERS                                       ', 'LOCH ARD OTTERS                                       ');
INSERT INTO airline_alias VALUES ('   ', '3XM', 'METCO                                                 ', 'METCO                                                 ');
INSERT INTO airline_alias VALUES ('   ', '3YA', 'ASSET MANAGEMENT ADVISORS (AMA)                       ', 'ASSET MANAGEMENT ADVISORS (AMA)                       ');
INSERT INTO airline_alias VALUES ('   ', '3YC', 'CRECOM BURJ RESOURCES                                 ', 'CRECOM BURJ RESOURCES                                 ');
INSERT INTO airline_alias VALUES ('   ', '3ZP', 'PEARL AIRCRAFT CORPORATION LTD.                       ', 'PEARL AIRCRAFT CORPORATION LTD.                       ');
INSERT INTO airline_alias VALUES ('   ', '41D', 'AERVENTURE (ALL ENTRIES)                              ', 'AERVENTURE (ALL ENTRIES)                              ');
INSERT INTO airline_alias VALUES ('   ', '46J', 'SUZUYO (ALL ENTRIES)                                  ', 'SUZUYO (ALL ENTRIES)                                  ');
INSERT INTO airline_alias VALUES ('   ', '4AY', 'FINNAIR AIRCRAFT FINANCE OY (ALL ENTRIES)             ', 'FINNAIR AIRCRAFT FINANCE OY (ALL ENTRIES)             ');
INSERT INTO airline_alias VALUES ('   ', '4D1', 'DRAGON AVIATION LEASING COMPANY LTD. (ALL ENTRIES)    ', 'DRAGON AVIATION LEASING COMPANY LTD. (ALL ENTRIES)    ');
INSERT INTO airline_alias VALUES ('   ', '4DA', 'AERCAP AVIATION SOLUTIONS B.V. (ALL ENTRIES)          ', 'AERCAP AVIATION SOLUTIONS B.V. (ALL ENTRIES)          ');
INSERT INTO airline_alias VALUES ('   ', '4G3', 'ALPSTREAM AG (ALL ENTRIES)                            ', 'ALPSTREAM AG (ALL ENTRIES)                            ');
INSERT INTO airline_alias VALUES ('   ', '4KF', 'KUWAIT FINANCE HOUSE (ALL ENTRIES)                    ', 'KUWAIT FINANCE HOUSE (ALL ENTRIES)                    ');
INSERT INTO airline_alias VALUES ('   ', '4L6', 'LEASE CORPORATION INTERNATIONAL LTD. (ALL ENTRIES)    ', 'LEASE CORPORATION INTERNATIONAL LTD. (ALL ENTRIES)    ');
INSERT INTO airline_alias VALUES ('   ', '4LD', 'AVOLON (ALL ENTRIES)                                  ', 'AVOLON (ALL ENTRIES)                                  ');
INSERT INTO airline_alias VALUES ('   ', '4M0', 'MARFIN INVESTMENT GROUP HOLDINGS S.A. (ALL ENTRIES)   ', 'MARFIN INVESTMENT GROUP HOLDINGS S.A. (ALL ENTRIES)   ');
INSERT INTO airline_alias VALUES ('   ', '4P3', 'AIRCRAFT PURCHASE FLEET LTD. (ALL ENTRIES)            ', 'AIRCRAFT PURCHASE FLEET LTD. (ALL ENTRIES)            ');
INSERT INTO airline_alias VALUES ('   ', '4PC', 'PILATUS AIRCRAFT LTD. (ALL ENTRIES)                   ', 'PILATUS AIRCRAFT LTD. (ALL ENTRIES)                   ');
INSERT INTO airline_alias VALUES ('   ', '4RP', 'REPUBLIC AIRWAYS HOLDINGS INC.                        ', 'REPUBLIC AIRWAYS HOLDINGS INC.                        ');
INSERT INTO airline_alias VALUES ('   ', '4TM', 'AIRCRAFT ASSET MANAGEMENT                             ', 'AIRCRAFT ASSET MANAGEMENT                             ');
INSERT INTO airline_alias VALUES ('   ', '4YC', 'AVIC I INTERNATIONAL LEASING                          ', 'AVIC I INTERNATIONAL LEASING                          ');
INSERT INTO airline_alias VALUES ('   ', '538', 'SYNERGY AEROSPACE (ALL ENTRIES)                       ', 'SYNERGY AEROSPACE (ALL ENTRIES)                       ');
INSERT INTO airline_alias VALUES ('   ', '57J', 'JETSCAPE (ALL ENTRIES)                                ', 'JETSCAPE (ALL ENTRIES)                                ');
INSERT INTO airline_alias VALUES ('   ', '5DV', 'DVB BANK SE (ALL ENTRIES)                             ', 'DVB BANK SE (ALL ENTRIES)                             ');
INSERT INTO airline_alias VALUES ('   ', '5FO', 'FORTRESS INVESTMENT GROUP LLC (ALL ENTRIES)           ', 'FORTRESS INVESTMENT GROUP LLC (ALL ENTRIES)           ');
INSERT INTO airline_alias VALUES ('   ', '5GU', 'GUGGENHEIM AVIATION PARTNERS (ALL ENTRIES)            ', 'GUGGENHEIM AVIATION PARTNERS (ALL ENTRIES)            ');
INSERT INTO airline_alias VALUES ('   ', '5LC', 'LCAL INC.                                             ', 'LCAL INC.                                             ');
INSERT INTO airline_alias VALUES ('   ', '5LH', 'LUFTHANSA TECHNIK GMBH                                ', 'LUFTHANSA TECHNIK GMBH                                ');
INSERT INTO airline_alias VALUES ('   ', '5N8', 'AERONEXUS CORPORATE (PTY) LTD.                        ', 'AERONEXUS CORPORATE (PTY) LTD.                        ');
INSERT INTO airline_alias VALUES ('   ', '5OC', 'OAK HILL CAPITAL MANAGEMENT LLC (ALL ENTRIES)         ', 'OAK HILL CAPITAL MANAGEMENT LLC (ALL ENTRIES)         ');
INSERT INTO airline_alias VALUES ('   ', '5P0', 'PIPER OK A.S.                                         ', 'PIPER OK A.S.                                         ');
INSERT INTO airline_alias VALUES ('   ', '5SZ', 'SHENZHEN FINANCIAL LEASING COMPANY                    ', 'SHENZHEN FINANCIAL LEASING COMPANY                    ');
INSERT INTO airline_alias VALUES ('   ', '5TG', 'TUI AG (ALL ENTRIES)                                  ', 'TUI AG (ALL ENTRIES)                                  ');
INSERT INTO airline_alias VALUES ('   ', '5WH', 'WAHA LEASING (ALL ENTRIES)                            ', 'WAHA LEASING (ALL ENTRIES)                            ');
INSERT INTO airline_alias VALUES ('   ', '6VP', 'LEVENFELD PEARLSTEIN (VIRGINIA PROPERTY) (ALL ENTRIES)', 'LEVENFELD PEARLSTEIN (VIRGINIA PROPERTY) (ALL ENTRIES)');
INSERT INTO airline_alias VALUES ('   ', '93B', 'MAURITIUS COAST GUARD                                 ', 'MAURITIUS COAST GUARD                                 ');
INSERT INTO airline_alias VALUES ('   ', '93C', 'EQUATORIAL GUINEA GOVERNMENT                          ', 'EQUATORIAL GUINEA GOVERNMENT                          ');
INSERT INTO airline_alias VALUES ('   ', '94K', 'AZERBAIJAN GOVERNMENT                                 ', 'AZERBAIJAN GOVERNMENT                                 ');
INSERT INTO airline_alias VALUES ('   ', '94R', 'SRI LANKA AIR FORCE                                   ', 'SRI LANKA AIR FORCE                                   ');
INSERT INTO airline_alias VALUES ('   ', '94X', 'ISRAELI AIR FORCE                                     ', 'ISRAELI AIR FORCE                                     ');
INSERT INTO airline_alias VALUES ('   ', '95A', 'LIBYAN MINISTRY OF HEALTH                             ', 'LIBYAN MINISTRY OF HEALTH                             ');
INSERT INTO airline_alias VALUES ('   ', '95B', 'CYPRUS COMBINED SERVICES PARACHUTE CENTR              ', 'CYPRUS COMBINED SERVICES PARACHUTE CENTR              ');
INSERT INTO airline_alias VALUES ('   ', '95H', 'TANZANIAN GOVERNMENT                                  ', 'TANZANIAN GOVERNMENT                                  ');
INSERT INTO airline_alias VALUES ('   ', '95N', 'NIGERIAN AIR BORDER PATROL UNIT                       ', 'NIGERIAN AIR BORDER PATROL UNIT                       ');
INSERT INTO airline_alias VALUES ('   ', '95R', 'MADAGASCAR GOVERNMENT                                 ', 'MADAGASCAR GOVERNMENT                                 ');
INSERT INTO airline_alias VALUES ('   ', '95T', 'MAURITANIAN AIR FORCE                                 ', 'MAURITANIAN AIR FORCE                                 ');
INSERT INTO airline_alias VALUES ('   ', '95U', 'NIGER GOVERNMENT                                      ', 'NIGER GOVERNMENT                                      ');
INSERT INTO airline_alias VALUES ('   ', '95V', 'TOGO GOVERNMENT                                       ', 'TOGO GOVERNMENT                                       ');
INSERT INTO airline_alias VALUES ('   ', '95Y', 'KENYAN POLICE                                         ', 'KENYAN POLICE                                         ');
INSERT INTO airline_alias VALUES ('   ', '96V', 'ASECNA                                                ', 'ASECNA                                                ');
INSERT INTO airline_alias VALUES ('   ', '96Y', 'JAMAICA DEFENCE FORCE                                 ', 'JAMAICA DEFENCE FORCE                                 ');
INSERT INTO airline_alias VALUES ('   ', '97O', 'SOUTH YEMEN AIR FORCE                                 ', 'SOUTH YEMEN AIR FORCE                                 ');
INSERT INTO airline_alias VALUES ('   ', '97P', 'LESOTHO DEFENCE FORCE                                 ', 'LESOTHO DEFENCE FORCE                                 ');
INSERT INTO airline_alias VALUES ('   ', '97Q', 'MALAWI AIR WING                                       ', 'MALAWI AIR WING                                       ');
INSERT INTO airline_alias VALUES ('   ', '97T', 'ALGERIAN NAT''L INSTITUTE FOR CARTOGRAPHY              ', 'ALGERIAN NAT''L INSTITUTE FOR CARTOGRAPHY              ');
INSERT INTO airline_alias VALUES ('   ', '98P', 'REGIONAL SECURITY SERVICE                             ', 'REGIONAL SECURITY SERVICE                             ');
INSERT INTO airline_alias VALUES ('   ', '98R', 'GUYANA DEFENCE FORCE                                  ', 'GUYANA DEFENCE FORCE                                  ');
INSERT INTO airline_alias VALUES ('   ', '999', 'UNKNOWN GOVERNMENT                                    ', 'UNKNOWN GOVERNMENT                                    ');
INSERT INTO airline_alias VALUES ('   ', '99A', 'CROATIAN AIR FORCE                                    ', 'CROATIAN AIR FORCE                                    ');
INSERT INTO airline_alias VALUES ('   ', '99G', 'GHANA AIR FORCE                                       ', 'GHANA AIR FORCE                                       ');
INSERT INTO airline_alias VALUES ('   ', '99H', '"MALTA, ARMED FORCES OF                                "', '"MALTA, ARMED FORCES OF                                "');
INSERT INTO airline_alias VALUES ('   ', '99J', 'ZAMBIAN AIR FORCE                                     ', 'ZAMBIAN AIR FORCE                                     ');
INSERT INTO airline_alias VALUES ('   ', '99K', 'KUWAIT AIR FORCE                                      ', 'KUWAIT AIR FORCE                                      ');
INSERT INTO airline_alias VALUES ('   ', '99M', 'MALAYSIAN POLICE                                      ', 'MALAYSIAN POLICE                                      ');
INSERT INTO airline_alias VALUES ('   ', '99N', 'NEPALESE ARMY AIR SERVICE                             ', 'NEPALESE ARMY AIR SERVICE                             ');
INSERT INTO airline_alias VALUES ('   ', '99Q', 'CONGO AIR FORCE                                       ', 'CONGO AIR FORCE                                       ');
INSERT INTO airline_alias VALUES ('   ', '99V', 'SINGAPORE AIR FORCE                                   ', 'SINGAPORE AIR FORCE                                   ');
INSERT INTO airline_alias VALUES ('   ', '99X', 'RWANDA AIR FORCE                                      ', 'RWANDA AIR FORCE                                      ');
INSERT INTO airline_alias VALUES ('   ', '9A2', 'BOTSWANA MINISTRY OF AGRICULTURE                      ', 'BOTSWANA MINISTRY OF AGRICULTURE                      ');
INSERT INTO airline_alias VALUES ('   ', '9A4', 'OMAN AIR FORCE                                        ', 'OMAN AIR FORCE                                        ');
INSERT INTO airline_alias VALUES ('   ', '9A6', 'AMIRI FLIGHT                                          ', 'AMIRI FLIGHT                                          ');
INSERT INTO airline_alias VALUES ('   ', '9A7', 'QATAR EMIRI AIR FORCE                                 ', 'QATAR EMIRI AIR FORCE                                 ');
INSERT INTO airline_alias VALUES ('   ', '9A9', 'BAHRAIN ROYAL FLIGHT                                  ', 'BAHRAIN ROYAL FLIGHT                                  ');
INSERT INTO airline_alias VALUES ('   ', '9AP', 'SINDH GOVERNMENT                                      ', 'SINDH GOVERNMENT                                      ');
INSERT INTO airline_alias VALUES ('   ', '9BB', 'CAAC SPECIAL SERVICES DIVISION                        ', 'CAAC SPECIAL SERVICES DIVISION                        ');
INSERT INTO airline_alias VALUES ('   ', '9BX', 'TAIWAN NATIONAL AIRBORNE SERVICE CORPS                ', 'TAIWAN NATIONAL AIRBORNE SERVICE CORPS                ');
INSERT INTO airline_alias VALUES ('   ', '9C5', 'GAMBIAN GOVERNMENT                                    ', 'GAMBIAN GOVERNMENT                                    ');
INSERT INTO airline_alias VALUES ('   ', '9C6', 'ROYAL BAHAMAS DEFENCE FORCE                           ', 'ROYAL BAHAMAS DEFENCE FORCE                           ');
INSERT INTO airline_alias VALUES ('   ', '9CC', 'CHILEAN AIR FORCE                                     ', 'CHILEAN AIR FORCE                                     ');
INSERT INTO airline_alias VALUES ('   ', '9CF', 'TRANSPORT CANADA                                      ', 'TRANSPORT CANADA                                      ');
INSERT INTO airline_alias VALUES ('   ', '9CN', 'MOROCCAN MINISTRY OF SEA FISHERIES                    ', 'MOROCCAN MINISTRY OF SEA FISHERIES                    ');
INSERT INTO airline_alias VALUES ('   ', '9CP', 'BOLIVIAN AIR FORCE                                    ', 'BOLIVIAN AIR FORCE                                    ');
INSERT INTO airline_alias VALUES ('   ', '9CS', 'PORTUGUESE AIR FORCE                                  ', 'PORTUGUESE AIR FORCE                                  ');
INSERT INTO airline_alias VALUES ('   ', '9CX', 'URUGUAYAN NAVY                                        ', 'URUGUAYAN NAVY                                        ');
INSERT INTO airline_alias VALUES ('   ', '9D2', 'GABINETE DE APROVEITAMENTO MEDIO KUANZA               ', 'GABINETE DE APROVEITAMENTO MEDIO KUANZA               ');
INSERT INTO airline_alias VALUES ('   ', '9D4', 'CAPE VERDE ISLANDS COAST GUARD                        ', 'CAPE VERDE ISLANDS COAST GUARD                        ');
INSERT INTO airline_alias VALUES ('   ', '9DD', 'GERMAN NAVY                                           ', 'GERMAN NAVY                                           ');
INSERT INTO airline_alias VALUES ('   ', '9EC', 'SPANISH POLICE                                        ', 'SPANISH POLICE                                        ');
INSERT INTO airline_alias VALUES ('   ', '9EI', 'IRISH AIR CORPS                                       ', 'IRISH AIR CORPS                                       ');
INSERT INTO airline_alias VALUES ('   ', '9EK', 'ARMENIAN GOVERNMENT                                   ', 'ARMENIAN GOVERNMENT                                   ');
INSERT INTO airline_alias VALUES ('   ', '9EP', 'IRANIAN GOVERNMENT                                    ', 'IRANIAN GOVERNMENT                                    ');
INSERT INTO airline_alias VALUES ('   ', '9ET', 'ETHIOPIAN AIR FORCE                                   ', 'ETHIOPIAN AIR FORCE                                   ');
INSERT INTO airline_alias VALUES ('   ', '9EW', 'BELARUS GOVERNMENT                                    ', 'BELARUS GOVERNMENT                                    ');
INSERT INTO airline_alias VALUES ('   ', '9FF', 'FRENCH POLYNESIAN GOVERNMENT                          ', 'FRENCH POLYNESIAN GOVERNMENT                          ');
INSERT INTO airline_alias VALUES ('   ', '9GG', 'BRITISH ANTARCTIC SURVEY                              ', 'BRITISH ANTARCTIC SURVEY                              ');
INSERT INTO airline_alias VALUES ('   ', '9HB', 'BUNDESAMT FUR LANDESTOPOGRAPHIE                       ', 'BUNDESAMT FUR LANDESTOPOGRAPHIE                       ');
INSERT INTO airline_alias VALUES ('   ', '9HC', 'ECUADOREAN ARMY                                       ', 'ECUADOREAN ARMY                                       ');
INSERT INTO airline_alias VALUES ('   ', '9HI', 'DOMINICAN REPUBLIC AIR FORCE                          ', 'DOMINICAN REPUBLIC AIR FORCE                          ');
INSERT INTO airline_alias VALUES ('   ', '9HK', 'COLOMBIAN CIVIL AVIATION AUTHORITY                    ', 'COLOMBIAN CIVIL AVIATION AUTHORITY                    ');
INSERT INTO airline_alias VALUES ('   ', '9HL', 'SOUTH KOREAN GOVERNMENT                               ', 'SOUTH KOREAN GOVERNMENT                               ');
INSERT INTO airline_alias VALUES ('   ', '9HP', 'PANAMANIAN GOVERNMENT                                 ', 'PANAMANIAN GOVERNMENT                                 ');
INSERT INTO airline_alias VALUES ('   ', '9HR', 'HONDURAS AIR FORCE                                    ', 'HONDURAS AIR FORCE                                    ');
INSERT INTO airline_alias VALUES ('   ', '9HS', 'THAI ROYAL AGRICULTURE AVIATION (KASET)               ', 'THAI ROYAL AGRICULTURE AVIATION (KASET)               ');
INSERT INTO airline_alias VALUES ('   ', '9HZ', 'PRESIDENCY OF METEOROLOGY & ENVIRONMENT               ', 'PRESIDENCY OF METEOROLOGY & ENVIRONMENT               ');
INSERT INTO airline_alias VALUES ('   ', '9II', 'ITALIAN FINANCE GUARD                                 ', 'ITALIAN FINANCE GUARD                                 ');
INSERT INTO airline_alias VALUES ('   ', '9J2', 'DJIBOUTI GOVERNMENT                                   ', 'DJIBOUTI GOVERNMENT                                   ');
INSERT INTO airline_alias VALUES ('   ', '9JA', 'JAPAN COAST GUARD                                     ', 'JAPAN COAST GUARD                                     ');
INSERT INTO airline_alias VALUES ('   ', '9JY', 'ROYAL JORDANIAN AIR FORCE                             ', 'ROYAL JORDANIAN AIR FORCE                             ');
INSERT INTO airline_alias VALUES ('   ', '9KN', 'KAZAKHSTAN GOVERNMENT                                 ', 'KAZAKHSTAN GOVERNMENT                                 ');
INSERT INTO airline_alias VALUES ('   ', '9LN', 'ROYAL NORWEGIAN AIR FORCE                             ', 'ROYAL NORWEGIAN AIR FORCE                             ');
INSERT INTO airline_alias VALUES ('   ', '9LV', 'BUENOS AIRES PROVINCIAL GOVERNMENT                    ', 'BUENOS AIRES PROVINCIAL GOVERNMENT                    ');
INSERT INTO airline_alias VALUES ('   ', '9LX', 'GOVERNMENT OF LUXEMBOURG                              ', 'GOVERNMENT OF LUXEMBOURG                              ');
INSERT INTO airline_alias VALUES ('   ', '9LY', 'LITHUANIAN AIR FORCE                                  ', 'LITHUANIAN AIR FORCE                                  ');
INSERT INTO airline_alias VALUES ('   ', '9LZ', 'BULGARIAN AIR FORCE                                   ', 'BULGARIAN AIR FORCE                                   ');
INSERT INTO airline_alias VALUES ('   ', '9NA', 'NATO                                                  ', 'NATO                                                  ');
INSERT INTO airline_alias VALUES ('   ', '9NN', 'UNITED STATES NAVY                                    ', 'UNITED STATES NAVY                                    ');
INSERT INTO airline_alias VALUES ('   ', '9OB', 'PERUVIAN ARMY                                         ', 'PERUVIAN ARMY                                         ');
INSERT INTO airline_alias VALUES ('   ', '9OD', 'LEBANESE AIR FORCE                                    ', 'LEBANESE AIR FORCE                                    ');
INSERT INTO airline_alias VALUES ('   ', '9OE', 'AUSTRIAN AIR FORCE                                    ', 'AUSTRIAN AIR FORCE                                    ');
INSERT INTO airline_alias VALUES ('   ', '9OH', 'FINNISH FRONTIER GUARD                                ', 'FINNISH FRONTIER GUARD                                ');
INSERT INTO airline_alias VALUES ('   ', '9OK', 'CZECH AIR FORCE                                       ', 'CZECH AIR FORCE                                       ');
INSERT INTO airline_alias VALUES ('   ', '9OO', 'INSTITUT ROYAL DES SCIENCES NATURELLES                ', 'INSTITUT ROYAL DES SCIENCES NATURELLES                ');
INSERT INTO airline_alias VALUES ('   ', '9OY', 'ROYAL DANISH AIR FORCE                                ', 'ROYAL DANISH AIR FORCE                                ');
INSERT INTO airline_alias VALUES ('   ', '9P2', 'PAPUA NEW GUINEA CIVIL AVIATION DEPT.                 ', 'PAPUA NEW GUINEA CIVIL AVIATION DEPT.                 ');
INSERT INTO airline_alias VALUES ('   ', '9PH', 'ROYAL NETHERLANDS AIR FORCE                           ', 'ROYAL NETHERLANDS AIR FORCE                           ');
INSERT INTO airline_alias VALUES ('   ', '9PK', 'DEPT. OF DEFENCE & SECURITY (HANKAM)                  ', 'DEPT. OF DEFENCE & SECURITY (HANKAM)                  ');
INSERT INTO airline_alias VALUES ('   ', '9PP', 'BRAZILIAN FEDERAL POLICE                              ', 'BRAZILIAN FEDERAL POLICE                              ');
INSERT INTO airline_alias VALUES ('   ', '9PZ', 'SURINAM AIR FORCE                                     ', 'SURINAM AIR FORCE                                     ');
INSERT INTO airline_alias VALUES ('   ', '9RA', 'TATARSTAN GOVERNMENT                                  ', 'TATARSTAN GOVERNMENT                                  ');
INSERT INTO airline_alias VALUES ('   ', '9RP', 'PHILIPPINE AIR FORCE                                  ', 'PHILIPPINE AIR FORCE                                  ');
INSERT INTO airline_alias VALUES ('   ', '9S2', 'BANGLADESH DEFENCE FORCE                              ', 'BANGLADESH DEFENCE FORCE                              ');
INSERT INTO airline_alias VALUES ('   ', '9S5', 'SLOVENIAN AIR FORCE                                   ', 'SLOVENIAN AIR FORCE                                   ');
INSERT INTO airline_alias VALUES ('   ', '9S7', 'SEYCHELLES COAST GUARD AIR WING                       ', 'SEYCHELLES COAST GUARD AIR WING                       ');
INSERT INTO airline_alias VALUES ('   ', '9SA', 'STRATEGIC AIRLIFT CAPABILITY                          ', 'STRATEGIC AIRLIFT CAPABILITY                          ');
INSERT INTO airline_alias VALUES ('   ', '9SE', 'SWEDISH COAST GUARD                                   ', 'SWEDISH COAST GUARD                                   ');
INSERT INTO airline_alias VALUES ('   ', '9SP', 'POLISH AIR FORCE                                      ', 'POLISH AIR FORCE                                      ');
INSERT INTO airline_alias VALUES ('   ', '9ST', 'SUDAN AIR FORCE                                       ', 'SUDAN AIR FORCE                                       ');
INSERT INTO airline_alias VALUES ('   ', '9SU', 'EGYPTIAN GOVERNMENT                                   ', 'EGYPTIAN GOVERNMENT                                   ');
INSERT INTO airline_alias VALUES ('   ', '9SX', 'GREEK AIR FORCE                                       ', 'GREEK AIR FORCE                                       ');
INSERT INTO airline_alias VALUES ('   ', '9TC', 'TURKISH COAST GUARD                                   ', 'TURKISH COAST GUARD                                   ');
INSERT INTO airline_alias VALUES ('   ', '9TF', 'ICELANDIC COAST GUARD                                 ', 'ICELANDIC COAST GUARD                                 ');
INSERT INTO airline_alias VALUES ('   ', '9TG', 'GUATEMALAN AIR FORCE                                  ', 'GUATEMALAN AIR FORCE                                  ');
INSERT INTO airline_alias VALUES ('   ', '9TJ', 'CAMEROON AIR FORCE                                    ', 'CAMEROON AIR FORCE                                    ');
INSERT INTO airline_alias VALUES ('   ', '9TL', 'CENTRAL AFRICAN REPUBLIC GOVERNMENT                   ', 'CENTRAL AFRICAN REPUBLIC GOVERNMENT                   ');
INSERT INTO airline_alias VALUES ('   ', '9TR', 'GABON GARDE REPUBLICAINE                              ', 'GABON GARDE REPUBLICAINE                              ');
INSERT INTO airline_alias VALUES ('   ', '9TS', 'TUNISIAN AIR FORCE                                    ', 'TUNISIAN AIR FORCE                                    ');
INSERT INTO airline_alias VALUES ('   ', '9TT', 'CHAD GOVERNMENT                                       ', 'CHAD GOVERNMENT                                       ');
INSERT INTO airline_alias VALUES ('   ', '9TU', 'IVORY COAST GOVERNMENT                                ', 'IVORY COAST GOVERNMENT                                ');
INSERT INTO airline_alias VALUES ('   ', '9TY', 'BENIN AIR FORCE                                       ', 'BENIN AIR FORCE                                       ');
INSERT INTO airline_alias VALUES ('   ', '9TZ', 'MALI MINISTRY OF AGRICULTURE                          ', 'MALI MINISTRY OF AGRICULTURE                          ');
INSERT INTO airline_alias VALUES ('   ', '9UK', 'UZBEKISTAN GOVERNMENT                                 ', 'UZBEKISTAN GOVERNMENT                                 ');
INSERT INTO airline_alias VALUES ('   ', '9UN', 'UNITED NATIONS                                        ', 'UNITED NATIONS                                        ');
INSERT INTO airline_alias VALUES ('   ', '9UR', 'UKRAINE GOVERNMENT                                    ', 'UKRAINE GOVERNMENT                                    ');
INSERT INTO airline_alias VALUES ('   ', '9V3', 'BELIZE DEFENCE FORCE                                  ', 'BELIZE DEFENCE FORCE                                  ');
INSERT INTO airline_alias VALUES ('   ', '9V5', 'NAMIBIA FISHERIES PROTECTION                          ', 'NAMIBIA FISHERIES PROTECTION                          ');
INSERT INTO airline_alias VALUES ('   ', '9V8', 'BRUNEI ARMED FORCES AIR WING                          ', 'BRUNEI ARMED FORCES AIR WING                          ');
INSERT INTO airline_alias VALUES ('   ', '9VH', 'NORTHERN TERRITORY POLICE                             ', 'NORTHERN TERRITORY POLICE                             ');
INSERT INTO airline_alias VALUES ('   ', '9VN', 'VIETNAMESE MARITIME POLICE                            ', 'VIETNAMESE MARITIME POLICE                            ');
INSERT INTO airline_alias VALUES ('   ', '9VT', 'INDIAN COAST GUARD                                    ', 'INDIAN COAST GUARD                                    ');
INSERT INTO airline_alias VALUES ('   ', '9XA', 'MEXICAN MINISTRY OF COMMUNICATIONS                    ', 'MEXICAN MINISTRY OF COMMUNICATIONS                    ');
INSERT INTO airline_alias VALUES ('   ', '9XT', 'BURKINA FASO GOVERNMENT                               ', 'BURKINA FASO GOVERNMENT                               ');
INSERT INTO airline_alias VALUES ('   ', '9XU', 'CAMBODIAN GOVERNMENT                                  ', 'CAMBODIAN GOVERNMENT                                  ');
INSERT INTO airline_alias VALUES ('   ', '9XY', 'MYANMAR AIR FORCE                                     ', 'MYANMAR AIR FORCE                                     ');
INSERT INTO airline_alias VALUES ('   ', '9YA', 'AFGHAN NATIONAL ARMY AIR CORPS                        ', 'AFGHAN NATIONAL ARMY AIR CORPS                        ');
INSERT INTO airline_alias VALUES ('   ', '9YI', 'IRAQI GOVERNMENT                                      ', 'IRAQI GOVERNMENT                                      ');
INSERT INTO airline_alias VALUES ('   ', '9YN', 'NICARAGUAN AIR FORCE                                  ', 'NICARAGUAN AIR FORCE                                  ');
INSERT INTO airline_alias VALUES ('   ', '9YR', 'ROMANIAN AIR FORCE                                    ', 'ROMANIAN AIR FORCE                                    ');
INSERT INTO airline_alias VALUES ('   ', '9YS', 'EL SALVADOR AIR FORCE                                 ', 'EL SALVADOR AIR FORCE                                 ');
INSERT INTO airline_alias VALUES ('   ', '9YU', 'SERBIAN GOVERNMENT [SERBIA]                           ', 'SERBIAN GOVERNMENT [SERBIA]                           ');
INSERT INTO airline_alias VALUES ('   ', '9YV', 'CUERPO TECNICO DE POLICIA JUDICIAL                    ', 'CUERPO TECNICO DE POLICIA JUDICIAL                    ');
INSERT INTO airline_alias VALUES ('   ', '9ZK', 'ROYAL NEW ZEALAND AIR FORCE                           ', 'ROYAL NEW ZEALAND AIR FORCE                           ');
INSERT INTO airline_alias VALUES ('   ', '9ZP', 'ADMINISTRACION NACIONAL DE ELECTRICIDAD               ', 'ADMINISTRACION NACIONAL DE ELECTRICIDAD               ');
INSERT INTO airline_alias VALUES ('   ', '9ZS', 'SOUTH AFRICAN POLICE SERVICE                          ', 'SOUTH AFRICAN POLICE SERVICE                          ');
INSERT INTO airline_alias VALUES ('   ', '9ZZ', 'ZIMBABWE AIR FORCE                                    ', 'ZIMBABWE AIR FORCE                                    ');
INSERT INTO airline_alias VALUES ('   ', 'AAG', 'AIR ATLANTIQUE [UK]                                   ', 'AIR ATLANTIQUE [UK]                                   ');
INSERT INTO airline_alias VALUES ('   ', 'AAN', 'AMSTERDAM AIRLINES                                    ', 'AMSTERDAM AIRLINES                                    ');
INSERT INTO airline_alias VALUES ('   ', 'AAP', 'ARABASCO LTD.                                         ', 'ARABASCO LTD.                                         ');
INSERT INTO airline_alias VALUES ('   ', 'ABF', 'SCANWINGS                                             ', 'SCANWINGS                                             ');
INSERT INTO airline_alias VALUES ('   ', 'ABJ', 'ABAETE LINHAS AEREAS                                  ', 'ABAETE LINHAS AEREAS                                  ');
INSERT INTO airline_alias VALUES ('   ', 'ABK', 'ALBERTA CITYLINK                                      ', 'ALBERTA CITYLINK                                      ');
INSERT INTO airline_alias VALUES ('BX ', 'ABL', 'AIR BUSAN                                             ', 'AIR BUSAN                                             ');
INSERT INTO airline_alias VALUES ('   ', 'ABP', 'ABS JETS                                              ', 'ABS JETS                                              ');
INSERT INTO airline_alias VALUES ('O4 ', 'ABV', 'ANTRAK AIR GHANA                                      ', 'ANTRAK AIR GHANA                                      ');
INSERT INTO airline_alias VALUES ('RU ', 'ABW', 'AIRBRIDGE CARGO AIRLINES                              ', 'AIRBRIDGE CARGO AIRLINES                              ');
INSERT INTO airline_alias VALUES ('G9 ', 'ABY', 'AIR ARABIA                                            ', 'AIR ARABIA                                            ');
INSERT INTO airline_alias VALUES ('   ', 'ACE', 'AIR CHARTER EXPRESS                                   ', 'AIR CHARTER EXPRESS                                   ');
INSERT INTO airline_alias VALUES ('   ', 'ACH', 'AFRICA''S CONNECTION STP                               ', 'AFRICA''S CONNECTION STP                               ');
INSERT INTO airline_alias VALUES ('8V ', 'ACP', 'ASTRAL AVIATION                                       ', 'ASTRAL AVIATION                                       ');
INSERT INTO airline_alias VALUES ('   ', 'ACS', 'AIRCRAFT SALES & SERVICES                             ', 'AIRCRAFT SALES & SERVICES                             ');
INSERT INTO airline_alias VALUES ('6U ', 'ACX', 'AIR CARGO GERMANY                                     ', 'AIR CARGO GERMANY                                     ');
INSERT INTO airline_alias VALUES ('   ', 'ADC', 'AD ASTRA EXECUTIVE CHARTER                            ', 'AD ASTRA EXECUTIVE CHARTER                            ');
INSERT INTO airline_alias VALUES ('   ', 'ADI', 'AUDELI AIR EXPRESS                                    ', 'AUDELI AIR EXPRESS                                    ');
INSERT INTO airline_alias VALUES ('   ', 'ADN', 'AERO-DIENST GMBH                                      ', 'AERO-DIENST GMBH                                      ');
INSERT INTO airline_alias VALUES ('   ', 'ADT', 'AIR DORVAL                                            ', 'AIR DORVAL                                            ');
INSERT INTO airline_alias VALUES ('   ', 'AED', 'EADS CASA                                             ', 'EADS CASA                                             ');
INSERT INTO airline_alias VALUES ('   ', 'AEI', 'AIR ITALY POLAND                                      ', 'AIR ITALY POLAND                                      ');
INSERT INTO airline_alias VALUES ('A4 ', 'AEK', 'AEROCON                                               ', 'AEROCON                                               ');
INSERT INTO airline_alias VALUES ('3S ', 'AEN', 'AEROLAND AIRWAYS                                      ', 'AEROLAND AIRWAYS                                      ');
INSERT INTO airline_alias VALUES ('   ', 'AES', 'AEROSUR PARAGUAY                                      ', 'AEROSUR PARAGUAY                                      ');
INSERT INTO airline_alias VALUES ('I9 ', 'AEY', 'AIR ITALY                                             ', 'AIR ITALY                                             ');
INSERT INTO airline_alias VALUES ('   ', 'AFE', 'AIRFAST INDONESIA                                     ', 'AIRFAST INDONESIA                                     ');
INSERT INTO airline_alias VALUES ('VC ', 'AGC', 'STRATEGIC AIRLINES [AUSTRALIA]                        ', 'STRATEGIC AIRLINES [AUSTRALIA]                        ');
INSERT INTO airline_alias VALUES ('C3 ', 'AGO', 'ANGOLA AIR CHARTER                                    ', 'ANGOLA AIR CHARTER                                    ');
INSERT INTO airline_alias VALUES ('   ', 'AGS', 'AIRGO AIRLINES                                        ', 'AIRGO AIRLINES                                        ');
INSERT INTO airline_alias VALUES ('JJ ', 'AGX', 'AVIOGENEX [SERBIA]                                    ', 'AVIOGENEX [SERBIA]                                    ');
INSERT INTO airline_alias VALUES ('   ', 'AHG', 'AGRO AIR INTERNATIONAL                                ', 'AGRO AIR INTERNATIONAL                                ');
INSERT INTO airline_alias VALUES ('   ', 'AHI', 'SERVICIOS AEREOS DE CHIHUAHUA AEROCHISA               ', 'SERVICIOS AEREOS DE CHIHUAHUA AEROCHISA               ');
INSERT INTO airline_alias VALUES ('   ', 'AHO', 'AIR HAMBURG                                           ', 'AIR HAMBURG                                           ');
INSERT INTO airline_alias VALUES ('   ', 'AHX', 'AMAKUSA AIRLINES                                      ', 'AMAKUSA AIRLINES                                      ');
INSERT INTO airline_alias VALUES ('Z7 ', 'AIF', 'AVIA TRAFFIC COMPANY                                  ', 'AVIA TRAFFIC COMPANY                                  ');
INSERT INTO airline_alias VALUES ('4O ', 'AIJ', 'INTERJET [MEXICO]                                     ', 'INTERJET [MEXICO]                                     ');
INSERT INTO airline_alias VALUES ('FD ', 'AIQ', 'THAI AIRASIA                                          ', 'THAI AIRASIA                                          ');
INSERT INTO airline_alias VALUES ('   ', 'AIX', 'AIRCRUISING AUSTRALIA                                 ', 'AIRCRUISING AUSTRALIA                                 ');
INSERT INTO airline_alias VALUES ('TK ', 'AJA', 'ANADOLUJET                                            ', 'ANADOLUJET                                            ');
INSERT INTO airline_alias VALUES ('   ', 'AJK', 'ALLIED AIR                                            ', 'ALLIED AIR                                            ');
INSERT INTO airline_alias VALUES ('   ', 'AJS', 'CENTRAL CHARTER DE COLOMBIA                           ', 'CENTRAL CHARTER DE COLOMBIA                           ');
INSERT INTO airline_alias VALUES ('9N ', 'AJV', 'ANA & JP EXPRESS                                      ', 'ANA & JP EXPRESS                                      ');
INSERT INTO airline_alias VALUES ('   ', 'AJW', 'ALPHA JET INTERNATIONAL                               ', 'ALPHA JET INTERNATIONAL                               ');
INSERT INTO airline_alias VALUES ('   ', 'AKA', 'AIR KOREA                                             ', 'AIR KOREA                                             ');
INSERT INTO airline_alias VALUES ('KP ', 'AKC', 'ASIALINK CARGO EXPRESS                                ', 'ASIALINK CARGO EXPRESS                                ');
INSERT INTO airline_alias VALUES ('4A ', 'AKL', 'AIR KIRIBATI                                          ', 'AIR KIRIBATI                                          ');
INSERT INTO airline_alias VALUES ('TO ', 'AKN', 'ALKAN AIR [CANADA]                                    ', 'ALKAN AIR [CANADA]                                    ');
INSERT INTO airline_alias VALUES ('   ', 'AKQ', 'AEROSPACE CONSORTIUM                                  ', 'AEROSPACE CONSORTIUM                                  ');
INSERT INTO airline_alias VALUES ('   ', 'ALE', 'AIRLIFT INTERNATIONAL OF GHANA                        ', 'AIRLIFT INTERNATIONAL OF GHANA                        ');
INSERT INTO airline_alias VALUES ('   ', 'ALR', 'ALFA AIR SERVICES                                     ', 'ALFA AIR SERVICES                                     ');
INSERT INTO airline_alias VALUES ('K4 ', 'ALW', 'AIRCRAFT LEASING SERVICES                             ', 'AIRCRAFT LEASING SERVICES                             ');
INSERT INTO airline_alias VALUES ('   ', 'ALZ', 'ALTA FLIGHTS (CHARTERS)                               ', 'ALTA FLIGHTS (CHARTERS)                               ');
INSERT INTO airline_alias VALUES ('   ', 'AMD', 'SOUTH AFRICAN RED CROSS AIR MERCY                     ', 'SOUTH AFRICAN RED CROSS AIR MERCY                     ');
INSERT INTO airline_alias VALUES ('6M ', 'AMG', 'AIR MINAS                                             ', 'AIR MINAS                                             ');
INSERT INTO airline_alias VALUES ('   ', 'AMJ', 'AMJET EXECUTIVE                                       ', 'AMJET EXECUTIVE                                       ');
INSERT INTO airline_alias VALUES ('   ', 'AMP', 'AERO TRANSPORTE S.A.                                  ', 'AERO TRANSPORTE S.A.                                  ');
INSERT INTO airline_alias VALUES ('YJ ', 'AMV', 'AMC AIRLINES                                          ', 'AMC AIRLINES                                          ');
INSERT INTO airline_alias VALUES ('YW ', 'ANE', 'AIR NOSTRUM                                           ', 'AIR NOSTRUM                                           ');
INSERT INTO airline_alias VALUES ('   ', 'ANQ', 'AEROLINEA DE ANTIOQUIA                                ', 'AEROLINEA DE ANTIOQUIA                                ');
INSERT INTO airline_alias VALUES ('EA ', 'ANU', 'ANDALUS LINEAS AEREAS                                 ', 'ANDALUS LINEAS AEREAS                                 ');
INSERT INTO airline_alias VALUES ('   ', 'AOA', 'ALCON SERVICIOS AEREOS                                ', 'ALCON SERVICIOS AEREOS                                ');
INSERT INTO airline_alias VALUES ('N9 ', 'AOH', 'NORTH COAST AVIATION                                  ', 'NORTH COAST AVIATION                                  ');
INSERT INTO airline_alias VALUES ('   ', 'AOJ', 'AVCON JET AG                                          ', 'AVCON JET AG                                          ');
INSERT INTO airline_alias VALUES ('   ', 'AON', 'AERO ENTREPRISE                                       ', 'AERO ENTREPRISE                                       ');
INSERT INTO airline_alias VALUES ('   ', 'AOV', 'AERO VISION                                           ', 'AERO VISION                                           ');
INSERT INTO airline_alias VALUES ('   ', 'APC', 'AIRPAC AIRLINES                                       ', 'AIRPAC AIRLINES                                       ');
INSERT INTO airline_alias VALUES ('   ', 'APF', 'AMAPOLA FLYG                                          ', 'AMAPOLA FLYG                                          ');
INSERT INTO airline_alias VALUES ('   ', 'APN', 'AIR PHOENIX                                           ', 'AIR PHOENIX                                           ');
INSERT INTO airline_alias VALUES ('   ', 'APO', 'AEROPRO                                               ', 'AEROPRO                                               ');
INSERT INTO airline_alias VALUES ('   ', 'AQB', 'AQUALATA AIR                                          ', 'AQUALATA AIR                                          ');
INSERT INTO airline_alias VALUES ('   ', 'AQR', 'AQUA AIRLINES                                         ', 'AQUA AIRLINES                                         ');
INSERT INTO airline_alias VALUES ('   ', 'AQU', 'AIRQUARIUS AVIATION                                   ', 'AIRQUARIUS AVIATION                                   ');
INSERT INTO airline_alias VALUES ('W3 ', 'ARA', 'ARIK AIR                                              ', 'ARIK AIR                                              ');
INSERT INTO airline_alias VALUES ('   ', 'ARL', 'AIRLEC                                                ', 'AIRLEC                                                ');
INSERT INTO airline_alias VALUES ('6Y ', 'ART', 'SMARTLYNX AIRLINES                                    ', 'SMARTLYNX AIRLINES                                    ');
INSERT INTO airline_alias VALUES ('   ', 'ARW', 'ARIA [FRANCE]                                         ', 'ARIA [FRANCE]                                         ');
INSERT INTO airline_alias VALUES ('   ', 'ASB', 'AIR SPRAY                                             ', 'AIR SPRAY                                             ');
INSERT INTO airline_alias VALUES ('   ', 'ASM', 'AWESOME FLIGHT SERVICES                               ', 'AWESOME FLIGHT SERVICES                               ');
INSERT INTO airline_alias VALUES ('   ', 'ASP', 'AIRSPRINT                                             ', 'AIRSPRINT                                             ');
INSERT INTO airline_alias VALUES ('QD ', 'ASS', 'AIR CLASS                                             ', 'AIR CLASS                                             ');
INSERT INTO airline_alias VALUES ('   ', 'ASY', 'ADAGOLD AVIATION                                      ', 'ADAGOLD AVIATION                                      ');
INSERT INTO airline_alias VALUES ('   ', 'ATV', 'AVANTI AIR [GERMANY]                                  ', 'AVANTI AIR [GERMANY]                                  ');
INSERT INTO airline_alias VALUES ('ZF ', 'ATW', 'ATHENS AIRWAYS                                        ', 'ATHENS AIRWAYS                                        ');
INSERT INTO airline_alias VALUES ('   ', 'ATY', 'AIR TRAFFIC                                           ', 'AIR TRAFFIC                                           ');
INSERT INTO airline_alias VALUES ('   ', 'AUK', 'AURIC AIR SERVICES                                    ', 'AURIC AIR SERVICES                                    ');
INSERT INTO airline_alias VALUES ('5N ', 'AUL', 'NORDAVIA REGIONAL AIRLINES                            ', 'NORDAVIA REGIONAL AIRLINES                            ');
INSERT INTO airline_alias VALUES ('   ', 'AUV', 'REDAIR LUFTFAHRT                                      ', 'REDAIR LUFTFAHRT                                      ');
INSERT INTO airline_alias VALUES ('   ', 'AVM', 'AVEMEX                                                ', 'AVEMEX                                                ');
INSERT INTO airline_alias VALUES ('   ', 'AVW', 'AVIATOR                                               ', 'AVIATOR                                               ');
INSERT INTO airline_alias VALUES ('G2 ', 'AVX', 'AVIREX GABON                                          ', 'AVIREX GABON                                          ');
INSERT INTO airline_alias VALUES ('Y5 ', 'AWA', 'ASIA WINGS                                            ', 'ASIA WINGS                                            ');
INSERT INTO airline_alias VALUES ('ZT ', 'AWC', 'TITAN AIRWAYS                                         ', 'TITAN AIRWAYS                                         ');
INSERT INTO airline_alias VALUES ('   ', 'AWK', 'AIRWORK (NZ) LTD.                                     ', 'AIRWORK (NZ) LTD.                                     ');
INSERT INTO airline_alias VALUES ('QZ ', 'AWQ', 'INDONESIA AIRASIA                                     ', 'INDONESIA AIRASIA                                     ');
INSERT INTO airline_alias VALUES ('   ', 'AWS', 'ARAB WINGS                                            ', 'ARAB WINGS                                            ');
INSERT INTO airline_alias VALUES ('   ', 'AWY', 'AEROWAY AIR TRANSPORT                                 ', 'AEROWAY AIR TRANSPORT                                 ');
INSERT INTO airline_alias VALUES ('IX ', 'AXB', 'AIR INDIA EXPRESS                                     ', 'AIR INDIA EXPRESS                                     ');
INSERT INTO airline_alias VALUES ('   ', 'AXE', 'AIREXPLORE                                            ', 'AIREXPLORE                                            ');
INSERT INTO airline_alias VALUES ('   ', 'AXU', 'ABU DHABI AVIATION                                    ', 'ABU DHABI AVIATION                                    ');
INSERT INTO airline_alias VALUES ('YH ', 'AYG', 'YANGON AIRWAYS                                        ', 'YANGON AIRWAYS                                        ');
INSERT INTO airline_alias VALUES ('   ', 'AYT', 'AYEET AVIATION & TOURISM                              ', 'AYEET AVIATION & TOURISM                              ');
INSERT INTO airline_alias VALUES ('   ', 'AYY', 'AIR ALLIANCE EXPRESS                                  ', 'AIR ALLIANCE EXPRESS                                  ');
INSERT INTO airline_alias VALUES ('Z8 ', 'AZN', 'AMASZONAS TRANSPORTES AEREOS                          ', 'AMASZONAS TRANSPORTES AEREOS                          ');
INSERT INTO airline_alias VALUES ('AD ', 'AZU', 'AZUL LINHAS AEREAS BRASILEIRAS                        ', 'AZUL LINHAS AEREAS BRASILEIRAS                        ');
INSERT INTO airline_alias VALUES ('BN ', 'BAB', 'BAHRAIN AIR                                           ', 'BAHRAIN AIR                                           ');
INSERT INTO airline_alias VALUES ('   ', 'BAE', 'BAE SYSTEMS ATTAC                                     ', 'BAE SYSTEMS ATTAC                                     ');
INSERT INTO airline_alias VALUES ('   ', 'BBT', 'AIR BASHKORTOSTAN                                     ', 'AIR BASHKORTOSTAN                                     ');
INSERT INTO airline_alias VALUES ('   ', 'BBZ', 'BLUE BIRD AVIATION [KENYA]                            ', 'BLUE BIRD AVIATION [KENYA]                            ');
INSERT INTO airline_alias VALUES ('8B ', 'BCC', 'BUSINESS AIR [THAILAND]                               ', 'BUSINESS AIR [THAILAND]                               ');
INSERT INTO airline_alias VALUES ('B4 ', 'BCF', 'BACH FLUGBETRIEBS                                     ', 'BACH FLUGBETRIEBS                                     ');
INSERT INTO airline_alias VALUES ('SI ', 'BCI', 'BLUE ISLANDS                                          ', 'BLUE ISLANDS                                          ');
INSERT INTO airline_alias VALUES ('BZ ', 'BDA', 'BLUE DART AVIATION                                    ', 'BLUE DART AVIATION                                    ');
INSERT INTO airline_alias VALUES ('   ', 'BDI', 'BENAIR [DENMARK]                                      ', 'BENAIR [DENMARK]                                      ');
INSERT INTO airline_alias VALUES ('   ', 'BDV', 'ABERDAIR AVIATION LTD.                                ', 'ABERDAIR AVIATION LTD.                                ');
INSERT INTO airline_alias VALUES ('   ', 'BEC', 'BERKUT STATE AIR COMPANY                              ', 'BERKUT STATE AIR COMPANY                              ');
INSERT INTO airline_alias VALUES ('SN ', 'BEL', 'BRUSSELS AIRLINES                                     ', 'BRUSSELS AIRLINES                                     ');
INSERT INTO airline_alias VALUES ('   ', 'BET', 'BRAZILIAN EXPRESS TRANSPORTES AEREOS                  ', 'BRAZILIAN EXPRESS TRANSPORTES AEREOS                  ');
INSERT INTO airline_alias VALUES ('   ', 'BEZ', 'AIR ST. KITTS & NEVIS                                 ', 'AIR ST. KITTS & NEVIS                                 ');
INSERT INTO airline_alias VALUES ('YH ', 'BFF', 'AIR NUNAVUT                                           ', 'AIR NUNAVUT                                           ');
INSERT INTO airline_alias VALUES ('   ', 'BFX', 'ALPHA EXECUTIVE FLUGBETRIEBS                          ', 'ALPHA EXECUTIVE FLUGBETRIEBS                          ');
INSERT INTO airline_alias VALUES ('8B ', 'BFY', 'BREMENFLY                                             ', 'BREMENFLY                                             ');
INSERT INTO airline_alias VALUES ('4Y ', 'BGA', 'AIRBUS TRANSPORT INTERNATIONAL                        ', 'AIRBUS TRANSPORT INTERNATIONAL                        ');
INSERT INTO airline_alias VALUES ('   ', 'BGB', 'BRITISH GLOBAL AIRLINES                               ', 'BRITISH GLOBAL AIRLINES                               ');
INSERT INTO airline_alias VALUES ('   ', 'BGH', 'BH-AIR                                                ', 'BH-AIR                                                ');
INSERT INTO airline_alias VALUES ('   ', 'BGM', 'AK BARS AERO                                          ', 'AK BARS AERO                                          ');
INSERT INTO airline_alias VALUES ('   ', 'BGT', 'BERGEN AIR TRANSPORT                                  ', 'BERGEN AIR TRANSPORT                                  ');
INSERT INTO airline_alias VALUES ('U4 ', 'BHA', 'BUDDHA AIR                                            ', 'BUDDHA AIR                                            ');
INSERT INTO airline_alias VALUES ('   ', 'BHN', 'BRISTOW HELICOPTERS NIGERIA                           ', 'BRISTOW HELICOPTERS NIGERIA                           ');
INSERT INTO airline_alias VALUES ('   ', 'BHR', 'BIGHORN AIRWAYS                                       ', 'BIGHORN AIRWAYS                                       ');
INSERT INTO airline_alias VALUES ('   ', 'BID', 'BINAIR AERO SERVICE                                   ', 'BINAIR AERO SERVICE                                   ');
INSERT INTO airline_alias VALUES ('ML ', 'BIE', 'AIR MEDITERRANEE [FRANCE]                             ', 'AIR MEDITERRANEE [FRANCE]                             ');
INSERT INTO airline_alias VALUES ('   ', 'BIG', 'BIG ISLAND AIR                                        ', 'BIG ISLAND AIR                                        ');
INSERT INTO airline_alias VALUES ('   ', 'BJC', 'BALTIC JET AIRCOMPANY                                 ', 'BALTIC JET AIRCOMPANY                                 ');
INSERT INTO airline_alias VALUES ('   ', 'BJT', 'ACM AVIATION INC.                                     ', 'ACM AVIATION INC.                                     ');
INSERT INTO airline_alias VALUES ('   ', 'BKO', 'BRIKO AIR SERVICES                                    ', 'BRIKO AIR SERVICES                                    ');
INSERT INTO airline_alias VALUES ('   ', 'BLB', 'BLUE BIRD AVIATION [SUDAN]                            ', 'BLUE BIRD AVIATION [SUDAN]                            ');
INSERT INTO airline_alias VALUES ('   ', 'BLE', 'BLUE LINE [FRANCE]                                    ', 'BLUE LINE [FRANCE]                                    ');
INSERT INTO airline_alias VALUES ('BD ', 'BMR', 'BRITISH MIDLAND REGIONAL                              ', 'BRITISH MIDLAND REGIONAL                              ');
INSERT INTO airline_alias VALUES ('   ', 'BMX', 'BANCO DE MEXICO                                       ', 'BANCO DE MEXICO                                       ');
INSERT INTO airline_alias VALUES ('   ', 'BMY', 'BIMINI ISLAND AIR                                     ', 'BIMINI ISLAND AIR                                     ');
INSERT INTO airline_alias VALUES ('   ', 'BOE', 'BOEING COMPANY                                        ', 'BOEING COMPANY                                        ');
INSERT INTO airline_alias VALUES ('2L ', 'BOL', 'TRANSPORTES AEREOS BOLIVIANOS                         ', 'TRANSPORTES AEREOS BOLIVIANOS                         ');
INSERT INTO airline_alias VALUES ('JA ', 'BON', 'B & H AIRLINES                                        ', 'B & H AIRLINES                                        ');
INSERT INTO airline_alias VALUES ('EC ', 'BOS', 'OPEN SKIES                                            ', 'OPEN SKIES                                            ');
INSERT INTO airline_alias VALUES ('OB ', 'BOV', 'BOLIVIANA DE AVIACION                                 ', 'BOLIVIANA DE AVIACION                                 ');
INSERT INTO airline_alias VALUES ('3S ', 'BOX', 'AEROLOGIC [GERMANY]                                   ', 'AEROLOGIC [GERMANY]                                   ');
INSERT INTO airline_alias VALUES ('NM ', 'BPS', 'MANX2                                                 ', 'MANX2                                                 ');
INSERT INTO airline_alias VALUES ('   ', 'BPX', 'BP EXPLORATION COMPANY COLOMBIA LTDA.                 ', 'BP EXPLORATION COMPANY COLOMBIA LTDA.                 ');
INSERT INTO airline_alias VALUES ('5Q ', 'BQB', 'BQB LINEAS AEREAS                                     ', 'BQB LINEAS AEREAS                                     ');
INSERT INTO airline_alias VALUES ('   ', 'BRH', 'STAR AIR CARGO                                        ', 'STAR AIR CARGO                                        ');
INSERT INTO airline_alias VALUES ('FQ ', 'BRI', 'BRINDABELLA AIRLINES                                  ', 'BRINDABELLA AIRLINES                                  ');
INSERT INTO airline_alias VALUES ('BJ ', 'BRJ', 'BORAJET                                               ', 'BORAJET                                               ');
INSERT INTO airline_alias VALUES ('K6 ', 'BRV', 'BRAVO AIR CONGO                                       ', 'BRAVO AIR CONGO                                       ');
INSERT INTO airline_alias VALUES ('   ', 'BSL', 'AIR BRASIL LINHAS AEREAS                              ', 'AIR BRASIL LINHAS AEREAS                              ');
INSERT INTO airline_alias VALUES ('5F ', 'BST', 'BEST AIRLINES                                         ', 'BEST AIRLINES                                         ');
INSERT INTO airline_alias VALUES ('   ', 'BTM', 'AIR BATUMI                                            ', 'AIR BATUMI                                            ');
INSERT INTO airline_alias VALUES ('   ', 'BUC', 'BULGARIAN AIR CHARTER                                 ', 'BULGARIAN AIR CHARTER                                 ');
INSERT INTO airline_alias VALUES ('   ', 'BUR', 'AIR BUCHAREST                                         ', 'AIR BUCHAREST                                         ');
INSERT INTO airline_alias VALUES ('XV ', 'BVI', 'BVI AIRWAYS                                           ', 'BVI AIRWAYS                                           ');
INSERT INTO airline_alias VALUES ('   ', 'BVR', 'ACM AIR CHARTER                                       ', 'ACM AIR CHARTER                                       ');
INSERT INTO airline_alias VALUES ('   ', 'BWI', 'BLUE WING AIRLINES                                    ', 'BLUE WING AIRLINES                                    ');
INSERT INTO airline_alias VALUES ('   ', 'BWS', 'BASS AIRWAYS                                          ', 'BASS AIRWAYS                                          ');
INSERT INTO airline_alias VALUES ('   ', 'BXA', 'BEXAIR                                                ', 'BEXAIR                                                ');
INSERT INTO airline_alias VALUES ('   ', 'BXH', 'BAR XH AIR                                            ', 'BAR XH AIR                                            ');
INSERT INTO airline_alias VALUES ('   ', 'BXR', 'REDDING AERO ENTERPRISES INC.                         ', 'REDDING AERO ENTERPRISES INC.                         ');
INSERT INTO airline_alias VALUES ('   ', 'BYA', 'BERRY AVIATION                                        ', 'BERRY AVIATION                                        ');
INSERT INTO airline_alias VALUES ('   ', 'BZS', 'AERO BINIZA                                           ', 'AERO BINIZA                                           ');
INSERT INTO airline_alias VALUES ('   ', 'BZT', 'BIZJET AIRCRAFT & HELICOPTERS MANAGEMENT              ', 'BIZJET AIRCRAFT & HELICOPTERS MANAGEMENT              ');
INSERT INTO airline_alias VALUES ('8F ', 'CAD', 'CARDIG AIR                                            ', 'CARDIG AIR                                            ');
INSERT INTO airline_alias VALUES ('7H ', 'CAI', 'CORENDON AIRLINES                                     ', 'CORENDON AIRLINES                                     ');
INSERT INTO airline_alias VALUES ('TX ', 'CAJ', 'AIR CARAIBES ATLANTIQUE                               ', 'AIR CARAIBES ATLANTIQUE                               ');
INSERT INTO airline_alias VALUES ('CA ', 'CAO', 'AIR CHINA CARGO                                       ', 'AIR CHINA CARGO                                       ');
INSERT INTO airline_alias VALUES ('   ', 'CAT', 'COPENHAGEN AIRTAXI                                    ', 'COPENHAGEN AIRTAXI                                    ');
INSERT INTO airline_alias VALUES ('   ', 'CBC', 'CARIBAIR [DOMINICAN REPUBLIC]                         ', 'CARIBAIR [DOMINICAN REPUBLIC]                         ');
INSERT INTO airline_alias VALUES ('   ', 'CBD', 'LOCKHEED MARTIN AERONAUTICS COMPANY                   ', 'LOCKHEED MARTIN AERONAUTICS COMPANY                   ');
INSERT INTO airline_alias VALUES ('JD ', 'CBJ', 'BEIJING CAPITAL AIRLINES                              ', 'BEIJING CAPITAL AIRLINES                              ');
INSERT INTO airline_alias VALUES ('   ', 'CBS', 'COLUMBUS AVIA                                         ', 'COLUMBUS AVIA                                         ');
INSERT INTO airline_alias VALUES ('   ', 'CBT', 'CATALINA FLYING BOATS                                 ', 'CATALINA FLYING BOATS                                 ');
INSERT INTO airline_alias VALUES ('   ', 'CCF', 'CCF MANAGER AIRLINE                                   ', 'CCF MANAGER AIRLINE                                   ');
INSERT INTO airline_alias VALUES ('   ', 'CCG', 'CENTRAL CONNECT AIRLINES                              ', 'CENTRAL CONNECT AIRLINES                              ');
INSERT INTO airline_alias VALUES ('CD ', 'CDA', 'AEROCARDAL                                            ', 'AEROCARDAL                                            ');
INSERT INTO airline_alias VALUES ('   ', 'CEG', 'CEGA AIR AMBULANCE UK LTD.                            ', 'CEGA AIR AMBULANCE UK LTD.                            ');
INSERT INTO airline_alias VALUES ('C2 ', 'CEL', 'CEIBA INTERCONTINENTAL                                ', 'CEIBA INTERCONTINENTAL                                ');
INSERT INTO airline_alias VALUES ('   ', 'CEY', 'AIR CENTURY                                           ', 'AIR CENTURY                                           ');
INSERT INTO airline_alias VALUES ('   ', 'CFD', 'CRANFIELD UNIVERSITY                                  ', 'CRANFIELD UNIVERSITY                                  ');
INSERT INTO airline_alias VALUES ('CJ ', 'CFE', 'BA CITYFLYER                                          ', 'BA CITYFLYER                                          ');
INSERT INTO airline_alias VALUES ('   ', 'CFH', 'CAREFLIGHT (NSW) LTD.                                 ', 'CAREFLIGHT (NSW) LTD.                                 ');
INSERT INTO airline_alias VALUES ('   ', 'CFV', 'AERO CALAFIA                                          ', 'AERO CALAFIA                                          ');
INSERT INTO airline_alias VALUES ('   ', 'CFX', 'CFA AIR CHARTERS                                      ', 'CFA AIR CHARTERS                                      ');
INSERT INTO airline_alias VALUES ('   ', 'CGF', 'CARGO AIR                                             ', 'CARGO AIR                                             ');
INSERT INTO airline_alias VALUES ('   ', 'CGR', 'COMPAGNIA GENERALE RIPRESEAEREE                       ', 'COMPAGNIA GENERALE RIPRESEAEREE                       ');
INSERT INTO airline_alias VALUES ('   ', 'CHA', 'CENTRAL FLYING SERVICE INC.                           ', 'CENTRAL FLYING SERVICE INC.                           ');
INSERT INTO airline_alias VALUES ('PN ', 'CHB', 'CHINA WEST AIR                                        ', 'CHINA WEST AIR                                        ');
INSERT INTO airline_alias VALUES ('   ', 'CHN', 'CHANNEL ISLANDS AVIATION                              ', 'CHANNEL ISLANDS AVIATION                              ');
INSERT INTO airline_alias VALUES ('   ', 'CHV', 'BUKOVYNA AVIATION ENTERPRISE                          ', 'BUKOVYNA AVIATION ENTERPRISE                          ');
INSERT INTO airline_alias VALUES ('   ', 'CIB', 'CONDOR BERLIN                                         ', 'CONDOR BERLIN                                         ');
INSERT INTO airline_alias VALUES ('   ', 'CII', 'CITYFLY                                               ', 'CITYFLY                                               ');
INSERT INTO airline_alias VALUES ('   ', 'CIN', 'COMORO ISLANDS AIRLINE                                ', 'COMORO ISLANDS AIRLINE                                ');
INSERT INTO airline_alias VALUES ('   ', 'CIS', 'CAT ISLAND AIR                                        ', 'CAT ISLAND AIR                                        ');
INSERT INTO airline_alias VALUES ('YC ', 'CJR', 'CAVERTON HELICOPTERS                                  ', 'CAVERTON HELICOPTERS                                  ');
INSERT INTO airline_alias VALUES ('   ', 'CKM', 'BKS AIR                                               ', 'BKS AIR                                               ');
INSERT INTO airline_alias VALUES ('   ', 'CLA', 'COMLUX AVIATION                                       ', 'COMLUX AVIATION                                       ');
INSERT INTO airline_alias VALUES ('   ', 'CLB', 'COBHAM FLIGHT INSPECTION LTD.                         ', 'COBHAM FLIGHT INSPECTION LTD.                         ');
INSERT INTO airline_alias VALUES ('   ', 'CLD', 'CLOWES (ESTATES) LTD.                                 ', 'CLOWES (ESTATES) LTD.                                 ');
INSERT INTO airline_alias VALUES ('   ', 'CLE', 'COLEMILL ENTERPRISES INC.                             ', 'COLEMILL ENTERPRISES INC.                             ');
INSERT INTO airline_alias VALUES ('   ', 'CLF', 'BRISTOL FLYING CENTRE                                 ', 'BRISTOL FLYING CENTRE                                 ');
INSERT INTO airline_alias VALUES ('CE ', 'CLG', 'CHALAIR                                               ', 'CHALAIR                                               ');
INSERT INTO airline_alias VALUES ('   ', 'CLJ', 'CELLO AVIATION                                        ', 'CELLO AVIATION                                        ');
INSERT INTO airline_alias VALUES ('   ', 'CLU', 'TRIPLE ALPHA LUFTFAHRTGESELLSCHAFT                    ', 'TRIPLE ALPHA LUFTFAHRTGESELLSCHAFT                    ');
INSERT INTO airline_alias VALUES ('   ', 'CLY', 'CLAY LACY AVIATION INC.                               ', 'CLAY LACY AVIATION INC.                               ');
INSERT INTO airline_alias VALUES ('FB ', 'CMB', 'COMBS AIRWAYS                                         ', 'COMBS AIRWAYS                                         ');
INSERT INTO airline_alias VALUES ('   ', 'CME', 'PRINCE EDWARD AIR                                     ', 'PRINCE EDWARD AIR                                     ');
INSERT INTO airline_alias VALUES ('I5 ', 'CMM', 'AIR MALI                                              ', 'AIR MALI                                              ');
INSERT INTO airline_alias VALUES ('   ', 'CMV', 'CALIMA DE AVIACION                                    ', 'CALIMA DE AVIACION                                    ');
INSERT INTO airline_alias VALUES ('ZM ', 'CNB', 'CITYLINE HUNGARY                                      ', 'CITYLINE HUNGARY                                      ');
INSERT INTO airline_alias VALUES ('   ', 'CNI', 'AEROTAXI [CUBA]                                       ', 'AEROTAXI [CUBA]                                       ');
INSERT INTO airline_alias VALUES ('   ', 'COL', 'COLUMBA AIR                                           ', 'COLUMBA AIR                                           ');
INSERT INTO airline_alias VALUES ('   ', 'COW', 'COWI A/S                                              ', 'COWI A/S                                              ');
INSERT INTO airline_alias VALUES ('   ', 'CPD', 'CAPITAL AIRLINES [KENYA]                              ', 'CAPITAL AIRLINES [KENYA]                              ');
INSERT INTO airline_alias VALUES ('   ', 'CPH', 'CHAMPAGNE AIRLINES                                    ', 'CHAMPAGNE AIRLINES                                    ');
INSERT INTO airline_alias VALUES ('   ', 'CPI', 'COMPAGNIA AERONAUTICA ITALIANA                        ', 'COMPAGNIA AERONAUTICA ITALIANA                        ');
INSERT INTO airline_alias VALUES ('   ', 'CPJ', 'BALTIMORE AIR TRANSPORT                               ', 'BALTIMORE AIR TRANSPORT                               ');
INSERT INTO airline_alias VALUES ('   ', 'CPT', 'CORPORATE AIR [MT-USA]                                ', 'CORPORATE AIR [MT-USA]                                ');
INSERT INTO airline_alias VALUES ('9C ', 'CQH', 'SPRING AIRLINES                                       ', 'SPRING AIRLINES                                       ');
INSERT INTO airline_alias VALUES ('OQ ', 'CQN', 'CHONGQING AIRLINES                                    ', 'CHONGQING AIRLINES                                    ');
INSERT INTO airline_alias VALUES ('C8 ', 'CRA', 'CRONOS AIRLINES [EQ. GUINEA]                          ', 'CRONOS AIRLINES [EQ. GUINEA]                          ');
INSERT INTO airline_alias VALUES ('   ', 'CRC', 'CONAIR AVIATION                                       ', 'CONAIR AVIATION                                       ');
INSERT INTO airline_alias VALUES ('   ', 'CRE', 'CARRE AVIATION                                        ', 'CARRE AVIATION                                        ');
INSERT INTO airline_alias VALUES ('2G ', 'CRG', 'CARGOITALIA                                           ', 'CARGOITALIA                                           ');
INSERT INTO airline_alias VALUES ('   ', 'CRS', 'COMERCIAL AEREA                                       ', 'COMERCIAL AEREA                                       ');
INSERT INTO airline_alias VALUES ('   ', 'CRT', 'CARIBINTAIR                                           ', 'CARIBINTAIR                                           ');
INSERT INTO airline_alias VALUES ('   ', 'CRV', 'ACROPOLIS AVIATION LTD.                               ', 'ACROPOLIS AVIATION LTD.                               ');
INSERT INTO airline_alias VALUES ('   ', 'CSJ', 'CASTLE AVIATION INC.                                  ', 'CASTLE AVIATION INC.                                  ');
INSERT INTO airline_alias VALUES ('O3 ', 'CSS', 'SF AIRLINES                                           ', 'SF AIRLINES                                           ');
INSERT INTO airline_alias VALUES ('   ', 'CTQ', 'CITYLINK [GHANA]                                      ', 'CITYLINK [GHANA]                                      ');
INSERT INTO airline_alias VALUES ('   ', 'CTR', 'AEROLINEAS CENTAURO                                   ', 'AEROLINEAS CENTAURO                                   ');
INSERT INTO airline_alias VALUES ('I3 ', 'CTW', 'PANAIR CARGO                                          ', 'PANAIR CARGO                                          ');
INSERT INTO airline_alias VALUES ('KN ', 'CUA', 'CHINA UNITED AIRLINES                                 ', 'CHINA UNITED AIRLINES                                 ');
INSERT INTO airline_alias VALUES ('   ', 'CUO', 'AEROCUAHONTE                                          ', 'AEROCUAHONTE                                          ');
INSERT INTO airline_alias VALUES ('   ', 'CVU', 'GRAND CANYON AIRLINES                                 ', 'GRAND CANYON AIRLINES                                 ');
INSERT INTO airline_alias VALUES ('   ', 'CVV', 'COMERAVIA LINEA AEREA                                 ', 'COMERAVIA LINEA AEREA                                 ');
INSERT INTO airline_alias VALUES ('   ', 'CWD', 'CAERNARFON AIRWORLD                                   ', 'CAERNARFON AIRWORLD                                   ');
INSERT INTO airline_alias VALUES ('CW ', 'CWM', 'AIR MARSHALL ISLANDS                                  ', 'AIR MARSHALL ISLANDS                                  ');
INSERT INTO airline_alias VALUES ('   ', 'CWX', 'CROW EXECUTIVE AIR INC.                               ', 'CROW EXECUTIVE AIR INC.                               ');
INSERT INTO airline_alias VALUES ('   ', 'CXR', 'CONGO EXPRESS                                         ', 'CONGO EXPRESS                                         ');
INSERT INTO airline_alias VALUES ('8Y ', 'CYZ', 'CHINA POSTAL AIRLINES                                 ', 'CHINA POSTAL AIRLINES                                 ');
INSERT INTO airline_alias VALUES ('   ', 'DAB', 'DASSAULT AVIATION S.A.                                ', 'DASSAULT AVIATION S.A.                                ');
INSERT INTO airline_alias VALUES ('X8 ', 'DAP', 'AEROVIAS DAP                                          ', 'AEROVIAS DAP                                          ');
INSERT INTO airline_alias VALUES ('   ', 'DAS', 'DELMUN AVIATION SERVICES                              ', 'DELMUN AVIATION SERVICES                              ');
INSERT INTO airline_alias VALUES ('   ', 'DAV', 'DORNIER AVIATION NIGERIA AIEP                         ', 'DORNIER AVIATION NIGERIA AIEP                         ');
INSERT INTO airline_alias VALUES ('NS ', 'DBH', 'NORTHEASTERN AIRLINES                                 ', 'NORTHEASTERN AIRLINES                                 ');
INSERT INTO airline_alias VALUES ('2D ', 'DBK', 'DUBROVNIK AIRLINES                                    ', 'DUBROVNIK AIRLINES                                    ');
INSERT INTO airline_alias VALUES ('   ', 'DCD', 'AIR 26                                                ', 'AIR 26                                                ');
INSERT INTO airline_alias VALUES ('DQ ', 'DCP', 'DELTA CONNECTION                                      ', 'DELTA CONNECTION                                      ');
INSERT INTO airline_alias VALUES ('   ', 'DCS', 'DC AVIATION GMBH                                      ', 'DC AVIATION GMBH                                      ');
INSERT INTO airline_alias VALUES ('   ', 'DCT', 'DIRECTFLIGHT                                          ', 'DIRECTFLIGHT                                          ');
INSERT INTO airline_alias VALUES ('3C ', 'DEC', 'DECCAN CARGO                                          ', 'DECCAN CARGO                                          ');
INSERT INTO airline_alias VALUES ('   ', 'DEF', 'AVIATION DEFENSE SERVICE                              ', 'AVIATION DEFENSE SERVICE                              ');
INSERT INTO airline_alias VALUES ('   ', 'DEJ', 'DANA EXECUTIVE JETS                                   ', 'DANA EXECUTIVE JETS                                   ');
INSERT INTO airline_alias VALUES ('   ', 'DEM', 'DESTILADORA DE ALCOHOLES Y MIELES S.A.                ', 'DESTILADORA DE ALCOHOLES Y MIELES S.A.                ');
INSERT INTO airline_alias VALUES ('JD ', 'DER', 'DEER JET                                              ', 'DEER JET                                              ');
INSERT INTO airline_alias VALUES ('D0 ', 'DHK', 'DHL AIR                                               ', 'DHL AIR                                               ');
INSERT INTO airline_alias VALUES ('   ', 'DHV', 'DHL AVIATION                                          ', 'DHL AVIATION                                          ');
INSERT INTO airline_alias VALUES ('   ', 'DIX', 'DIX AVIATION                                          ', 'DIX AVIATION                                          ');
INSERT INTO airline_alias VALUES ('HO ', 'DKH', 'JUNEYAO AIRLINES                                      ', 'JUNEYAO AIRLINES                                      ');
INSERT INTO airline_alias VALUES ('   ', 'DLI', 'DALIA AIR                                             ', 'DALIA AIR                                             ');
INSERT INTO airline_alias VALUES ('   ', 'DNC', 'AERODYNAMICS MALAGA                                   ', 'AERODYNAMICS MALAGA                                   ');
INSERT INTO airline_alias VALUES ('   ', 'DNI', 'SERVICIOS AEREOS DENIM                                ', 'SERVICIOS AEREOS DENIM                                ');
INSERT INTO airline_alias VALUES ('   ', 'DNJ', 'AERODYNAMICS INC.                                     ', 'AERODYNAMICS INC.                                     ');
INSERT INTO airline_alias VALUES ('9H ', 'DNL', 'DUTCH ANTILLES EXPRESS                                ', 'DUTCH ANTILLES EXPRESS                                ');
INSERT INTO airline_alias VALUES ('R6 ', 'DNU', 'DANU ORO TRANSPORTAS                                  ', 'DANU ORO TRANSPORTAS                                  ');
INSERT INTO airline_alias VALUES ('Q2 ', 'DQA', 'ISLAND AVIATION SERVICES                              ', 'ISLAND AVIATION SERVICES                              ');
INSERT INTO airline_alias VALUES ('   ', 'DRA', 'DEER AIR                                              ', 'DEER AIR                                              ');
INSERT INTO airline_alias VALUES ('   ', 'DRT', 'DARTA TRANSPORTS AERIENS                              ', 'DARTA TRANSPORTS AERIENS                              ');
INSERT INTO airline_alias VALUES ('   ', 'DRY', 'DERAYA AIR TAXI                                       ', 'DERAYA AIR TAXI                                       ');
INSERT INTO airline_alias VALUES ('4M ', 'DSM', 'LAN ARGENTINA                                         ', 'LAN ARGENTINA                                         ');
INSERT INTO airline_alias VALUES ('   ', 'DSV', 'DIRECT AERO SERVICES                                  ', 'DIRECT AERO SERVICES                                  ');
INSERT INTO airline_alias VALUES ('   ', 'DUG', 'AEROTECNICA                                           ', 'AEROTECNICA                                           ');
INSERT INTO airline_alias VALUES ('   ', 'DVI', 'AERO DAVINCI INTERNACIONAL                            ', 'AERO DAVINCI INTERNACIONAL                            ');
INSERT INTO airline_alias VALUES ('   ', 'DVN', 'ADVENTIA                                              ', 'ADVENTIA                                              ');
INSERT INTO airline_alias VALUES ('   ', 'DVR', 'DIVI DIVI AIR                                         ', 'DIVI DIVI AIR                                         ');
INSERT INTO airline_alias VALUES ('   ', 'DWI', 'BALTIC AIR SERVICE                                    ', 'BALTIC AIR SERVICE                                    ');
INSERT INTO airline_alias VALUES ('0D ', 'DWT', 'DARWIN AIRLINE                                        ', 'DARWIN AIRLINE                                        ');
INSERT INTO airline_alias VALUES ('   ', 'DXT', 'DEXTER AIR TAXI                                       ', 'DEXTER AIR TAXI                                       ');
INSERT INTO airline_alias VALUES ('   ', 'DYA', 'DYNAMIC AIRWAYS                                       ', 'DYNAMIC AIRWAYS                                       ');
INSERT INTO airline_alias VALUES ('   ', 'DYL', 'SEAIR AIRWAYS                                         ', 'SEAIR AIRWAYS                                         ');
INSERT INTO airline_alias VALUES ('E4 ', 'EAA', 'EASTOK AVIA                                           ', 'EASTOK AVIA                                           ');
INSERT INTO airline_alias VALUES ('   ', 'EAS', 'EXECUTIVE AEROSPACE (PTY) LTD.                        ', 'EXECUTIVE AEROSPACE (PTY) LTD.                        ');
INSERT INTO airline_alias VALUES ('   ', 'ECG', 'AERO EJECUTIVOS RCG                                   ', 'AERO EJECUTIVOS RCG                                   ');
INSERT INTO airline_alias VALUES ('   ', 'ECN', 'EURO CONTINENTAL AIR                                  ', 'EURO CONTINENTAL AIR                                  ');
INSERT INTO airline_alias VALUES ('   ', 'ECU', 'ECUAVIA S.A.                                          ', 'ECUAVIA S.A.                                          ');
INSERT INTO airline_alias VALUES ('   ', 'ECV', 'EUROGUINEANA DE AVIACION                              ', 'EUROGUINEANA DE AVIACION                              ');
INSERT INTO airline_alias VALUES ('   ', 'EDA', 'EXEC DIRECT AVIATION SERVICES                         ', 'EXEC DIRECT AVIATION SERVICES                         ');
INSERT INTO airline_alias VALUES ('   ', 'EDJ', 'EDWARDS JET CENTER OF MONTANA                         ', 'EDWARDS JET CENTER OF MONTANA                         ');
INSERT INTO airline_alias VALUES ('   ', 'EEM', 'EJECUTIVA AEREO DE MEXICO                             ', 'EJECUTIVA AEREO DE MEXICO                             ');
INSERT INTO airline_alias VALUES ('   ', 'EFA', 'EXPRESS FREIGHTERS AUSTRALIA                          ', 'EXPRESS FREIGHTERS AUSTRALIA                          ');
INSERT INTO airline_alias VALUES ('   ', 'EFC', 'AIR MANA                                              ', 'AIR MANA                                              ');
INSERT INTO airline_alias VALUES ('EF ', 'EFY', 'EASYFLY                                               ', 'EASYFLY                                               ');
INSERT INTO airline_alias VALUES ('   ', 'EGL', 'CAPITAL AIR CHARTER LTD.                              ', 'CAPITAL AIR CHARTER LTD.                              ');
INSERT INTO airline_alias VALUES ('   ', 'EGN', 'EAGLE AVIATION EUROPE                                 ', 'EAGLE AVIATION EUROPE                                 ');
INSERT INTO airline_alias VALUES ('E3 ', 'EGS', 'EAGLES AIRLINES                                       ', 'EAGLES AIRLINES                                       ');
INSERT INTO airline_alias VALUES ('   ', 'EJG', 'EXECUJET EUROPE GMBH                                  ', 'EXECUJET EUROPE GMBH                                  ');
INSERT INTO airline_alias VALUES ('   ', 'EJO', 'EXECUJET MIDDLE EAST                                  ', 'EXECUJET MIDDLE EAST                                  ');
INSERT INTO airline_alias VALUES ('   ', 'ELC', 'FLYLAL CHARTER EESTI                                  ', 'FLYLAL CHARTER EESTI                                  ');
INSERT INTO airline_alias VALUES ('   ', 'ELX', 'ELAN EXPRESS                                          ', 'ELAN EXPRESS                                          ');
INSERT INTO airline_alias VALUES ('   ', 'EMD', 'EAGLEMED                                              ', 'EAGLEMED                                              ');
INSERT INTO airline_alias VALUES ('   ', 'EMT', 'EMETEBE                                               ', 'EMETEBE                                               ');
INSERT INTO airline_alias VALUES ('   ', 'ENJ', 'ENERJET                                               ', 'ENERJET                                               ');
INSERT INTO airline_alias VALUES ('   ', 'ENT', 'ENTER AIR                                             ', 'ENTER AIR                                             ');
INSERT INTO airline_alias VALUES ('   ', 'ENW', 'AERONAVES DEL NOROESTE                                ', 'AERONAVES DEL NOROESTE                                ');
INSERT INTO airline_alias VALUES ('   ', 'EOL', 'AIRAILES                                              ', 'AIRAILES                                              ');
INSERT INTO airline_alias VALUES ('J5 ', 'EPA', 'SHENZHEN DONGHAI AIRLINES                             ', 'SHENZHEN DONGHAI AIRLINES                             ');
INSERT INTO airline_alias VALUES ('   ', 'EPC', 'ESPACE AVIATION SERVICES                              ', 'ESPACE AVIATION SERVICES                              ');
INSERT INTO airline_alias VALUES ('   ', 'EPS', 'EPPS AIR SERVICE INC.                                 ', 'EPPS AIR SERVICE INC.                                 ');
INSERT INTO airline_alias VALUES ('7H ', 'ERR', 'ERA AVIATION INC.                                     ', 'ERA AVIATION INC.                                     ');
INSERT INTO airline_alias VALUES ('6S ', 'ESC', 'EL SOL DE AMERICA                                     ', 'EL SOL DE AMERICA                                     ');
INSERT INTO airline_alias VALUES ('K9 ', 'ESD', 'ESEN AIR                                              ', 'ESEN AIR                                              ');
INSERT INTO airline_alias VALUES ('OV ', 'ESG', 'ESTONIAN AIR REGIONAL                                 ', 'ESTONIAN AIR REGIONAL                                 ');
INSERT INTO airline_alias VALUES ('EE ', 'ESJ', 'EASTERN SKY JETS                                      ', 'EASTERN SKY JETS                                      ');
INSERT INTO airline_alias VALUES ('   ', 'ESO', 'EUROP STAR AIRCRAFT                                   ', 'EUROP STAR AIRCRAFT                                   ');
INSERT INTO airline_alias VALUES ('ZE ', 'ESR', 'EASTAR JET AIRLINES                                   ', 'EASTAR JET AIRLINES                                   ');
INSERT INTO airline_alias VALUES ('   ', 'ESW', 'SW BUSINESS AVIATION                                  ', 'SW BUSINESS AVIATION                                  ');
INSERT INTO airline_alias VALUES ('ML ', 'ETC', 'ATTICO                                                ', 'ATTICO                                                ');
INSERT INTO airline_alias VALUES ('EG ', 'ETJ', 'EAST AIR [TAJIKISTAN]                                 ', 'EAST AIR [TAJIKISTAN]                                 ');
INSERT INTO airline_alias VALUES ('   ', 'ETN', 'CHIM-NIR AVIATION                                     ', 'CHIM-NIR AVIATION                                     ');
INSERT INTO airline_alias VALUES ('   ', 'ETR', 'ESTELAR LATINOAMERICA                                 ', 'ESTELAR LATINOAMERICA                                 ');
INSERT INTO airline_alias VALUES ('2Q ', 'ETS', 'AVITRANS NORDIC AB                                    ', 'AVITRANS NORDIC AB                                    ');
INSERT INTO airline_alias VALUES ('   ', 'EUW', 'EFS EUROPEAN FLIGHT SERVICE                           ', 'EFS EUROPEAN FLIGHT SERVICE                           ');
INSERT INTO airline_alias VALUES ('   ', 'EXH', 'G5 EXECUTIVE AG                                       ', 'G5 EXECUTIVE AG                                       ');
INSERT INTO airline_alias VALUES ('OW ', 'EXK', 'EXECUTIVE AIRLINES [PR-USA]                           ', 'EXECUTIVE AIRLINES [PR-USA]                           ');
INSERT INTO airline_alias VALUES ('   ', 'EXT', 'NIGHTEXPRESS                                          ', 'NIGHTEXPRESS                                          ');
INSERT INTO airline_alias VALUES ('B5 ', 'EXZ', 'EAST AFRICAN SAFARI AIR EXPRESS                       ', 'EAST AFRICAN SAFARI AIR EXPRESS                       ');
INSERT INTO airline_alias VALUES ('ZY ', 'EZA', 'EZNIS AIRWAYS                                         ', 'EZNIS AIRWAYS                                         ');
INSERT INTO airline_alias VALUES ('Z2 ', 'EZD', 'ZEST AIRWAYS                                          ', 'ZEST AIRWAYS                                          ');
INSERT INTO airline_alias VALUES ('   ', 'EZR', 'EZAIR                                                 ', 'EZAIR                                                 ');
INSERT INTO airline_alias VALUES ('   ', 'FAH', 'FARNAIR HUNGARY                                       ', 'FARNAIR HUNGARY                                       ');
INSERT INTO airline_alias VALUES ('   ', 'FAT', 'FARNAIR SWITZERLAND                                   ', 'FARNAIR SWITZERLAND                                   ');
INSERT INTO airline_alias VALUES ('   ', 'FBR', 'FLUGBEREITSCHAFT GMBH                                 ', 'FLUGBEREITSCHAFT GMBH                                 ');
INSERT INTO airline_alias VALUES ('   ', 'FCK', 'FLIGHT CALIBRATION SERVICES GMBH                      ', 'FLIGHT CALIBRATION SERVICES GMBH                      ');
INSERT INTO airline_alias VALUES ('FC ', 'FCM', 'FINNISH COMMUTER AIRLINES                             ', 'FINNISH COMMUTER AIRLINES                             ');
INSERT INTO airline_alias VALUES ('7Y ', 'FCR', 'MED AIRWAYS                                           ', 'MED AIRWAYS                                           ');
INSERT INTO airline_alias VALUES ('   ', 'FCV', 'NAV AIR CHARTER                                       ', 'NAV AIR CHARTER                                       ');
INSERT INTO airline_alias VALUES ('FC ', 'FCX', 'FALCON EXPRESS CARGO AIRLINES                         ', 'FALCON EXPRESS CARGO AIRLINES                         ');
INSERT INTO airline_alias VALUES ('JH ', 'FDA', 'FUJI DREAM AIRLINES                                   ', 'FUJI DREAM AIRLINES                                   ');
INSERT INTO airline_alias VALUES ('FZ ', 'FDB', 'FLYDUBAI                                              ', 'FLYDUBAI                                              ');
INSERT INTO airline_alias VALUES ('   ', 'FDD', 'FEEDER AIRLINES                                       ', 'FEEDER AIRLINES                                       ');
INSERT INTO airline_alias VALUES ('ZD ', 'FDN', 'DOLPHIN AIR                                           ', 'DOLPHIN AIR                                           ');
INSERT INTO airline_alias VALUES ('   ', 'FDR', 'FEDERAL AIR                                           ', 'FEDERAL AIR                                           ');
INSERT INTO airline_alias VALUES ('   ', 'FDS', 'AFRICAN MEDICAL & RESEARCH FOUNDATION                 ', 'AFRICAN MEDICAL & RESEARCH FOUNDATION                 ');
INSERT INTO airline_alias VALUES ('   ', 'FFD', 'STUTTGARTER FLUGDIENST                                ', 'STUTTGARTER FLUGDIENST                                ');
INSERT INTO airline_alias VALUES ('FY ', 'FFM', 'FLYFIREFLY                                            ', 'FLYFIREFLY                                            ');
INSERT INTO airline_alias VALUES ('5H ', 'FFV', 'FLY540.COM                                            ', 'FLY540.COM                                            ');
INSERT INTO airline_alias VALUES ('JH ', 'FFX', 'FLEX LINHAS AEREAS                                    ', 'FLEX LINHAS AEREAS                                    ');
INSERT INTO airline_alias VALUES ('HW ', 'FHE', 'HELLO                                                 ', 'HELLO                                                 ');
INSERT INTO airline_alias VALUES ('FH ', 'FHY', 'FREE BIRD AIRLINES                                    ', 'FREE BIRD AIRLINES                                    ');
INSERT INTO airline_alias VALUES ('   ', 'FII', 'AERODATA FLIGHT INSPECTION                            ', 'AERODATA FLIGHT INSPECTION                            ');
INSERT INTO airline_alias VALUES ('PI ', 'FJA', 'PACIFIC SUN                                           ', 'PACIFIC SUN                                           ');
INSERT INTO airline_alias VALUES ('   ', 'FKI', 'FLM-AVIATION MOHRDIECK                                ', 'FLM-AVIATION MOHRDIECK                                ');
INSERT INTO airline_alias VALUES ('   ', 'FLE', 'FLAIR AIRLINES                                        ', 'FLAIR AIRLINES                                        ');
INSERT INTO airline_alias VALUES ('   ', 'FLK', 'FLYLINK EXPRESS                                       ', 'FLYLINK EXPRESS                                       ');
INSERT INTO airline_alias VALUES ('   ', 'FNL', 'LAPIN TILAUSLENTO OY                                  ', 'LAPIN TILAUSLENTO OY                                  ');
INSERT INTO airline_alias VALUES ('   ', 'FNT', 'FLIGHT INTERNATIONAL AVIATION LLC                     ', 'FLIGHT INTERNATIONAL AVIATION LLC                     ');
INSERT INTO airline_alias VALUES ('   ', 'FON', 'FLYINGTON FREIGHTERS                                  ', 'FLYINGTON FREIGHTERS                                  ');
INSERT INTO airline_alias VALUES ('   ', 'FOR', 'FORMULA ONE MANAGEMENT LTD.                           ', 'FORMULA ONE MANAGEMENT LTD.                           ');
INSERT INTO airline_alias VALUES ('5O ', 'FPO', 'EUROPE AIRPOST                                        ', 'EUROPE AIRPOST                                        ');
INSERT INTO airline_alias VALUES ('   ', 'FRA', 'FR AVIATION LTD.                                      ', 'FR AVIATION LTD.                                      ');
INSERT INTO airline_alias VALUES ('   ', 'FRC', '"ICARE FRANCHE COMPTE, SARL                            "', '"ICARE FRANCHE COMPTE, SARL                            "');
INSERT INTO airline_alias VALUES ('   ', 'FRF', 'FLEET AIR INTERNATIONAL                               ', 'FLEET AIR INTERNATIONAL                               ');
INSERT INTO airline_alias VALUES ('F8 ', 'FRL', 'FREEDOM AIRLINES [AZ-USA]                             ', 'FREEDOM AIRLINES [AZ-USA]                             ');
INSERT INTO airline_alias VALUES ('   ', 'FSK', 'AFRICA CHARTER AIRLINE                                ', 'AFRICA CHARTER AIRLINE                                ');
INSERT INTO airline_alias VALUES ('   ', 'FTL', 'FLIGHTLINE [SPAIN]                                    ', 'FLIGHTLINE [SPAIN]                                    ');
INSERT INTO airline_alias VALUES ('   ', 'FTR', 'FINIST''AIR                                            ', 'FINIST''AIR                                            ');
INSERT INTO airline_alias VALUES ('FY ', 'FUN', 'FONTSHI AVIATION SERVICE                              ', 'FONTSHI AVIATION SERVICE                              ');
INSERT INTO airline_alias VALUES ('   ', 'FUP', 'FOXAIR [GERMANY]                                      ', 'FOXAIR [GERMANY]                                      ');
INSERT INTO airline_alias VALUES ('I4 ', 'FWA', 'INTERSTATE AIRLINES [NETHERLANDS]                     ', 'INTERSTATE AIRLINES [NETHERLANDS]                     ');
INSERT INTO airline_alias VALUES ('NY ', 'FXI', 'AIR ICELAND                                           ', 'AIR ICELAND                                           ');
INSERT INTO airline_alias VALUES ('   ', 'FXR', 'K-AIR                                                 ', 'K-AIR                                                 ');
INSERT INTO airline_alias VALUES ('FO ', 'FXX', 'FELIX AIRWAYS                                         ', 'FELIX AIRWAYS                                         ');
INSERT INTO airline_alias VALUES ('   ', 'FYA', 'SAICUS AIR                                            ', 'SAICUS AIR                                            ');
INSERT INTO airline_alias VALUES ('   ', 'FYD', 'FLYING DEVIL S.A.                                     ', 'FLYING DEVIL S.A.                                     ');
INSERT INTO airline_alias VALUES ('3R ', 'GAI', 'MOSKOVIA AIRLINES                                     ', 'MOSKOVIA AIRLINES                                     ');
INSERT INTO airline_alias VALUES ('QG ', 'GBB', 'GLOBAL AVIATION OPERATIONS                            ', 'GLOBAL AVIATION OPERATIONS                            ');
INSERT INTO airline_alias VALUES ('7G ', 'GBG', 'GLOBAL JET LTD.                                       ', 'GLOBAL JET LTD.                                       ');
INSERT INTO airline_alias VALUES ('GY ', 'GBK', 'GABON AIRLINES                                        ', 'GABON AIRLINES                                        ');
INSERT INTO airline_alias VALUES ('   ', 'GBX', 'GB AIRLINK INC.                                       ', 'GB AIRLINK INC.                                       ');
INSERT INTO airline_alias VALUES ('GS ', 'GCR', 'TIANJIN AIRLINES                                      ', 'TIANJIN AIRLINES                                      ');
INSERT INTO airline_alias VALUES ('CN ', 'GDC', 'GRAND CHINA AIR                                       ', 'GRAND CHINA AIR                                       ');
INSERT INTO airline_alias VALUES ('LH ', 'GEC', 'LUFTHANSA CARGO                                       ', 'LUFTHANSA CARGO                                       ');
INSERT INTO airline_alias VALUES ('   ', 'GED', 'EUROPE AIR LINES                                      ', 'EUROPE AIR LINES                                      ');
INSERT INTO airline_alias VALUES ('   ', 'GEN', 'GENSA                                                 ', 'GENSA                                                 ');
INSERT INTO airline_alias VALUES ('   ', 'GET', 'GUINEA ECUATORIAL DE TRANSPORTES AEREOS               ', 'GUINEA ECUATORIAL DE TRANSPORTES AEREOS               ');
INSERT INTO airline_alias VALUES ('QB ', 'GFG', 'SKY GEORGIA                                           ', 'SKY GEORGIA                                           ');
INSERT INTO airline_alias VALUES ('G0 ', 'GHB', 'GHANA INTERNATIONAL AIRLINES                          ', 'GHANA INTERNATIONAL AIRLINES                          ');
INSERT INTO airline_alias VALUES ('   ', 'GHS', 'GATARI AIR SERVICE                                    ', 'GATARI AIR SERVICE                                    ');
INSERT INTO airline_alias VALUES ('0G ', 'GHT', 'GHADAMES AIR TRANSPORT                                ', 'GHADAMES AIR TRANSPORT                                ');
INSERT INTO airline_alias VALUES ('   ', 'GHY', 'GERMAN SKY AIRLINES                                   ', 'GERMAN SKY AIRLINES                                   ');
INSERT INTO airline_alias VALUES ('4L ', 'GIL', 'GEORGIAN INTERNATIONAL AIRLINES                       ', 'GEORGIAN INTERNATIONAL AIRLINES                       ');
INSERT INTO airline_alias VALUES ('   ', 'GJH', 'GUINEE AIR CARGO                                      ', 'GUINEE AIR CARGO                                      ');
INSERT INTO airline_alias VALUES ('G7 ', 'GJS', 'GOJET AIRLINES                                        ', 'GOJET AIRLINES                                        ');
INSERT INTO airline_alias VALUES ('   ', 'GLJ', 'GLOBAL JET AUSTRIA                                    ', 'GLOBAL JET AUSTRIA                                    ');
INSERT INTO airline_alias VALUES ('   ', 'GLL', 'AIR GEMINI                                            ', 'AIR GEMINI                                            ');
INSERT INTO airline_alias VALUES ('   ', 'GLP', 'GLOBUS                                                ', 'GLOBUS                                                ');
INSERT INTO airline_alias VALUES ('   ', 'GMA', 'GAMA AVIATION                                         ', 'GAMA AVIATION                                         ');
INSERT INTO airline_alias VALUES ('Z5 ', 'GMG', 'GMG AIRLINES                                          ', 'GMG AIRLINES                                          ');
INSERT INTO airline_alias VALUES ('   ', 'GMT', 'MAGNICHARTERS                                         ', 'MAGNICHARTERS                                         ');
INSERT INTO airline_alias VALUES ('   ', 'GNJ', 'GAINJET AVIATION                                      ', 'GAINJET AVIATION                                      ');
INSERT INTO airline_alias VALUES ('   ', 'GNL', 'GENERAL AIR SERVICES                                  ', 'GENERAL AIR SERVICES                                  ');
INSERT INTO airline_alias VALUES ('   ', 'GOI', 'GOFIR S.A.                                            ', 'GOFIR S.A.                                            ');
INSERT INTO airline_alias VALUES ('XV ', 'GOT', 'WALTAIR [SWEDEN]                                      ', 'WALTAIR [SWEDEN]                                      ');
INSERT INTO airline_alias VALUES ('G8 ', 'GOW', 'GOAIR                                                 ', 'GOAIR                                                 ');
INSERT INTO airline_alias VALUES ('TJ ', 'GPD', 'TRADEWIND AVIATION                                    ', 'TRADEWIND AVIATION                                    ');
INSERT INTO airline_alias VALUES ('   ', 'GRR', 'AGROAR-TRABALHOS AEREOS                               ', 'AGROAR-TRABALHOS AEREOS                               ');
INSERT INTO airline_alias VALUES ('   ', 'GRV', 'EPSILON AVIATION                                      ', 'EPSILON AVIATION                                      ');
INSERT INTO airline_alias VALUES ('   ', 'GSB', 'GADING SARI AVIATION SERVICES                         ', 'GADING SARI AVIATION SERVICES                         ');
INSERT INTO airline_alias VALUES ('GD ', 'GSC', 'GRANDSTAR CARGO INTERNATIONAL AIRLINES                ', 'GRANDSTAR CARGO INTERNATIONAL AIRLINES                ');
INSERT INTO airline_alias VALUES ('   ', 'GSE', 'CV CARGO                                              ', 'CV CARGO                                              ');
INSERT INTO airline_alias VALUES ('   ', 'GSJ', 'GROSSMANN JET SERVICE                                 ', 'GROSSMANN JET SERVICE                                 ');
INSERT INTO airline_alias VALUES ('   ', 'GSS', 'GLOBAL SUPPLY SYSTEMS                                 ', 'GLOBAL SUPPLY SYSTEMS                                 ');
INSERT INTO airline_alias VALUES ('   ', 'GSW', 'SKY WINGS AIRLINES                                    ', 'SKY WINGS AIRLINES                                    ');
INSERT INTO airline_alias VALUES ('   ', 'GSY', 'GUARD SYSTEMS A/S                                     ', 'GUARD SYSTEMS A/S                                     ');
INSERT INTO airline_alias VALUES ('   ', 'GTP', 'AEROTAXI GRUPO TAMPICO                                ', 'AEROTAXI GRUPO TAMPICO                                ');
INSERT INTO airline_alias VALUES ('KG ', 'GTV', 'AEROGAVIOTA                                           ', 'AEROGAVIOTA                                           ');
INSERT INTO airline_alias VALUES ('   ', 'GUE', 'AEREO SERVICIO GUERRERO                               ', 'AEREO SERVICIO GUERRERO                               ');
INSERT INTO airline_alias VALUES ('   ', 'GUM', 'GUM AIR                                               ', 'GUM AIR                                               ');
INSERT INTO airline_alias VALUES ('GV ', 'GUN', 'GRANT AVIATION INC.                                   ', 'GRANT AVIATION INC.                                   ');
INSERT INTO airline_alias VALUES ('   ', 'GWK', 'GENERAL WORK AVIACION                                 ', 'GENERAL WORK AVIACION                                 ');
INSERT INTO airline_alias VALUES ('IJ ', 'GWL', 'GREAT WALL AIRLINES                                   ', 'GREAT WALL AIRLINES                                   ');
INSERT INTO airline_alias VALUES ('   ', 'GWX', 'SOC. DE TRANS.DE L''ARCHIPEL GUADELOUPEEN              ', 'SOC. DE TRANS.DE L''ARCHIPEL GUADELOUPEEN              ');
INSERT INTO airline_alias VALUES ('G1 ', 'GXL', 'XL AIRWAYS GERMANY                                    ', 'XL AIRWAYS GERMANY                                    ');
INSERT INTO airline_alias VALUES ('   ', 'HAN', 'HANSUNG AIRLINES                                      ', 'HANSUNG AIRLINES                                      ');
INSERT INTO airline_alias VALUES ('   ', 'HAU', 'SKYHAUL                                               ', 'SKYHAUL                                               ');
INSERT INTO airline_alias VALUES ('   ', 'HAX', 'BENAIR NORWAY                                         ', 'BENAIR NORWAY                                         ');
INSERT INTO airline_alias VALUES ('NS ', 'HBH', 'HEBEI AIRLINES                                        ', 'HEBEI AIRLINES                                        ');
INSERT INTO airline_alias VALUES ('   ', 'HBR', 'HEBRIDEAN AIR SERVICES                                ', 'HEBRIDEAN AIR SERVICES                                ');
INSERT INTO airline_alias VALUES ('   ', 'HCN', 'HALCYON AIR BISSAU                                    ', 'HALCYON AIR BISSAU                                    ');
INSERT INTO airline_alias VALUES ('7Z ', 'HCV', 'HALCYON AIR CABO VERDE                                ', 'HALCYON AIR CABO VERDE                                ');
INSERT INTO airline_alias VALUES ('V9 ', 'HCW', 'STAR1 AIRLINES                                        ', 'STAR1 AIRLINES                                        ');
INSERT INTO airline_alias VALUES ('   ', 'HFD', 'BLUE CITY AVIATION                                    ', 'BLUE CITY AVIATION                                    ');
INSERT INTO airline_alias VALUES ('5K ', 'HFY', 'HI FLY                                                ', 'HI FLY                                                ');
INSERT INTO airline_alias VALUES ('   ', 'HGR', 'HANGAR 8 MANAGEMENT LTD.                              ', 'HANGAR 8 MANAGEMENT LTD.                              ');
INSERT INTO airline_alias VALUES ('   ', 'HIB', 'HELIBRAVO AVIACAO                                     ', 'HELIBRAVO AVIACAO                                     ');
INSERT INTO airline_alias VALUES ('   ', 'HKB', 'HAWKER BEECHCRAFT CORPORATION                         ', 'HAWKER BEECHCRAFT CORPORATION                         ');
INSERT INTO airline_alias VALUES ('UO ', 'HKE', 'HONG KONG EXPRESS AIRWAYS                             ', 'HONG KONG EXPRESS AIRWAYS                             ');
INSERT INTO airline_alias VALUES ('   ', 'HKN', 'JIM HANKINS AIR SERVICE                               ', 'JIM HANKINS AIR SERVICE                               ');
INSERT INTO airline_alias VALUES ('   ', 'HKR', 'HAWK AIR                                              ', 'HAWK AIR                                              ');
INSERT INTO airline_alias VALUES ('5C ', 'HMA', 'AIR TAHOMA                                            ', 'AIR TAHOMA                                            ');
INSERT INTO airline_alias VALUES ('   ', 'HMB', 'CHC CAMEROON                                          ', 'CHC CAMEROON                                          ');
INSERT INTO airline_alias VALUES ('C8 ', 'HMR', 'NAC AIR                                               ', 'NAC AIR                                               ');
INSERT INTO airline_alias VALUES ('   ', 'HMX', 'HAWK DE MEXICO                                        ', 'HAWK DE MEXICO                                        ');
INSERT INTO airline_alias VALUES ('   ', 'HND', 'HINTERLAND AVIATION                                   ', 'HINTERLAND AVIATION                                   ');
INSERT INTO airline_alias VALUES ('H5 ', 'HOA', 'HOLA AIRLINES                                         ', 'HOLA AIRLINES                                         ');
INSERT INTO airline_alias VALUES ('   ', 'HPL', 'HELIPORTUGAL                                          ', 'HELIPORTUGAL                                          ');
INSERT INTO airline_alias VALUES ('   ', 'HPN', 'LINEAR AIR                                            ', 'LINEAR AIR                                            ');
INSERT INTO airline_alias VALUES ('   ', 'HPY', 'HAPPY AIR TRAVELLERS                                  ', 'HAPPY AIR TRAVELLERS                                  ');
INSERT INTO airline_alias VALUES ('   ', 'HRT', 'CHARTRIGHT AIR                                        ', 'CHARTRIGHT AIR                                        ');
INSERT INTO airline_alias VALUES ('   ', 'HSF', 'HANSEO UNIVERSITY                                     ', 'HANSEO UNIVERSITY                                     ');
INSERT INTO airline_alias VALUES ('   ', 'HSG', 'HESNES AIR                                            ', 'HESNES AIR                                            ');
INSERT INTO airline_alias VALUES ('   ', 'HSS', 'TRANSPORTES AEREOS DEL SUR                            ', 'TRANSPORTES AEREOS DEL SUR                            ');
INSERT INTO airline_alias VALUES ('9I ', 'HTA', 'HELITRANS A/S [NORWAY]                                ', 'HELITRANS A/S [NORWAY]                                ');
INSERT INTO airline_alias VALUES ('   ', 'HTG', 'GROSSMANN AIR SERVICE                                 ', 'GROSSMANN AIR SERVICE                                 ');
INSERT INTO airline_alias VALUES ('HC ', 'HVL', 'HEAVYLIFT INTERNATIONAL AIRLINES                      ', 'HEAVYLIFT INTERNATIONAL AIRLINES                      ');
INSERT INTO airline_alias VALUES ('8H ', 'HWY', 'HIGHLAND AIRWAYS                                      ', 'HIGHLAND AIRWAYS                                      ');
INSERT INTO airline_alias VALUES ('G5 ', 'HXA', 'CHINA EXPRESS AIRLINES                                ', 'CHINA EXPRESS AIRLINES                                ');
INSERT INTO airline_alias VALUES ('0Q ', 'HYD', 'HYDRO-QUEBEC                                          ', 'HYDRO-QUEBEC                                          ');
INSERT INTO airline_alias VALUES ('   ', 'HYR', 'AIRLINK AIRWAYS                                       ', 'AIRLINK AIRWAYS                                       ');
INSERT INTO airline_alias VALUES ('OI ', 'IAZ', 'ITALIATOUR AIRLINES                                   ', 'ITALIATOUR AIRLINES                                   ');
INSERT INTO airline_alias VALUES ('   ', 'IBJ', 'AIR TAXI & CHARTER INTERNATIONAL                      ', 'AIR TAXI & CHARTER INTERNATIONAL                      ');
INSERT INTO airline_alias VALUES ('FW ', 'IBX', 'IBEX AIRLINES                                         ', 'IBEX AIRLINES                                         ');
INSERT INTO airline_alias VALUES ('   ', 'ICC', 'INSTITUTO CARTOGRAFICO DE CATALUNA                    ', 'INSTITUTO CARTOGRAFICO DE CATALUNA                    ');
INSERT INTO airline_alias VALUES ('X8 ', 'ICD', 'ICARO EXPRESS                                         ', 'ICARO EXPRESS                                         ');
INSERT INTO airline_alias VALUES ('C8 ', 'ICV', 'CARGOLUX ITALIA                                       ', 'CARGOLUX ITALIA                                       ');
INSERT INTO airline_alias VALUES ('I8 ', 'IDA', 'INDONESIA AIR TRANSPORT                               ', 'INDONESIA AIR TRANSPORT                               ');
INSERT INTO airline_alias VALUES ('   ', 'IDR', 'INDICATOR AVIATION                                    ', 'INDICATOR AVIATION                                    ');
INSERT INTO airline_alias VALUES ('   ', 'IFA', 'FAI RENT-A-JET                                        ', 'FAI RENT-A-JET                                        ');
INSERT INTO airline_alias VALUES ('   ', 'IGA', 'SKYTAXI                                               ', 'SKYTAXI                                               ');
INSERT INTO airline_alias VALUES ('6E ', 'IGO', 'INDIGO                                                ', 'INDIGO                                                ');
INSERT INTO airline_alias VALUES ('   ', 'IHO', '748 AIR SERVICES                                      ', '748 AIR SERVICES                                      ');
INSERT INTO airline_alias VALUES ('   ', 'IKY', 'INTERSKY                                              ', 'INTERSKY                                              ');
INSERT INTO airline_alias VALUES ('   ', 'ILF', 'ISLAND AIR CHARTERS INC.                              ', 'ISLAND AIR CHARTERS INC.                              ');
INSERT INTO airline_alias VALUES ('   ', 'IMD', 'IMD AIRWAYS                                           ', 'IMD AIRWAYS                                           ');
INSERT INTO airline_alias VALUES ('   ', 'IMJ', 'IMPERIAL JET                                          ', 'IMPERIAL JET                                          ');
INSERT INTO airline_alias VALUES ('HT ', 'IMP', 'HELLENIC IMPERIAL AIRWAYS                             ', 'HELLENIC IMPERIAL AIRWAYS                             ');
INSERT INTO airline_alias VALUES ('7I ', 'INC', 'INSEL AIR INTERNATIONAL                               ', 'INSEL AIR INTERNATIONAL                               ');
INSERT INTO airline_alias VALUES ('   ', 'INJ', 'INTERJET [GREECE]                                     ', 'INTERJET [GREECE]                                     ');
INSERT INTO airline_alias VALUES ('   ', 'INL', 'INTAL AIR                                             ', 'INTAL AIR                                             ');
INSERT INTO airline_alias VALUES ('   ', 'IRG', 'NAFT AIRLINES                                         ', 'NAFT AIRLINES                                         ');
INSERT INTO airline_alias VALUES ('   ', 'IRS', 'SAHAND AIR                                            ', 'SAHAND AIR                                            ');
INSERT INTO airline_alias VALUES ('   ', 'IRU', 'CHABAHAR AIR                                          ', 'CHABAHAR AIR                                          ');
INSERT INTO airline_alias VALUES ('   ', 'IRX', 'ARIA TOUR                                             ', 'ARIA TOUR                                             ');
INSERT INTO airline_alias VALUES ('YE ', 'IRY', 'ERAM AIRLINES                                         ', 'ERAM AIRLINES                                         ');
INSERT INTO airline_alias VALUES ('   ', 'IRZ', 'SAHA AIRLINES                                         ', 'SAHA AIRLINES                                         ');
INSERT INTO airline_alias VALUES ('   ', 'ISD', 'ISD AVIA                                              ', 'ISD AVIA                                              ');
INSERT INTO airline_alias VALUES ('   ', 'ISN', 'INTERISLAND AIRLINES                                  ', 'INTERISLAND AIRLINES                                  ');
INSERT INTO airline_alias VALUES ('   ', 'ITE', 'AEROTAXI [CZECH REP.]                                 ', 'AEROTAXI [CZECH REP.]                                 ');
INSERT INTO airline_alias VALUES ('   ', 'ITW', 'INTER AIR [BULGARIA]                                  ', 'INTER AIR [BULGARIA]                                  ');
INSERT INTO airline_alias VALUES ('   ', 'IVS', 'AIR EVASION                                           ', 'AIR EVASION                                           ');
INSERT INTO airline_alias VALUES ('ZV ', 'IZG', 'ZAGROS AIRLINES                                       ', 'ZAGROS AIRLINES                                       ');
INSERT INTO airline_alias VALUES ('4I ', 'IZM', 'IZMIR AIRLINES                                        ', 'IZMIR AIRLINES                                        ');
INSERT INTO airline_alias VALUES ('W9 ', 'JAB', 'AIR BAGAN                                             ', 'AIR BAGAN                                             ');
INSERT INTO airline_alias VALUES ('JI ', 'JAE', 'JADE CARGO INTERNATIONAL                              ', 'JADE CARGO INTERNATIONAL                              ');
INSERT INTO airline_alias VALUES ('TB ', 'JAF', 'TUI AIRLINES BELGIUM                                  ', 'TUI AIRLINES BELGIUM                                  ');
INSERT INTO airline_alias VALUES ('   ', 'JAG', 'JETALLIANCE FLUGBETRIEBS                              ', 'JETALLIANCE FLUGBETRIEBS                              ');
INSERT INTO airline_alias VALUES ('   ', 'JAR', 'AIRLINK LUFTVERKEHRS GMBH                             ', 'AIRLINK LUFTVERKEHRS GMBH                             ');
INSERT INTO airline_alias VALUES ('R5 ', 'JAV', 'JORDAN AVIATION                                       ', 'JORDAN AVIATION                                       ');
INSERT INTO airline_alias VALUES ('3B ', 'JBR', 'JOB AIR                                               ', 'JOB AIR                                               ');
INSERT INTO airline_alias VALUES ('   ', 'JBW', 'JUBBA AIRWAYS (K) LTD. [KENYA]                        ', 'JUBBA AIRWAYS (K) LTD. [KENYA]                        ');
INSERT INTO airline_alias VALUES ('   ', 'JCC', 'JETCRAFT AVIATION                                     ', 'JETCRAFT AVIATION                                     ');
INSERT INTO airline_alias VALUES ('   ', 'JDP', 'JDP LUX                                               ', 'JDP LUX                                               ');
INSERT INTO airline_alias VALUES ('O2 ', 'JEA', 'JET AIR                                               ', 'JET AIR                                               ');
INSERT INTO airline_alias VALUES ('JX ', 'JEC', 'JETT8 AIRLINES CARGO                                  ', 'JETT8 AIRLINES CARGO                                  ');
INSERT INTO airline_alias VALUES ('   ', 'JEF', 'JETFLITE OY                                           ', 'JETFLITE OY                                           ');
INSERT INTO airline_alias VALUES ('   ', 'JEI', 'JET EXECUTIVE INTERNATIONAL CHARTER                   ', 'JET EXECUTIVE INTERNATIONAL CHARTER                   ');
INSERT INTO airline_alias VALUES ('8J ', 'JFU', 'JET4YOU                                               ', 'JET4YOU                                               ');
INSERT INTO airline_alias VALUES ('   ', 'JIA', 'PSA AIRLINES                                          ', 'PSA AIRLINES                                          ');
INSERT INTO airline_alias VALUES ('   ', 'JIB', 'AZMAR AIRLINES                                        ', 'AZMAR AIRLINES                                        ');
INSERT INTO airline_alias VALUES ('7C ', 'JJA', 'JEJU AIR                                              ', 'JEJU AIR                                              ');
INSERT INTO airline_alias VALUES ('   ', 'JLB', 'JHONLIN AIR TRANSPORT                                 ', 'JHONLIN AIR TRANSPORT                                 ');
INSERT INTO airline_alias VALUES ('J0 ', 'JLX', 'JETLINK EXPRESS                                       ', 'JETLINK EXPRESS                                       ');
INSERT INTO airline_alias VALUES ('   ', 'JMP', 'BUSINESS WINGS LUFTFAHRTUNTERNEHMEN                   ', 'BUSINESS WINGS LUFTFAHRTUNTERNEHMEN                   ');
INSERT INTO airline_alias VALUES ('LJ ', 'JNA', 'JIN AIR                                               ', 'JIN AIR                                               ');
INSERT INTO airline_alias VALUES ('   ', 'JNL', 'JETNETHERLANDS                                        ', 'JETNETHERLANDS                                        ');
INSERT INTO airline_alias VALUES ('   ', 'JON', 'JOHNSONS AIR                                          ', 'JOHNSONS AIR                                          ');
INSERT INTO airline_alias VALUES ('0B ', 'JOR', 'BLUE AIR-TRANSPORT AERIAN                             ', 'BLUE AIR-TRANSPORT AERIAN                             ');
INSERT INTO airline_alias VALUES ('   ', 'JPI', 'JP AIR                                                ', 'JP AIR                                                ');
INSERT INTO airline_alias VALUES ('   ', 'JPS', 'AIR NATIONAL CORPORATE                                ', 'AIR NATIONAL CORPORATE                                ');
INSERT INTO airline_alias VALUES ('3K ', 'JSA', 'JETSTAR ASIA                                          ', 'JETSTAR ASIA                                          ');
INSERT INTO airline_alias VALUES ('   ', 'JSJ', 'JS FOCUS AIR                                          ', 'JS FOCUS AIR                                          ');
INSERT INTO airline_alias VALUES ('   ', 'JSN', 'SUNCOR ENERGY INC.                                    ', 'SUNCOR ENERGY INC.                                    ');
INSERT INTO airline_alias VALUES ('   ', 'JTE', 'NATIONAL JET EXPRESS                                  ', 'NATIONAL JET EXPRESS                                  ');
INSERT INTO airline_alias VALUES ('   ', 'JTG', 'JET TIME                                              ', 'JET TIME                                              ');
INSERT INTO airline_alias VALUES ('   ', 'JTI', 'JETAIR FLUG                                           ', 'JETAIR FLUG                                           ');
INSERT INTO airline_alias VALUES ('   ', 'JTR', 'EXECUTIVE AVIATION SERVICES [UK]                      ', 'EXECUTIVE AVIATION SERVICES [UK]                      ');
INSERT INTO airline_alias VALUES ('   ', 'JXT', 'JETSTREAM EXECUTIVE TRAVEL                            ', 'JETSTREAM EXECUTIVE TRAVEL                            ');
INSERT INTO airline_alias VALUES ('J9 ', 'JZR', 'JAZEERA AIRWAYS                                       ', 'JAZEERA AIRWAYS                                       ');
INSERT INTO airline_alias VALUES ('   ', 'KAE', 'KARTIKA AIRLINES                                      ', 'KARTIKA AIRLINES                                      ');
INSERT INTO airline_alias VALUES ('   ', 'KBR', 'KORALBLUE AIRLINES                                    ', 'KORALBLUE AIRLINES                                    ');
INSERT INTO airline_alias VALUES ('   ', 'KCE', 'IRVING AIR SERVICE INC.                               ', 'IRVING AIR SERVICE INC.                               ');
INSERT INTO airline_alias VALUES ('   ', 'KEA', 'KOREA EXPRESS AIR                                     ', 'KOREA EXPRESS AIR                                     ');
INSERT INTO airline_alias VALUES ('   ', 'KEM', 'CEMAIR (PTY) LTD.                                     ', 'CEMAIR (PTY) LTD.                                     ');
INSERT INTO airline_alias VALUES ('M5 ', 'KEN', 'KENMORE AIR                                           ', 'KENMORE AIR                                           ');
INSERT INTO airline_alias VALUES ('   ', 'KES', 'KALLAT EL SAKER AIR                                   ', 'KALLAT EL SAKER AIR                                   ');
INSERT INTO airline_alias VALUES ('KW ', 'KFA', 'KELOWNA FLIGHTCRAFT AIR CHARTER                       ', 'KELOWNA FLIGHTCRAFT AIR CHARTER                       ');
INSERT INTO airline_alias VALUES ('IT ', 'KFR', 'KINGFISHER AIRLINES                                   ', 'KINGFISHER AIRLINES                                   ');
INSERT INTO airline_alias VALUES ('ZR ', 'KHH', 'ALEXANDRIA AIRLINES                                   ', 'ALEXANDRIA AIRLINES                                   ');
INSERT INTO airline_alias VALUES ('K6 ', 'KHV', 'CAMBODIA ANGKOR AIR                                   ', 'CAMBODIA ANGKOR AIR                                   ');
INSERT INTO airline_alias VALUES ('C3 ', 'KIS', 'CONTACT AIR [GERMANY]                                 ', 'CONTACT AIR [GERMANY]                                 ');
INSERT INTO airline_alias VALUES ('KK ', 'KKK', 'ATLASJET INTERNATIONAL                                ', 'ATLASJET INTERNATIONAL                                ');
INSERT INTO airline_alias VALUES ('   ', 'KLO', 'SKYXPRESS AIRLINE                                     ', 'SKYXPRESS AIRLINE                                     ');
INSERT INTO airline_alias VALUES ('   ', 'KLS', 'KALSTAR AVIATION                                      ', 'KALSTAR AVIATION                                      ');
INSERT INTO airline_alias VALUES ('   ', 'KMC', 'KAHAMA MINING CORPORATION                             ', 'KAHAMA MINING CORPORATION                             ');
INSERT INTO airline_alias VALUES ('RQ ', 'KMF', 'KAM AIR                                               ', 'KAM AIR                                               ');
INSERT INTO airline_alias VALUES ('8K ', 'KMI', 'K-MILE AIR                                            ', 'K-MILE AIR                                            ');
INSERT INTO airline_alias VALUES ('   ', 'KMS', 'COSMOS AIR CARGO                                      ', 'COSMOS AIR CARGO                                      ');
INSERT INTO airline_alias VALUES ('KY ', 'KNA', 'KUNMING AIRLINES                                      ', 'KUNMING AIRLINES                                      ');
INSERT INTO airline_alias VALUES ('XY ', 'KNE', 'NATIONAL AIR SERVICES                                 ', 'NATIONAL AIR SERVICES                                 ');
INSERT INTO airline_alias VALUES ('   ', 'KNT', 'FLIGHTPATH CHARTER AIRWAYS                            ', 'FLIGHTPATH CHARTER AIRWAYS                            ');
INSERT INTO airline_alias VALUES ('VD ', 'KPA', 'HENAN AIRLINES                                        ', 'HENAN AIRLINES                                        ');
INSERT INTO airline_alias VALUES ('   ', 'KRA', 'ARKAS                                                 ', 'ARKAS                                                 ');
INSERT INTO airline_alias VALUES ('6N ', 'KRE', 'AEROSUCRE COLOMBIA                                    ', 'AEROSUCRE COLOMBIA                                    ');
INSERT INTO airline_alias VALUES ('   ', 'KSJ', 'K2 SMARTJETS S.A.                                     ', 'K2 SMARTJETS S.A.                                     ');
INSERT INTO airline_alias VALUES ('   ', 'KSU', 'KANSAS STATE UNIVERSITY                               ', 'KANSAS STATE UNIVERSITY                               ');
INSERT INTO airline_alias VALUES ('   ', 'KUK', 'KUDLIK AVIATION INC.                                  ', 'KUDLIK AVIATION INC.                                  ');
INSERT INTO airline_alias VALUES ('   ', 'KVA', 'KAVOK AIRLINES                                        ', 'KAVOK AIRLINES                                        ');
INSERT INTO airline_alias VALUES ('   ', 'KYB', 'SKYBRIDGE AIROPS                                      ', 'SKYBRIDGE AIROPS                                      ');
INSERT INTO airline_alias VALUES ('GG ', 'KYE', 'SKYLEASE CARGO                                        ', 'SKYLEASE CARGO                                        ');
INSERT INTO airline_alias VALUES ('GO ', 'KZU', 'ULS AIRLINES CARGO                                    ', 'ULS AIRLINES CARGO                                    ');
INSERT INTO airline_alias VALUES ('   ', 'LAU', 'LINEAS AEREAS SURAMERICANAS                           ', 'LINEAS AEREAS SURAMERICANAS                           ');
INSERT INTO airline_alias VALUES ('   ', 'LAY', 'LAYANG-LAYANG AEROSPACE SDN. BHD.                     ', 'LAYANG-LAYANG AEROSPACE SDN. BHD.                     ');
INSERT INTO airline_alias VALUES ('LZ ', 'LBY', 'BELLE AIR                                             ', 'BELLE AIR                                             ');
INSERT INTO airline_alias VALUES ('W4 ', 'LCB', 'L.C. BUSRE                                            ', 'L.C. BUSRE                                            ');
INSERT INTO airline_alias VALUES ('4V ', 'LCG', 'LIGNES AERIENNES CONGOLAISES                          ', 'LIGNES AERIENNES CONGOLAISES                          ');
INSERT INTO airline_alias VALUES ('   ', 'LCH', 'LYNCH FLYING SERVICE INC.                             ', 'LYNCH FLYING SERVICE INC.                             ');
INSERT INTO airline_alias VALUES ('   ', 'LCN', 'LINEAS AEREAS CANEDO                                  ', 'LINEAS AEREAS CANEDO                                  ');
INSERT INTO airline_alias VALUES ('   ', 'LCR', 'LIBYAN ARAB COMPANY FOR AIR CARGO                     ', 'LIBYAN ARAB COMPANY FOR AIR CARGO                     ');
INSERT INTO airline_alias VALUES ('   ', 'LEA', 'UNIJET                                                ', 'UNIJET                                                ');
INSERT INTO airline_alias VALUES ('   ', 'LEF', 'EFLY                                                  ', 'EFLY                                                  ');
INSERT INTO airline_alias VALUES ('   ', 'LEJ', 'FSH LUFTFAHRTUNTERNEHMEN                              ', 'FSH LUFTFAHRTUNTERNEHMEN                              ');
INSERT INTO airline_alias VALUES ('   ', 'LET', 'AEROLINEAS EJECUTIVAS                                 ', 'AEROLINEAS EJECUTIVAS                                 ');
INSERT INTO airline_alias VALUES ('   ', 'LEU', 'LIONS AIR AG                                          ', 'LIONS AIR AG                                          ');
INSERT INTO airline_alias VALUES ('   ', 'LFH', 'ALFA HISTRIA                                          ', 'ALFA HISTRIA                                          ');
INSERT INTO airline_alias VALUES ('   ', 'LFM', 'AIRLIFT SERVICE                                       ', 'AIRLIFT SERVICE                                       ');
INSERT INTO airline_alias VALUES ('   ', 'LGJ', 'ICEJET                                                ', 'ICEJET                                                ');
INSERT INTO airline_alias VALUES ('   ', 'LGN', 'AEROLAGUNA                                            ', 'AEROLAGUNA                                            ');
INSERT INTO airline_alias VALUES ('   ', 'LIX', 'LINXAIR BUSINESS AIRLINES                             ', 'LINXAIR BUSINESS AIRLINES                             ');
INSERT INTO airline_alias VALUES ('   ', 'LJM', 'INTERNATIONAL AIRLINK                                 ', 'INTERNATIONAL AIRLINK                                 ');
INSERT INTO airline_alias VALUES ('8L ', 'LKE', 'LUCKY AIR [CHINA]                                     ', 'LUCKY AIR [CHINA]                                     ');
INSERT INTO airline_alias VALUES ('   ', 'LLC', 'FLYLAL CHARTERS                                       ', 'FLYLAL CHARTERS                                       ');
INSERT INTO airline_alias VALUES ('   ', 'LLP', 'FLYLAL POLSKA                                         ', 'FLYLAL POLSKA                                         ');
INSERT INTO airline_alias VALUES ('   ', 'LMO', 'SKY LIMO AIR CHARTER                                  ', 'SKY LIMO AIR CHARTER                                  ');
INSERT INTO airline_alias VALUES ('UJ ', 'LMU', 'ALMASRIA UNIVERSAL AIRLINES                           ', 'ALMASRIA UNIVERSAL AIRLINES                           ');
INSERT INTO airline_alias VALUES ('   ', 'LMZ', 'STARLINE KZ                                           ', 'STARLINE KZ                                           ');
INSERT INTO airline_alias VALUES ('XL ', 'LNE', 'LAN ECUADOR                                           ', 'LAN ECUADOR                                           ');
INSERT INTO airline_alias VALUES ('   ', 'LNQ', 'LINKS AIR                                             ', 'LINKS AIR                                             ');
INSERT INTO airline_alias VALUES ('   ', 'LNX', 'LONDON EXECUTIVE AVIATION                             ', 'LONDON EXECUTIVE AVIATION                             ');
INSERT INTO airline_alias VALUES ('   ', 'LOD', 'FLY LOGIC                                             ', 'FLY LOGIC                                             ');
INSERT INTO airline_alias VALUES ('   ', 'LOG', 'LOGANAIR                                              ', 'LOGANAIR                                              ');
INSERT INTO airline_alias VALUES ('   ', 'LRA', 'LITTLE RED AIR SERVICE                                ', 'LITTLE RED AIR SERVICE                                ');
INSERT INTO airline_alias VALUES ('   ', 'LSE', 'LINEA DE AEROSERVICIOS                                ', 'LINEA DE AEROSERVICIOS                                ');
INSERT INTO airline_alias VALUES ('   ', 'LSK', 'AURELA                                                ', 'AURELA                                                ');
INSERT INTO airline_alias VALUES ('L5 ', 'LTR', 'LUFTTRANSPORT                                         ', 'LUFTTRANSPORT                                         ');
INSERT INTO airline_alias VALUES ('   ', 'LUK', 'LUKOIL COMPANY                                        ', 'LUKOIL COMPANY                                        ');
INSERT INTO airline_alias VALUES ('   ', 'LUZ', 'LUZAIR                                                ', 'LUZAIR                                                ');
INSERT INTO airline_alias VALUES ('   ', 'LVB', 'IRS AIRLINES                                          ', 'IRS AIRLINES                                          ');
INSERT INTO airline_alias VALUES ('   ', 'LVR', 'AVIAVILSA                                             ', 'AVIAVILSA                                             ');
INSERT INTO airline_alias VALUES ('   ', 'LXC', 'CAE AVIATION                                          ', 'CAE AVIATION                                          ');
INSERT INTO airline_alias VALUES ('   ', 'LXF', 'LYNX AIR INTERNATIONAL                                ', 'LYNX AIR INTERNATIONAL                                ');
INSERT INTO airline_alias VALUES ('LU ', 'LXP', 'LANEXPRESS                                            ', 'LANEXPRESS                                            ');
INSERT INTO airline_alias VALUES ('   ', 'LYD', 'LYDD AIR                                              ', 'LYDD AIR                                              ');
INSERT INTO airline_alias VALUES ('   ', 'LYM', 'KEY LIME AIR                                          ', 'KEY LIME AIR                                          ');
INSERT INTO airline_alias VALUES ('   ', 'MAF', 'MISSION AVIATION FELLOWSHIP MADAGASCAR                ', 'MISSION AVIATION FELLOWSHIP MADAGASCAR                ');
INSERT INTO airline_alias VALUES ('   ', 'MAG', 'MERIDIAN AIRWAYS                                      ', 'MERIDIAN AIRWAYS                                      ');
INSERT INTO airline_alias VALUES ('   ', 'MAI', 'MAURITANIA AIRLINES INTERNATIONAL                     ', 'MAURITANIA AIRLINES INTERNATIONAL                     ');
INSERT INTO airline_alias VALUES ('   ', 'MAL', 'MORNINGSTAR AIR EXPRESS                               ', 'MORNINGSTAR AIR EXPRESS                               ');
INSERT INTO airline_alias VALUES ('L4 ', 'MAX', 'AIR LIAISON                                           ', 'AIR LIAISON                                           ');
INSERT INTO airline_alias VALUES ('M2 ', 'MBB', 'AIR MANAS                                             ', 'AIR MANAS                                             ');
INSERT INTO airline_alias VALUES ('   ', 'MBC', 'AIRJET EXPLORACAO AEREA                               ', 'AIRJET EXPLORACAO AEREA                               ');
INSERT INTO airline_alias VALUES ('   ', 'MBE', 'MARTIN-BAKER (ENGINEERING) LTD.                       ', 'MARTIN-BAKER (ENGINEERING) LTD.                       ');
INSERT INTO airline_alias VALUES ('S6 ', 'MBI', 'SALMON AIR                                            ', 'SALMON AIR                                            ');
INSERT INTO airline_alias VALUES ('   ', 'MBJ', 'TAFARAYT JET                                          ', 'TAFARAYT JET                                          ');
INSERT INTO airline_alias VALUES ('   ', 'MCC', 'MCC AVIATION                                          ', 'MCC AVIATION                                          ');
INSERT INTO airline_alias VALUES ('   ', 'MCD', 'AIR MEDICAL                                           ', 'AIR MEDICAL                                           ');
INSERT INTO airline_alias VALUES ('VM ', 'MCJ', 'MACAIR JET                                            ', 'MACAIR JET                                            ');
INSERT INTO airline_alias VALUES ('   ', 'MDC', 'MID-ATLANTIC FREIGHT                                  ', 'MID-ATLANTIC FREIGHT                                  ');
INSERT INTO airline_alias VALUES ('   ', 'MDF', 'SWIFTAIR HELLAS                                       ', 'SWIFTAIR HELLAS                                       ');
INSERT INTO airline_alias VALUES ('WZ ', 'MDJ', 'JETRAN INTERNATIONAL AIRWAYS                          ', 'JETRAN INTERNATIONAL AIRWAYS                          ');
INSERT INTO airline_alias VALUES ('N5 ', 'MDM', 'MEDAVIA                                               ', 'MEDAVIA                                               ');
INSERT INTO airline_alias VALUES ('   ', 'MDS', 'MCNEELY CHARTER SERVICES                              ', 'MCNEELY CHARTER SERVICES                              ');
INSERT INTO airline_alias VALUES ('   ', 'MDT', 'SUNDT AIR                                             ', 'SUNDT AIR                                             ');
INSERT INTO airline_alias VALUES ('   ', 'MEI', 'MERLIN AIRWAYS                                        ', 'MERLIN AIRWAYS                                        ');
INSERT INTO airline_alias VALUES ('   ', 'MEJ', 'MID EAST JET                                          ', 'MID EAST JET                                          ');
INSERT INTO airline_alias VALUES ('   ', 'MEV', 'MED-VIEW AIRLINES                                     ', 'MED-VIEW AIRLINES                                     ');
INSERT INTO airline_alias VALUES ('MG ', 'MGD', 'MIAMI AIR LEASE                                       ', 'MIAMI AIR LEASE                                       ');
INSERT INTO airline_alias VALUES ('   ', 'MGE', 'ASIA PACIFIC AIRLINES [GUAM]                          ', 'ASIA PACIFIC AIRLINES [GUAM]                          ');
INSERT INTO airline_alias VALUES ('   ', 'MGK', 'MEGA AIRCOMPANY                                       ', 'MEGA AIRCOMPANY                                       ');
INSERT INTO airline_alias VALUES ('   ', 'MGT', 'AIR ATTACK TECHNOLOGIES                               ', 'AIR ATTACK TECHNOLOGIES                               ');
INSERT INTO airline_alias VALUES ('6N ', 'MHK', 'ALNASER AIRLINES                                      ', 'ALNASER AIRLINES                                      ');
INSERT INTO airline_alias VALUES ('   ', 'MHS', 'AIR MEMPHIS                                           ', 'AIR MEMPHIS                                           ');
INSERT INTO airline_alias VALUES ('   ', 'MIC', 'MINT AIRWAYS                                          ', 'MINT AIRWAYS                                          ');
INSERT INTO airline_alias VALUES ('MG ', 'MIX', 'MIDEX AIRLINES                                        ', 'MIDEX AIRLINES                                        ');
INSERT INTO airline_alias VALUES ('   ', 'MJE', 'EMPIRE AVIATION GROUP FZCO                            ', 'EMPIRE AVIATION GROUP FZCO                            ');
INSERT INTO airline_alias VALUES ('   ', 'MJF', 'MJET AVIATION GMBH                                    ', 'MJET AVIATION GMBH                                    ');
INSERT INTO airline_alias VALUES ('4L ', 'MJX', 'EUROLINE                                              ', 'EUROLINE                                              ');
INSERT INTO airline_alias VALUES ('   ', 'MKD', 'MAT AIRWAYS                                           ', 'MAT AIRWAYS                                           ');
INSERT INTO airline_alias VALUES ('P8 ', 'MKG', 'AIR MEKONG                                            ', 'AIR MEKONG                                            ');
INSERT INTO airline_alias VALUES ('   ', 'MKH', 'AIR MARRAKECH SERVICE                                 ', 'AIR MARRAKECH SERVICE                                 ');
INSERT INTO airline_alias VALUES ('   ', 'MKL', 'MCCALL & WILDERNESS AIR                               ', 'MCCALL & WILDERNESS AIR                               ');
INSERT INTO airline_alias VALUES ('   ', 'MLC', 'MALIFT AIR                                            ', 'MALIFT AIR                                            ');
INSERT INTO airline_alias VALUES ('   ', 'MLM', 'COMLUX MALTA                                          ', 'COMLUX MALTA                                          ');
INSERT INTO airline_alias VALUES ('   ', 'MLO', 'SERVICIOS AEREOS MILENIO                              ', 'SERVICIOS AEREOS MILENIO                              ');
INSERT INTO airline_alias VALUES ('MJ ', 'MLR', 'MIHIN LANKA                                           ', 'MIHIN LANKA                                           ');
INSERT INTO airline_alias VALUES ('8M ', 'MMA', 'MYANMAR AIRWAYS INTERNATIONAL                         ', 'MYANMAR AIRWAYS INTERNATIONAL                         ');
INSERT INTO airline_alias VALUES ('   ', 'MMG', 'AEREO RUTA MAYA                                       ', 'AEREO RUTA MAYA                                       ');
INSERT INTO airline_alias VALUES ('   ', 'MMT', 'SAM INTERCONTINENTAL GROUP                            ', 'SAM INTERCONTINENTAL GROUP                            ');
INSERT INTO airline_alias VALUES ('M0 ', 'MNG', 'AERO MONGOLIA                                         ', 'AERO MONGOLIA                                         ');
INSERT INTO airline_alias VALUES ('   ', 'MNL', 'MINILINER                                             ', 'MINILINER                                             ');
INSERT INTO airline_alias VALUES ('JE ', 'MNO', 'MANGO                                                 ', 'MANGO                                                 ');
INSERT INTO airline_alias VALUES ('SM ', 'MNP', 'SPIRIT OF MANILA AIRLINES                             ', 'SPIRIT OF MANILA AIRLINES                             ');
INSERT INTO airline_alias VALUES ('5M ', 'MNT', 'MONTSERRAT AIRWAYS                                    ', 'MONTSERRAT AIRWAYS                                    ');
INSERT INTO airline_alias VALUES ('7B ', 'MOA', 'MOSCOW AIRLINES                                       ', 'MOSCOW AIRLINES                                       ');
INSERT INTO airline_alias VALUES ('   ', 'MPF', 'MAP EXECUTIVE FLIGHT SERVICE GMBH                     ', 'MAP EXECUTIVE FLIGHT SERVICE GMBH                     ');
INSERT INTO airline_alias VALUES ('AQ ', 'MPJ', 'MAP MANAGEMENT & PLANNING GMBH                        ', 'MAP MANAGEMENT & PLANNING GMBH                        ');
INSERT INTO airline_alias VALUES ('   ', 'MRA', 'MARTINAIRE                                            ', 'MARTINAIRE                                            ');
INSERT INTO airline_alias VALUES ('   ', 'MRE', 'NAMIBIA COMMERCIAL AVIATION                           ', 'NAMIBIA COMMERCIAL AVIATION                           ');
INSERT INTO airline_alias VALUES ('   ', 'MRG', 'MANAG''AIR                                             ', 'MANAG''AIR                                             ');
INSERT INTO airline_alias VALUES ('6V ', 'MRW', 'MRK AIRLINES                                          ', 'MRK AIRLINES                                          ');
INSERT INTO airline_alias VALUES ('7M ', 'MSA', 'MISTRAL AIR                                           ', 'MISTRAL AIR                                           ');
INSERT INTO airline_alias VALUES ('   ', 'MSC', 'AIR CAIRO                                             ', 'AIR CAIRO                                             ');
INSERT INTO airline_alias VALUES ('   ', 'MSE', 'EGYPTAIR EXPRESS                                      ', 'EGYPTAIR EXPRESS                                      ');
INSERT INTO airline_alias VALUES ('M7 ', 'MSL', 'MARSLAND AVIATION                                     ', 'MARSLAND AVIATION                                     ');
INSERT INTO airline_alias VALUES ('   ', 'MSM', 'AEROMAS                                               ', 'AEROMAS                                               ');
INSERT INTO airline_alias VALUES ('   ', 'MSQ', 'MESQUITA TRANSPORTES AEREOS                           ', 'MESQUITA TRANSPORTES AEREOS                           ');
INSERT INTO airline_alias VALUES ('BM ', 'MST', 'MASTERTOP LINHAS AEREAS                               ', 'MASTERTOP LINHAS AEREAS                               ');
INSERT INTO airline_alias VALUES ('   ', 'MSX', 'EGYPTAIR CARGO                                        ', 'EGYPTAIR CARGO                                        ');
INSERT INTO airline_alias VALUES ('   ', 'MTE', 'AEROMET LINEA AEREA                                   ', 'AEROMET LINEA AEREA                                   ');
INSERT INTO airline_alias VALUES ('   ', 'MTJ', 'METROJET                                              ', 'METROJET                                              ');
INSERT INTO airline_alias VALUES ('   ', 'MTL', 'RAF-AVIA                                              ', 'RAF-AVIA                                              ');
INSERT INTO airline_alias VALUES ('   ', 'MTM', 'MD AIR                                                ', 'MD AIR                                                ');
INSERT INTO airline_alias VALUES ('YD ', 'MTW', 'MAURITANIA AIRWAYS                                    ', 'MAURITANIA AIRWAYS                                    ');
INSERT INTO airline_alias VALUES ('MH ', 'MWG', 'MASWINGS                                              ', 'MASWINGS                                              ');
INSERT INTO airline_alias VALUES ('   ', 'MXE', 'MOCAMBIQUE EXPRESSO                                   ', 'MOCAMBIQUE EXPRESSO                                   ');
INSERT INTO airline_alias VALUES ('I6 ', 'MXI', 'MEXICANA INTER                                        ', 'MEXICANA INTER                                        ');
INSERT INTO airline_alias VALUES ('   ', 'MXU', 'MAXIMUS AIR CARGO                                     ', 'MAXIMUS AIR CARGO                                     ');
INSERT INTO airline_alias VALUES ('   ', 'MYA', 'MYFLUG                                                ', 'MYFLUG                                                ');
INSERT INTO airline_alias VALUES ('7M ', 'MYI', 'MAYAIR                                                ', 'MAYAIR                                                ');
INSERT INTO airline_alias VALUES ('   ', 'MYO', 'MAYORAL EXECUTIVE JET                                 ', 'MAYORAL EXECUTIVE JET                                 ');
INSERT INTO airline_alias VALUES ('   ', 'MZT', 'FIRST MANDARIN BUSINESS AVIATION                      ', 'FIRST MANDARIN BUSINESS AVIATION                      ');
INSERT INTO airline_alias VALUES ('   ', 'NAG', 'NORTHERN AIR CHARTER [GERMANY]                        ', 'NORTHERN AIR CHARTER [GERMANY]                        ');
INSERT INTO airline_alias VALUES ('   ', 'NAL', 'NORTHWAY AVIATION                                     ', 'NORTHWAY AVIATION                                     ');
INSERT INTO airline_alias VALUES ('ZN ', 'NAY', 'NAYSA AEROTAXIS                                       ', 'NAYSA AEROTAXIS                                       ');
INSERT INTO airline_alias VALUES ('   ', 'NCB', 'NORTH CARIBOO FLYING SERVICE                          ', 'NORTH CARIBOO FLYING SERVICE                          ');
INSERT INTO airline_alias VALUES ('   ', 'NCP', 'CAPITAL AIRLINES [NIGERIA]                            ', 'CAPITAL AIRLINES [NIGERIA]                            ');
INSERT INTO airline_alias VALUES ('   ', 'NDU', 'UND AEROSPACE FOUNDATION                              ', 'UND AEROSPACE FOUNDATION                              ');
INSERT INTO airline_alias VALUES ('   ', 'NEF', 'NORDFLYG LOGISTIK AB                                  ', 'NORDFLYG LOGISTIK AB                                  ');
INSERT INTO airline_alias VALUES ('D5 ', 'NEP', 'NEPC AIRLINES                                         ', 'NEPC AIRLINES                                         ');
INSERT INTO airline_alias VALUES ('NR ', 'NGL', 'MAX AIR                                               ', 'MAX AIR                                               ');
INSERT INTO airline_alias VALUES ('NP ', 'NIA', 'NILE AIR                                              ', 'NILE AIR                                              ');
INSERT INTO airline_alias VALUES ('   ', 'NJE', 'NETJETS TRANSPORTES AEREOS                            ', 'NETJETS TRANSPORTES AEREOS                            ');
INSERT INTO airline_alias VALUES ('   ', 'NKT', 'NORTH COUNTRY AVIATION INC.                           ', 'NORTH COUNTRY AVIATION INC.                           ');
INSERT INTO airline_alias VALUES ('N8 ', 'NLE', 'NATIONAL AIRLINES [MI-USA]                            ', 'NATIONAL AIRLINES [MI-USA]                            ');
INSERT INTO airline_alias VALUES ('   ', 'NLF', 'WESTAIR AVIATION [CANADA]                             ', 'WESTAIR AVIATION [CANADA]                             ');
INSERT INTO airline_alias VALUES ('   ', 'NMA', 'NESMA AIRLINES                                        ', 'NESMA AIRLINES                                        ');
INSERT INTO airline_alias VALUES ('   ', 'NMD', 'BAY AIR AVIATION                                      ', 'BAY AIR AVIATION                                      ');
INSERT INTO airline_alias VALUES ('LW ', 'NMI', 'PACIFIC WINGS                                         ', 'PACIFIC WINGS                                         ');
INSERT INTO airline_alias VALUES ('   ', 'NOF', 'FONNAFLY                                              ', 'FONNAFLY                                              ');
INSERT INTO airline_alias VALUES ('   ', 'NOJ', 'NOVAJET                                               ', 'NOVAJET                                               ');
INSERT INTO airline_alias VALUES ('DD ', 'NOK', 'NOK AIRLINES                                          ', 'NOK AIRLINES                                          ');
INSERT INTO airline_alias VALUES ('O9 ', 'NOV', 'NOVA AIRWAYS                                          ', 'NOVA AIRWAYS                                          ');
INSERT INTO airline_alias VALUES ('   ', 'NPT', 'ATLANTIC AIRLINES [UK]                                ', 'ATLANTIC AIRLINES [UK]                                ');
INSERT INTO airline_alias VALUES ('   ', 'NRG', 'ROSS AVIATION INC. [NM-USA]                           ', 'ROSS AVIATION INC. [NM-USA]                           ');
INSERT INTO airline_alias VALUES ('   ', 'NRK', 'NATURELINK AVIATION                                   ', 'NATURELINK AVIATION                                   ');
INSERT INTO airline_alias VALUES ('   ', 'NRL', 'NOLINOR AVIATION                                      ', 'NOLINOR AVIATION                                      ');
INSERT INTO airline_alias VALUES ('5C ', 'NRR', 'NATURE AIR                                            ', 'NATURE AIR                                            ');
INSERT INTO airline_alias VALUES ('   ', 'NRT', 'NORESTAIR                                             ', 'NORESTAIR                                             ');
INSERT INTO airline_alias VALUES ('   ', 'NRX', 'NORSE AIR CHARTER                                     ', 'NORSE AIR CHARTER                                     ');
INSERT INTO airline_alias VALUES ('P4 ', 'NSO', 'AEROLINEAS SOSA                                       ', 'AEROLINEAS SOSA                                       ');
INSERT INTO airline_alias VALUES ('   ', 'NST', 'PAKISTAN AVIATORS & AVIATION                          ', 'PAKISTAN AVIATORS & AVIATION                          ');
INSERT INTO airline_alias VALUES ('4R ', 'NTA', 'NORTHERN THUNDERBIRD AIR                              ', 'NORTHERN THUNDERBIRD AIR                              ');
INSERT INTO airline_alias VALUES ('   ', 'NTH', 'HOKKAIDO AIR SYSTEM                                   ', 'HOKKAIDO AIR SYSTEM                                   ');
INSERT INTO airline_alias VALUES ('2N ', 'NTJ', 'NEXTJET                                               ', 'NEXTJET                                               ');
INSERT INTO airline_alias VALUES ('   ', 'NTR', 'TNT EXPRESS WORLDWIDE                                 ', 'TNT EXPRESS WORLDWIDE                                 ');
INSERT INTO airline_alias VALUES ('   ', 'NTV', 'AIR INTER IVOIRE                                      ', 'AIR INTER IVOIRE                                      ');
INSERT INTO airline_alias VALUES ('X9 ', 'NVD', 'AVION EXPRESS [LITHUANIA]                             ', 'AVION EXPRESS [LITHUANIA]                             ');
INSERT INTO airline_alias VALUES ('   ', 'NVS', 'AIR AFFAIRES GABON                                    ', 'AIR AFFAIRES GABON                                    ');
INSERT INTO airline_alias VALUES ('   ', 'NWG', 'AIRWING                                               ', 'AIRWING                                               ');
INSERT INTO airline_alias VALUES ('N4 ', 'NWS', 'NORDWIND AIRLINES                                     ', 'NORDWIND AIRLINES                                     ');
INSERT INTO airline_alias VALUES ('7A ', 'NXA', 'AIR NEXT                                              ', 'AIR NEXT                                              ');
INSERT INTO airline_alias VALUES ('YT ', 'NYT', 'YETI AIRLINES                                         ', 'YETI AIRLINES                                         ');
INSERT INTO airline_alias VALUES ('   ', 'OAI', 'TOR AIR                                               ', 'TOR AIR                                               ');
INSERT INTO airline_alias VALUES ('   ', 'OBS', 'ORBEST                                                ', 'ORBEST                                                ');
INSERT INTO airline_alias VALUES ('   ', 'OCS', 'OCEAN SKY AIRCRAFT MANAGEMENT LTD.                    ', 'OCEAN SKY AIRCRAFT MANAGEMENT LTD.                    ');
INSERT INTO airline_alias VALUES ('   ', 'OGI', 'AEROGISA                                              ', 'AEROGISA                                              ');
INSERT INTO airline_alias VALUES ('BK ', 'OKA', 'OKAY AIRWAYS                                          ', 'OKAY AIRWAYS                                          ');
INSERT INTO airline_alias VALUES ('   ', 'OKT', 'SOKO AVIATION                                         ', 'SOKO AVIATION                                         ');
INSERT INTO airline_alias VALUES ('8R ', 'OLS', 'SOL LINEAS AEREAS                                     ', 'SOL LINEAS AEREAS                                     ');
INSERT INTO airline_alias VALUES ('   ', 'OMF', 'OMNIFLYS                                              ', 'OMNIFLYS                                              ');
INSERT INTO airline_alias VALUES ('   ', 'OMR', 'MINAIR                                                ', 'MINAIR                                                ');
INSERT INTO airline_alias VALUES ('O6 ', 'ONE', 'OCEANAIR [BRAZIL]                                     ', 'OCEANAIR [BRAZIL]                                     ');
INSERT INTO airline_alias VALUES ('N6 ', 'ONR', 'AIR ONE NINE                                          ', 'AIR ONE NINE                                          ');
INSERT INTO airline_alias VALUES ('   ', 'OPJ', 'OPERA JET                                             ', 'OPERA JET                                             ');
INSERT INTO airline_alias VALUES ('OC ', 'ORC', 'ORIENTAL AIR BRIDGE                                   ', 'ORIENTAL AIR BRIDGE                                   ');
INSERT INTO airline_alias VALUES ('   ', 'ORE', 'ORANGE AVIATION                                       ', 'ORANGE AVIATION                                       ');
INSERT INTO airline_alias VALUES ('   ', 'ORZ', 'ZOREX AIR TRANSPORT                                   ', 'ZOREX AIR TRANSPORT                                   ');
INSERT INTO airline_alias VALUES ('   ', 'OVA', 'AERONOVA                                              ', 'AERONOVA                                              ');
INSERT INTO airline_alias VALUES ('   ', 'OVC', 'AEROVIC                                               ', 'AEROVIC                                               ');
INSERT INTO airline_alias VALUES ('   ', 'OWT', 'TWO TAXI AEREO                                        ', 'TWO TAXI AEREO                                        ');
INSERT INTO airline_alias VALUES ('   ', 'OZU', 'HOZU-AVIA                                             ', 'HOZU-AVIA                                             ');
INSERT INTO airline_alias VALUES ('XR ', 'OZW', 'SKYWEST AIRLINES [AUSTRALIA]                          ', 'SKYWEST AIRLINES [AUSTRALIA]                          ');
INSERT INTO airline_alias VALUES ('A8 ', 'PAY', 'AEROLINEAS PARAGUAYAS                                 ', 'AEROLINEAS PARAGUAYAS                                 ');
INSERT INTO airline_alias VALUES ('   ', 'PBL', 'POLYNESIAN BLUE AIRLINES                              ', 'POLYNESIAN BLUE AIRLINES                              ');
INSERT INTO airline_alias VALUES ('   ', 'PBN', 'PACIFIC BLUE AIRLINES                                 ', 'PACIFIC BLUE AIRLINES                                 ');
INSERT INTO airline_alias VALUES ('   ', 'PCG', 'AEROPOSTAL CARGO DE MEXICO                            ', 'AEROPOSTAL CARGO DE MEXICO                            ');
INSERT INTO airline_alias VALUES ('   ', 'PCK', 'AIR PACK EXPRESS                                      ', 'AIR PACK EXPRESS                                      ');
INSERT INTO airline_alias VALUES ('5P ', 'PCP', 'AEROLINEA PRINCIPAL CHILE                             ', 'AEROLINEA PRINCIPAL CHILE                             ');
INSERT INTO airline_alias VALUES ('   ', 'PDD', 'CONOCOPHILLIPS ALASKA INC.                            ', 'CONOCOPHILLIPS ALASKA INC.                            ');
INSERT INTO airline_alias VALUES ('US ', 'PDT', 'PIEDMONT AIRLINES [MD-USA]                            ', 'PIEDMONT AIRLINES [MD-USA]                            ');
INSERT INTO airline_alias VALUES ('   ', 'PDX', 'PACKAGE DELIVERY EXPRESS                              ', 'PACKAGE DELIVERY EXPRESS                              ');
INSERT INTO airline_alias VALUES ('   ', 'PEA', 'PAN EUROPEENNE AIR SERVICE                            ', 'PAN EUROPEENNE AIR SERVICE                            ');
INSERT INTO airline_alias VALUES ('   ', 'PEO', 'PETRO AIR                                             ', 'PETRO AIR                                             ');
INSERT INTO airline_alias VALUES ('5P ', 'PEP', 'PENTA                                                 ', 'PENTA                                                 ');
INSERT INTO airline_alias VALUES ('   ', 'PEV', 'AIRSEA LINES                                          ', 'AIRSEA LINES                                          ');
INSERT INTO airline_alias VALUES ('   ', 'PFA', 'PACIFIC FLIGHT SERVICES                               ', 'PACIFIC FLIGHT SERVICES                               ');
INSERT INTO airline_alias VALUES ('PI ', 'PFL', 'PACIFIC FLIER                                         ', 'PACIFIC FLIER                                         ');
INSERT INTO airline_alias VALUES ('   ', 'PFT', 'PRO FREIGHT CARGO SERVICES INC.                       ', 'PRO FREIGHT CARGO SERVICES INC.                       ');
INSERT INTO airline_alias VALUES ('P0 ', 'PFZ', 'PROFLIGHT COMMUTER SERVICES                           ', 'PROFLIGHT COMMUTER SERVICES                           ');
INSERT INTO airline_alias VALUES ('   ', 'PGX', 'PARAGON AIR EXPRESS                                   ', 'PARAGON AIR EXPRESS                                   ');
INSERT INTO airline_alias VALUES ('   ', 'PHA', 'PHOENIX AIR [USA]                                     ', 'PHOENIX AIR [USA]                                     ');
INSERT INTO airline_alias VALUES ('PE ', 'PHB', 'PHOEBUS APOLLO AVIATION                               ', 'PHOEBUS APOLLO AVIATION                               ');
INSERT INTO airline_alias VALUES ('   ', 'PHD', 'DUNCAN AVIATION INC.                                  ', 'DUNCAN AVIATION INC.                                  ');
INSERT INTO airline_alias VALUES ('   ', 'PHE', 'PAWAN HANS HELICOPTERS                                ', 'PAWAN HANS HELICOPTERS                                ');
INSERT INTO airline_alias VALUES ('   ', 'PHM', 'PHI INC.                                              ', 'PHI INC.                                              ');
INSERT INTO airline_alias VALUES ('   ', 'PHN', 'PHOENIX AVIATION [KENYA]                              ', 'PHOENIX AVIATION [KENYA]                              ');
INSERT INTO airline_alias VALUES ('   ', 'PHU', 'PANNON AIR SERVICE                                    ', 'PANNON AIR SERVICE                                    ');
INSERT INTO airline_alias VALUES ('   ', 'PHV', 'PHENIX AVIATION                                       ', 'PHENIX AVIATION                                       ');
INSERT INTO airline_alias VALUES ('2E ', 'PHW', 'AVE.COM                                               ', 'AVE.COM                                               ');
INSERT INTO airline_alias VALUES ('   ', 'PJJ', 'AIRSPEED AVIATION OF OKLAHOMA LLC                     ', 'AIRSPEED AVIATION OF OKLAHOMA LLC                     ');
INSERT INTO airline_alias VALUES ('   ', 'PJR', 'PRESTIGE JET [UAE]                                    ', 'PRESTIGE JET [UAE]                                    ');
INSERT INTO airline_alias VALUES ('P8 ', 'PKW', 'SIERRA WEST AIRLINES                                  ', 'SIERRA WEST AIRLINES                                  ');
INSERT INTO airline_alias VALUES ('   ', 'PKZ', 'PRIME AVIATION JSC                                    ', 'PRIME AVIATION JSC                                    ');
INSERT INTO airline_alias VALUES ('   ', 'PLE', 'PLANAIR ENTERPRISES LTD.                              ', 'PLANAIR ENTERPRISES LTD.                              ');
INSERT INTO airline_alias VALUES ('EB ', 'PLM', 'PULLMANTUR AIR                                        ', 'PULLMANTUR AIR                                        ');
INSERT INTO airline_alias VALUES ('   ', 'PLV', 'PERLA AIRLINES                                        ', 'PERLA AIRLINES                                        ');
INSERT INTO airline_alias VALUES ('   ', 'PLY', 'PUMA LINHAS AEREAS                                    ', 'PUMA LINHAS AEREAS                                    ');
INSERT INTO airline_alias VALUES ('   ', 'PMA', 'PAN-MALAYSIAN AIR TRANSPORT                           ', 'PAN-MALAYSIAN AIR TRANSPORT                           ');
INSERT INTO airline_alias VALUES ('   ', 'PMS', 'PLANEMASTERS LTD.                                     ', 'PLANEMASTERS LTD.                                     ');
INSERT INTO airline_alias VALUES ('I7 ', 'PMW', 'PARAMOUNT AIRWAYS [INDIA]                             ', 'PARAMOUNT AIRWAYS [INDIA]                             ');
INSERT INTO airline_alias VALUES ('   ', 'PNP', 'PINEAPPLE AIR                                         ', 'PINEAPPLE AIR                                         ');
INSERT INTO airline_alias VALUES ('   ', 'PNS', 'PENAS                                                 ', 'PENAS                                                 ');
INSERT INTO airline_alias VALUES ('   ', 'PNT', 'BALMORAL CENTRAL CONTRACTS SA (PTY) LTD.              ', 'BALMORAL CENTRAL CONTRACTS SA (PTY) LTD.              ');
INSERT INTO airline_alias VALUES ('PD ', 'POE', 'REGCO HOLDINGS LTD.                                   ', 'REGCO HOLDINGS LTD.                                   ');
INSERT INTO airline_alias VALUES ('YQ ', 'POT', 'POLET AVIAKOMPANIA                                    ', 'POLET AVIAKOMPANIA                                    ');
INSERT INTO airline_alias VALUES ('   ', 'PPM', 'PACIFIC PEARL AIRWAYS                                 ', 'PACIFIC PEARL AIRWAYS                                 ');
INSERT INTO airline_alias VALUES ('2P ', 'PRB', 'PUERTO RICO AIR MANAGEMENT SERVICES INC.              ', 'PUERTO RICO AIR MANAGEMENT SERVICES INC.              ');
INSERT INTO airline_alias VALUES ('   ', 'PRG', 'AIR PRAGUE                                            ', 'AIR PRAGUE                                            ');
INSERT INTO airline_alias VALUES ('PF ', 'PRI', 'PRIMERA AIR SCANDINAVIA                               ', 'PRIMERA AIR SCANDINAVIA                               ');
INSERT INTO airline_alias VALUES ('   ', 'PRJ', 'PRONAIR AIRLINES                                      ', 'PRONAIR AIRLINES                                      ');
INSERT INTO airline_alias VALUES ('   ', 'PRN', 'PIRINAIR EXPRESS                                      ', 'PIRINAIR EXPRESS                                      ');
INSERT INTO airline_alias VALUES ('   ', 'PRO', 'PROPAIR                                               ', 'PROPAIR                                               ');
INSERT INTO airline_alias VALUES ('   ', 'PRY', 'PRIORITY AIR CHARTER LLC                              ', 'PRIORITY AIR CHARTER LLC                              ');
INSERT INTO airline_alias VALUES ('P6 ', 'PSC', 'PASCAN AVIATION                                       ', 'PASCAN AVIATION                                       ');
INSERT INTO airline_alias VALUES ('   ', 'PSK', 'PRESCOTT SUPPORT COMPANY                              ', 'PRESCOTT SUPPORT COMPANY                              ');
INSERT INTO airline_alias VALUES ('   ', 'PST', 'AIR PANAMA                                            ', 'AIR PANAMA                                            ');
INSERT INTO airline_alias VALUES ('P3 ', 'PTB', 'PASSAREDO TRANSPORTES AEREOS                          ', 'PASSAREDO TRANSPORTES AEREOS                          ');
INSERT INTO airline_alias VALUES ('   ', 'PTF', 'PETROFF AIR                                           ', 'PETROFF AIR                                           ');
INSERT INTO airline_alias VALUES ('   ', 'PTG', 'PRIVATAIR [GERMANY]                                   ', 'PRIVATAIR [GERMANY]                                   ');
INSERT INTO airline_alias VALUES ('   ', 'PTI', 'PRIVATAIR [SWITZERLAND]                               ', 'PRIVATAIR [SWITZERLAND]                               ');
INSERT INTO airline_alias VALUES ('   ', 'PTO', 'NORTH WEST GEOMATICS LTD.                             ', 'NORTH WEST GEOMATICS LTD.                             ');
INSERT INTO airline_alias VALUES ('   ', 'PTR', 'PETRA AIRLINES                                        ', 'PETRA AIRLINES                                        ');
INSERT INTO airline_alias VALUES ('   ', 'PTT', 'PROMOTORA INDUSTRIAL TOTOLAPA S.A.                    ', 'PROMOTORA INDUSTRIAL TOTOLAPA S.A.                    ');
INSERT INTO airline_alias VALUES ('   ', 'PUL', 'ORNGE AIR                                             ', 'ORNGE AIR                                             ');
INSERT INTO airline_alias VALUES ('   ', 'PVG', 'PRIVILEGE STYLE                                       ', 'PRIVILEGE STYLE                                       ');
INSERT INTO airline_alias VALUES ('   ', 'PVJ', 'PRIVAJET LTD.                                         ', 'PRIVAJET LTD.                                         ');
INSERT INTO airline_alias VALUES ('P9 ', 'PVN', 'PERUVIAN AIRLINES                                     ', 'PERUVIAN AIRLINES                                     ');
INSERT INTO airline_alias VALUES ('   ', 'PWC', 'PRATT & WHITNEY CANADA CORPORATION                    ', 'PRATT & WHITNEY CANADA CORPORATION                    ');
INSERT INTO airline_alias VALUES ('7Q ', 'PWD', 'PAN AM WORLD AIRWAYS DOMINICANA                       ', 'PAN AM WORLD AIRWAYS DOMINICANA                       ');
INSERT INTO airline_alias VALUES ('8W ', 'PWF', 'PRIVATE WINGS FLUGCHARTER                             ', 'PRIVATE WINGS FLUGCHARTER                             ');
INSERT INTO airline_alias VALUES ('   ', 'QAJ', 'QUICK AIR JET CHARTER                                 ', 'QUICK AIR JET CHARTER                                 ');
INSERT INTO airline_alias VALUES ('N9 ', 'QNK', 'KABO AIR                                              ', 'KABO AIR                                              ');
INSERT INTO airline_alias VALUES ('QF ', 'QNZ', 'JETCONNECT                                            ', 'JETCONNECT                                            ');
INSERT INTO airline_alias VALUES ('   ', 'QUI', 'AERO QUIMMCO                                          ', 'AERO QUIMMCO                                          ');
INSERT INTO airline_alias VALUES ('QD ', 'QWA', 'PEL-AIR AVIATION                                      ', 'PEL-AIR AVIATION                                      ');
INSERT INTO airline_alias VALUES ('   ', 'QWL', 'QWILA AIR                                             ', 'QWILA AIR                                             ');
INSERT INTO airline_alias VALUES ('   ', 'RAB', 'RAYYAN AIR                                            ', 'RAYYAN AIR                                            ');
INSERT INTO airline_alias VALUES ('   ', 'RAG', 'REGIO-AIR                                             ', 'REGIO-AIR                                             ');
INSERT INTO airline_alias VALUES ('   ', 'RAV', 'ROLLINS AIR                                           ', 'ROLLINS AIR                                           ');
INSERT INTO airline_alias VALUES ('   ', 'RBC', 'REPUBLICAIR                                           ', 'REPUBLICAIR                                           ');
INSERT INTO airline_alias VALUES ('   ', 'RBE', 'AIR RUM                                               ', 'AIR RUM                                               ');
INSERT INTO airline_alias VALUES ('E5 ', 'RBG', 'AIR ARABIA EGYPT                                      ', 'AIR ARABIA EGYPT                                      ');
INSERT INTO airline_alias VALUES ('   ', 'RBV', 'AIR ROBERVAL                                          ', 'AIR ROBERVAL                                          ');
INSERT INTO airline_alias VALUES ('   ', 'RBW', 'SHANDONG AIRLINES RAINBOW JET                         ', 'SHANDONG AIRLINES RAINBOW JET                         ');
INSERT INTO airline_alias VALUES ('   ', 'RCC', 'AIR CHARTERS EUROPE                                   ', 'AIR CHARTERS EUROPE                                   ');
INSERT INTO airline_alias VALUES ('   ', 'RCO', 'AERO RENTA DE COAHUILA                                ', 'AERO RENTA DE COAHUILA                                ');
INSERT INTO airline_alias VALUES ('F2 ', 'RCQ', 'AEROLINEAS REGIONALES                                 ', 'AEROLINEAS REGIONALES                                 ');
INSERT INTO airline_alias VALUES ('7S ', 'RCT', 'ARCTIC TRANSPORTATION SERVICES INC.                   ', 'ARCTIC TRANSPORTATION SERVICES INC.                   ');
INSERT INTO airline_alias VALUES ('   ', 'RDS', 'RHOADES INTERNATIONAL INC.                            ', 'RHOADES INTERNATIONAL INC.                            ');
INSERT INTO airline_alias VALUES ('   ', 'REG', 'REGIONAL AIR SERVICES [TANZANIA]                      ', 'REGIONAL AIR SERVICES [TANZANIA]                      ');
INSERT INTO airline_alias VALUES ('   ', 'REN', 'AERORENT                                              ', 'AERORENT                                              ');
INSERT INTO airline_alias VALUES ('P7 ', 'REP', 'AERO REGIONAL PARAGUAYA                               ', 'AERO REGIONAL PARAGUAYA                               ');
INSERT INTO airline_alias VALUES ('   ', 'REW', 'REGIONAL AIR EXPRESS                                  ', 'REGIONAL AIR EXPRESS                                  ');
INSERT INTO airline_alias VALUES ('RL ', 'RFJ', 'ROYAL FALCON OF JORDAN                                ', 'ROYAL FALCON OF JORDAN                                ');
INSERT INTO airline_alias VALUES ('   ', 'RFL', 'INTERFLY                                              ', 'INTERFLY                                              ');
INSERT INTO airline_alias VALUES ('   ', 'RGB', 'REGIONAL AIR [BAHAMAS]                                ', 'REGIONAL AIR [BAHAMAS]                                ');
INSERT INTO airline_alias VALUES ('   ', 'RGN', 'GESTAIR CARGO                                         ', 'GESTAIR CARGO                                         ');
INSERT INTO airline_alias VALUES ('RH ', 'RHA', 'ROBIN HOOD AVIATION                                   ', 'ROBIN HOOD AVIATION                                   ');
INSERT INTO airline_alias VALUES ('   ', 'RHL', 'AIR ARCHIPELS                                         ', 'AIR ARCHIPELS                                         ');
INSERT INTO airline_alias VALUES ('   ', 'RIO', 'RIO LINHAS AEREAS                                     ', 'RIO LINHAS AEREAS                                     ');
INSERT INTO airline_alias VALUES ('   ', 'RIU', 'RIAU AIRLINES                                         ', 'RIAU AIRLINES                                         ');
INSERT INTO airline_alias VALUES ('RT ', 'RKM', 'RAK AIRWAYS                                           ', 'RAK AIRWAYS                                           ');
INSERT INTO airline_alias VALUES ('RW ', 'RLD', 'RHEINLAND AIR SERVICE                                 ', 'RHEINLAND AIR SERVICE                                 ');
INSERT INTO airline_alias VALUES ('C7 ', 'RLE', 'RICO LINHAS AEREAS                                    ', 'RICO LINHAS AEREAS                                    ');
INSERT INTO airline_alias VALUES ('   ', 'RLK', 'AIR NELSON                                            ', 'AIR NELSON                                            ');
INSERT INTO airline_alias VALUES ('QL ', 'RLN', 'AERO LANKA                                            ', 'AERO LANKA                                            ');
INSERT INTO airline_alias VALUES ('   ', 'RLR', 'AIR NOW                                               ', 'AIR NOW                                               ');
INSERT INTO airline_alias VALUES ('7R ', 'RLU', 'RUSLINE                                               ', 'RUSLINE                                               ');
INSERT INTO airline_alias VALUES ('   ', 'RLY', 'AIR LOYAUTE                                           ', 'AIR LOYAUTE                                           ');
INSERT INTO airline_alias VALUES ('   ', 'RLZ', 'AIR ALIZE                                             ', 'AIR ALIZE                                             ');
INSERT INTO airline_alias VALUES ('   ', 'RMA', 'ROCKY MOUNTAIN HELICOPTERS INC.                       ', 'ROCKY MOUNTAIN HELICOPTERS INC.                       ');
INSERT INTO airline_alias VALUES ('T6 ', 'RNX', '1TIME AIRLINE                                         ', '1TIME AIRLINE                                         ');
INSERT INTO airline_alias VALUES ('   ', 'ROE', 'AEROESTE                                              ', 'AEROESTE                                              ');
INSERT INTO airline_alias VALUES ('   ', 'ROJ', 'ROYAL JET                                             ', 'ROYAL JET                                             ');
INSERT INTO airline_alias VALUES ('   ', 'ROR', 'RORAIMA AIRWAYS                                       ', 'RORAIMA AIRWAYS                                       ');
INSERT INTO airline_alias VALUES ('   ', 'ROX', 'ROBLEX AVIATION                                       ', 'ROBLEX AVIATION                                       ');
INSERT INTO airline_alias VALUES ('   ', 'RPM', 'POLARIS AVIATION SOLUTIONS                            ', 'POLARIS AVIATION SOLUTIONS                            ');
INSERT INTO airline_alias VALUES ('   ', 'RSE', 'SNAS AVIATION                                         ', 'SNAS AVIATION                                         ');
INSERT INTO airline_alias VALUES ('S2 ', 'RSH', 'JET LITE                                              ', 'JET LITE                                              ');
INSERT INTO airline_alias VALUES ('   ', 'RSJ', 'RUSJET                                                ', 'RUSJET                                                ');
INSERT INTO airline_alias VALUES ('   ', 'RSP', 'SUPERIOR AIR CHARTER INC.                             ', 'SUPERIOR AIR CHARTER INC.                             ');
INSERT INTO airline_alias VALUES ('5L ', 'RSU', 'AEROSUR [BOLIVIA]                                     ', 'AEROSUR [BOLIVIA]                                     ');
INSERT INTO airline_alias VALUES ('H5 ', 'RSY', 'I-FLY                                                 ', 'I-FLY                                                 ');
INSERT INTO airline_alias VALUES ('   ', 'RTZ', 'REGIONAL AIR SERVICES [ROMANIA]                       ', 'REGIONAL AIR SERVICES [ROMANIA]                       ');
INSERT INTO airline_alias VALUES ('   ', 'RUC', 'RUTACA                                                ', 'RUTACA                                                ');
INSERT INTO airline_alias VALUES ('   ', 'RUF', 'AIR 1ST AVIATION COMPANY OF OKLAHOMA                  ', 'AIR 1ST AVIATION COMPANY OF OKLAHOMA                  ');
INSERT INTO airline_alias VALUES ('9T ', 'RUN', 'ACT AIRLINES                                          ', 'ACT AIRLINES                                          ');
INSERT INTO airline_alias VALUES ('   ', 'RVP', 'AERO VIP [PORTUGAL]                                   ', 'AERO VIP [PORTUGAL]                                   ');
INSERT INTO airline_alias VALUES ('X7 ', 'RVS', 'AIR SERVICE GABON                                     ', 'AIR SERVICE GABON                                     ');
INSERT INTO airline_alias VALUES ('   ', 'RWG', 'C & M AIRWAYS INC.                                    ', 'C & M AIRWAYS INC.                                    ');
INSERT INTO airline_alias VALUES ('ZL ', 'RXA', 'REGIONAL EXPRESS [AUSTRALIA]                          ', 'REGIONAL EXPRESS [AUSTRALIA]                          ');
INSERT INTO airline_alias VALUES ('AT ', 'RXP', 'ROYAL AIR MAROC EXPRESS                               ', 'ROYAL AIR MAROC EXPRESS                               ');
INSERT INTO airline_alias VALUES ('   ', 'RXX', 'KING AIR CHARTER [SOUTH AFRICA]                       ', 'KING AIR CHARTER [SOUTH AFRICA]                       ');
INSERT INTO airline_alias VALUES ('RY ', 'RYW', 'ROYAL WINGS                                           ', 'ROYAL WINGS                                           ');
INSERT INTO airline_alias VALUES ('   ', 'RZJ', 'RIZON JET                                             ', 'RIZON JET                                             ');
INSERT INTO airline_alias VALUES ('   ', 'RZZ', 'ANOKA AIR CHARTER INC.                                ', 'ANOKA AIR CHARTER INC.                                ');
INSERT INTO airline_alias VALUES ('   ', 'SAG', 'SOS FLYGAMBULANS                                      ', 'SOS FLYGAMBULANS                                      ');
INSERT INTO airline_alias VALUES ('   ', 'SAV', 'SAMAL AIR                                             ', 'SAMAL AIR                                             ');
INSERT INTO airline_alias VALUES ('6Q ', 'SAW', 'CHAM WINGS AIRLINES                                   ', 'CHAM WINGS AIRLINES                                   ');
INSERT INTO airline_alias VALUES ('   ', 'SAX', 'SABAH AIR                                             ', 'SABAH AIR                                             ');
INSERT INTO airline_alias VALUES ('T8 ', 'SBA', 'STA MALI                                              ', 'STA MALI                                              ');
INSERT INTO airline_alias VALUES ('   ', 'SBC', 'EMOYENI AIR CHARTER                                   ', 'EMOYENI AIR CHARTER                                   ');
INSERT INTO airline_alias VALUES ('   ', 'SBF', 'SEVEN BAR FLYING SERVICE                              ', 'SEVEN BAR FLYING SERVICE                              ');
INSERT INTO airline_alias VALUES ('   ', 'SBL', 'SOBEL AIR OF GHANA                                    ', 'SOBEL AIR OF GHANA                                    ');
INSERT INTO airline_alias VALUES ('Q7 ', 'SBM', 'SKY BAHAMAS                                           ', 'SKY BAHAMAS                                           ');
INSERT INTO airline_alias VALUES ('BB ', 'SBS', 'SEABORNE AIRLINES                                     ', 'SEABORNE AIRLINES                                     ');
INSERT INTO airline_alias VALUES ('PV ', 'SBU', 'ST. BARTH COMMUTER                                    ', 'ST. BARTH COMMUTER                                    ');
INSERT INTO airline_alias VALUES ('   ', 'SBX', 'NORTH STAR AIR CARGO                                  ', 'NORTH STAR AIR CARGO                                  ');
INSERT INTO airline_alias VALUES ('   ', 'SBZ', 'SCIBE AIRLIFT CONGO                                   ', 'SCIBE AIRLIFT CONGO                                   ');
INSERT INTO airline_alias VALUES ('   ', 'SCD', 'ASSOCIATED AVIATION LTD.                              ', 'ASSOCIATED AVIATION LTD.                              ');
INSERT INTO airline_alias VALUES ('YR ', 'SCE', 'SCENIC AIRLINES                                       ', 'SCENIC AIRLINES                                       ');
INSERT INTO airline_alias VALUES ('   ', 'SCL', 'SHELL CANADA LTD.                                     ', 'SHELL CANADA LTD.                                     ');
INSERT INTO airline_alias VALUES ('   ', 'SCV', 'SERVICIOS AEREOS DEL CENTRO                           ', 'SERVICIOS AEREOS DEL CENTRO                           ');
INSERT INTO airline_alias VALUES ('   ', 'SCY', 'SCD AVIATION                                          ', 'SCD AVIATION                                          ');
INSERT INTO airline_alias VALUES ('   ', 'SDL', 'SKYDRIFT                                              ', 'SKYDRIFT                                              ');
INSERT INTO airline_alias VALUES ('   ', 'SDP', 'AERO SUDPACIFICO                                      ', 'AERO SUDPACIFICO                                      ');
INSERT INTO airline_alias VALUES ('GQ ', 'SEH', 'SKY EXPRESS [GREECE]                                  ', 'SKY EXPRESS [GREECE]                                  ');
INSERT INTO airline_alias VALUES ('SG ', 'SEJ', 'SPICEJET                                              ', 'SPICEJET                                              ');
INSERT INTO airline_alias VALUES ('UG ', 'SEN', 'SEVENAIR                                              ', 'SEVENAIR                                              ');
INSERT INTO airline_alias VALUES ('   ', 'SEV', 'SERAIR                                                ', 'SERAIR                                                ');
INSERT INTO airline_alias VALUES ('   ', 'SEZ', 'SEC COLOMBIA                                          ', 'SEC COLOMBIA                                          ');
INSERT INTO airline_alias VALUES ('   ', 'SFE', 'SEFOFANE AIR CHARTERS                                 ', 'SEFOFANE AIR CHARTERS                                 ');
INSERT INTO airline_alias VALUES ('7G ', 'SFJ', 'STAR FLYER                                            ', 'STAR FLYER                                            ');
INSERT INTO airline_alias VALUES ('4Q ', 'SFW', 'SAFI AIRWAYS                                          ', 'SAFI AIRWAYS                                          ');
INSERT INTO airline_alias VALUES ('DN ', 'SGG', 'SENEGAL AIRLINES                                      ', 'SENEGAL AIRLINES                                      ');
INSERT INTO airline_alias VALUES ('   ', 'SGL', 'SENEGALAIR                                            ', 'SENEGALAIR                                            ');
INSERT INTO airline_alias VALUES ('H3 ', 'SGX', 'SAGA AIRLINES                                         ', 'SAGA AIRLINES                                         ');
INSERT INTO airline_alias VALUES ('F4 ', 'SHQ', 'SHANGHAI AIRLINES CARGO INTERNATIONAL                 ', 'SHANGHAI AIRLINES CARGO INTERNATIONAL                 ');
INSERT INTO airline_alias VALUES ('ZY ', 'SHY', 'SKY AIRLINES                                          ', 'SKY AIRLINES                                          ');
INSERT INTO airline_alias VALUES ('   ', 'SIK', 'SILVER SKY LINEAS AEREAS                              ', 'SILVER SKY LINEAS AEREAS                              ');
INSERT INTO airline_alias VALUES ('   ', 'SIW', 'SIRIO EXECUTIVE                                       ', 'SIRIO EXECUTIVE                                       ');
INSERT INTO airline_alias VALUES ('UQ ', 'SJA', 'SKYJET AVIATION UGANDA                                ', 'SKYJET AVIATION UGANDA                                ');
INSERT INTO airline_alias VALUES ('   ', 'SJT', 'SWISS JET                                             ', 'SWISS JET                                             ');
INSERT INTO airline_alias VALUES ('SJ ', 'SJY', 'SRIWIJAYA AIR                                         ', 'SRIWIJAYA AIR                                         ');
INSERT INTO airline_alias VALUES ('   ', 'SKA', 'SKYLAN AIRWAYS                                        ', 'SKYLAN AIRWAYS                                        ');
INSERT INTO airline_alias VALUES ('SX ', 'SKB', 'SKYBUS AIRLINES [OH-USA]                              ', 'SKYBUS AIRLINES [OH-USA]                              ');
INSERT INTO airline_alias VALUES ('   ', 'SKC', 'SKYMASTER AIRLINES                                    ', 'SKYMASTER AIRLINES                                    ');
INSERT INTO airline_alias VALUES ('   ', 'SKG', 'SKY GABON                                             ', 'SKY GABON                                             ');
INSERT INTO airline_alias VALUES ('KP ', 'SKK', 'ASKY AIRLINES                                         ', 'ASKY AIRLINES                                         ');
INSERT INTO airline_alias VALUES ('Q6 ', 'SKP', 'SKYTRANS                                              ', 'SKYTRANS                                              ');
INSERT INTO airline_alias VALUES ('   ', 'SKS', 'SKY-SERVICE                                           ', 'SKY-SERVICE                                           ');
INSERT INTO airline_alias VALUES ('   ', 'SKZ', 'SKY WAY ENTERPRISES INC.                              ', 'SKY WAY ENTERPRISES INC.                              ');
INSERT INTO airline_alias VALUES ('SO ', 'SLC', 'SALSA D''HAITI                                         ', 'SALSA D''HAITI                                         ');
INSERT INTO airline_alias VALUES ('   ', 'SLQ', 'SKYLINK EXPRESS                                       ', 'SKYLINK EXPRESS                                       ');
INSERT INTO airline_alias VALUES ('   ', 'SLX', 'SETE LINHAS AEREAS                                    ', 'SETE LINHAS AEREAS                                    ');
INSERT INTO airline_alias VALUES ('   ', 'SMC', 'SABANG MERAUKE RAYA AIR CHARTER                       ', 'SABANG MERAUKE RAYA AIR CHARTER                       ');
INSERT INTO airline_alias VALUES ('   ', 'SME', 'SMART AVIATION [EGYPT]                                ', 'SMART AVIATION [EGYPT]                                ');
INSERT INTO airline_alias VALUES ('Z3 ', 'SMJ', 'AVIENT AVIATION                                       ', 'AVIENT AVIATION                                       ');
INSERT INTO airline_alias VALUES ('E8 ', 'SMK', 'SEMEYAVIA                                             ', 'SEMEYAVIA                                             ');
INSERT INTO airline_alias VALUES ('4J ', 'SMR', 'SOMON AIR                                             ', 'SOMON AIR                                             ');
INSERT INTO airline_alias VALUES ('   ', 'SND', 'SKYTRADERS                                            ', 'SKYTRADERS                                            ');
INSERT INTO airline_alias VALUES ('   ', 'SNQ', 'SUN QUEST EXECUTIVE AIR CHARTER                       ', 'SUN QUEST EXECUTIVE AIR CHARTER                       ');
INSERT INTO airline_alias VALUES ('S6 ', 'SNR', 'SUN AIR [SUDAN]                                       ', 'SUN AIR [SUDAN]                                       ');
INSERT INTO airline_alias VALUES ('   ', 'SNX', 'AIR SWEDEN                                            ', 'AIR SWEDEN                                            ');
INSERT INTO airline_alias VALUES ('PL ', 'SOA', 'SOUTHERN AIR CHARTER                                  ', 'SOUTHERN AIR CHARTER                                  ');
INSERT INTO airline_alias VALUES ('   ', 'SOP', 'SOLINAIR                                              ', 'SOLINAIR                                              ');
INSERT INTO airline_alias VALUES ('   ', 'SOR', 'SONAIR                                                ', 'SONAIR                                                ');
INSERT INTO airline_alias VALUES ('   ', 'SOX', 'SOLID-AIR                                             ', 'SOLID-AIR                                             ');
INSERT INTO airline_alias VALUES ('   ', 'SOY', 'ISLAND AVIATION [PHILIPPINES]                         ', 'ISLAND AVIATION [PHILIPPINES]                         ');
INSERT INTO airline_alias VALUES ('   ', 'SOZ', 'JET AIRLINES                                          ', 'JET AIRLINES                                          ');
INSERT INTO airline_alias VALUES ('SI ', 'SPA', 'SIERRA PACIFIC AIRLINES                               ', 'SIERRA PACIFIC AIRLINES                               ');
INSERT INTO airline_alias VALUES ('   ', 'SPB', 'LOCH LOMOND SEAPLANES                                 ', 'LOCH LOMOND SEAPLANES                                 ');
INSERT INTO airline_alias VALUES ('PB ', 'SPR', 'PROVINCIAL AIRLINES                                   ', 'PROVINCIAL AIRLINES                                   ');
INSERT INTO airline_alias VALUES ('   ', 'SPU', 'SOUTHEAST AIRMOTIVE CORPORATION                       ', 'SOUTHEAST AIRMOTIVE CORPORATION                       ');
INSERT INTO airline_alias VALUES ('SQ ', 'SQC', 'SINGAPORE AIRLINES CARGO                              ', 'SINGAPORE AIRLINES CARGO                              ');
INSERT INTO airline_alias VALUES ('K5 ', 'SQH', 'WINGS OF ALASKA                                       ', 'WINGS OF ALASKA                                       ');
INSERT INTO airline_alias VALUES ('   ', 'SQS', 'SUSI AIR                                              ', 'SUSI AIR                                              ');
INSERT INTO airline_alias VALUES ('   ', 'SRB', 'SOLAR AVIATION COMPANY                                ', 'SOLAR AVIATION COMPANY                                ');
INSERT INTO airline_alias VALUES ('   ', 'SRC', 'SERVICIOS AERO DE CAPURGANA (SEARCA)                  ', 'SERVICIOS AERO DE CAPURGANA (SEARCA)                  ');
INSERT INTO airline_alias VALUES ('   ', 'SRI', 'AIR SAFARIS & SERVICES                                ', 'AIR SAFARIS & SERVICES                                ');
INSERT INTO airline_alias VALUES ('SX ', 'SRK', 'SKY WORK                                              ', 'SKY WORK                                              ');
INSERT INTO airline_alias VALUES ('   ', 'SRN', 'SPRINTAIR                                             ', 'SPRINTAIR                                             ');
INSERT INTO airline_alias VALUES ('MZ ', 'SRO', 'SERVICIOS AEREOS EJECUTIVOS SAEREO                    ', 'SERVICIOS AEREOS EJECUTIVOS SAEREO                    ');
INSERT INTO airline_alias VALUES ('S6 ', 'SRR', 'STAR AIR [DENMARK]                                    ', 'STAR AIR [DENMARK]                                    ');
INSERT INTO airline_alias VALUES ('2I ', 'SRU', 'STAR UP                                               ', 'STAR UP                                               ');
INSERT INTO airline_alias VALUES ('   ', 'SSN', 'AIRQUARIUS AIR CHARTER                                ', 'AIRQUARIUS AIR CHARTER                                ');
INSERT INTO airline_alias VALUES ('   ', 'SSQ', 'SUNSTATE AIRLINES                                     ', 'SUNSTATE AIRLINES                                     ');
INSERT INTO airline_alias VALUES ('   ', 'SSU', 'SERVICIOS AEREOS SUCRE                                ', 'SERVICIOS AEREOS SUCRE                                ');
INSERT INTO airline_alias VALUES ('L3 ', 'SSX', 'LYNX AVIATION                                         ', 'LYNX AVIATION                                         ');
INSERT INTO airline_alias VALUES ('   ', 'SSZ', 'SPECSAVERS INTERNATIONAL HEALTHCARE LTD.              ', 'SPECSAVERS INTERNATIONAL HEALTHCARE LTD.              ');
INSERT INTO airline_alias VALUES ('4S ', 'STB', 'STAR AIRWAYS [ALBANIA]                                ', 'STAR AIRWAYS [ALBANIA]                                ');
INSERT INTO airline_alias VALUES ('   ', 'STM', 'STAR AIRLINES [MACEDONIA]                             ', 'STAR AIRLINES [MACEDONIA]                             ');
INSERT INTO airline_alias VALUES ('   ', 'STR', 'SOLITAIRE AIR                                         ', 'SOLITAIRE AIR                                         ');
INSERT INTO airline_alias VALUES ('   ', 'STX', 'STARS AWAY AVIATION                                   ', 'STARS AWAY AVIATION                                   ');
INSERT INTO airline_alias VALUES ('   ', 'STZ', 'STRATEGIC AIRLINES [FRANCE]                           ', 'STRATEGIC AIRLINES [FRANCE]                           ');
INSERT INTO airline_alias VALUES ('   ', 'SUB', 'SUBURBAN AIR FREIGHT                                  ', 'SUBURBAN AIR FREIGHT                                  ');
INSERT INTO airline_alias VALUES ('ZS ', 'SVB', 'SAMA AIRWAYS                                          ', 'SAMA AIRWAYS                                          ');
INSERT INTO airline_alias VALUES ('   ', 'SVD', 'SVG AIR                                               ', 'SVG AIR                                               ');
INSERT INTO airline_alias VALUES ('   ', 'SVW', 'GLOBAL JET LUXEMBOURG                                 ', 'GLOBAL JET LUXEMBOURG                                 ');
INSERT INTO airline_alias VALUES ('   ', 'SVX', 'SECURITY AVIATION INC.                                ', 'SECURITY AVIATION INC.                                ');
INSERT INTO airline_alias VALUES ('WG ', 'SWG', 'SUNWING AIRLINES                                      ', 'SUNWING AIRLINES                                      ');
INSERT INTO airline_alias VALUES ('   ', 'SWH', 'ADLER AVIATION                                        ', 'ADLER AVIATION                                        ');
INSERT INTO airline_alias VALUES ('7J ', 'SWT', 'SWIFTAIR [SPAIN]                                      ', 'SWIFTAIR [SPAIN]                                      ');
INSERT INTO airline_alias VALUES ('LX ', 'SWU', 'SWISS EUROPEAN AIR LINES                              ', 'SWISS EUROPEAN AIR LINES                              ');
INSERT INTO airline_alias VALUES ('   ', 'SXN', 'SAXONAIR LTD.                                         ', 'SAXONAIR LTD.                                         ');
INSERT INTO airline_alias VALUES ('   ', 'SXP', 'SOUTH PACIFIC EXPRESS                                 ', 'SOUTH PACIFIC EXPRESS                                 ');
INSERT INTO airline_alias VALUES ('XW ', 'SXR', 'SKYEXPRESS                                            ', 'SKYEXPRESS                                            ');
INSERT INTO airline_alias VALUES ('   ', 'SYB', 'SKYSERVICE BUSINESS AVIATION                          ', 'SKYSERVICE BUSINESS AVIATION                          ');
INSERT INTO airline_alias VALUES ('   ', 'SYG', 'SYNERGY AVIATION                                      ', 'SYNERGY AVIATION                                      ');
INSERT INTO airline_alias VALUES ('   ', 'SYV', 'SPECIAL AVIATION SYSTEMS INC.                         ', 'SPECIAL AVIATION SYSTEMS INC.                         ');
INSERT INTO airline_alias VALUES ('   ', 'SZL', 'AIRLINK SWAZILAND                                     ', 'AIRLINK SWAZILAND                                     ');
INSERT INTO airline_alias VALUES ('   ', 'TAA', 'AEROSERVICIOS DE LA COSTA                             ', 'AEROSERVICIOS DE LA COSTA                             ');
INSERT INTO airline_alias VALUES ('QE ', 'TAH', 'AIR MOOREA                                            ', 'AIR MOOREA                                            ');
INSERT INTO airline_alias VALUES ('   ', 'TAJ', 'TUNISAVIA                                             ', 'TUNISAVIA                                             ');
INSERT INTO airline_alias VALUES ('U9 ', 'TAK', 'TATARSTAN AIRCOMPANY                                  ', 'TATARSTAN AIRCOMPANY                                  ');
INSERT INTO airline_alias VALUES ('JJ ', 'TAM', 'TAM LINHAS AEREAS                                     ', 'TAM LINHAS AEREAS                                     ');
INSERT INTO airline_alias VALUES ('B4 ', 'TAN', 'ZANAIR                                                ', 'ZANAIR                                                ');
INSERT INTO airline_alias VALUES ('   ', 'TBA', 'TIBET AIRLINES                                        ', 'TIBET AIRLINES                                        ');
INSERT INTO airline_alias VALUES ('HH ', 'TBM', 'TABAN AIR LINES                                       ', 'TABAN AIR LINES                                       ');
INSERT INTO airline_alias VALUES ('   ', 'TBT', 'TOMBOUCTOU AVIATION                                   ', 'TOMBOUCTOU AVIATION                                   ');
INSERT INTO airline_alias VALUES ('I3 ', 'TBZ', 'ATA AIRLINES [IRAN]                                   ', 'ATA AIRLINES [IRAN]                                   ');
INSERT INTO airline_alias VALUES ('TT ', 'TCJ', 'TRANSPORTES CHARTER DO BRASIL                         ', 'TRANSPORTES CHARTER DO BRASIL                         ');
INSERT INTO airline_alias VALUES ('PH ', 'TDK', 'TRANSAVIA DENMARK                                     ', 'TRANSAVIA DENMARK                                     ');
INSERT INTO airline_alias VALUES ('8P ', 'TDR', 'TRADE AIR                                             ', 'TRADE AIR                                             ');
INSERT INTO airline_alias VALUES ('WI ', 'TDX', 'TRADEWINDS AIRLINES [NC-USA]                          ', 'TRADEWINDS AIRLINES [NC-USA]                          ');
INSERT INTO airline_alias VALUES ('   ', 'TEA', 'EXECUTIVE TURBINE AIR CHARTER                         ', 'EXECUTIVE TURBINE AIR CHARTER                         ');
INSERT INTO airline_alias VALUES ('   ', 'TEJ', 'AERO JET [ANGOLA]                                     ', 'AERO JET [ANGOLA]                                     ');
INSERT INTO airline_alias VALUES ('   ', 'TEL', 'TELFORD AVIATION INC.                                 ', 'TELFORD AVIATION INC.                                 ');
INSERT INTO airline_alias VALUES ('   ', 'TFK', 'TRANSAFRIK INTERNATIONAL                              ', 'TRANSAFRIK INTERNATIONAL                              ');
INSERT INTO airline_alias VALUES ('OR ', 'TFL', 'TUI AIRLINES NEDERLAND                                ', 'TUI AIRLINES NEDERLAND                                ');
INSERT INTO airline_alias VALUES ('   ', 'TFO', 'TRANSPORTES AEREO DEL PACIFICO                        ', 'TRANSPORTES AEREO DEL PACIFICO                        ');
INSERT INTO airline_alias VALUES ('   ', 'TFR', 'TOLL PRIORITY                                         ', 'TOLL PRIORITY                                         ');
INSERT INTO airline_alias VALUES ('TF ', 'TFT', 'THAI FLYING SERVICE                                   ', 'THAI FLYING SERVICE                                   ');
INSERT INTO airline_alias VALUES ('   ', 'TFX', 'TOLL AVIATION                                         ', 'TOLL AVIATION                                         ');
INSERT INTO airline_alias VALUES ('   ', 'TGN', 'TRIGANA AIR SERVICE                                   ', 'TRIGANA AIR SERVICE                                   ');
INSERT INTO airline_alias VALUES ('   ', 'TGT', 'SAAB NYGE AERO AB                                     ', 'SAAB NYGE AERO AB                                     ');
INSERT INTO airline_alias VALUES ('   ', 'TGU', 'TRANSPORTES AEREOS GUATEMALTECOS                      ', 'TRANSPORTES AEREOS GUATEMALTECOS                      ');
INSERT INTO airline_alias VALUES ('   ', 'TGY', 'TRANS GUYANA AIRWAYS                                  ', 'TRANS GUYANA AIRWAYS                                  ');
INSERT INTO airline_alias VALUES ('   ', 'THC', 'TAR HEEL AVIATION INC.                                ', 'TAR HEEL AVIATION INC.                                ');
INSERT INTO airline_alias VALUES ('   ', 'THD', 'JETPORT                                               ', 'JETPORT                                               ');
INSERT INTO airline_alias VALUES ('9D ', 'THE', 'TOUMAI AIR TCHAD                                      ', 'TOUMAI AIR TCHAD                                      ');
INSERT INTO airline_alias VALUES ('   ', 'THK', 'TURK HAVA KURUMU                                      ', 'TURK HAVA KURUMU                                      ');
INSERT INTO airline_alias VALUES ('   ', 'THU', 'THUNDER AIRLINES                                      ', 'THUNDER AIRLINES                                      ');
INSERT INTO airline_alias VALUES ('   ', 'THZ', 'TRANS HELICOPTERE SERVICE                             ', 'TRANS HELICOPTERE SERVICE                             ');
INSERT INTO airline_alias VALUES ('T4 ', 'TIB', 'TRIP LINHAS AEREAS                                    ', 'TRIP LINHAS AEREAS                                    ');
INSERT INTO airline_alias VALUES ('   ', 'TIE', 'TIME AIR                                              ', 'TIME AIR                                              ');
INSERT INTO airline_alias VALUES ('   ', 'TIH', 'ION TIRIAC AIR                                        ', 'ION TIRIAC AIR                                        ');
INSERT INTO airline_alias VALUES ('VY ', 'TIP', 'C & M AVIATION                                        ', 'C & M AVIATION                                        ');
INSERT INTO airline_alias VALUES ('T9 ', 'TIW', 'TRANSCARGA INTERNATIONAL AIRWAYS                      ', 'TRANSCARGA INTERNATIONAL AIRWAYS                      ');
INSERT INTO airline_alias VALUES ('   ', 'TJS', 'TYROLEAN JET SERVICE                                  ', 'TYROLEAN JET SERVICE                                  ');
INSERT INTO airline_alias VALUES ('   ', 'TKW', 'SAMSUNG TECHWIN COMPANY LTD.                          ', 'SAMSUNG TECHWIN COMPANY LTD.                          ');
INSERT INTO airline_alias VALUES ('   ', 'TLB', 'ATLANTIQUE AIR ASSISTANCE                             ', 'ATLANTIQUE AIR ASSISTANCE                             ');
INSERT INTO airline_alias VALUES ('   ', 'TLI', 'EUROPEAN AIR SERVICES LTD.                            ', 'EUROPEAN AIR SERVICES LTD.                            ');
INSERT INTO airline_alias VALUES ('   ', 'TLY', 'TOP FLY                                               ', 'TOP FLY                                               ');
INSERT INTO airline_alias VALUES ('   ', 'TMI', 'TAMIR AIRWAYS                                         ', 'TAMIR AIRWAYS                                         ');
INSERT INTO airline_alias VALUES ('   ', 'TMW', 'TRANS MALDIVIAN AIRWAYS                               ', 'TRANS MALDIVIAN AIRWAYS                               ');
INSERT INTO airline_alias VALUES ('3P ', 'TNM', 'TIARA AIR                                             ', 'TIARA AIR                                             ');
INSERT INTO airline_alias VALUES ('   ', 'TNV', 'TRANSNORTHERN AVIATION                                ', 'TRANSNORTHERN AVIATION                                ');
INSERT INTO airline_alias VALUES ('CG ', 'TOK', 'AIRLINES OF PAPUA NEW GUINEA                          ', 'AIRLINES OF PAPUA NEW GUINEA                          ');
INSERT INTO airline_alias VALUES ('   ', 'TOM', 'THOMSON AIRWAYS                                       ', 'THOMSON AIRWAYS                                       ');
INSERT INTO airline_alias VALUES ('   ', 'TPN', 'TRANSPORTACION AEREA DEL NORTE                        ', 'TRANSPORTACION AEREA DEL NORTE                        ');
INSERT INTO airline_alias VALUES ('   ', 'TPQ', 'TROPIC AIRLINES                                       ', 'TROPIC AIRLINES                                       ');
INSERT INTO airline_alias VALUES ('   ', 'TRF', 'TAXI AIR FRET                                         ', 'TAXI AIR FRET                                         ');
INSERT INTO airline_alias VALUES ('   ', 'TRG', 'EMPRESA DE TRANSFORMACION AGRARIA S.A.                ', 'EMPRESA DE TRANSFORMACION AGRARIA S.A.                ');
INSERT INTO airline_alias VALUES ('   ', 'TRK', 'TURKUAZ AIRLINES                                      ', 'TURKUAZ AIRLINES                                      ');
INSERT INTO airline_alias VALUES ('   ', 'TRN', 'SERVICIOS AEREOS CORPORATIVOS                         ', 'SERVICIOS AEREOS CORPORATIVOS                         ');
INSERT INTO airline_alias VALUES ('R9 ', 'TSD', 'TAF LINHAS AEREAS                                     ', 'TAF LINHAS AEREAS                                     ');
INSERT INTO airline_alias VALUES ('   ', 'TSH', 'REGIONAL 1 AIRLINES                                   ', 'REGIONAL 1 AIRLINES                                   ');
INSERT INTO airline_alias VALUES ('S5 ', 'TSJ', 'TRAST AERO                                            ', 'TRAST AERO                                            ');
INSERT INTO airline_alias VALUES ('9O ', 'TSP', 'TRANSPORTES AEREOS INTER                              ', 'TRANSPORTES AEREOS INTER                              ');
INSERT INTO airline_alias VALUES ('   ', 'TSR', 'TRANS SERVICE AIRLIFT                                 ', 'TRANS SERVICE AIRLIFT                                 ');
INSERT INTO airline_alias VALUES ('   ', 'TSW', 'TRANSWING                                             ', 'TRANSWING                                             ');
INSERT INTO airline_alias VALUES ('   ', 'TSY', 'TRISTAR AIR                                           ', 'TRISTAR AIR                                           ');
INSERT INTO airline_alias VALUES ('2Z ', 'TTA', 'TRANSPORTE E TRABALHO AEREO                           ', 'TRANSPORTE E TRABALHO AEREO                           ');
INSERT INTO airline_alias VALUES ('   ', 'TTE', 'AVCENTER INC.                                         ', 'AVCENTER INC.                                         ');
INSERT INTO airline_alias VALUES ('   ', 'TTL', 'TOTAL LINHAS AEREAS                                   ', 'TOTAL LINHAS AEREAS                                   ');
INSERT INTO airline_alias VALUES ('TO ', 'TVF', 'TRANSAVIA FRANCE                                      ', 'TRANSAVIA FRANCE                                      ');
INSERT INTO airline_alias VALUES ('   ', 'TVL', 'TRAVEL SERVICE HUNGARY                                ', 'TRAVEL SERVICE HUNGARY                                ');
INSERT INTO airline_alias VALUES ('   ', 'TVV', 'TRAVIRA AIR                                           ', 'TRAVIRA AIR                                           ');
INSERT INTO airline_alias VALUES ('TW ', 'TWB', 'T''WAY AIR                                             ', 'T''WAY AIR                                             ');
INSERT INTO airline_alias VALUES ('   ', 'TWD', 'WINGS AVIATION                                        ', 'WINGS AVIATION                                        ');
INSERT INTO airline_alias VALUES ('   ', 'TWE', 'TRANSWEDE AIRWAYS                                     ', 'TRANSWEDE AIRWAYS                                     ');
INSERT INTO airline_alias VALUES ('TZ ', 'TWG', 'AIR-TAXI EUROPE                                       ', 'AIR-TAXI EUROPE                                       ');
INSERT INTO airline_alias VALUES ('TI ', 'TWI', 'TAILWIND HAVA YOLLARI                                 ', 'TAILWIND HAVA YOLLARI                                 ');
INSERT INTO airline_alias VALUES ('   ', 'TWJ', 'TWINJET AIRCRAFT                                      ', 'TWINJET AIRCRAFT                                      ');
INSERT INTO airline_alias VALUES ('   ', 'TWM', 'TRANSAIRWAYS                                          ', 'TRANSAIRWAYS                                          ');
INSERT INTO airline_alias VALUES ('   ', 'TWR', 'TRANSWORLD AIRFREIGHTERS COMPANY                      ', 'TRANSWORLD AIRFREIGHTERS COMPANY                      ');
INSERT INTO airline_alias VALUES ('   ', 'TWT', 'TRANSWISATA PRIMA AVIATION                            ', 'TRANSWISATA PRIMA AVIATION                            ');
INSERT INTO airline_alias VALUES ('Y7 ', 'TYA', 'AIRLINE TAJMYR                                        ', 'AIRLINE TAJMYR                                        ');
INSERT INTO airline_alias VALUES ('7J ', 'TZK', 'TAJIKISTAN AIRLINES                                   ', 'TAJIKISTAN AIRLINES                                   ');
INSERT INTO airline_alias VALUES ('   ', 'UAR', 'AEROSTAR                                              ', 'AEROSTAR                                              ');
INSERT INTO airline_alias VALUES ('4H ', 'UBD', 'UNITED AIRWAYS                                        ', 'UNITED AIRWAYS                                        ');
INSERT INTO airline_alias VALUES ('   ', 'UCC', 'UGANDA AIR CARGO                                      ', 'UGANDA AIR CARGO                                      ');
INSERT INTO airline_alias VALUES ('EU ', 'UEA', 'CHENGDU AIRLINES                                      ', 'CHENGDU AIRLINES                                      ');
INSERT INTO airline_alias VALUES ('U7 ', 'UGB', 'AIR UGANDA                                            ', 'AIR UGANDA                                            ');
INSERT INTO airline_alias VALUES ('   ', 'UGC', 'URGEMER CANARIAS                                      ', 'URGEMER CANARIAS                                      ');
INSERT INTO airline_alias VALUES ('   ', 'UKO', 'YUKOS PETROLEUM                                       ', 'YUKOS PETROLEUM                                       ');
INSERT INTO airline_alias VALUES ('   ', 'UKU', 'SVERDLOVSK 2ND AVIATION ENTERPRISE                    ', 'SVERDLOVSK 2ND AVIATION ENTERPRISE                    ');
INSERT INTO airline_alias VALUES ('   ', 'UNA', 'ASIA UNITED BUSINESS AVIATION                         ', 'ASIA UNITED BUSINESS AVIATION                         ');
INSERT INTO airline_alias VALUES ('UJ ', 'UNS', 'UENSPED PAKET SERVISI                                 ', 'UENSPED PAKET SERVISI                                 ');
INSERT INTO airline_alias VALUES ('6S ', 'URJ', 'STAR AIR AVIATION (PVT) LTD.                          ', 'STAR AIR AVIATION (PVT) LTD.                          ');
INSERT INTO airline_alias VALUES ('   ', 'URX', 'EUREX CARGO                                           ', 'EUREX CARGO                                           ');
INSERT INTO airline_alias VALUES ('UT ', 'UTA', 'UTAIR AVIATION                                        ', 'UTAIR AVIATION                                        ');
INSERT INTO airline_alias VALUES ('QU ', 'UTN', 'UTAIR UKRAINE                                         ', 'UTAIR UKRAINE                                         ');
INSERT INTO airline_alias VALUES ('QQ ', 'UTY', 'ALLIANCE AIRLINES                                     ', 'ALLIANCE AIRLINES                                     ');
INSERT INTO airline_alias VALUES ('   ', 'UVN', 'UNITED AVIATION [KUWAIT]                              ', 'UNITED AVIATION [KUWAIT]                              ');
INSERT INTO airline_alias VALUES ('VC ', 'VAL', 'VOYAGEUR AIRWAYS                                      ', 'VOYAGEUR AIRWAYS                                      ');
INSERT INTO airline_alias VALUES ('VA ', 'VAU', 'V AUSTRALIA                                           ', 'V AUSTRALIA                                           ');
INSERT INTO airline_alias VALUES ('   ', 'VCN', 'EXECUJET EUROPE AG                                    ', 'EXECUJET EUROPE AG                                    ');
INSERT INTO airline_alias VALUES ('J6 ', 'VCR', 'CRUISER LINHAS AEREAS                                 ', 'CRUISER LINHAS AEREAS                                 ');
INSERT INTO airline_alias VALUES ('V0 ', 'VCV', 'CONVIASA                                              ', 'CONVIASA                                              ');
INSERT INTO airline_alias VALUES ('V4 ', 'VEC', 'VENSECAR INTERNACIONAL                                ', 'VENSECAR INTERNACIONAL                                ');
INSERT INTO airline_alias VALUES ('   ', 'VEJ', 'AEROEJECUTIVOS [VENEZUELA]                            ', 'AEROEJECUTIVOS [VENEZUELA]                            ');
INSERT INTO airline_alias VALUES ('   ', 'VEN', 'TRANSPORTE AEREO DE VENEZUELA                         ', 'TRANSPORTE AEREO DE VENEZUELA                         ');
INSERT INTO airline_alias VALUES ('V4 ', 'VES', 'VIEQUES AIR LINK                                      ', 'VIEQUES AIR LINK                                      ');
INSERT INTO airline_alias VALUES ('0V ', 'VFC', 'VIETNAM AIR SERVICE COMPANY                           ', 'VIETNAM AIR SERVICE COMPANY                           ');
INSERT INTO airline_alias VALUES ('   ', 'VGF', 'AEROVISTA GULF EXPRESS                                ', 'AEROVISTA GULF EXPRESS                                ');
INSERT INTO airline_alias VALUES ('   ', 'VGJ', 'VIGO JET                                              ', 'VIGO JET                                              ');
INSERT INTO airline_alias VALUES ('VK ', 'VGN', 'AIR NIGERIA                                           ', 'AIR NIGERIA                                           ');
INSERT INTO airline_alias VALUES ('   ', 'VHM', 'VHM SCHUL- UND CHARTERFLUG                            ', 'VHM SCHUL- UND CHARTERFLUG                            ');
INSERT INTO airline_alias VALUES ('   ', 'VIB', 'VIBROAIR FLUGSERVICE                                  ', 'VIBROAIR FLUGSERVICE                                  ');
INSERT INTO airline_alias VALUES ('   ', 'VIE', 'VIP EMPRESARIAL                                       ', 'VIP EMPRESARIAL                                       ');
INSERT INTO airline_alias VALUES ('4P ', 'VIK', 'VIKING AIRLINES                                       ', 'VIKING AIRLINES                                       ');
INSERT INTO airline_alias VALUES ('   ', 'VIL', 'VI AIR LINK                                           ', 'VI AIR LINK                                           ');
INSERT INTO airline_alias VALUES ('BF ', 'VIN', 'VINCENT AVIATION [AUSTRALIA]                          ', 'VINCENT AVIATION [AUSTRALIA]                          ');
INSERT INTO airline_alias VALUES ('   ', 'VIP', 'TAG AVIATION (UK) LTD.                                ', 'TAG AVIATION (UK) LTD.                                ');
INSERT INTO airline_alias VALUES ('   ', 'VIS', 'VISION AIR INTERNATIONAL                              ', 'VISION AIR INTERNATIONAL                              ');
INSERT INTO airline_alias VALUES ('   ', 'VIT', 'AVIASTAR MANDIRI                                      ', 'AVIASTAR MANDIRI                                      ');
INSERT INTO airline_alias VALUES ('VB ', 'VIV', 'VIVA AEROBUS                                          ', 'VIVA AEROBUS                                          ');
INSERT INTO airline_alias VALUES ('   ', 'VJA', 'VIENNA JET BEDARFSFLUG                                ', 'VIENNA JET BEDARFSFLUG                                ');
INSERT INTO airline_alias VALUES ('   ', 'VJS', 'VISTAJET LUFTFAHRTUNTERNEHMEN                         ', 'VISTAJET LUFTFAHRTUNTERNEHMEN                         ');
INSERT INTO airline_alias VALUES ('VQ ', 'VKH', 'VIKING HELLAS AVIATION                                ', 'VIKING HELLAS AVIATION                                ');
INSERT INTO airline_alias VALUES ('   ', 'VLJ', 'LA BAULE AVIATION                                     ', 'LA BAULE AVIATION                                     ');
INSERT INTO airline_alias VALUES ('   ', 'VMP', 'EXECUJET EUROPE                                       ', 'EXECUJET EUROPE                                       ');
INSERT INTO airline_alias VALUES ('   ', 'VNE', 'VENEZOLANA LINEA AEREA BOLIVARIANA                    ', 'VENEZOLANA LINEA AEREA BOLIVARIANA                    ');
INSERT INTO airline_alias VALUES ('AO ', 'VNV', 'AVIANOVA [RUSSIA]                                     ', 'AVIANOVA [RUSSIA]                                     ');
INSERT INTO airline_alias VALUES ('V6 ', 'VOG', 'VOYAGER AIRLINES                                      ', 'VOYAGER AIRLINES                                      ');
INSERT INTO airline_alias VALUES ('Y4 ', 'VOI', 'VOLARIS                                               ', 'VOLARIS                                               ');
INSERT INTO airline_alias VALUES ('   ', 'VOS', 'ROVOS AIR                                             ', 'ROVOS AIR                                             ');
INSERT INTO airline_alias VALUES ('V5 ', 'VPA', 'DANUBE WINGS                                          ', 'DANUBE WINGS                                          ');
INSERT INTO airline_alias VALUES ('   ', 'VRB', 'SILVERBACK CARGO FREIGHTERS                           ', 'SILVERBACK CARGO FREIGHTERS                           ');
INSERT INTO airline_alias VALUES ('VX ', 'VRD', 'VIRGIN AMERICA                                        ', 'VIRGIN AMERICA                                        ');
INSERT INTO airline_alias VALUES ('   ', 'VRT', 'AVERITT AIR CHARTER INC.                              ', 'AVERITT AIR CHARTER INC.                              ');
INSERT INTO airline_alias VALUES ('   ', 'VRZ', 'VERTIR AIRLINES OF ARMENIA                            ', 'VERTIR AIRLINES OF ARMENIA                            ');
INSERT INTO airline_alias VALUES ('   ', 'VSR', 'AVIOSTART                                             ', 'AVIOSTART                                             ');
INSERT INTO airline_alias VALUES ('   ', 'VTE', 'CORPORATE FLIGHT [TN-USA]                             ', 'CORPORATE FLIGHT [TN-USA]                             ');
INSERT INTO airline_alias VALUES ('   ', 'VTF', 'VETERAN AIRLINE                                       ', 'VETERAN AIRLINE                                       ');
INSERT INTO airline_alias VALUES ('   ', 'VTM', 'AERONAVES TSM                                         ', 'AERONAVES TSM                                         ');
INSERT INTO airline_alias VALUES ('V6 ', 'VUR', 'VUELOS INTERNOS PRIVADOS (VIP)                        ', 'VUELOS INTERNOS PRIVADOS (VIP)                        ');
INSERT INTO airline_alias VALUES ('ZG ', 'VVM', 'VIVA MACAU                                            ', 'VIVA MACAU                                            ');
INSERT INTO airline_alias VALUES ('   ', 'VXP', 'MALI AIR EXPRESS                                      ', 'MALI AIR EXPRESS                                      ');
INSERT INTO airline_alias VALUES ('   ', 'WAA', 'WESTAIR WINGS CHARTERS                                ', 'WESTAIR WINGS CHARTERS                                ');
INSERT INTO airline_alias VALUES ('   ', 'WAE', 'WESTERN AIR EXPRESS [ID-USA]                          ', 'WESTERN AIR EXPRESS [ID-USA]                          ');
INSERT INTO airline_alias VALUES ('ZQ ', 'WAL', 'WORLD ATLANTIC AIRLINES                               ', 'WORLD ATLANTIC AIRLINES                               ');
INSERT INTO airline_alias VALUES ('KW ', 'WAN', 'WATANIYA AIRWAYS                                      ', 'WATANIYA AIRWAYS                                      ');
INSERT INTO airline_alias VALUES ('   ', 'WAS', 'WALSTEN AIR SERVICE                                   ', 'WALSTEN AIR SERVICE                                   ');
INSERT INTO airline_alias VALUES ('WU ', 'WAU', 'WIZZ AIR UKRAINE                                      ', 'WIZZ AIR UKRAINE                                      ');
INSERT INTO airline_alias VALUES ('   ', 'WBR', 'AIR CHOICE ONE                                        ', 'AIR CHOICE ONE                                        ');
INSERT INTO airline_alias VALUES ('   ', 'WCO', 'COLUMBIA HELICOPTERS INC.                             ', 'COLUMBIA HELICOPTERS INC.                             ');
INSERT INTO airline_alias VALUES ('9C ', 'WDA', 'WIMBI DIRA AIRWAYS                                    ', 'WIMBI DIRA AIRWAYS                                    ');
INSERT INTO airline_alias VALUES ('   ', 'WDL', 'WDL AVIATION                                          ', 'WDL AVIATION                                          ');
INSERT INTO airline_alias VALUES ('   ', 'WDP', 'SCANAVIATION A/S                                      ', 'SCANAVIATION A/S                                      ');
INSERT INTO airline_alias VALUES ('   ', 'WEA', 'WHITE EAGLE AVIATION                                  ', 'WHITE EAGLE AVIATION                                  ');
INSERT INTO airline_alias VALUES ('   ', 'WEB', 'WEBJET LINHAS AEREAS                                  ', 'WEBJET LINHAS AEREAS                                  ');
INSERT INTO airline_alias VALUES ('   ', 'WEW', 'WEST WIND AVIATION                                    ', 'WEST WIND AVIATION                                    ');
INSERT INTO airline_alias VALUES ('AW ', 'WFR', 'ALWAFEER AIR                                          ', 'ALWAFEER AIR                                          ');
INSERT INTO airline_alias VALUES ('   ', 'WGT', 'VOLKSWAGEN AG                                         ', 'VOLKSWAGEN AG                                         ');
INSERT INTO airline_alias VALUES ('   ', 'WHT', 'WHITE AIRWAYS                                         ', 'WHITE AIRWAYS                                         ');
INSERT INTO airline_alias VALUES ('   ', 'WIG', 'WIGGINS AIRWAYS                                       ', 'WIGGINS AIRWAYS                                       ');
INSERT INTO airline_alias VALUES ('   ', 'WLA', 'AIRWAVES AIRLINK                                      ', 'AIRWAVES AIRLINK                                      ');
INSERT INTO airline_alias VALUES ('   ', 'WLB', 'WINGS OF LEBANON                                      ', 'WINGS OF LEBANON                                      ');
INSERT INTO airline_alias VALUES ('   ', 'WLG', 'VOLGA AVIAEXPRESS                                     ', 'VOLGA AVIAEXPRESS                                     ');
INSERT INTO airline_alias VALUES ('   ', 'WLI', 'AIRECON                                               ', 'AIRECON                                               ');
INSERT INTO airline_alias VALUES ('   ', 'WLR', 'AIR WALSER                                            ', 'AIR WALSER                                            ');
INSERT INTO airline_alias VALUES ('   ', 'WLX', 'WEST AIR LUXEMBOURG                                   ', 'WEST AIR LUXEMBOURG                                   ');
INSERT INTO airline_alias VALUES ('   ', 'WNR', 'WONDAIR ON DEMAND AVIATION                            ', 'WONDAIR ON DEMAND AVIATION                            ');
INSERT INTO airline_alias VALUES ('IW ', 'WON', 'WINGS ABADI AIRLINES                                  ', 'WINGS ABADI AIRLINES                                  ');
INSERT INTO airline_alias VALUES ('SZ ', 'WOW', 'AIR SOUTHWEST                                         ', 'AIR SOUTHWEST                                         ');
INSERT INTO airline_alias VALUES ('7W ', 'WRC', 'WIND ROSE                                             ', 'WIND ROSE                                             ');
INSERT INTO airline_alias VALUES ('8V ', 'WRF', 'WRIGHT AIR SERVICE                                    ', 'WRIGHT AIR SERVICE                                    ');
INSERT INTO airline_alias VALUES ('   ', 'WST', 'WESTERN AIR                                           ', 'WESTERN AIR                                           ');
INSERT INTO airline_alias VALUES ('   ', 'WTJ', 'WHITEJETS TRANSPORTES AEREOS                          ', 'WHITEJETS TRANSPORTES AEREOS                          ');
INSERT INTO airline_alias VALUES ('8Z ', 'WVL', 'WIZZ AIR BULGARIA                                     ', 'WIZZ AIR BULGARIA                                     ');
INSERT INTO airline_alias VALUES ('P2 ', 'XAK', 'AIRKENYA                                              ', 'AIRKENYA                                              ');
INSERT INTO airline_alias VALUES ('XN ', 'XAR', 'TRAVEL EXPRESS AVIATION SERVICES                      ', 'TRAVEL EXPRESS AVIATION SERVICES                      ');
INSERT INTO airline_alias VALUES ('D7 ', 'XAX', 'AIRASIA X                                             ', 'AIRASIA X                                             ');
INSERT INTO airline_alias VALUES ('   ', 'XGO', 'AIRGO FLUGSERVICE                                     ', 'AIRGO FLUGSERVICE                                     ');
INSERT INTO airline_alias VALUES ('SE ', 'XLF', 'XL AIRWAYS FRANCE                                     ', 'XL AIRWAYS FRANCE                                     ');
INSERT INTO airline_alias VALUES ('F2 ', 'XLK', 'SAFARILINK AVIATION                                   ', 'SAFARILINK AVIATION                                   ');
INSERT INTO airline_alias VALUES ('   ', 'XLL', 'AIR EXCEL                                             ', 'AIR EXCEL                                             ');
INSERT INTO airline_alias VALUES ('   ', 'XLS', 'EXCELAIRE SERVICE INC.                                ', 'EXCELAIRE SERVICE INC.                                ');
INSERT INTO airline_alias VALUES ('   ', 'XXX', 'AIR SERVICE LIEGE                                     ', 'AIR SERVICE LIEGE                                     ');
INSERT INTO airline_alias VALUES ('   ', 'ZBA', 'BOSKOVIC Z AIR CHARTERS                               ', 'BOSKOVIC Z AIR CHARTERS                               ');
INSERT INTO airline_alias VALUES ('ZJ ', 'ZMA', 'ZAMBEZI AIRLINES                                      ', 'ZAMBEZI AIRLINES                                      ');
INSERT INTO airline_alias VALUES ('XDH', '7KR', 'Kitty Hawk Aircargo, Inc.', 'Kitty Hawk');
INSERT INTO airline_alias VALUES ('GA', 'ELJ', 'Delta Air Elite Business Jets', 'Elite Jet');
INSERT INTO airline_alias VALUES ('GA', 'ELT', 'Elliott Aviation', 'Elliot Aviation');
INSERT INTO airline_alias VALUES ('GA', 'LAK', 'General Mills', 'General Mills');
INSERT INTO airline_alias VALUES ('GA', 'GTW', 'American Air Charter Gateway', 'Gateway');
INSERT INTO airline_alias VALUES ('GA', 'CYO', 'Air Transport El Paso Coyote', 'Coyote');
INSERT INTO airline_alias VALUES ('GA', 'MMD', 'Air Alsie A/s Mermaid', 'Mermaid');
INSERT INTO airline_alias VALUES ('RP', 'CHQ', 'US Airways Express/Chautauqua Airlines (USA)', 'Chautq. Airlines');
INSERT INTO airline_alias VALUES ('GA', 'HRF', 'RBJ INDUSTRIES', 'RBJ Industries, Inc');


--
-- TOC entry 3357 (class 0 OID 128679)
-- Dependencies: 170
-- Data for Name: airportcodes; Type: TABLE DATA; Schema: alias; Owner: postgres
--

INSERT INTO airportcodes VALUES ('ABR', 'ABERDEEN  SOUTH DAKOTA  USA', 'ABERDEEN', 3, 285, '0101000020E6100000000000C0FE9A58C0000000207CB94640', 256.344421, 1);
INSERT INTO airportcodes VALUES ('ALO', 'WATERLOO  IOWA  USA', 'WATERLOO', 6, 160, '0101000020E6100000000000809E1957C0000000004F474540', 165.817581, 1);
INSERT INTO airportcodes VALUES ('ATY', 'WATERTOWN  SOUTH DAKOTA  USA', 'WATERTOWN', 14, 269, '0101000020E6100000000000A0E64958C000000000FE744640', 192.530304, 1);
INSERT INTO airportcodes VALUES ('AZO', 'KALAMAZOO  MICHIGAN  USA', 'KALAMAZOO', 18, 109, '0101000020E6100000000000A0556355C000000040111E4540', 425.196411, 1);
INSERT INTO airportcodes VALUES ('BIS', 'BISMARCK  NORTH DAKOTA  USA', 'BISMARCK', 25, 291, '0101000020E610000000000080BE2F59C0000000E0E7624740', 384.991669, 1);
INSERT INTO airportcodes VALUES ('ILN', 'WILMINGTON  OHIO  USA', 'WILMINGTON', 115, 124, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('GPZ', 'GRAND RAPIDS  MINNESOTA  USA', 'GRAND RAPIDS, MN', 92, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('ABE', 'ALLENTOWN  PENNSYLVANIA  USA', 'ALLENTOWN', 1, NULL, '0101000020E61000000000002036DC52C00000000078534440', 945.975098, 2);
INSERT INTO airportcodes VALUES ('ABQ', 'ALBUQUERQUE  NEW MEXICO  USA', 'ALBUQUERQUE', 2, 226, '0101000020E6100000000000E0F9A65AC00000004025854140', 980.13269, 2);
INSERT INTO airportcodes VALUES ('ALB', 'ALBANY NEW YORK USA', 'ALBANY', 5, 97, '0101000020E6100000000000004F7352C000000040C85F4540', 977.155334, 2);
INSERT INTO airportcodes VALUES ('ATL', 'ATLANTA  GEORGIA  USA', 'ATLANTA', 12, 149, '0101000020E610000000000000661B55C0000000607FD14040', 907.211914, 2);
INSERT INTO airportcodes VALUES ('AVL', 'ASHEVILLE, NORTH CAROLINA', 'ASHEVILLE', 17, 138, '0101000020E6100000000000E0ACA254C000000060D5B74140', 861.187622, 2);
INSERT INTO airportcodes VALUES ('BHM', 'BIRMINGHAM ALABAMA USA', 'BIRMINGHAM', 23, 155, '0101000020E61000000000006039B055C0000000200DC84040', 854.743835, 2);
INSERT INTO airportcodes VALUES ('BIL', 'BILLINGS  MONTANA  USA', 'BILLINGS', 24, 275, '0101000020E610000000000080C0225BC0000000C062E74640', 745.774414, 2);
INSERT INTO airportcodes VALUES ('BNA', 'NASHVILLE  TENNESSEE  USA', 'NASHVILLE', 31, 147, '0101000020E6100000000000A067AB55C0000000A0EF0F4240', 695.497559, 2);
INSERT INTO airportcodes VALUES ('BTR', 'BATON ROUGE LOUISIANNA USA', 'BATON ROUGE', 37, NULL, '0101000020E61000000000000093C956C0000000C07F883E40', 997.968384, 2);
INSERT INTO airportcodes VALUES ('BWI', 'BALTIMORE  MARYLAND  USA', 'BALTIMORE', 41, 112, '0101000020E610000000000060C52A53C00000008073964340', 934.501282, 2);
INSERT INTO airportcodes VALUES ('GSP', 'GREENVILLE\\SPARTANBURG SC USA', 'GREENVILLE\\SPARTANBURG', 97, 141, '0101000020E610000000000080028E54C000000040A6724140', 901.979004, 2);
INSERT INTO airportcodes VALUES ('GTF', 'GREAT FALLS  MONTANA  USA', 'GREAT FALLS', 98, 283, '0101000020E610000000000080BED75BC000000020B2BD4740', 884.639465, 2);
INSERT INTO airportcodes VALUES ('IAD', 'WASHINGTON(DULLES ARPT)', 'WASHINGTON D.C. (DULLES INTL)', 110, 117, '0101000020E6100000000000E02B5D53C000000060E5784340', 906.578918, 2);
INSERT INTO airportcodes VALUES ('AUS', 'AUSTIN  TEXAS  USA', 'AUSTIN', 16, 191, '0101000020E6100000000000A0DF6A58C0000000C0CA313E40', 1043.43945, 3);
INSERT INTO airportcodes VALUES ('BDL', 'HARTFORD CT\\SPRINGFIELD  MA  USA', 'HARTFORD', 19, 101, '0101000020E610000000000080B92B52C0000000E02DF84440', 1047.98608, 3);
INSERT INTO airportcodes VALUES ('BGR', 'BANGOR, MAINE USA', 'BANGOR', 22, 90, '0101000020E6100000000000A0FF3451C0000000E058674640', 1190.74585, 3);
INSERT INTO airportcodes VALUES ('BOI', 'BOISE  IDAHO  USA', 'BOISE', 33, 266, '0101000020E6100000000000A0450E5DC0000000403EC84540', 1138.93555, 3);
INSERT INTO airportcodes VALUES ('BOS', 'BOSTON  MASSACHUSETTS  USA', 'BOSTON', 35, 97, '0101000020E61000000000004055C051C000000060A12E4540', 1121.328, 3);
INSERT INTO airportcodes VALUES ('SRQ', 'SARASOTA\\BRADENTON  FLORIDA  USA', 'SARASOTA\\BRADENTON', 228, NULL, '0101000020E6100000000000407BA354C0000000E038653B40', 1344.34631, 3);
INSERT INTO airportcodes VALUES ('TLH', 'TALLAHASSEE FLORIDA USA', 'TALLAHASSEE', 235, NULL, '0101000020E6100000000000606B1655C00000000081653E40', 1110.91309, 3);
INSERT INTO airportcodes VALUES ('TPA', 'TAMPA\\ST. PETERSBURG  FLORIDA  USA', 'TAMPA ST PETERSBURG', 237, 155, '0101000020E61000000000000020A254C000000060BAF93B40', 1308.11194, 3);
INSERT INTO airportcodes VALUES ('VPS', 'VALPARAISO FLORIDA(EGLIN AFB) USA', 'VALPARAISO', 244, NULL, '0101000020E610000000000020A0A155C000000000B37B3E40', 1059.36548, 3);
INSERT INTO airportcodes VALUES ('YEG', 'EDMONTON  ALBERTA  CANADA', 'EDMONTON', 246, 302, '0101000020E6100000000000C01E655CC000000040A4A74A40', 1084.04761, 3);
INSERT INTO airportcodes VALUES ('YXD', 'EDMONTON  ALBERTA  CANADA', 'EDMONTON', 254, NULL, '0101000020E61000000000002058615CC0000000A047C94A40', 1089.43945, 3);
INSERT INTO airportcodes VALUES ('IAH', 'HOUSTON(INTL ARPT) TEXAS USA', 'HOUSTON', 111, 185, '0101000020E610000000000080D9D557C0000000A001FC3D40', 1035.98718, 3);
INSERT INTO airportcodes VALUES ('MTY', 'MONTERREY MEXICO', 'MONTERREY', 168, NULL, '0101000020E610000000000020D90659C0000000C04BC73940', 1374.78809, 3);
INSERT INTO airportcodes VALUES ('IFP', 'BULLHEAD CITY ARIZONA USA', 'BULLHEAD CITY', 114, 239, '0101000020E610000000000000D7A35CC0000000A025944140', 1308.17346, 3);
INSERT INTO airportcodes VALUES ('JFK', 'NEW YORK(KENNEDY ARPT)', 'NEW YORK (KENNEDY INTL)', 124, 105, '0101000020E610000000000080D97152C000000000E5514440', 1026.26416, 3);
INSERT INTO airportcodes VALUES ('LAS', 'LAS VEGAS  NEVADA  USA', 'LAS VEGAS', 131, 243, '0101000020E610000000000060BAC95CC0000000C0400A4240', 1297.55713, 3);
INSERT INTO airportcodes VALUES ('YYC', 'CALGARY  ALBERTA  CANADA', 'CALGARY', 256, 294, '0101000020E6100000000000A047815CC000000040948E4940', 1049.11072, 3);
INSERT INTO airportcodes VALUES ('CHS', 'CHARLESTON SOUTH CAROLINA USA', 'CHARLESTON', 47, 142, '0101000020E610000000000080970254C00000006005734040', 1087.30273, 3);
INSERT INTO airportcodes VALUES ('BFL', 'BAKERSFIELD  CALIFORNIA  USA', 'BAKERSFIELD', 20, NULL, '0101000020E6100000000000E0A5C35DC00000004080B74140', 1503.9458, 4);
INSERT INTO airportcodes VALUES ('BJX', 'LEON MEXICO', 'LEON', 27, NULL, '0101000020E6100000000000C0C85E59C00000000056FE3440', 1716.7373, 4);
INSERT INTO airportcodes VALUES ('BUR', 'BURBANK CALIFORNIA USA', 'BURBANK', 40, NULL, '0101000020E6100000000000E0F9965DC000000080B0194140', 1520.50452, 4);
INSERT INTO airportcodes VALUES ('SMF', 'SACRAMENTO  CALIFORNIA  USA', 'SACRAMENTO', 225, 253, '0101000020E610000000000000D3655EC0000000E002594340', 1514.26965, 4);
INSERT INTO airportcodes VALUES ('SNA', 'ORANGE COUNTY  CALIFORNIA  USA', 'ORANGE COUNTY', 226, 237, '0101000020E6100000000000408D775DC0000000607DD64040', 1520.03857, 4);
INSERT INTO airportcodes VALUES ('CUN', 'CANCUN  MEXICO', 'CANCUN', 56, 167, '0101000020E61000000000006022B855C00000002058093540', 1687.14294, 4);
INSERT INTO airportcodes VALUES ('MEX', 'MEXICO CITY MEXICO', 'MEXICO CITY', 150, NULL, '0101000020E6100000000000409DC458C000000060B16F3340', 1790.302, 4);
INSERT INTO airportcodes VALUES ('CZM', 'COZUMEL MEXICO', 'COZUMEL', 59, 168, '0101000020E6100000000000003DBB55C000000000BC853440', 1721.45911, 4);
INSERT INTO airportcodes VALUES ('GDL', 'GUADALAJARA MEXICO', 'GUADALAJARA', 89, NULL, '0101000020E610000000000060E7D359C0000000A094853440', 1779.43335, 4);
INSERT INTO airportcodes VALUES ('ZIH', 'IXTAPA/ZIHUATENEJO MEXICO', 'IXTAPA/ZIHUATENEJO', 258, 192, '0101000020E610000000000000815D59C000000080029A3140', 1944.65247, 4);
INSERT INTO airportcodes VALUES ('ZLO', 'MANZANILLO MEXICO', 'MANZANILLO MEXICO', 259, 197, '0101000020E6100000000000A0C6235AC0000000A011253340', 1894.25757, 4);
INSERT INTO airportcodes VALUES ('SAL', 'COMALAPA INTERNATIONAL EL SALVADOR', 'COMALAPA INTERNATIONAL EL SALVADOR', 208, NULL, '0101000020E6100000000000A0904356C0000000A0BDE12A40', 2186.60913, 4);
INSERT INTO airportcodes VALUES ('ESC', 'ESCANABA  MICHIGAN  USA', 'ESCANABA', 73, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('BKX', 'BROOKINGS  SOUTH DAKOTA  USA', 'BROOKINGS', 29, NULL, '0101000020E610000000000020483458C0000000A003274640', 181.352921, 1);
INSERT INTO airportcodes VALUES ('BMI', 'BLOOMINGTON ILLINOIS USA', 'BLOOMINGTON', 30, NULL, '0101000020E6100000000000209E3A56C0000000A0113D4440', 374.733307, 1);
INSERT INTO airportcodes VALUES ('DBQ', 'DUBUQUE  IOWA  USA', 'DUBUQUE', 62, 132, '0101000020E61000000000008068AD56C0000000C074334540', 212.476913, 1);
INSERT INTO airportcodes VALUES ('GRI', 'GRAND ISLAND  NEBRASKA  USA', 'GRAND ISLAND', 94, NULL, '0101000020E610000000000080D09358C000000000D77B4440', 373.308319, 1);
INSERT INTO airportcodes VALUES ('LAN', 'LANSING  MICHIGAN  USA', 'LANSING', 130, 107, '0101000020E610000000000000982555C000000080AC634540', 454.059479, 1);
INSERT INTO airportcodes VALUES ('LNK', 'LINCOLN  NEBRASKA  USA', 'LINCOLN', 139, 208, '0101000020E6100000000000C0963058C0000000A0ED6C4440', 331.143219, 1);
INSERT INTO airportcodes VALUES ('LSE', 'LA CROSSE WI\\WINONA  MN  USA', 'LA CROSSE', 140, 124, '0101000020E6100000000000C06DD056C00000002083F04540', 119.256737, 1);
INSERT INTO airportcodes VALUES ('MCI', 'KANSAS CITY  MISSOURI  USA', 'KANSAS CITY', 144, 188, '0101000020E610000000000080B0AD57C0000000C017A64340', 393.416748, 1);
INSERT INTO airportcodes VALUES ('BKL', 'CLEVELAND (LAKE FRONT OHIO USA', 'CLEVELAND (LAKE FRONT OHIO USA', 28, NULL, '0101000020E610000000000020BB6B54C0000000803DC24440', 625.343201, 2);
INSERT INTO airportcodes VALUES ('BTV', 'BURLINGTON VERMONT  USA', 'BURLINGTON', 38, 90, '0101000020E6100000000000A0CF4952C000000040673C4640', 984.083252, 2);
INSERT INTO airportcodes VALUES ('BUF', 'BUFFALO NEW YORK USA', 'BUFFALO', 39, 100, '0101000020E610000000000060DCAE53C00000004062784540', 732.709656, 2);
INSERT INTO airportcodes VALUES ('CAE', 'COLUMBIA  SOUTH CAROLINA  USA', 'COLUMBIA', 43, NULL, '0101000020E6100000000000E0A54754C0000000A02AF84040', 992.473694, 2);
INSERT INTO airportcodes VALUES ('CMH', 'COLUMBUS  OHIO  USA', 'COLUMBUS', 51, 122, '0101000020E6100000000000E014B954C000000080BEFF4340', 624.924561, 2);
INSERT INTO airportcodes VALUES ('CVG', 'CINCINNATI  OHIO  USA', 'CINCINNATI', 57, 127, '0101000020E610000000000040BD2A55C0000000203F864340', 595.791199, 2);
INSERT INTO airportcodes VALUES ('EGE', 'EAGLE COLORADO USA', 'EAGLE', 71, 241, '0101000020E610000000000080C0BA5AC0000000C040D24340', 787.116455, 2);
INSERT INTO airportcodes VALUES ('LIT', 'LITTLE ROCK ARKANSAS USA', 'LITTLE ROCK', 138, 175, '0101000020E6100000000000E05A0E57C0000000005D5D4140', 703.600586, 2);
INSERT INTO airportcodes VALUES ('MCO', 'ORLANDO  FLORIDA  USA', 'ORLANDO', 145, 151, '0101000020E6100000000000A0C65354C000000020ED6D3C40', 1311.63574, 3);
INSERT INTO airportcodes VALUES ('ACA', 'ACAPULCO, MEXICO', 'ACAPULCO', 4, 188, '0101000020E61000000000008041F058C000000040D1C13040', 1980.33215, 4);
INSERT INTO airportcodes VALUES ('MBJ', 'MONTEGO BAY JAMAICA', 'MONTEGO BAY', 142, 156, '0101000020E610000000000020757A53C000000080F2803240', 2025.10034, 4);
INSERT INTO airportcodes VALUES ('SAN', 'SAN DIEGO  CALIFORNIA  USA', 'SAN DIEGO', 209, 235, '0101000020E610000000000000294C5DC0000000A0E65D4040', 1530.63879, 4);
INSERT INTO airportcodes VALUES ('BOG', 'BOGOTA COLOMBIA', 'BOGOTA', 32, NULL, '0101000020E6100000000000C0668952C0000000A06DCE1240', 3006.95093, 5);
INSERT INTO airportcodes VALUES ('ANC', 'ANCHORAGE  ALASKA  USA', 'ANCHORAGE', 9, 292, '0101000020E610000000000040DFBF62C0000000C052964E40', 2512.12085, 5);
INSERT INTO airportcodes VALUES ('SXM', 'ST. MARTIN NETH. ANTILLES', 'ST. MARTIN', 233, 140, '0101000020E610000000000060F08D4FC0000000007F0A3240', 2539.16602, 5);
INSERT INTO airportcodes VALUES ('ELP', 'EL PASO TEXAS USA', 'EL PASO', 72, 215, '0101000020E6100000000000806F1653C0000000A0D1480B40', 3043.57471, 5);
INSERT INTO airportcodes VALUES ('ISP', 'LONG ISLAND MACARTHUR NY USA', 'LONG ISLAND/MACARTHUR', 120, NULL, '0101000020E6100000000000C0AB1953C0000000805E4D0C40', 3034.14478, 5);
INSERT INTO airportcodes VALUES ('KEF', 'REYKJAVIK ICELAND', 'REYKJAVIK', 126, 68, '0101000020E6100000000000A0089B36C00000008014FE4F40', 2936.96509, 5);
INSERT INTO airportcodes VALUES ('MNL', 'MANILA PHILIPPINES', 'MANILA', 161, NULL, '0101000020E6100000000000A047415E400000004067042D40', 7807.28467, 7);
INSERT INTO airportcodes VALUES ('CCS', 'CARACAS MAIQUETA INTERNATIONAL VENEZUELA', 'CARACAS MAIQUETA INTERNATIONAL VENEZUELA', 44, NULL, '0101000020E6100000000000C065BF50C0000000C0CB342540', 2834.1853, 5);
INSERT INTO airportcodes VALUES ('ARN', 'STOCKHOLM  SWEDEN', 'STOCKHOLM', 10, NULL, '0101000020E61000000000006029EB31400000008071D34D40', 4238.04834, 6);
INSERT INTO airportcodes VALUES ('CDG', 'PARIS(C.DEGAULLE)  FRANCE', 'PARIS C.DEGAULLE', 45, 86, '0101000020E6100000000000606666044000000060A3814840', 4210.52588, 6);
INSERT INTO airportcodes VALUES ('FRA', 'FRANKFURT  FED. REP. OF GERMANY', 'FRANKFURT', 84, NULL, '0101000020E610000000000020151621400000002061034940', 4380.58496, 6);
INSERT INTO airportcodes VALUES ('HNL', 'HONOLULU  OAHU; HAWAII  USA', 'HONOLULU', 103, 243, '0101000020E61000000000000081BD63C00000006096513540', 3967.46802, 6);
INSERT INTO airportcodes VALUES ('KOA', 'KONA INTERNATIONAL HAWAII USA', 'KONA INTERNATIONAL HAWAII USA', 128, NULL, '0101000020E6100000000000E0788163C00000000022BD3340', 3947.26318, 6);
INSERT INTO airportcodes VALUES ('LGW', 'LONDON  ENGLAND UK', 'LONDON', 135, -1, '0101000020E610000000000080075BC8BF00000000F5924940', 4026.38574, 6);
INSERT INTO airportcodes VALUES ('LHR', 'LONDON (HEATHROW) ENGLAND UK', 'LONDON (HEATHROW) ENGLAND UK', 136, -1, '0101000020E6100000000000007190DDBF000000A03CBC4940', 4004.29028, 6);
INSERT INTO airportcodes VALUES ('BOM', 'MUMBAI, INDIA', 'MUMBAI', 34, NULL, '0101000020E6100000000000A08B37524000000000B5163340', 7932.46777, 7);
INSERT INTO airportcodes VALUES ('TPE', 'TAIPEI  TAIWAN', 'TAIPEI', 238, NULL, '0101000020E610000000000080E94E5E4000000020E4133940', 7139.05225, 7);
INSERT INTO airportcodes VALUES ('KUL', 'KUALALUMPUR MALAYSIA', 'KUALALUMPUR', 129, NULL, '0101000020E6100000000000A0706D5940000000A0F2F60540', 9021.72168, 7);
INSERT INTO airportcodes VALUES ('SIN', 'SINGAPORE  SINGAPORE', 'SINGAPORE', 220, NULL, '0101000020E6100000000000C09DFF5940000000E0609AF53F', 9073.87402, 7);
INSERT INTO airportcodes VALUES ('HKG', 'HONG KONG HONG KONG', 'HONG KONG', 101, NULL, '0101000020E6100000000000608F7A5C4000000020144F3640', 7490.69385, 7);
INSERT INTO airportcodes VALUES ('STC', 'SAINT CLOUD MINNESOTA USA', 'SAINT CLOUD', 229, 324, '0101000020E610000000000060D58357C000000000F7C54640', 61.4415283, 1);
INSERT INTO airportcodes VALUES ('STL', 'ST. LOUIS  MISSOURI  USA', 'ST LOUIS', 230, 160, '0101000020E610000000000020AE9756C000000060D55F4340', 448.50296, 1);
INSERT INTO airportcodes VALUES ('SUX', 'SIOUX CITY  IOWA  USA', 'SIOUX CITY', 231, 227, '0101000020E6100000000000009A1858C00000006088334540', 233.149567, 1);
INSERT INTO airportcodes VALUES ('TVC', 'TRAVERSE CITY MICHIGAN USA', 'TRAVERSE CITY', 241, 90, '0101000020E6100000000000C0426555C000000040E65E4640', 374.528259, 1);
INSERT INTO airportcodes VALUES ('DLH', 'DULUTH MN\\SUPERIOR  WI  USA', 'DULUTH', 66, 19, '0101000020E610000000000000640C57C0000000E0C96B4740', 144.211349, 1);
INSERT INTO airportcodes VALUES ('DSM', 'DES MOINES  IOWA  USA', 'DES MOINES', 67, 180, '0101000020E610000000000040706A57C0000000205AC44440', 232.434433, 1);
INSERT INTO airportcodes VALUES ('FOD', 'FORT DODGE  IOWA  USA', 'FORT DOGE', 83, NULL, '0101000020E610000000000080538C57C00000008097464540', 168.192017, 1);
INSERT INTO airportcodes VALUES ('FSD', 'SIOUX FALLS  SOUTH DAKOTA  USA', 'SIOUX FALLS', 86, 245, '0101000020E6100000000000407B2F58C0000000007FCA4540', 196.075912, 1);
INSERT INTO airportcodes VALUES ('GFK', 'GRAND FORKS  NORTH DAKOTA  USA', 'GRAND FORKS', 91, 316, '0101000020E610000000000040454B58C0000000A082F94740', 283.52829, 1);
INSERT INTO airportcodes VALUES ('GRR', 'GRAND RAPIDS  MICHIGAN  USA', 'GRAND RAPIDS, MI', 95, 109, '0101000020E610000000000080756155C000000000BE704540', 407.46579, 1);
INSERT INTO airportcodes VALUES ('INL', 'INTL FALLS  MINNESOTA  USA', 'INTL FALLS', 118, 359, '0101000020E610000000000060CC5957C00000004079484840', 254.756226, 1);
INSERT INTO airportcodes VALUES ('MKE', 'MILWAUKEE  WISCONSIN  USA', 'MILWAUKEE', 155, 294, '0101000020E6100000000000E061F955C0000000E03D794540', 296.827148, 1);
INSERT INTO airportcodes VALUES ('MSN', 'MADISON  WISCONSIN  USA', 'MADISON', 164, 109, '0101000020E6100000000000A0995556C000000040E8914540', 227.476913, 1);
INSERT INTO airportcodes VALUES ('SLC', 'SALT LAKE CITY  UTAH  USA', 'SALT LAKE CITY', 224, 252, '0101000020E61000000000008097FE5BC000000040EA644440', 989.148254, 2);
INSERT INTO airportcodes VALUES ('SWF', 'NEWBURGH NEW YORK USA', 'NEWBURGH', 232, NULL, '0101000020E610000000000000B58652C00000006086C04440', 988.51532, 2);
INSERT INTO airportcodes VALUES ('SYR', 'SYRACUSE  NEW YORK  USA', 'SYRACUSE', 234, 94, '0101000020E6100000000000A0CD0653C0000000C03B8E4540', 858.000122, 2);
INSERT INTO airportcodes VALUES ('TUL', 'TULSA OKLAHOMA USA', 'TULSA', 239, 190, '0101000020E6100000000000A0D6F857C00000002065194240', 616.126099, 2);
INSERT INTO airportcodes VALUES ('TYS', 'KNOXVILLE  TENNESSEE  USA', 'KNOXVILLE', 243, 141, '0101000020E6100000000000C09DFF54C0000000E0CEE74140', 792.092957, 2);
INSERT INTO airportcodes VALUES ('YOW', 'OTTOWA ONTARIO CANADA', 'OTTOWA', 248, NULL, '0101000020E610000000000020D4EA52C0000000A047A94640', 855.046509, 2);
INSERT INTO airportcodes VALUES ('YQR', 'REGINA  SASK  CANADA', 'REGINA', 249, 307, '0101000020E6100000000000C09F2A5AC00000008048374940', 655.25592, 2);
INSERT INTO airportcodes VALUES ('YUL', 'MONTREAL-DORVAL CANADA', 'MONTREAL-DORVAL', 251, 86, '0101000020E610000000000040696F52C0000000A03CBC4640', 947.578003, 2);
INSERT INTO airportcodes VALUES ('AMA', 'AMARILLO, TEXAS (AMARILLO INT''L) USA', 'AMARILLO', 7, NULL, '0101000020E6100000000000202F6D59C000000040159C4140', 803.555237, 2);
INSERT INTO airportcodes VALUES ('BGM', 'BINGHAMTON  NEW YORK  USA', 'BINGHAMTON', 21, NULL, '0101000020E610000000000000B5FE52C0000000A0B61A4540', 881.40509, 2);
INSERT INTO airportcodes VALUES ('BZN', 'BOZEMAN  MONTANA  USA', 'BOZEMAN', 42, 274, '0101000020E6100000000000C0CAC95BC00000002085E34640', 871.546509, 2);
INSERT INTO airportcodes VALUES ('DAY', 'DAYTON(INTL)  OHIO  USA', 'DAYTON', 61, 127, '0101000020E6100000000000A00A0E55C0000000E081F34340', 573.475098, 2);
INSERT INTO airportcodes VALUES ('DFW', 'DALLAS\\FT. WORTH  TEXAS  USA', 'DALLAS/ FORT WORTH', 65, 193, '0101000020E6100000000000A06E4258C000000060CA724040', 853.05896, 2);
INSERT INTO airportcodes VALUES ('DTW', 'DETROIT MICH(METRO WAYNE CO.)', 'DETROIT', 68, 285, '0101000020E6100000000000209ED654C0000000E02F1B4540', 527.179138, 2);
INSERT INTO airportcodes VALUES ('GSO', 'GREENSBORO\\H.PT\\WIN-SALEM  NC  USA', 'GREENSBORO\\H.PT\\WIN-SALEM', 96, 128, '0101000020E6100000000000C0FCFB53C0000000C0840C4240', 923.053467, 2);
INSERT INTO airportcodes VALUES ('PIA', 'PEORIA  ILLINOIS  USA', 'PEORIA', 186, 144, '0101000020E6100000000000005F6C56C00000008004554440', 341.966736, 1);
INSERT INTO airportcodes VALUES ('CMI', 'CHAMPAIGN/URBANA ILLINOIS USA', 'CHAMPAIGN/URBANA', 52, NULL, '0101000020E610000000000060CC1156C00000008004054440', 418.783722, 1);
INSERT INTO airportcodes VALUES ('FAR', 'FARGO  NORTH DAKOTA  USA', 'FARGO', 77, 312, '0101000020E610000000000020363458C000000080D9754740', 222.956802, 1);
INSERT INTO airportcodes VALUES ('FNT', 'FLINT MICHIGAN USA', 'FLINT', 82, 105, '0101000020E61000000000002097EF54C000000040927B4540', 489.690002, 1);
INSERT INTO airportcodes VALUES ('GRB', 'GREEN BAY  WISCONSIN  USA', 'GREEN BAY', 93, 90, '0101000020E6100000000000604B0856C0000000C0173E4640', 251.65921, 1);
INSERT INTO airportcodes VALUES ('HUF', 'TERRE HAUTE INDIANA USA', 'TERRE HAUTE', 109, NULL, '0101000020E6100000000000C0AFD355C0000000C0CAB94340', 482.010284, 1);
INSERT INTO airportcodes VALUES ('JMS', 'JAMESTOWN  NORTH DAKOTA  USA', 'JAMESTOWN', 125, 299, '0101000020E6100000000000A067AB58C00000006000774740', 298.026703, 1);
INSERT INTO airportcodes VALUES ('EAU', 'EAU CLAIRE  WISCONSIN  USA', 'EAU CLAIRE', 70, 90, '0101000020E6100000000000C0FEDE56C000000080D26E4640', 85.0917892, 1);
INSERT INTO airportcodes VALUES ('ROC', 'ROCHESTER NEW YORK USA', 'ROCHESTER NY', 205, 94, '0101000020E6100000000000A0086B53C000000020388F4540', 781.275635, 2);
INSERT INTO airportcodes VALUES ('SGF', 'SPRINGFIELD MISSOURI USA', 'SPRINGFIELD MISSOURI USA', 218, 180, '0101000020E6100000000000E0DE5857C000000020739F4240', 527.796448, 2);
INSERT INTO airportcodes VALUES ('CHA', 'CHATTANOOGA TENNESSEE USA', 'CHATTANOOGA', 46, NULL, '0101000020E6100000000000000B4D55C0000000C084844140', 801.211487, 2);
INSERT INTO airportcodes VALUES ('DCA', 'WASHINGTON(NATIONAL ARPT)', 'WASHINGTON D.C. (REAGAN  NATIONAL)', 63, 117, '0101000020E6100000000000A0694253C0000000A0116D4340', 929.043335, 2);
INSERT INTO airportcodes VALUES ('DEN', 'DENVER  COLORADO  USA', 'DENVER', 64, 237, '0101000020E610000000000060122B5AC0000000204CEE4340', 678.904297, 2);
INSERT INTO airportcodes VALUES ('HLN', 'HELENA  MONTANA  USA', 'HELENA', 102, 278, '0101000020E610000000000080E9FE5BC0000000A0AB4D4740', 910.428406, 2);
INSERT INTO airportcodes VALUES ('IDA', 'IDAHO FALLS IDAHO USA', 'IDAHO FALLS IDAHO USA', 113, 265, '0101000020E6100000000000408B045CC000000060DEC14540', 936.540283, 2);
INSERT INTO airportcodes VALUES ('YXE', 'SASKATOON CANADA', 'SASKATOON', 255, 310, '0101000020E6100000000000C0CCAC5AC0000000C0DC154A40', 794.232483, 2);
INSERT INTO airportcodes VALUES ('YYZ', 'TORONTO ONT.(PEARSON ARPT)', 'TORONTO', 257, 95, '0101000020E6100000000000C05BE853C000000080AED64540', 676.771362, 2);
INSERT INTO airportcodes VALUES ('CLE', 'CLEVELAND  OHIO  USA', 'CLEVELAND', 49, 109, '0101000020E610000000000020637654C0000000A0B2B44440', 620.817505, 2);
INSERT INTO airportcodes VALUES ('CLT', 'CHARLOTTE  NORTH CAROLINA  USA', 'CHARLOTTE', 50, 133, '0101000020E6100000000000C05B3C54C000000060649B4140', 929.806091, 2);
INSERT INTO airportcodes VALUES ('COS', 'COLORADO SPRINGS COLORADO USA', 'COLORADO SPRINGS', 54, 232, '0101000020E610000000000020DD2C5AC00000008024674340', 723.849426, 2);
INSERT INTO airportcodes VALUES ('MYR', 'MYRTLE BEACH SOUTH CAROLINA USA', 'MYRTLE BEACH', 170, -1, '0101000020E61000000000004069BB53C00000006000D74040', 1084.94543, 3);
INSERT INTO airportcodes VALUES ('PSC', 'PASCO  WASHINGTON  USA', 'PASCO', 192, 276, '0101000020E6100000000000C09DC75DC0000000C0E1214740', 1250.83459, 3);
INSERT INTO airportcodes VALUES ('PVD', 'PROVIDENCE  RHODE ISLAND  USA', 'PROVIDENCE', 195, 100, '0101000020E6100000000000E0E7DA51C0000000E0C5DD4440', 1114.18481, 3);
INSERT INTO airportcodes VALUES ('DAB', 'DAYTONA BEACH FLORIDA USA', 'DAYTONA BEACH', 60, NULL, '0101000020E6100000000000E0B74354C0000000E00D2E3D40', 1272.61914, 3);
INSERT INTO airportcodes VALUES ('EUG', 'EUGENE OREGON USA', 'EUGENE', 74, NULL, '0101000020E61000000000006091CD5EC0000000E0F20F4640', 1470.67517, 3);
INSERT INTO airportcodes VALUES ('GEG', 'SPOKANE  WASHINGTON  USA', 'SPOKANE', 90, 279, '0101000020E6100000000000002D625DC0000000E058CF4740', 1172.1604, 3);
INSERT INTO airportcodes VALUES ('DVL', 'DEVILS LAKE  NORTH DAKOTA  USA', 'DEVILS LAKE', 69, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('MKT', 'MANKATO  MINNESOTA  USA', 'MANKATO', 157, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('FRM', 'FAIRMONT  MINNESOTA  USA', 'FAIRMONT', 85, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('FFM', 'FERGUS FALLS MINNESOTA USA', 'FERGUS FALLS', 80, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('IMT', 'IRON MOUNTAIN  MICHIGAN  USA', 'IRON MOUNTAIN', 116, -1, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('MML', 'MARSHALL MINNESOTA USA', 'MARSHALL', 160, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('IWD', 'IRONWOOD  MICHIGAN  USA', 'IRONWOOD', 121, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('CWA', 'WAUSAU  WISCONSIN  USA', 'WAUSAU', 58, 90, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('YKN', 'YANKTON  SOUTH DAKOTA  USA', 'YANKTON', 247, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('LYU', 'ELY MINNESOTA USA', 'ELY', 141, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('FWA', 'FORT WAYNE  INDIANA  USA', 'FORT WAYNE', 87, NULL, '0101000020E6100000000000807C4C55C0000000803F7D4440', 487.202789, 1);
INSERT INTO airportcodes VALUES ('HIB', 'HIBBING  MINNESOTA  USA', 'HIBBING', 100, 13, '0101000020E610000000000020B23557C0000000207CB14740', 174.058456, 1);
INSERT INTO airportcodes VALUES ('MDW', 'CHICAGO  ILLINOIS  USA', 'CHICAGO (MIDWAY)', 148, 124, '0101000020E61000000000006027F055C0000000A09BE44440', 348.230042, 1);
INSERT INTO airportcodes VALUES ('CMX', 'HANCOCK  MICHIGAN  USA', 'HANCOCK', 53, 50, '0101000020E6100000000000604D1F56C0000000208E954740', 276.575104, 1);
INSERT INTO airportcodes VALUES ('HON', 'HURON  SOUTH DAKOTA  USA', 'HURON', 104, NULL, '0101000020E6100000000000C09F8E58C0000000404E314640', 248.567444, 1);
INSERT INTO airportcodes VALUES ('RAP', 'RAPID CITY  SOUTH DAKOTA  USA', 'RAPID CITY', 198, 269, '0101000020E6100000000000E0A5C359C000000060CC054640', 488.224884, 1);
INSERT INTO airportcodes VALUES ('RFD', 'ROCKFORD  ILLINOIS  USA', 'ROCKFORD', 200, NULL, '0101000020E610000000000080384656C0000000E002194540', 277.715179, 1);
INSERT INTO airportcodes VALUES ('RHI', 'RHINELANDER  WISCONSIN  USA', 'RHINELANDER', 201, 70, '0101000020E610000000000080EB5D56C000000020CBD04640', 189.807907, 1);
INSERT INTO airportcodes VALUES ('RST', 'ROCHESTER  MINNESOTA  USA', 'ROCHESTER MN', 206, 144, '0101000020E610000000000000002057C00000002043F44540', 76.1398315, 1);
INSERT INTO airportcodes VALUES ('LEX', 'LEXINGTON  KENTUCKY  USA', 'LEXINGTON', 133, 132, '0101000020E610000000000020C72655C000000000AC044340', 649.582275, 2);
INSERT INTO airportcodes VALUES ('MDT', 'HARRISBURG PENNSYLVANIA USA', 'HARRISBURG', 147, 108, '0101000020E610000000000080DB3053C0000000A0C4184440', 896.520142, 2);
INSERT INTO airportcodes VALUES ('HSV', 'HUNTSVILLE ALABAMA USA', 'HUNTSVILLE', 108, NULL, '0101000020E6100000000000409BB155C0000000C08F514140', 785.832031, 2);
INSERT INTO airportcodes VALUES ('IND', 'INDIANAPOLIS  INDIANA  USA', 'INDIANAPOLIS', 117, 134, '0101000020E610000000000080D79255C000000080D0DB4340', 502.395721, 2);
INSERT INTO airportcodes VALUES ('JAC', 'JACKSON HOLE WYOMING USA', 'JACKSON HOLE', 122, 265, '0101000020E6100000000000603BAF5BC000000000BCCD4540', 869.927124, 2);
INSERT INTO airportcodes VALUES ('RDU', 'RALIEGH/DURHAM NORTH CAROLINA USA', 'RALIEGH/DURHAM', 199, 129, '0101000020E61000000000006066B253C00000004055F04140', 979.578064, 2);
INSERT INTO airportcodes VALUES ('RIC', 'RICHMOND VIRGINA USA', 'RICHMOND', 202, 121, '0101000020E610000000000000765453C000000060AAC04240', 968.867249, 2);
INSERT INTO airportcodes VALUES ('ROA', 'ROANOKE VIRGINIA USA', 'ROANOKE', 204, NULL, '0101000020E6100000000000006DFE53C000000000AAA94240', 863.323914, 2);
INSERT INTO airportcodes VALUES ('FAT', 'FRESNO  CALIFORNIA  USA', 'FRESNO', 78, NULL, '0101000020E6100000000000C0F3ED5DC0000000805A634240', 1486.05066, 3);
INSERT INTO airportcodes VALUES ('FCA', 'KALISPELL\\GLACIER NATL PK  MT  USA', 'KALISPELL\\GLACIER', 79, 284, '0101000020E61000000000004062905CC000000080BE274840', 1023.03662, 3);
INSERT INTO airportcodes VALUES ('FLL', 'FT. LAUDERDALE  FLORIDA  USA', 'FT. LAUDERDALE', 81, 152, '0101000020E6100000000000E0C50954C0000000E095123A40', 1489.12366, 3);
INSERT INTO airportcodes VALUES ('LGA', 'NEW YORK(LA GUARDIA)', 'NEW YORK (LA GUARDIA)', 134, 105, '0101000020E6100000000000A0D87752C0000000407B634440', 1018.0575, 3);
INSERT INTO airportcodes VALUES ('MHT', 'MANCHESTER NEW HAMPSHIRE USA', 'MANCHESTER', 153, 97, '0101000020E610000000000080E2DB51C0000000605F774540', 1089.71472, 3);
INSERT INTO airportcodes VALUES ('HPN', 'WHITE PLAINS NEW YORK USA', 'WHITE PLAINS', 106, 101, '0101000020E610000000000060496D52C00000008093884440', 1018.52289, 3);
INSERT INTO airportcodes VALUES ('JAX', 'JACKSONVILLE FLORIDA USA', 'JACKSONVILLE', 123, 148, '0101000020E610000000000080066C54C0000000607D7E3E40', 1174.80505, 3);
INSERT INTO airportcodes VALUES ('PWM', 'PORTLAND MAINE USA', 'PORTLAND', 197, 93, '0101000020E6100000000000A0CB9351C0000000A0B6D24540', 1133.36987, 3);
INSERT INTO airportcodes VALUES ('RNO', 'RENO NEVADA USA', 'RENO', 203, 255, '0101000020E6100000000000E026F15DC000000080E2BF4340', 1402.21826, 3);
INSERT INTO airportcodes VALUES ('RSW', 'FORT MYERS  FLORIDA  USA', 'FORT MYERS', 207, 154, '0101000020E610000000000040557054C00000006044893A40', 1418.40698, 3);
INSERT INTO airportcodes VALUES ('SAT', 'SAN ANTONIO  TEXAS  USA', 'SAN ANTONIO', 210, 193, '0101000020E610000000000040119E58C0000000A0A0883D40', 1098.68384, 3);
INSERT INTO airportcodes VALUES ('SAV', 'SAVANNAH  GEORGIA  USA', 'SAVANNAH', 211, 144, '0101000020E610000000000040EF4C54C00000004055104040', 1092.59949, 3);
INSERT INTO airportcodes VALUES ('GCM', 'GRAND CAYMAN', 'GRAND CAYMAN', 88, 160, '0101000020E610000000000080E45654C000000000F54A3340', 1895.16614, 4);
INSERT INTO airportcodes VALUES ('LAX', 'LOS ANGELES(INTL ARPT)  CALIF.  USA', 'LOS ANGELES', 132, 238, '0101000020E6100000000000A01C9A5DC0000000E0A3F84040', 1533.43494, 4);
INSERT INTO airportcodes VALUES ('LIR', 'LIBERIA COSTA RICA', 'LIBERIA', 137, -1, '0101000020E610000000000080D76255C000000000C52F2540', 2413.14771, 4);
INSERT INTO airportcodes VALUES ('MIA', 'MIAMI FLA.(INTL ARPT)', 'MIAMI', 154, 153, '0101000020E610000000000040991254C0000000200FCB3940', 1502.8335, 4);
INSERT INTO airportcodes VALUES ('PUJ', 'PUNTA CANA DOMINICAN REP.', 'PUNTA CANA', 194, 145, '0101000020E610000000000000421751C00000002041913240', 2313.271, 4);
INSERT INTO airportcodes VALUES ('PVR', 'PUERTO VALLARTA  MEXICO', 'PUERTO VALLARTA', 196, 199, '0101000020E61000000000008041505AC0000000001BAE3440', 1808.07471, 4);
INSERT INTO airportcodes VALUES ('MBS', 'SAGINAW  MICHIGAN  USA', 'SAGINAW', 143, 98, '0101000020E610000000000020180555C00000002036C44540', 462.107788, 1);
INSERT INTO airportcodes VALUES ('MKG', 'MUSKEGON  MICHIGAN  USA', 'MUSKEGON', 156, NULL, '0101000020E6100000000000A03E8F55C000000020B2954540', 366.492371, 1);
INSERT INTO airportcodes VALUES ('CPR', 'CASPER WHYOMING USA', 'CASPER WHYOMING USA', 55, 257, '0101000020E610000000000020B29D5AC00000006039744540', 672.616272, 2);
INSERT INTO airportcodes VALUES ('MEM', 'MEMPHIS  TENNESSEE  USA', 'MEMPHIS', 149, 162, '0101000020E610000000000040827E56C0000000606D854140', 701.2146, 2);
INSERT INTO airportcodes VALUES ('EWR', 'NEW YORK NY\\NEWARK  NJ  USA', 'NEW YORK', 75, 106, '0101000020E610000000000000CC8A52C0000000E0A3584440', 1006.0351, 3);
INSERT INTO airportcodes VALUES ('MFE', 'MC ALLEN TEXAS USA', 'MC ALLEN', 151, NULL, '0101000020E610000000000040458F58C000000040012D3A40', 1322.49109, 3);
INSERT INTO airportcodes VALUES ('MLB', 'MELBOURNE FLORIDA USA', 'MELBOURNE', 158, NULL, '0101000020E6100000000000A04C2954C000000020511A3C40', 1350.13281, 3);
INSERT INTO airportcodes VALUES ('FAI', 'FAIRBANKS ALASKA USA', 'FAIRBANKS', 76, 297, '0101000020E610000000000060647B62C0000000A02A345040', 2460.33252, 4);
INSERT INTO airportcodes VALUES ('AMS', 'AMSTERDAM  NETHERLANDS', 'AMSTERDAM', 8, 83, '0101000020E610000000000020390E13400000004080274A40', 4154.67578, 6);
INSERT INTO airportcodes VALUES ('KIX', 'OSAKA JAPAN', 'OSAKA', 127, NULL, '0101000020E6100000000000E0CEE76040000000C0B1364140', 6174.52588, 7);
INSERT INTO airportcodes VALUES ('NRT', 'TOKYO  JAPAN', 'TOKYO', 172, 93, '0101000020E6100000000000205A8C6140000000C0E1E14140', 5937.15381, 7);
INSERT INTO airportcodes VALUES ('MHE', 'MITCHELL  SOUTH DAKOTA  USA', 'MITCHELL', 152, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('XNA', 'FAYETTEVILL ARKANSAS USA', 'FAYETTEVILL', 245, 185, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('ATW', 'APPLETON  WISCONSIN  USA', 'APPLETON', 13, 90, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('SEL', 'SEOUL SOUTH KOREA', 'SEOUL', 216, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('MLI', 'MOLINE  ILLINOIS  USA', 'MOLINE', 159, 144, '0101000020E6100000000000E07AA056C00000008068B94440', 273.854218, 1);
INSERT INTO airportcodes VALUES ('MOT', 'MINOT  NORTH DAKOTA  USA', 'MINOT', 162, 304, '0101000020E610000000000080EB5159C00000000034214840', 448.03595, 1);
INSERT INTO airportcodes VALUES ('MSP', 'MINNEAPOLIS\\ST. PAUL  MN  USA', 'MINNEAPOLIS\\ST PAUL', 166, NULL, '0101000020E610000000000000324E57C000000060E5704640', 0.00769107882, 1);
INSERT INTO airportcodes VALUES ('OMA', 'OMAHA  NEBRASKA  USA', 'OMAHA', 177, 205, '0101000020E6100000000000E038F957C000000040CFA64440', 281.66153, 1);
INSERT INTO airportcodes VALUES ('ORD', 'CHICAGO ILL.(O''HARE ARPT)', 'CHICAGO (O''HARE)', 179, 124, '0101000020E610000000000040E8F955C0000000C042FD4440', 333.736389, 1);
INSERT INTO airportcodes VALUES ('PIR', 'PIERRE  SOUTH DAKOTA  USA', 'PIERRE', 187, 269, '0101000020E6100000000000E04D1259C000000060FC304640', 349.015503, 1);
INSERT INTO airportcodes VALUES ('PLN', 'PELLSTON MICHIGAN USA', 'PELLSTON', 189, -1, '0101000020E610000000000020FD3255C00000004013C94640', 412.629944, 1);
INSERT INTO airportcodes VALUES ('SBN', 'SOUTH BEND INDIANA USA', 'SOUTH BEND', 213, 120, '0101000020E6100000000000A04E9455C0000000A0B6DA4440', 410.503967, 1);
INSERT INTO airportcodes VALUES ('PHL', 'PHILADELPHIA PA\\WILM''TON  DE  USA', 'PHILADELPHIA', 184, 111, '0101000020E6100000000000206ECF52C0000000609AEF4340', 978.501038, 2);
INSERT INTO airportcodes VALUES ('PIT', 'PITTSBURGH  PENNSYLVANIA  USA', 'PITTSBURGH', 188, 113, '0101000020E6100000000000E0E70E54C000000080E93E4440', 725.125793, 2);
INSERT INTO airportcodes VALUES ('SDF', 'LOUISVILLE  KENTUCKY  USA', 'LOUISVILLE', 214, 136, '0101000020E6100000000000A01A6F55C0000000C052164340', 603.482483, 2);
INSERT INTO airportcodes VALUES ('SHV', 'SHREVEPORT LOUISIANA USA', 'SHREVEPORT', 219, NULL, '0101000020E6100000000000A0D67457C0000000402A394040', 859.991638, 2);
INSERT INTO airportcodes VALUES ('MSO', 'MISSOULA  MONTANA  USA', 'MISSOULA', 165, 277, '0101000020E610000000000000D3855CC00000006049754740', 1010.41718, 3);
INSERT INTO airportcodes VALUES ('MSY', 'NEW ORLEANS  LOUISIANA  USA', 'NEW ORLEANS', 167, 171, '0101000020E610000000000020839056C0000000804FFE3D40', 1041.49036, 3);
INSERT INTO airportcodes VALUES ('ONT', 'ONTARIO  CALIFORNIA  USA', 'ONTARIO', 178, 239, '0101000020E6100000000000C076665DC0000000002B074140', 1491.85767, 3);
INSERT INTO airportcodes VALUES ('ORF', 'NORFOLK\\VA. BEACH\\WMBG  VA  USA', 'NORFOLK\\VA.', 180, 123, '0101000020E610000000000080E00C53C00000004082724240', 1043.43408, 3);
INSERT INTO airportcodes VALUES ('PBI', 'WEST PALM BEACH  FLORIDA  USA', 'WEST PALM BEACH', 182, 152, '0101000020E6100000000000401E0654C000000040E6AE3A40', 1452.84351, 3);
INSERT INTO airportcodes VALUES ('PDX', 'PORTLAND  OREGON  USA', 'PORTLAND', 183, 272, '0101000020E6100000000000A045A65EC0000000805ACB4640', 1422.43457, 3);
INSERT INTO airportcodes VALUES ('PHX', 'PHOENIX(INTL)  ARIZONA  USA', 'PHOENIX', 185, 231, '0101000020E6100000000000A0C4005CC00000002097B74040', 1275.14575, 3);
INSERT INTO airportcodes VALUES ('PNS', 'PENSACOLA FLORIDA USA', 'PENSACOLA', 190, 162, '0101000020E610000000000040F1CB55C0000000C030793E40', 1048.2489, 3);
INSERT INTO airportcodes VALUES ('PSP', 'PALM SPRINGS  CALIFORNIA  USA', 'PALM SPRINGS', 193, 236, '0101000020E6100000000000C072205DC0000000A033EA4040', 1452.04602, 3);
INSERT INTO airportcodes VALUES ('SEA', 'SEATTLE  WASHINGTON  USA', 'SEATTLE', 215, 278, '0101000020E6100000000000A0C6935EC0000000E078B94740', 1395.16223, 3);
INSERT INTO airportcodes VALUES ('MZT', 'MAZATLAN MEXICO', 'MAZATLAN MEXICO', 171, 204, '0101000020E61000000000002006915AC00000008051293740', 1671.74048, 4);
INSERT INTO airportcodes VALUES ('OAK', 'OAKLAND CALIFORNIA USA', 'OAKLAND', 173, NULL, '0101000020E6100000000000E0248E5EC00000008053DC4240', 1574.95959, 4);
INSERT INTO airportcodes VALUES ('POP', 'PUERTO PLATA DOMINICAN REP.', 'PUERTO PLATA', 191, NULL, '0101000020E6100000000000E07AA451C0000000C005C23340', 2166.93726, 4);
INSERT INTO airportcodes VALUES ('SBA', 'SANTA BARBARA  CALIFORNIA  USA', 'SANTA BARBARA', 212, NULL, '0101000020E610000000000080C2F55DC0000000C08D364140', 1579.88879, 4);
INSERT INTO airportcodes VALUES ('SFO', 'SAN FRANCISCO  CALIFORNIA  USA', 'SAN FRANCISCO', 217, 251, '0101000020E61000000000000000985EC0000000603BCF4240', 1585.70081, 4);
INSERT INTO airportcodes VALUES ('SJC', 'SAN JOSE  CALIFORNIA  USA', 'SAN JOSE', 221, 250, '0101000020E6100000000000C0747B5EC0000000A069AE4240', 1572.4397, 4);
INSERT INTO airportcodes VALUES ('SJD', 'LOS CABOS MEXICO', 'LOS CABOS', 222, 208, '0101000020E6100000000000E0246E5BC000000060DC263740', 1766.60852, 4);
INSERT INTO airportcodes VALUES ('SJU', 'SAN JUAN PUERTO RICO', 'SAN JUAN', 223, 143, '0101000020E6100000000000801D8050C0000000807C703240', 2406.39209, 4);
INSERT INTO airportcodes VALUES ('OGG', 'KAHULUI HAWAII USA', 'KAHULUI HAWAII USA', 175, NULL, '0101000020E610000000000080C28D63C0000000A00AE63440', 3913.37671, 6);
INSERT INTO airportcodes VALUES ('MXP', 'MALPENSA ITALY', 'MALPENSA', 169, NULL, '0101000020E6100000000000E0CA74214000000080B7D04640', 4582.33252, 7);
INSERT INTO airportcodes VALUES ('ASE', 'ASPEN COLORADO USA', 'ASPEN', 11, 241, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('BJI', 'BEMIDJI  MINNESOTA  USA', 'BEMIDJI', 26, 346, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('BRD', 'BRAINERD  MINNESOTA  USA', 'BRAINERD', 36, 340, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('OFK', 'NORFOLK  NEBRASKA  USA', 'NORFOLK', 174, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('MQT', 'MARQUETTE  MICHIGAN  USA', 'MARQUETTE', 163, 65, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('MCW', 'MASON CITY  IOWA  USA', 'MASON CITY', 146, 180, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('ISN', 'WILLISTON NORTH DAKOTA USA', 'WILLISTON', 119, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('SPW', 'SPENCER  IOWA  USA', 'SPENCER', 227, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('CID', 'CEDAR RAPIDS\\IOWA CITY  IOWA  USA', 'CEDAR RAPIDS', 48, 154, '0101000020E6100000000000C07DED56C0000000E03DF14440', 220.584915, 1);
INSERT INTO airportcodes VALUES ('YQT', 'THUNDER BAY  ONTARIO  CANADA', 'THUNDER BAY', 250, 35, '0101000020E6100000000000C0BA5456C0000000609A2F4840', 303.86911, 1);
INSERT INTO airportcodes VALUES ('YWG', 'WINNIPEG MANITOBA CANADA', 'WINNIPEG', 253, 330, '0101000020E6100000000000805A4F58C0000000E07AF44840', 394.92514, 1);
INSERT INTO airportcodes VALUES ('ICT', 'WICHITA  KANSAS  USA', 'WICHITA', 112, 202, '0101000020E6100000000000E0B75B58C0000000E02FD34240', 545.37146, 2);
INSERT INTO airportcodes VALUES ('OKC', 'OKLAHOMA CITY  OKLAHOMA  USA', 'OKLAHOMA CITY', 176, 197, '0101000020E6100000000000E0716658C00000002051B24140', 695.086731, 2);
INSERT INTO airportcodes VALUES ('TOL', 'TOLEDO OHIO USA', 'TOLEDO', 236, NULL, '0101000020E610000000000000B3F354C0000000401CCB4440', 525.404846, 2);
INSERT INTO airportcodes VALUES ('HOU', 'HOUSTON(HOBBY ARPT) TEXAS USA', 'HOUSTON HOBBY', 105, 185, '0101000020E610000000000080D9D157C0000000E038A53D40', 1058.93005, 3);
INSERT INTO airportcodes VALUES ('HRL', 'HARLINGEN  TEXAS  USA', 'HARLINGEN', 107, 189, '0101000020E6100000000000C0E16958C0000000007F3A3A40', 1312.43494, 3);
INSERT INTO airportcodes VALUES ('TUS', 'TUCSON  ARIZONA  USA', 'TUCSON', 240, 225, '0101000020E61000000000006039BC5BC000000060DC0E4040', 1297.25, 3);
INSERT INTO airportcodes VALUES ('YVR', 'VANCOUVER  BC  CANADA', 'VANCOUVER', 252, 283, '0101000020E6100000000000A0C6CB5EC0000000C0D1984840', 1432.31335, 3);
INSERT INTO airportcodes VALUES ('AUA', 'ARUBA ARUBA', 'ARUBA', 15, NULL, '0101000020E610000000000000F98051C000000080B7002940', 2622.69727, 5);
INSERT INTO airportcodes VALUES ('TVF', 'THIEF RIVER FALLS  MINNESOTA  USA', 'THIEF RIVER FALLS', 242, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('OTG', 'WORTHINGTON  MINNESOTA  USA', 'WORTHINGTON', 181, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('HDN', 'STEAMBOAT SPRINGS  COLORADO  USA', 'STEAMBOAT SPRINGS', 99, 248, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('CYEG', 'EDMONTON  ALBERTA  CANADA', 'EDMONTON', 246, 302, '0101000020E6100000000000C01E655CC000000040A4A74A40', 1084.04761, 3);
INSERT INTO airportcodes VALUES ('CYXD', 'EDMONTON  ALBERTA  CANADA', 'EDMONTON', 254, NULL, '0101000020E61000000000002058615CC0000000A047C94A40', 1089.43945, 3);
INSERT INTO airportcodes VALUES ('CYYC', 'CALGARY  ALBERTA  CANADA', 'CALGARY', 256, 294, '0101000020E6100000000000A047815CC000000040948E4940', 1049.11072, 3);
INSERT INTO airportcodes VALUES ('CYOW', 'OTTOWA ONTARIO CANADA', 'OTTOWA', 248, NULL, '0101000020E610000000000020D4EA52C0000000A047A94640', 855.046509, 2);
INSERT INTO airportcodes VALUES ('CYQR', 'REGINA  SASK  CANADA', 'REGINA', 249, 307, '0101000020E6100000000000C09F2A5AC00000008048374940', 655.25592, 2);
INSERT INTO airportcodes VALUES ('CYUL', 'MONTREAL-DORVAL CANADA', 'MONTREAL-DORVAL', 251, 86, '0101000020E610000000000040696F52C0000000A03CBC4640', 947.578003, 2);
INSERT INTO airportcodes VALUES ('CYXE', 'SASKATOON CANADA', 'SASKATOON', 255, 310, '0101000020E6100000000000C0CCAC5AC0000000C0DC154A40', 794.232483, 2);
INSERT INTO airportcodes VALUES ('CYYZ', 'TORONTO ONT.(PEARSON ARPT)', 'TORONTO', 257, 95, '0101000020E6100000000000C05BE853C000000080AED64540', 676.771362, 2);
INSERT INTO airportcodes VALUES ('CYKN', 'YANKTON  SOUTH DAKOTA  USA', 'YANKTON', 247, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('CYQT', 'THUNDER BAY  ONTARIO  CANADA', 'THUNDER BAY', 250, 35, '0101000020E6100000000000C0BA5456C0000000609A2F4840', 303.86911, 1);
INSERT INTO airportcodes VALUES ('CYWG', 'WINNIPEG MANITOBA CANADA', 'WINNIPEG', 253, 330, '0101000020E6100000000000805A4F58C0000000E07AF44840', 394.92514, 1);
INSERT INTO airportcodes VALUES ('CYVR', 'VANCOUVER  BC  CANADA', 'VANCOUVER', 252, 283, '0101000020E6100000000000A0C6CB5EC0000000C0D1984840', 1432.31335, 3);
INSERT INTO airportcodes VALUES ('STP', 'SAINT PAUL MINNESOTA USA', 'SAINT PAUL DOWNTOWN', 260, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('TEB', 'TETERBORO NEW JERSEY USA', 'TETERBORO', 261, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('SSC', 'SUMTER AFB SOUTH CAROLINA USA', 'SUMTER', 262, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('SAW', 'SABIHA GOKCEN ISTANBUL TURKEY', 'ISTANBUL', 263, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('RJAA', 'NARITA JAPAN', 'NARITA', 264, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('PANC', 'TED STEVENS ANCHORAGE ALASKA USA', 'ANCHORAGE', 265, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('PAFA', 'FAIRBANKS ALASKA USA', 'FAIRBANKS', 266, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('PAED', 'ELMENDORF AFB ANCHORAGE ALASKA USA', 'ELMENDORF AFB', 267, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('MMEX', 'MEXICO CITY MEXICO', 'MEXICO CITY', 268, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('MMU', 'MORRISTOWN NEW JERSEY USA', 'MORRISTOWN', 269, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('MCN', 'MIDDLE GEORGIA USA', 'MIDDLE GEORGIA', 270, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('LFPG', 'PARIS-CHARLES DE GAULLE FRANCE', 'PARIS', 271, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('JQF', 'CONCORD NORTH CAROLINA USA', 'CONCORD', 272, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('GPI', 'GLACIER PARK MONTANA USA', 'GLACIER PARK', 273, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('GJT', 'GRAND JUNCTION COLORADO USA', 'GRAND JUNCTION', 274, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('EVV', 'EVANSVILLE INDIANA USA', 'EVANSVILLE', 275, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('EIL', 'EIELSON AFB ALASKA USA', 'EIELSON AFB', 276, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('EHAM', 'AMSTERDAM AIRPORT SCHIPHOL', 'AMSTERDAM', 277, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('EGLL', 'LONDON HEATHROW UNITED KINGDOM', 'LONDON', 278, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('EDFH', 'FRANKFURT-HAHN GERMANY', 'FRANKFURT', 279, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('EDF', 'ELMENDORF AFB ANCHORAGE ALASKA USA', 'ELMENDORF AFB', 280, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('DYS', 'DYESS AFB TEXAS USA', 'DYESS AFB', 281, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('CYS', 'CHEYENNE WYOMING USA', 'CHEYENNE', 282, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('BIKF', 'KEFLAVIK ICELAND', 'KEFLAVIK', 283, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('BFI', 'BOEING FIELD WASHINGTON USA', 'BOEING FIELD', 284, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('AFW', 'FORT WORTH ALLIANCE TEXAS USA', 'FORT WORTH ALLIANCE', 285, NULL, NULL, NULL, NULL);
INSERT INTO airportcodes VALUES ('AEX', 'ALEXANDRIA LOUISIANA USA', 'ALEXANDRIA', 286, NULL, NULL, NULL, NULL);


--
-- TOC entry 3358 (class 0 OID 128685)
-- Dependencies: 171
-- Data for Name: alias_scheduled; Type: TABLE DATA; Schema: alias; Owner: postgres
--



--
-- TOC entry 3360 (class 0 OID 128778)
-- Dependencies: 185
-- Data for Name: anoms_oag_alias; Type: TABLE DATA; Schema: alias; Owner: postgres
--



--
-- TOC entry 3361 (class 0 OID 128784)
-- Dependencies: 186
-- Data for Name: headinglookup; Type: TABLE DATA; Schema: alias; Owner: postgres
--



--
-- TOC entry 3362 (class 0 OID 128790)
-- Dependencies: 187
-- Data for Name: icao; Type: TABLE DATA; Schema: alias; Owner: postgres
--



--
-- TOC entry 3363 (class 0 OID 128796)
-- Dependencies: 188
-- Data for Name: inm_runup_lookup; Type: TABLE DATA; Schema: alias; Owner: postgres
--



--
-- TOC entry 3364 (class 0 OID 128802)
-- Dependencies: 189
-- Data for Name: inmcode; Type: TABLE DATA; Schema: alias; Owner: postgres
--



--
-- TOC entry 3365 (class 0 OID 128810)
-- Dependencies: 191
-- Data for Name: inmcode_lookup; Type: TABLE DATA; Schema: alias; Owner: postgres
--



--
-- TOC entry 3366 (class 0 OID 128816)
-- Dependencies: 192
-- Data for Name: mac_airport_aoi; Type: TABLE DATA; Schema: alias; Owner: postgres
--



--
-- TOC entry 3355 (class 0 OID 128505)
-- Dependencies: 163
-- Data for Name: mactype; Type: TABLE DATA; Schema: alias; Owner: postgres
--

INSERT INTO mactype VALUES ('7ECA', 'P', '7ECA.jpg', NULL, 'Bellanca 7ECA', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('B707', '3', 'B707.jpg', 105.5, 'Boeing 707 Modified Stage 3', false, '3', 'J', 'M', NULL);
INSERT INTO mactype VALUES ('A700', '3', 'A700.jpg', NULL, 'Adam Aircraft A-700', true, '3', 'J', '', NULL);
INSERT INTO mactype VALUES ('AC12', 'P', 'AC11.jpg', NULL, 'Rockwell Aero Commander 112', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('AC60', 'P', 'AC60.jpg', NULL, 'Rockwell Turbo Commander 690', false, 'T', 'T', 'P', NULL);
INSERT INTO mactype VALUES ('AC14', 'P', 'AC14.jpg', NULL, 'Rockwell Commander 114', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('BL7', 'P', 'CH7.jpg', NULL, 'American Champion', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('AG5B', 'P', 'AA5.jpg', NULL, 'Grumman American AG5B', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('AMPH', 'P', 'AMPH.jpg', NULL, 'Floatplane', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('B17', 'P', 'B17.jpg', NULL, 'B-17 Flying Fortress', false, 'P', 'PM', '', NULL);
INSERT INTO mactype VALUES ('B24', 'P', 'B24.jpg', NULL, 'B-24 Liberator', false, 'P', 'PM', '', NULL);
INSERT INTO mactype VALUES ('B58P', 'P', 'B58P.jpg', NULL, 'Beechcraft Baron BE-58P Twin', false, 'P', 'PM', '', NULL);
INSERT INTO mactype VALUES ('B60', 'P', 'BE60.jpg', NULL, 'Beechcraft Duke Twin', false, 'P', 'PM', '', NULL);
INSERT INTO mactype VALUES ('BE52', 'P', 'BE55.jpg', NULL, 'Beech Baron 95-B55', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('BE59', 'P', 'BE58.jpg', NULL, 'Beechcraft Baron BE-58', false, 'P', 'PM', '', NULL);
INSERT INTO mactype VALUES ('BL26', 'P', 'BL26.jpg', NULL, 'Bellanca Viking', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('BS20', 'P', 'BE20.jpg', NULL, 'Beechcraft King Air 200', false, 'T', 'T', '', NULL);
INSERT INTO mactype VALUES ('BT6S', 'P', 'BT6S.jpg', NULL, 'Beagle 206', false, 'P', 'PM', '', NULL);
INSERT INTO mactype VALUES ('DIAM', 'P', 'DA20.jpg', NULL, 'Diamond Aircraft DA-20', false, 'P', 'PS', 'J', NULL);
INSERT INTO mactype VALUES ('CUBS', 'P', 'PA18.jpg', NULL, 'Piper Super Cub', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('CH7', 'P', 'CH7.jpg', NULL, 'American Champion', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('C218', 'P', 'C208.jpg', NULL, 'Cessna Single', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('C21P', 'P', 'C210.jpg', NULL, 'Cessna Centurion 210', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('C21T', 'P', 'C421.jpg', NULL, 'Cessna Golden Eagle 421', false, 'P', 'PM', '', NULL);
INSERT INTO mactype VALUES ('C25B', '3', 'C25B.jpg', NULL, 'Cessna Citation CJ3', true, '3', 'J', '', NULL);
INSERT INTO mactype VALUES ('C30J', 'U', 'UKN.jpg', NULL, 'Lockheed C130 Hercules', false, 'T', 'T', '', NULL);
INSERT INTO mactype VALUES ('C400', 'P', 'C400.jpg', NULL, 'Cessna 400', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('C401', 'P', 'C401.jpg', NULL, 'Cessna 401 Twin', false, 'P', 'PM', '', NULL);
INSERT INTO mactype VALUES ('C510', '3', 'C510.jpg', NULL, 'Cessna Citation Mustang', true, '3', 'J', '', NULL);
INSERT INTO mactype VALUES ('C77', 'P', 'C177.jpg', NULL, 'Cessna Cardinal 177 RG', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('CE35', 'P', 'CE35.jpg', NULL, 'Hawker Beechcraft G36', NULL, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('CESSNA', 'P', 'C172.jpg', NULL, 'Cessna', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('CH60', 'P', 'CH60.jpg', NULL, 'AMD Zodiac', NULL, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('CITB', 'P', 'CH18.jpg', NULL, 'Champion Citabria', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('CL7', 'P', 'CH7.jpg', NULL, 'American Champion', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('COL', 'P', 'LANC.jpg', NULL, 'Lancair Columbia', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('COUR', 'P', 'COUR.jpg', NULL, 'Super Courier', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('CTSW', 'P', 'CTSW.jpg', NULL, 'Flight Design CTSW', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('CUB', 'P', 'CUB.jpg', NULL, 'Piper Cub', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('CUR', 'P', 'CUR.jpg', NULL, 'Helio HT-295 Super Courier', NULL, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('DECA', 'P', 'DECA.jpg', NULL, 'Bellanca Decathlon', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('DH6', 'P', 'DH6.jpg', NULL, 'De Havilland DH-6', false, 'P', 'PM', '', NULL);
INSERT INTO mactype VALUES ('E90', 'P', 'BE90.jpg', NULL, 'Beech King Air 90', false, 'T', 'T', '', NULL);
INSERT INTO mactype VALUES ('EA23', 'P', 'EA23.jpg', NULL, 'Extra', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('EA40', 'P', 'EA40.jpg', NULL, 'Extra 400', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('EXP', 'P', 'EXP.jpg', NULL, 'Experimental', NULL, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('EXPR', 'P', 'EXP.jpg', NULL, 'Experimental', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('F02', 'P', 'F02.jpg', NULL, 'Alon A2', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('F33A', 'P', 'F33A.jpg', NULL, 'Beechcraft F33A Bonanza', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('G150', '3', 'GALX.jpg', NULL, 'Gulfstream G150', false, '3', 'J', '', NULL);
INSERT INTO mactype VALUES ('GC1B', 'P', 'GC1B.jpg', NULL, 'Globe GC-1B', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('GLAS', 'P', 'GLAS.jpg', NULL, 'Glasair', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('LR45', '3', 'LJ45.jpg', NULL, 'Learjet 45', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('GOV1', 'P', 'GOV1.jpg', NULL, 'Grumman Mohawk OV-1', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('PARO', 'P', 'PARO.jpg', NULL, 'Piper Arrow', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('GLST', 'P', 'GLST.jpg', NULL, 'Glastar', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('PASE', 'P', 'PASE.jpg', NULL, 'Piper Seneca Twin', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('H500', 'P', 'H500.jpg', NULL, 'Dee Howard Company 500', false, 'P', 'PM', '', NULL);
INSERT INTO mactype VALUES ('PAZT', 'P', 'PA27.jpg', NULL, 'Piper Aztec Twin', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('HSKY', 'P', 'HSKY.jpg', NULL, 'Aviat Husky A-1', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('MO20', 'P', 'M20.jpg', NULL, 'Mooney M-20', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('MAUL', 'P', 'MAUL.jpg', NULL, 'Maule', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('NAVR', 'P', 'NAVI.jpg', NULL, 'Ryan Navion', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('LAN', 'P', 'LAN.jpg', NULL, 'Lancair 360', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('LANC', 'P', 'LANC.jpg', NULL, 'Lancair Columbia', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('LNS2', 'P', 'LAN.jpg', NULL, 'Lancair 360 SFB', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('M20A', 'P', 'M20A.jpg', NULL, 'Mooney M-20A', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('M20C', 'P', 'M20C.jpg', NULL, 'Mooney M-20C', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('M20E', 'P', 'M20E.jpg', NULL, 'Mooney M-20E', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('M20F', 'P', 'M20F.jpg', NULL, 'Mooney M-20F', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('M20G', 'P', 'M20G.jpg', NULL, 'Mooney M-20G', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('M20J', 'P', 'M20J.jpg', NULL, 'Mooney M-20J', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('M20K', 'P', 'M20K.jpg', NULL, 'Mooney M-20K', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('M20L', 'P', 'M20L.jpg', NULL, 'Mooney M-20L Pegasus', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('M20M', 'P', 'M20M.jpg', NULL, 'Mooney M-20M', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('M20R', 'P', 'M20R.jpg', NULL, 'Mooney M-20R', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('M20S', 'P', 'M20S.jpg', NULL, 'Mooney M-20S', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('M35', 'P', 'BE35.jpg', NULL, 'Beech M35', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('MS76', '3', 'MS76.jpg', NULL, 'Morane-Sauliner MS 760', true, '3', 'J', '', NULL);
INSERT INTO mactype VALUES ('P284', 'P', 'P284.jpg', NULL, 'Piper Arrow RT', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('P36T', 'P', 'PA36.jpg', NULL, 'Piper Pawnee Brave', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('PA28', 'P', 'PA28.jpg', NULL, 'Piper Cherokee', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('PA60', 'P', 'PA60.jpg', NULL, 'Piper Aerostar', false, 'P', 'PM', '', NULL);
INSERT INTO mactype VALUES ('PAYE', 'P', 'PAY1.jpg', NULL, 'Piper Cheyenne Twin', false, 'T', 'T', '', NULL);
INSERT INTO mactype VALUES ('PITZ', 'P', 'PITS.jpg', NULL, 'Pitts Aviat S-1-11B', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('GL5T', 'P', 'GL5T.jpg', 82.700000000000003, 'Bombardier BD-700', false, 'P', 'PM', '', NULL);
INSERT INTO mactype VALUES ('A36', 'P', 'BE36.jpg', NULL, 'Beechcraft Bonanza 36/ BEECH A36', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('B7377', '3', 'B737.jpg', 85.900000000000006, 'Boeing 737-700', true, '3', 'J', 'C', 'B737');
INSERT INTO mactype VALUES ('A300', '3', 'A306.jpg', 91.5, 'Airbus Industries A300', true, '3', 'J', 'C', NULL);
INSERT INTO mactype VALUES ('B717', '3', 'B712.jpg', 84.099999999999994, 'Boeing 717', true, '3', 'J', 'C', 'B717');
INSERT INTO mactype VALUES ('B757', '3', 'B752.jpg', 91.400000000000006, 'Boeing 757-200', true, '3', 'J', 'C', 'B757');
INSERT INTO mactype VALUES ('LJ36', '3', 'LJ36.jpg', 84.5, 'Learjet 36', true, '3', 'J', '', NULL);
INSERT INTO mactype VALUES ('C56X', '3', 'C560.jpg', 72.400000000000006, 'Cessna Citation Jet 560XL', true, '3', 'J', '', NULL);
INSERT INTO mactype VALUES ('LJ29', '2', 'LJ28.jpg', 87, 'Learjet 29', false, '2', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('DA10', '3', 'DA10.jpg', 82.200000000000003, 'Dassault Falcon Jet 10', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('LR31', '3', 'LJ31A.jpg', 82.900000000000006, 'Learjet 31A', false, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('P200', 'P', 'P200.jpg', NULL, 'Tecnam Bravo', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('LA42', 'U', 'UKN.jpg', NULL, 'Unknown', false, NULL, NULL, '', NULL);
INSERT INTO mactype VALUES ('HA1B', 'P', 'HSKY.jpg', NULL, 'Aviat Aircraft A-1B', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('EA50', '3', 'EA50.jpg', NULL, 'Eclipse 500', true, '3', 'J', '', NULL);
INSERT INTO mactype VALUES ('CRJ', '3', 'CRJ1.jpg', 84.599999999999994, 'Canadair Regional Jet-CRJ', true, '3', 'J', 'C', 'CRJ');
INSERT INTO mactype VALUES ('B767', '3', 'B763.jpg', 92.099999999999994, 'Boeing 767-200', true, '3', 'J', 'C', 'B767');
INSERT INTO mactype VALUES ('B777', '3', 'B772.jpg', 96.200000000000003, 'Boeing 777', true, '3', 'J', 'C', 'B777');
INSERT INTO mactype VALUES ('T33', 'M', 'T33.jpg', NULL, 'T-33 Shooting Star', NULL, 'M', 'J', 'M', NULL);
INSERT INTO mactype VALUES ('RJ85', '3', 'RJ85.jpg', 84.900000000000006, 'Avro RJ85', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('B206', 'H', 'B06.jpg', NULL, 'BELL 206', false, 'H', 'H', 'H', NULL);
INSERT INTO mactype VALUES ('C90', 'P', 'C90.jpg', NULL, 'Beechcraft King Air C90', false, 'T', 'T', '', NULL);
INSERT INTO mactype VALUES ('PUSH', 'P', 'PUSH.jpg', NULL, 'Prescott Pusher', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('T34', 'P', 'MENT.jpg', NULL, 'T-34A Mentor', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('VC10', 'M', 'VC10.jpg', 100.5, 'Vickers VC10', false, 'M', 'M', 'M', NULL);
INSERT INTO mactype VALUES ('RC70', 'P', 'RC700.jpg', NULL, 'Rockwell Commander 700', false, 'P', 'PM', '', NULL);
INSERT INTO mactype VALUES ('RV', 'P', 'RV10.jpg', NULL, 'Vans', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('RV10', 'P', 'RV10.jpg', NULL, 'Vans RV-10', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('RV4', 'P', 'RV4.jpg', NULL, 'Vans RV-4', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('RV6', 'P', 'RV6.jpg', NULL, 'Vans RV-6', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('RV7A', 'P', 'RV9A.jpg', NULL, 'Vans RV-7', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('RV8', 'P', 'RV8.jpg', NULL, 'Vans RV-8', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('RV9', 'P', 'RV9A.jpg', NULL, 'Vans RV-9', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('S38', 'P', 'S38.jpg', NULL, 'Sikorsky S-38', false, 'P', 'PM', '', NULL);
INSERT INTO mactype VALUES ('SCUB', 'P', 'SCUB.jpg', NULL, 'Aero Kuhlmann Scub', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('SF20', 'P', 'SF20.jpg', NULL, 'Siai-Marchetti SF260', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('SIRA', 'P', 'SIRA.jpg', NULL, 'Tecnam Sierra', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('SR22', 'P', 'SR22.jpg', NULL, 'Cirrus SR-22', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('SS2P', 'P', 'SS2P.jpg', NULL, 'Rockwell Thrush Commander', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('STIL', 'P', 'STIL.jpg', NULL, 'Terzi T-9 Stiletto', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('T210', 'P', 'C210.jpg', NULL, 'Cessna 210T', false, 'T', 'T', '', NULL);
INSERT INTO mactype VALUES ('T30', 'P', 'T30.jpg', NULL, 'Terzi Katana', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('T310', 'P', 'T310.jpg', NULL, 'Cessna T-310', false, 'P', 'PM', '', NULL);
INSERT INTO mactype VALUES ('T45', 'M', 'T45.jpg', NULL, 'T-45 Goshawk', false, 'M', 'M', '', NULL);
INSERT INTO mactype VALUES ('TB20', 'P', 'TB20.jpg', NULL, 'Socata TB-20 Trinidad', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('TBM', 'P', 'TBM.jpg', NULL, 'Socata TBM', false, 'T', 'T', '', NULL);
INSERT INTO mactype VALUES ('Y52', 'U', 'UKN.jpg', NULL, 'Unknown', false, NULL, NULL, '', NULL);
INSERT INTO mactype VALUES ('BA11', '3', 'BA11.jpg', 97, 'BAC 1-11 Modified Stage 3', false, '3', 'J', 'C', NULL);
INSERT INTO mactype VALUES ('E135', '3', 'E135.jpg', 77.900000000000006, 'Embraer 135', true, '3', 'J', 'C', NULL);
INSERT INTO mactype VALUES ('F28', '2', 'F28.jpg', NULL, 'Fokker 28', false, '2', 'J', 'C', NULL);
INSERT INTO mactype VALUES ('J328', '3', 'J328.jpg', 76.5, 'Fairchild Dornier 328', true, '3', 'J', 'C', NULL);
INSERT INTO mactype VALUES ('L101', '3', 'L101.jpg', 99.299999999999997, 'Lockheed L-1011', true, '3', 'J', 'C', NULL);
INSERT INTO mactype VALUES ('BE40', '3', 'BE40.jpg', NULL, 'Raytheon Beechjet 400', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('C680', '3', 'C680.jpg', NULL, 'Cessna Citation Jet 680 Sovereign', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('CL30', '3', 'CL30.jpg', NULL, 'Canadair CL30', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('CL60', '3', 'CL64.jpg', NULL, 'Canadair Challenger', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('GLF2', '2', 'GLF2.jpg', NULL, 'Gulfstream II', false, '2', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('GLF3', '2', 'GLF3.jpg', NULL, 'Gulfstream III', false, '2', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('JCOM', '3', 'JCOM.jpg', NULL, 'Rockwell 1121 Jet Commander', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('MU30', '3', 'MU3.jpg', NULL, 'Mitsubishi MU 300', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('WW23', '3', 'WW23.jpg', NULL, 'IAI 1123 Westwind', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('A109', 'H', 'A109.jpg', NULL, 'Agusta 109', false, 'H', 'H', 'H', NULL);
INSERT INTO mactype VALUES ('B117', 'H', 'B117.jpg', NULL, 'Eurocopter BK-117', false, 'H', 'H', 'H', NULL);
INSERT INTO mactype VALUES ('B222', 'H', 'B222.jpg', NULL, 'BELL 222', false, 'H', 'H', 'H', NULL);
INSERT INTO mactype VALUES ('EC35', 'H', 'EC35.jpg', NULL, 'Eurocopter EC-135', false, 'H', 'H', 'H', NULL);
INSERT INTO mactype VALUES ('H269', 'H', 'HU30.jpg', NULL, 'Schweizer Helicopter 269C', false, 'H', 'H', 'H', NULL);
INSERT INTO mactype VALUES ('HELO', 'H', 'UKN.jpg', NULL, 'Helicopter', false, 'H', 'H', 'H', NULL);
INSERT INTO mactype VALUES ('GALX', '3', 'GALX.jpg', NULL, 'Gulfstream Galaxy G200', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('GLF5', '3', 'GLF5.jpg', NULL, 'Gulfstream V', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('MD90', '3', 'MD90.jpg', 84.200000000000003, 'McDonnell Douglas MD90', true, '3', 'J', 'C', 'MD90');
INSERT INTO mactype VALUES ('E170', '3', 'E170.jpg', 83.700000000000003, 'Embraer 170', true, '3', 'J', 'C', 'E170');
INSERT INTO mactype VALUES ('DC10', '3', 'DC10.jpg', 101.8, 'McDonnell Douglas DC10', true, '3', 'J', 'C', 'DC10');
INSERT INTO mactype VALUES ('A319', '3', 'A319.jpg', 87.400000000000006, 'Airbus Industries A319', true, '3', 'J', 'C', 'A319');
INSERT INTO mactype VALUES ('A330', '3', 'A333.jpg', 95.599999999999994, 'Airbus Industries A330', true, '3', 'J', 'C', 'A330');
INSERT INTO mactype VALUES ('B72Q', '3', 'B72Q.jpg', 97.599999999999994, 'Boeing 727 Modified Stage 3', false, '3', 'J', 'C', 'B727');
INSERT INTO mactype VALUES ('B73Q', '3', 'B73Q.jpg', 91.400000000000006, 'Boeing 737 Modified Stage 3', false, '3', 'J', 'C', 'B737');
INSERT INTO mactype VALUES ('B47G', 'H', 'B47G.jpg', NULL, 'BELL 47G', false, 'H', 'H', 'H', NULL);
INSERT INTO mactype VALUES ('B06', 'H', 'B06.jpg', NULL, 'Bell 206', false, 'H', 'H', 'H', NULL);
INSERT INTO mactype VALUES ('A318', '3', 'A318.jpg', 84.099999999999994, 'Airbus Industries A318', true, '3', 'J', 'C', 'A318');
INSERT INTO mactype VALUES ('E190', '3', 'E190.jpg', 86.900000000000006, 'Embraer 190', true, '3', 'J', 'C', NULL);
INSERT INTO mactype VALUES ('B737', '3', 'B737.jpg', 88.900000000000006, 'Boeing 737', true, '3', 'J', 'C', 'B737');
INSERT INTO mactype VALUES ('H25B', '3', 'H25B.jpg', 92.299999999999997, 'Hawker 125 Jet', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('SBR2', '3', 'SBR65.jpg', 90.700000000000003, 'Rockwell Sabreliner 70/75', true, '3', 'J', '', NULL);
INSERT INTO mactype VALUES ('PRE1', '3', 'PRM1.jpg', 76.599999999999994, 'Raytheon Premier', true, '3', 'J', '', NULL);
INSERT INTO mactype VALUES ('LJ35', '3', 'LJ35.jpg', 84.5, 'Learjet 35', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('LJ31', '3', 'LJ31.jpg', 82.900000000000006, 'Learjet 31', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('LJ55', '3', 'LJ55.jpg', 87, 'Learjet 55', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('C500', '3', 'C500.jpg', 78, 'Cessna Citation Jet 500', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('C501', '3', 'C501.jpg', 78, 'Cessna Citation Jet 501', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('C525', '3', 'C525.jpg', 74.5, 'Cessna Citation Jet 525', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('C550', '3', 'C550.jpg', 80.099999999999994, 'Cessna Citation Jet 550', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('C551', '3', 'C551.jpg', 80.099999999999994, 'Cessna Citation Jet 551', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('C560', '3', 'C560.jpg', 84.599999999999994, 'Cessna Citation Jet 560', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('C650', '3', 'C650.jpg', 84.900000000000006, 'Cessna Citation Jet 650', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('F2TH', '3', 'F2TH.jpg', 79.400000000000006, 'Dassault Falcon 2000', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('FA20', '3', 'FA20.jpg', 83.900000000000006, 'Falcon 200', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('F900', '3', 'F900.jpg', 82.900000000000006, 'Falcon  900', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('FA50', '3', 'FA50.jpg', 84.799999999999997, 'Falcon 50', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('WW24', '3', 'WW24.jpg', 85.400000000000006, 'IAI 1124 Westwind', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('UKN', 'U', 'UKN.jpg', NULL, 'Unknown', false, NULL, NULL, '', NULL);
INSERT INTO mactype VALUES ('DC9Q', '3', 'DC9Q.jpg', 98.099999999999994, 'McDonnell Douglas DC9 Modified Stage 3', false, '3', 'J', 'C', 'DC9');
INSERT INTO mactype VALUES ('E145', '3', 'E145.jpg', 83.700000000000003, 'Embraer 145', true, '3', 'J', 'C', 'E145');
INSERT INTO mactype VALUES ('DC8Q', '3', 'DC8Q.jpg', 95.700000000000003, 'McDonnell Douglas DC8 Re-manufactured', true, '3', 'J', 'C', NULL);
INSERT INTO mactype VALUES ('MD11', '3', 'MD11.jpg', 92.799999999999997, 'McDonnell Douglas MD11', true, '3', 'J', 'C', NULL);
INSERT INTO mactype VALUES ('B741', '3', 'B741.jpg', 109.40000000000001, 'Boeing 747-100', true, '3', 'J', 'C', 'B747');
INSERT INTO mactype VALUES ('A310', '3', 'A310.jpg', 92.900000000000006, 'Airbus Industries A310', true, '3', 'J', 'C', NULL);
INSERT INTO mactype VALUES ('B738', '3', 'B738.jpg', 88.599999999999994, 'Boeing 737-800', true, '3', 'J', 'C', 'B737');
INSERT INTO mactype VALUES ('B742', '3', 'B742.jpg', 110, 'Boeing 747-200', true, '3', 'J', 'C', 'B747');
INSERT INTO mactype VALUES ('B743', '3', 'B743.jpg', 105.5, 'Boeing 747-300', true, '3', 'J', 'C', 'B747');
INSERT INTO mactype VALUES ('B744', '3', 'B744.jpg', 101.59999999999999, 'Boeing 747-400', true, '3', 'J', 'C', 'B747');
INSERT INTO mactype VALUES ('B733', '3', 'B733.jpg', 87.5, 'Boeing 737-300', true, '3', 'J', 'C', 'B737');
INSERT INTO mactype VALUES ('B734', '3', 'B734.jpg', 88.900000000000006, 'Boeing 737-400', true, '3', 'J', 'C', 'B737');
INSERT INTO mactype VALUES ('B735', '3', 'B735.jpg', 87.700000000000003, 'Boeing 737-500', true, '3', 'J', 'C', 'B737');
INSERT INTO mactype VALUES ('B736', '3', 'B736.jpg', 85.700000000000003, 'Boeing 737-600', true, '3', 'J', 'C', 'B737');
INSERT INTO mactype VALUES ('MD80', '3', 'MD80.jpg', 91.5, 'McDonnell Douglas MD80', true, '3', 'J', 'C', 'MD80');
INSERT INTO mactype VALUES ('GLF4', '3', 'GLF4.jpg', NULL, 'Gulfstream IV/G450', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('COL3', 'P', 'COL3.jpg', NULL, 'Lancair Columbia 300', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('B190', 'P', 'B190.jpg', NULL, 'Beechcraft 1900', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('BE10', 'P', 'BE10.jpg', NULL, 'Beechcraft King Air 100', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('BE20', 'P', 'BE20.jpg', NULL, 'Beechcraft King Air 200', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('BE30', 'P', 'BE30.jpg', NULL, 'Beechcraft King Air 300', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('BE9L', 'P', 'BE9L.jpg', NULL, 'Beechcraft King Air 90', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('F100', '3', 'F100.jpg', 81.799999999999997, 'Fokker 100/Fokker 70', true, '3', 'J', 'C', NULL);
INSERT INTO mactype VALUES ('C208', 'P', 'C208.jpg', NULL, 'Cessna 208', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('C425', 'P', 'C425.jpg', NULL, 'Cessna Corsair 425', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('C441', 'P', 'C441.jpg', NULL, 'Cessna Conquest 441', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('D328', '3', 'D328.jpg', 76.5, 'Fairchild Dornier 328', true, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('DHC6', 'P', 'DHC2.jpg', NULL, 'DE HAVILLAND TWIN OTTER', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('G159', 'P', 'G159.jpg', NULL, 'Gulfstream American G-1159', false, 'P', 'PM', 'T', NULL);
INSERT INTO mactype VALUES ('MU2', 'P', 'MU2.jpg', NULL, 'Mitsubishi MU-2', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('PC6T', 'P', 'PC6P.jpg', NULL, 'Pilatus PC-6 Turbo Porter', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('SH33', 'P', 'SH33.jpg', NULL, 'Short 330', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('SH36', 'P', 'SH33.jpg', NULL, 'Short 336', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('STAR', 'P', 'STAR.jpg', NULL, 'Beechcraft 2000 Starship', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('P210', 'P', 'C210.jpg', NULL, 'Cessna Centurion 210', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('P28A', 'P', 'P28A.jpg', NULL, 'Piper Warrior', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('P28B', 'P', 'P28B.jpg', NULL, 'Piper Cherokee Dakota', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('P32R', 'P', 'P32T.jpg', NULL, 'Piper Lance/Saratoga', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('SW2', 'P', 'SW3.jpg', NULL, 'Swearingen Merlin II', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('PA17', 'P', 'PA17.jpg', NULL, 'Piper Vagabond', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('PA22', 'P', 'PA22.jpg', NULL, 'Piper Tri-Pacer/Colt', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('PA23', 'P', 'PA23.jpg', NULL, 'Piper Apache Twin', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('PA24', 'P', 'PA24.jpg', NULL, 'Piper Comanche', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('PA25', 'P', 'PA25.jpg', NULL, 'Piper Pawnee', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('PA30', 'P', 'PA30.jpg', NULL, 'Piper Twin Comanche', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('PA31', 'P', 'PA31.jpg', NULL, 'Piper Navajo Twin', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('PA32', 'P', 'PA32.jpg', NULL, 'Piper Cherokee Six', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('PA38', 'P', 'PA38.jpg', NULL, 'Piper Tomahawk', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('PA36', 'P', 'PA36.jpg', NULL, 'Piper Pawnee Brave', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('C130', 'U', 'UKN.jpg', NULL, 'Lockheed C-130 Hercules', false, 'M', 'M', 'M', NULL);
INSERT INTO mactype VALUES ('C9', 'U', 'UKN.jpg', NULL, 'Unknown', false, 'M', 'M', 'M', NULL);
INSERT INTO mactype VALUES ('T37', 'M', 'T37.jpg', NULL, 'Cessna T-37', false, 'M', 'M', 'M', NULL);
INSERT INTO mactype VALUES ('AA5', 'P', 'AA5.jpg', NULL, 'Grumman American', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('AC50', 'P', 'AC50.jpg', NULL, 'Rockwell Aero Commander 500', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('AEST', 'P', 'AEST.jpg', NULL, 'Piper Aerostar 600', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('B14A', 'P', 'B14A.jpg', NULL, 'Bellanca 14', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('BE18', 'P', 'BE18.jpg', NULL, 'Beechcraft 18 Twin', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('BE23', 'P', 'BE23.jpg', NULL, 'Beechcraft Musketeer', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('BE24', 'P', 'BE24.jpg', NULL, 'Beechcraft Sierra/Sundowner', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('BE33', 'P', 'BE33.jpg', NULL, 'Beechcraft Debonair/Bonanza', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('BE35', 'P', 'BE35.jpg', NULL, 'Beechcraft Bonanza 35', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('BE50', 'P', 'BE50.jpg', NULL, 'Beechcraft Bonanza Twin', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('BE55', 'P', 'BE55.jpg', NULL, 'Beechcraft Baron BE-55', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('BE58', 'P', 'BE58.jpg', NULL, 'Beechcraft Baron BE-58', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('BE60', 'P', 'BE60.jpg', NULL, 'Beechcraft Duke Twin', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('BE76', 'P', 'BE76.jpg', NULL, 'Beechcraft Duchess Twin', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('BE80', 'P', 'BE80.jpg', NULL, 'Beechcraft Queen Air 80', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('BE95', 'P', 'BE95.jpg', NULL, 'Beechcraft Travel Air', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('BL17', 'P', 'BL17.jpg', NULL, 'Bellanca Super Viking', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('C150', 'P', 'C150.jpg', NULL, 'Cessna 150', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('C152', 'P', 'C152.jpg', NULL, 'Cessna 152', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('C170', 'P', 'C170.jpg', NULL, 'Cessna 170', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('C172', 'P', 'C172.jpg', NULL, 'Cessna Skyhawk 172', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('C177', 'P', 'C177.jpg', NULL, 'Cessna Cardinal 177', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('C180', 'P', 'C185.jpg', NULL, 'Cessna Skywagon 180', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('C182', 'P', 'C182.jpg', NULL, 'Cessna Skylane 182', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('C185', 'P', 'C185.jpg', NULL, 'Cessna Skywagon 185', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('C188', 'P', 'C188.jpg', NULL, 'Cessna 188  AgWagon/AgTruck', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('C205', 'P', 'C205.jpg', NULL, 'Cessna 205', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('C207', 'P', 'C207.jpg', NULL, 'Cessna 207', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('C210', 'P', 'C210.jpg', NULL, 'Cessna Centurion 210', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('C303', 'P', 'C303.jpg', NULL, 'Cessna Crusader 303', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('C310', 'P', 'C310.jpg', NULL, 'Cessna 310 Twin', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('C320', 'P', 'C320.jpg', NULL, 'Cessna Executive Skynight', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('C335', 'P', 'C335.jpg', NULL, 'Cessna Twin 335', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('C336', 'P', 'C337.jpg', NULL, 'Cessna Skymaster 336', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('C337', 'P', 'C337.jpg', NULL, 'Cessna Skymaster 337', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('C402', 'P', 'C402.jpg', NULL, 'Cessna 402 Twin', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('C404', 'P', 'C404.jpg', NULL, 'Cessna 404 Titan', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('C414', 'P', 'C414.jpg', NULL, 'Cessna 414 Twin', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('C421', 'P', 'C421.jpg', NULL, 'Cessna Golden Eagle 421', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('DC3', 'P', 'DC3.jpg', NULL, 'McDonnell Douglas DC3', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('DHC2', 'P', 'DHC2.jpg', NULL, 'De Havilland Canada Beaver', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('G164', 'P', 'G164.jpg', NULL, 'Gruman Ag-Cat', false, 'P', 'P', 'P', NULL);
INSERT INTO mactype VALUES ('G2T1', 'P', 'G2T1.jpg', NULL, 'Great Lakes Sport Trainer', false, 'P', 'P', 'P', NULL);
INSERT INTO mactype VALUES ('GA7', 'P', 'GA7.jpg', NULL, 'Grumman Cougar', false, 'P', 'P', 'P', NULL);
INSERT INTO mactype VALUES ('LA4', 'P', 'LA4.jpg', NULL, 'Lake Buccaneer', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('LNC4', 'P', 'COL4.jpg', NULL, 'Lancair Columbia 400', NULL, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('M20P', 'P', 'M20P.jpg', NULL, 'Mooney M-20P', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('M20T', 'P', 'M20T.jpg', NULL, 'Mooney M-20T', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('PA44', 'P', 'PA44.jpg', NULL, 'Piper Seminole Twin', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('PA46', 'P', 'PA46.jpg', NULL, 'Piper Malibu', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('PC6P', 'P', 'PC6P.jpg', NULL, 'Pilatus PC-6 Porter', false, 'P', 'P', 'P', NULL);
INSERT INTO mactype VALUES ('SR20', 'P', 'SR20.jpg', NULL, 'Cirrus SR-20', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('AC90', 'P', 'AC90.jpg', NULL, 'Rockwell Turbo Commander 900', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('SW3', 'P', 'SW3.jpg', NULL, 'Swearingen Merlin III', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('SW4', 'P', 'SW3.jpg', NULL, 'Swearingen Merlin IV', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('T34T', 'P', 'MENT.jpg', NULL, 'T-34 Turbo Mentor', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('TBM7', 'P', 'TBM7.jpg', NULL, 'Socata TBM 700', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('B350', 'P', 'B350.jpg', NULL, 'Beechcraft King Air 350', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('P46T', 'P', 'PA46.jpg', NULL, 'Piper Malibu Meridian', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('PAY2', 'P', 'PAY2.jpg', NULL, 'Piper Cheyenne II Twin', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('PAY3', 'P', 'PAY3.jpg', NULL, 'Piper Cheyenne III Twin', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('PRM1', '3', 'PRM1.jpg', 76.599999999999994, 'Raytheon Premier', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('E110', 'P', 'E110.jpg', NULL, 'Embraer EMB-110 Bandeirante', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('JS41', 'P', 'JS41.jpg', NULL, 'Jetstream 4101 Twin/Handley Page Regional Airliner', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('BE65', 'P', 'BE65.jpg', NULL, 'Beechcraft Queen Air 65', false, 'P', 'PM', 'P', 'BE65');
INSERT INTO mactype VALUES ('BE99', 'P', 'BE99.jpg', NULL, 'Beechcraft 99', false, 'T', 'T', 'T', 'BE99');
INSERT INTO mactype VALUES ('PTS1', 'P', 'PTS1.jpg', NULL, 'Pitts S-1 Special', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('N262', 'P', 'N262.jpg', NULL, 'NORD Aviation Fregate', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('SF34', 'P', 'SF34.jpg', NULL, 'SAAB 340', false, 'T', 'T', 'T', 'SF34');
INSERT INTO mactype VALUES ('PAY4', 'P', 'PAY4.jpg', NULL, 'Piper Cheyenne 400 Twin', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('PC12', 'P', 'PC12.jpg', NULL, 'Pilatus PC-12', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('L8', 'P', 'L8.jpg', NULL, 'Luscombe 8', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('P180', 'P', 'P180.jpg', NULL, 'Piaggio P-180 Avanti', false, 'T', 'T', 'P', NULL);
INSERT INTO mactype VALUES ('P51', 'P', 'P51.jpg', NULL, 'P-51 Mustang', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('P68', 'P', 'P68.jpg', NULL, 'P-68 Observer', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('PA20', 'P', 'PA22.jpg', NULL, 'Piper Pacer', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('AA1', 'P', 'AA1.jpg', NULL, 'American Aviation AA-1', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('B25', 'P', 'B25.jpg', NULL, 'B-25 Mitchell', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('BE17', 'P', 'BE17.jpg', NULL, 'Beech D17S Staggerwing', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('BE19', 'P', 'BE23.jpg', NULL, 'Beechcraft Sport', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('BE36', 'P', 'BE36.jpg', NULL, 'Beechcraft Bonanza 36', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('C120', 'P', 'C120.jpg', NULL, 'Cessna 120', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('C140', 'P', 'C140.jpg', NULL, 'Cessna 140', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('C175', 'P', 'C175.jpg', NULL, 'Cessna 175', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('C195', 'P', 'C195.jpg', NULL, 'Cessna 195', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('C206', 'P', 'C206.jpg', NULL, 'Cessna 206', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('DG15', 'P', 'DG15.jpg', NULL, 'Howard DGA-15P', NULL, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('DA20', 'P', 'DV20.jpg', NULL, 'Diamond Katana', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('DA40', 'P', 'DA40.jpg', NULL, 'Diamond Star DA-40', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('DA42', 'P', 'DA42.jpg', NULL, 'Diamond Twin Star', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('E400', 'P', 'E401.jpg', NULL, 'EXTRA FLUGZEUGBAU', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('ERCO', 'P', 'ERCO.jpg', NULL, 'AeroCoupe', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('G115', 'P', 'G115.jpg', NULL, 'Grob G-115', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('GC1', 'P', 'GC1.jpg', NULL, 'Swift GC-1', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('LA25', 'P', 'LA25.jpg', NULL, 'Lake 250', false, 'P', 'P', 'P', NULL);
INSERT INTO mactype VALUES ('NAVI', 'P', 'NAVI.jpg', NULL, 'North American Navion', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('RALL', 'P', 'RALL.jpg', NULL, 'Morane-Sauliner Rallye', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('RANG', 'P', 'RANG.jpg', NULL, 'Navion Rangemaster', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('S108', 'P', 'S108.jpg', NULL, 'Stinson 108', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('ST75', 'P', 'ST75.jpg', NULL, 'Boeing Stearman PT-17', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('T28', 'P', 'T28.jpg', NULL, 'T-28 Nomair', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('T6', 'P', 'T6.jpg', NULL, 'T-6 TEXAN', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('TNAV', 'P', 'TNAV.jpg', NULL, 'Temco Twin Navion', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('TOBA', 'P', 'TB10.jpg', NULL, 'Socata TB-10 Tobago', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('TRIN', 'P', 'TB20.jpg', NULL, 'Socata TB-21 Trinidad', false, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('A340', '3', 'UKN.jpg', 96.900000000000006, 'Airbus A340', true, '3', 'J', 'C', 'A340');
INSERT INTO mactype VALUES ('C750', '3', 'C750.jpg', 72.299999999999997, 'Cessna Citation Jet 750', true, '3', 'J', 'J', 'C750');
INSERT INTO mactype VALUES ('E55P', '3', NULL, NULL, 'Embraer Phenom 300', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('CTLS', 'P', NULL, NULL, 'Flight Design CTLS', false, 'P', 'PS', NULL, NULL);
INSERT INTO mactype VALUES ('G109', 'P', 'UKN.jpg', NULL, 'Grobe G-109 Motor-Glider', false, 'P', NULL, 'P', NULL);
INSERT INTO mactype VALUES ('JS31', 'P', 'UKN.jpg', NULL, 'British Aerospace BAe-3100/3200 Jetstream 31/32 Twin turboprop', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('BN2P', 'U', 'UKN.jpg', NULL, 'Britten-Norman BN-2 Islander/BN-2A Trislander', false, NULL, NULL, 'P', NULL);
INSERT INTO mactype VALUES ('E120', 'P', 'UKN.jpg', NULL, 'Embraer EMB-120 Brasilia Twin', true, NULL, NULL, NULL, NULL);
INSERT INTO mactype VALUES ('A380', '3', 'A380.jpg', 95.599999999999994, 'Airbus Industries A380', true, '3', 'J', '', NULL);
INSERT INTO mactype VALUES ('B377', 'U', 'UKN.jpg', NULL, 'BOEING 377 STRATOCRUISER', false, NULL, NULL, '"', NULL);
INSERT INTO mactype VALUES ('B720', '2', 'UKN.jpg', NULL, 'BOEING 720', false, '2', 'J', 'C', NULL);
INSERT INTO mactype VALUES ('ATR', 'P', 'UKN.jpg', NULL, 'Aerospatiale ATR-42-300', false, 'T', NULL, 'T', NULL);
INSERT INTO mactype VALUES ('B407', 'H', 'UKN.jpg', NULL, 'Bell 407', false, 'H', 'H', 'H', NULL);
INSERT INTO mactype VALUES ('ATP', 'P', 'UKN.jpg', NULL, 'British Aerospace ATP', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('SBR1', '3', 'SBR65.jpg', 95, 'Saberliner 65', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('LJ28', '2', 'LJ28.jpg', 87, 'Learjet 28', false, '2', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('LJ25', '2', 'UKN.jpg
', 94, 'Learjet 25', false, '2', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('LJ24', '2', 'LJ24.jpg', 91.900000000000006, 'Learjet 24', false, '2', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('F27', 'P', 'UNK.jpg', NULL, 'Fokker F-27 Friendship', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('FAL2', '3', 'UKN.jpg', NULL, 'Falcon 20', true, NULL, NULL, 'J', NULL);
INSERT INTO mactype VALUES ('WW25', '3', 'UKN.jpg', 84.099999999999994, 'Israel Aircraft 1125 Astra', true, NULL, NULL, 'J', NULL);
INSERT INTO mactype VALUES ('KC35', 'M', 'UKN.jpg', NULL, 'KC-135', false, NULL, NULL, 'M', NULL);
INSERT INTO mactype VALUES ('X02S', 'U', 'UKN.jpg', NULL, 'Unknown', false, NULL, NULL, '', NULL);
INSERT INTO mactype VALUES ('X50A', 'U', 'UKN.jpg', NULL, 'Unknown', false, NULL, NULL, '', NULL);
INSERT INTO mactype VALUES ('X58U', 'U', 'UKN.jpg', NULL, 'Unknown', false, NULL, NULL, '', NULL);
INSERT INTO mactype VALUES ('Q100', 'P', 'Q100.jpg', NULL, 'Quest Kodiak 100', false, 'T', 'T', '', NULL);
INSERT INTO mactype VALUES ('JAB4', 'P', 'JAB4.jpg', NULL, 'Jabiru USA Sport Aircraft', false, 'P', 'PS', '', NULL);
INSERT INTO mactype VALUES ('G21', 'P', 'G21.jpg', NULL, 'Grumman G-21 Goose', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('AC95', 'P', 'AC90.jpg', NULL, 'Gulfstream Aerospace 695 Jetprop Commander 1000', false, 'T', 'T', 'P', NULL);
INSERT INTO mactype VALUES ('DH8', 'P', 'UKN.jpg', NULL, 'Bombardier Dash 8', true, NULL, NULL, 'T', NULL);
INSERT INTO mactype VALUES ('HA4T', '3', NULL, 92.299999999999997, 'Hawker Beechcraft 4000', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('J250', 'P', NULL, NULL, 'Jabiru J250 LSA', true, 'P', 'PS', 'P', NULL);
INSERT INTO mactype VALUES ('P750', 'P', NULL, NULL, 'Pacific Aerospace P-750 XSTOL', true, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('A320', '3', 'A320.jpg', 87.799999999999997, 'Airbus Industries A320', true, '3', 'J', 'C', 'A320');
INSERT INTO mactype VALUES ('B739', '3', 'B738.jpg', 88.400000000000006, 'Boeing 737-900', true, '3', 'J', 'C', 'B737');
INSERT INTO mactype VALUES ('A321', '3', 'A321.jpg', 89.799999999999997, 'Airbus Industries A321', true, '3', 'J', 'C', 'A321');
INSERT INTO mactype VALUES ('B463', '3', 'UNK.jpg', NULL, 'BRITISH AEROSPACE BAE146-100/200/300', false, '3', 'J', 'C', NULL);
INSERT INTO mactype VALUES ('CN35', 'P', 'UNK.jpg', NULL, 'CASA/IPTN twin engine transport', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('C212', 'P', 'UNK.jpg', NULL, 'CASA C-212 AVIOCAR', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('CVLT', 'P', 'UNK.jpg', NULL, 'Convair', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('DF7X', '3', 'UNK.jpg', 83.700000000000003, 'Dassault Facon 7X', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('KODI', 'P', 'UKN.jpg', NULL, 'Quest Kodiak', true, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('CW46', 'U', 'UNK.jpg', NULL, 'Curtiss Wright', false, NULL, NULL, '"', NULL);
INSERT INTO mactype VALUES ('DC6', 'P', 'UNK.jpg', NULL, 'Douglas DC-6', false, 'P', 'P', 'P', NULL);
INSERT INTO mactype VALUES ('DC4', 'P', 'UNK.jpg', NULL, 'Douglas DC-4', false, 'P', 'P', 'P', NULL);
INSERT INTO mactype VALUES ('A748', 'U', 'UNK.jpg', NULL, 'Hawker Siddeley HS-748', false, NULL, NULL, '"', NULL);
INSERT INTO mactype VALUES ('L49', 'U', 'UNK.jpg', NULL, 'Lockheed L-049/L-149 Constellation', false, NULL, NULL, '"', NULL);
INSERT INTO mactype VALUES ('L188', 'T', 'UKN.jpg', NULL, 'Lockheed L-188 Electra', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('SB20', 'T', 'UKN.jpg', NULL, 'SAAB 2000', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('VFW6', 'U', 'UKN.jpg', NULL, 'VFW Fokker614', false, NULL, NULL, '', NULL);
INSERT INTO mactype VALUES ('SSJ9', '3', 'UKN.jpg', NULL, 'Sukhoi SSJ 100-95 (Superjet 100) Regional Airliner', true, '3', 'J', 'C', NULL);
INSERT INTO mactype VALUES ('GAF', 'U', 'UKN.jpg', NULL, 'GAF Nomad', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('SH5B', 'U', 'UKN.jpg', NULL, 'Short SC-5 Belfast Turboprop Freighter', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('IAIA', 'U', 'UKN.jpg', NULL, 'IAI Arava Israeli Aircraft Industries Transport', false, NULL, NULL, '', NULL);
INSERT INTO mactype VALUES ('YS11', 'U', 'UKN.jpg', NULL, 'NAMC YS-11 Turboprop Airliner', false, 'T', 'T', 'T', NULL);
INSERT INTO mactype VALUES ('HWK8', 'U', 'UKN.jpg', NULL, 'Hawker 800/800XP', false, NULL, NULL, 'J', NULL);
INSERT INTO mactype VALUES ('G200', '3', 'UKN.jpg', NULL, 'Gulfstream G200/Astra 1125', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('CH2T', 'P', 'UKN.jpg', NULL, 'Zenith CH2000', false, 'P', NULL, 'P', NULL);
INSERT INTO mactype VALUES ('BD700', '3', 'UKN.jpg', NULL, 'Bombardier BD 700', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('HWK9', '3', 'UKN.jpg', NULL, 'Hawker 9000', true, NULL, NULL, 'J', NULL);
INSERT INTO mactype VALUES ('A124', '3', 'UKN.jpg', NULL, 'Antonov An-124', false, '3', 'J', 'C', NULL);
INSERT INTO mactype VALUES ('B748', '3', NULL, NULL, 'Boeing 747-800', true, '3', 'J', 'C', 'B748');
INSERT INTO mactype VALUES ('LP38', 'P', 'UKN.jpg', NULL, 'Lockheed P38 Lightning', false, 'P', 'P', 'P', NULL);
INSERT INTO mactype VALUES ('LZN7', 'U', 'UKN.jpg', NULL, 'ZEPPELIN lUFTSCHIFFTECHNIK LZNO7-100', false, NULL, NULL, '', NULL);
INSERT INTO mactype VALUES ('G100', '3', 'UKN.jpg', NULL, 'Gulfstream 100/Astra SPX', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('EC20', 'U', 'UKN.jpg', NULL, 'Unknown', false, NULL, NULL, '', NULL);
INSERT INTO mactype VALUES ('EA30', 'U', 'UKN.jpg', NULL, 'Experimental Aircraft', false, NULL, NULL, '', NULL);
INSERT INTO mactype VALUES ('BASS', 'U', 'UKN.jpg', NULL, 'Beagle-Auster B206 Twin-engine Piston (BASS/G)', false, 'P', 'PM', '', NULL);
INSERT INTO mactype VALUES ('LR60', '3', 'LJ60.jpg', 70.799999999999997, 'Learjet 60', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('R44', 'H', 'R44.jpg', NULL, 'Robinson R44', false, 'H', 'H', 'H', NULL);
INSERT INTO mactype VALUES ('R22', 'H', 'R22.jpg', NULL, 'Robinson R22', false, 'H', 'H', 'H', NULL);
INSERT INTO mactype VALUES ('BK17', 'H', 'B117.jpg', NULL, 'Eurocopter BK-117', false, 'H', 'H', 'H', NULL);
INSERT INTO mactype VALUES ('SK75', 'H', 'SK75.jpg', NULL, 'Sikorsky S-75', false, 'H', 'H', 'H', NULL);
INSERT INTO mactype VALUES ('SK76', 'H', 'SK76.jpg', NULL, 'Sikorsky S-76', false, 'H', 'H', 'H', NULL);
INSERT INTO mactype VALUES ('HU1B', 'H', 'HU1B.jpg', NULL, 'Huey UH-1B', false, 'H', 'H', 'H', NULL);
INSERT INTO mactype VALUES ('LXL2', 'U', 'UKN.jpg', NULL, 'Liberty Aerospace XL2', NULL, 'P', 'PS', 'p', NULL);
INSERT INTO mactype VALUES ('P136', 'P', 'UKN.jpg', NULL, 'Piaggio Aero', false, 'P', 'PM', 'P', NULL);
INSERT INTO mactype VALUES ('FA7X', '3', 'UKN.jpg', NULL, 'Falcon 7X', true, '3', 'J', 'J', NULL);
INSERT INTO mactype VALUES ('C340', 'P', 'C340.jpg', NULL, 'Cessna 340 Twin', false, NULL, NULL, 'P', NULL);
INSERT INTO mactype VALUES ('BD100', 'U', 'UKN.jpg', 75.299999999999997, 'Bombardier Challenger 300', true, NULL, NULL, '', NULL);


--
-- TOC entry 3367 (class 0 OID 128824)
-- Dependencies: 194
-- Data for Name: mactype_ft; Type: TABLE DATA; Schema: alias; Owner: postgres
--



--
-- TOC entry 3368 (class 0 OID 128830)
-- Dependencies: 195
-- Data for Name: oag_airline_substitution; Type: TABLE DATA; Schema: alias; Owner: postgres
--



--
-- TOC entry 3369 (class 0 OID 128836)
-- Dependencies: 196
-- Data for Name: runup_thrust_lookup; Type: TABLE DATA; Schema: alias; Owner: postgres
--



--
-- TOC entry 3370 (class 0 OID 128842)
-- Dependencies: 197
-- Data for Name: tailnumber_lookup; Type: TABLE DATA; Schema: alias; Owner: postgres
--



--
-- TOC entry 3334 (class 2606 OID 129124)
-- Dependencies: 183 183
-- Name: actype_airline_nnumber_pkey; Type: CONSTRAINT; Schema: alias; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY actype_airline_nnumber
    ADD CONSTRAINT actype_airline_nnumber_pkey PRIMARY KEY (id);


--
-- TOC entry 3336 (class 2606 OID 129126)
-- Dependencies: 183 183
-- Name: actype_airline_nnumber_temp_nnumber_key; Type: CONSTRAINT; Schema: alias; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY actype_airline_nnumber
    ADD CONSTRAINT actype_airline_nnumber_temp_nnumber_key UNIQUE (nnumber);


--
-- TOC entry 3318 (class 2606 OID 129128)
-- Dependencies: 162 162
-- Name: actype_pkey; Type: CONSTRAINT; Schema: alias; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY actype
    ADD CONSTRAINT actype_pkey PRIMARY KEY (actype);


--
-- TOC entry 3325 (class 2606 OID 129130)
-- Dependencies: 169 169
-- Name: airline_alias_icao_key; Type: CONSTRAINT; Schema: alias; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY airline_alias
    ADD CONSTRAINT airline_alias_icao_key UNIQUE (icao);


--
-- TOC entry 3327 (class 2606 OID 129132)
-- Dependencies: 169 169
-- Name: airline_alias_pkey; Type: CONSTRAINT; Schema: alias; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY airline_alias
    ADD CONSTRAINT airline_alias_pkey PRIMARY KEY (icao);


--
-- TOC entry 3330 (class 2606 OID 129134)
-- Dependencies: 170 170
-- Name: airportcodes_pkey; Type: CONSTRAINT; Schema: alias; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY airportcodes
    ADD CONSTRAINT airportcodes_pkey PRIMARY KEY (code);


--
-- TOC entry 3341 (class 2606 OID 129136)
-- Dependencies: 189 189
-- Name: alias_inmcode_pkey; Type: CONSTRAINT; Schema: alias; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY inmcode
    ADD CONSTRAINT alias_inmcode_pkey PRIMARY KEY (id);


--
-- TOC entry 3332 (class 2606 OID 129138)
-- Dependencies: 171 171
-- Name: alias_scheduled_pkey; Type: CONSTRAINT; Schema: alias; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY alias_scheduled
    ADD CONSTRAINT alias_scheduled_pkey PRIMARY KEY (inpacft);


--
-- TOC entry 3339 (class 2606 OID 129140)
-- Dependencies: 188 188
-- Name: inm_runup_lookup_pkey; Type: CONSTRAINT; Schema: alias; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY inm_runup_lookup
    ADD CONSTRAINT inm_runup_lookup_pkey PRIMARY KEY (ac);


--
-- TOC entry 3344 (class 2606 OID 129142)
-- Dependencies: 191 191
-- Name: inmcode_lookup_pkey; Type: CONSTRAINT; Schema: alias; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY inmcode_lookup
    ADD CONSTRAINT inmcode_lookup_pkey PRIMARY KEY (inmcode);


--
-- TOC entry 3346 (class 2606 OID 129144)
-- Dependencies: 192 192
-- Name: mac_airport_aoi_pkey; Type: CONSTRAINT; Schema: alias; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY mac_airport_aoi
    ADD CONSTRAINT mac_airport_aoi_pkey PRIMARY KEY (id);


--
-- TOC entry 3348 (class 2606 OID 129146)
-- Dependencies: 194 194
-- Name: mactype_ft_pkey; Type: CONSTRAINT; Schema: alias; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY mactype_ft
    ADD CONSTRAINT mactype_ft_pkey PRIMARY KEY (mactype);


--
-- TOC entry 3321 (class 2606 OID 129148)
-- Dependencies: 163 163
-- Name: mactype_pkey; Type: CONSTRAINT; Schema: alias; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY mactype
    ADD CONSTRAINT mactype_pkey PRIMARY KEY (mactype);


--
-- TOC entry 3352 (class 2606 OID 129150)
-- Dependencies: 197 197
-- Name: tailnumber_lookup_pkey; Type: CONSTRAINT; Schema: alias; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tailnumber_lookup
    ADD CONSTRAINT tailnumber_lookup_pkey PRIMARY KEY (id);


--
-- TOC entry 3322 (class 1259 OID 129207)
-- Dependencies: 169
-- Name: airline_alias_iata_idx; Type: INDEX; Schema: alias; Owner: postgres; Tablespace: 
--

CREATE INDEX airline_alias_iata_idx ON airline_alias USING btree (iata);

ALTER TABLE airline_alias CLUSTER ON airline_alias_iata_idx;


--
-- TOC entry 3323 (class 1259 OID 129208)
-- Dependencies: 169
-- Name: airline_alias_icao_idx; Type: INDEX; Schema: alias; Owner: postgres; Tablespace: 
--

CREATE INDEX airline_alias_icao_idx ON airline_alias USING btree (icao);


--
-- TOC entry 3328 (class 1259 OID 129209)
-- Dependencies: 170
-- Name: airportcodes_code; Type: INDEX; Schema: alias; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX airportcodes_code ON airportcodes USING btree (code);

ALTER TABLE airportcodes CLUSTER ON airportcodes_code;


--
-- TOC entry 3319 (class 1259 OID 129210)
-- Dependencies: 162
-- Name: fki_; Type: INDEX; Schema: alias; Owner: postgres; Tablespace: 
--

CREATE INDEX fki_ ON actype USING btree (mactype);


--
-- TOC entry 3337 (class 1259 OID 129211)
-- Dependencies: 186
-- Name: headinglookup_otherport_idx; Type: INDEX; Schema: alias; Owner: postgres; Tablespace: 
--

CREATE INDEX headinglookup_otherport_idx ON headinglookup USING btree (otherport);

ALTER TABLE headinglookup CLUSTER ON headinglookup_otherport_idx;


--
-- TOC entry 3342 (class 1259 OID 129212)
-- Dependencies: 189
-- Name: inmcode_actype_idx; Type: INDEX; Schema: alias; Owner: postgres; Tablespace: 
--

CREATE INDEX inmcode_actype_idx ON inmcode USING btree (actype);

ALTER TABLE inmcode CLUSTER ON inmcode_actype_idx;


--
-- TOC entry 3349 (class 1259 OID 129213)
-- Dependencies: 195
-- Name: oag_airline_substitutions_icao; Type: INDEX; Schema: alias; Owner: postgres; Tablespace: 
--

CREATE INDEX oag_airline_substitutions_icao ON oag_airline_substitution USING btree (icao);

ALTER TABLE oag_airline_substitution CLUSTER ON oag_airline_substitutions_icao;


--
-- TOC entry 3350 (class 1259 OID 129214)
-- Dependencies: 197
-- Name: tailnumber_lookup_idx; Type: INDEX; Schema: alias; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX tailnumber_lookup_idx ON tailnumber_lookup USING btree (tailnumber);

ALTER TABLE tailnumber_lookup CLUSTER ON tailnumber_lookup_idx;


--
-- TOC entry 3353 (class 2606 OID 129274)
-- Dependencies: 163 162 3320
-- Name: actype_mactype_fkey; Type: FK CONSTRAINT; Schema: alias; Owner: postgres
--

ALTER TABLE ONLY actype
    ADD CONSTRAINT actype_mactype_fkey FOREIGN KEY (mactype) REFERENCES mactype(mactype) ON UPDATE CASCADE ON DELETE RESTRICT;


-- Completed on 2011-12-01 14:55:10

--
-- PostgreSQL database dump complete
--

