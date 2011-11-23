--
-- PostgreSQL database dump
--

-- Dumped from database version 9.0.5
-- Dumped by pg_dump version 9.0.5
-- Started on 2011-11-23 10:44:37

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = app_metadata, pg_catalog;

--
-- TOC entry 3273 (class 0 OID 142976)
-- Dependencies: 262
-- Data for Name: airlines; Type: TABLE DATA; Schema: app_metadata; Owner: postgres
--

COPY airlines (code, name, checked) FROM stdin;
TRS	Airtran	t
AWE	America West	t
AAL	American	t
EGF	American Eagle	t
CAW	Comair	t
CPZ	Compass	t
COA	Continental	t
DAL	Delta	t
FDX	FedEx	t
FFT	Frontier Airlines	t
MES	Mesaba	t
FLG	Pinnacle	t
RPA	Republic Airlines	t
TCF	Shuttle America	t
SLL	Skywest Airlines	t
SWA	Southwest	t
SCX	Sun Country	t
UAL	United	t
UPS	UPS	t
\.


--
-- TOC entry 3271 (class 0 OID 142940)
-- Dependencies: 260
-- Data for Name: airports; Type: TABLE DATA; Schema: app_metadata; Owner: postgres
--

COPY airports (code, name, geom) FROM stdin;
MSP	MINNEAPOLIS\\ST PAUL	0101000020E610000000000000324E57C000000060E5704640
STP	SAINT PAUL DOWNTOWN	\N
FCM	Flying Cloud	\N
ANE	Anoka/Blaine	\N
MIC	Crystal	\N
LVN	Airlake	\N
21D	Lake Elmo	\N
\.


--
-- TOC entry 3274 (class 0 OID 142996)
-- Dependencies: 264
-- Data for Name: flight_types; Type: TABLE DATA; Schema: app_metadata; Owner: postgres
--

COPY flight_types (type, code, checked) FROM stdin;
Arrivals	A	t
Departures	D	t
Unknown	O	t
\.


--
-- TOC entry 3272 (class 0 OID 142959)
-- Dependencies: 261 3271
-- Data for Name: runways; Type: TABLE DATA; Schema: app_metadata; Owner: postgres
--

COPY runways (airport_code, runway, checked) FROM stdin;
MSP	12R	t
MSP	30L	t
MSP	12L	t
MSP	30R	t
MSP	17	t
MSP	35	t
MSP	4	t
MSP	22	t
STP	14	t
STP	32	t
STP	13	t
STP	31	t
STP	9	t
STP	27	t
FCM	10R	t
FCM	10L	t
FCM	28R	t
FCM	28L	t
FCM	36	t
FCM	18	t
\.


-- Completed on 2011-11-23 10:44:37

--
-- PostgreSQL database dump complete
--

