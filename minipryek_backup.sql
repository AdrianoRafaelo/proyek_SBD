--
-- PostgreSQL database dump
--

-- Dumped from database version 16.4
-- Dumped by pg_dump version 16.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pemesanan_tiket; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA pemesanan_tiket;


ALTER SCHEMA pemesanan_tiket OWNER TO postgres;

--
-- Name: insert_laporan_pemesanan(); Type: FUNCTION; Schema: pemesanan_tiket; Owner: postgres
--

CREATE FUNCTION pemesanan_tiket.insert_laporan_pemesanan() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO pemesanan_tiket.Laporan_Destinasi (bulan, tahun, id_destinasi, total_kunjungan)
    SELECT 
        EXTRACT(MONTH FROM NEW.tanggal_kunjungan),  
        EXTRACT(YEAR FROM NEW.tanggal_kunjungan),  
        NEW.id_destinasi,                           
        COUNT(*)                                    
    FROM pemesanan_tiket.Pemesanan
    WHERE id_destinasi = NEW.id_destinasi
    AND EXTRACT(MONTH FROM tanggal_kunjungan) = EXTRACT(MONTH FROM NEW.tanggal_kunjungan)
    AND EXTRACT(YEAR FROM tanggal_kunjungan) = EXTRACT(YEAR FROM NEW.tanggal_kunjungan)
    GROUP BY EXTRACT(MONTH FROM NEW.tanggal_kunjungan), EXTRACT(YEAR FROM NEW.tanggal_kunjungan), NEW.id_destinasi;

    RETURN NEW;
END;
$$;


ALTER FUNCTION pemesanan_tiket.insert_laporan_pemesanan() OWNER TO postgres;

--
-- Name: pemesanan_tiket(integer, integer, integer, date, date); Type: PROCEDURE; Schema: pemesanan_tiket; Owner: postgres
--

CREATE PROCEDURE pemesanan_tiket.pemesanan_tiket(IN p_id_pengguna integer, IN p_id_destinasi integer, IN p_jumlah_tiket integer, IN p_tanggal_pemesanan date, IN p_tanggal_kunjungan date)
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF (SELECT kuota_tiket FROM pemesanan_tiket.Destinasi WHERE id_destinasi = p_id_destinasi) >= p_jumlah_tiket THEN
        INSERT INTO pemesanan_tiket.Pemesanan (tanggal_pemesanan, tanggal_kunjungan, jumlah_tiket, id_pengguna, id_destinasi)
        VALUES (p_tanggal_pemesanan, p_tanggal_kunjungan, p_jumlah_tiket, p_id_pengguna, p_id_destinasi);

        UPDATE pemesanan_tiket.Destinasi
        SET kuota_tiket = GREATEST(kuota_tiket - p_jumlah_tiket, 0)
        WHERE id_destinasi = p_id_destinasi;

        RAISE NOTICE 'Pemesanan berhasil';
    ELSE
        RAISE NOTICE 'Kuota tiket tidak cukup untuk destinasi ID %', p_id_destinasi;
    END IF;
END;
$$;


ALTER PROCEDURE pemesanan_tiket.pemesanan_tiket(IN p_id_pengguna integer, IN p_id_destinasi integer, IN p_jumlah_tiket integer, IN p_tanggal_pemesanan date, IN p_tanggal_kunjungan date) OWNER TO postgres;

--
-- Name: tambah_kuota_tiket(integer, integer); Type: PROCEDURE; Schema: pemesanan_tiket; Owner: postgres
--

CREATE PROCEDURE pemesanan_tiket.tambah_kuota_tiket(IN p_id_destinasi integer, IN p_tambah_kuota integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Melakukan update kuota tiket dengan menambahkan jumlah kuota yang diberi
    UPDATE pemesanan_tiket.Destinasi
    SET kuota_tiket = kuota_tiket + p_tambah_kuota
    WHERE id_destinasi = p_id_destinasi;

    -- apabila berhasil akan menampilkan pesan 
    RAISE NOTICE 'Kuota tiket untuk destinasi ID % berhasil ditambah sebanyak % tiket', p_id_destinasi, p_tambah_kuota;
END;
$$;


ALTER PROCEDURE pemesanan_tiket.tambah_kuota_tiket(IN p_id_destinasi integer, IN p_tambah_kuota integer) OWNER TO postgres;

--
-- Name: insert_laporan_pemesanan(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.insert_laporan_pemesanan() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Menyimpan data pemesanan baru ke dalam tabel Laporan
    INSERT INTO Laporan (pengunjung_id, id_destinasi, jumlah_tiket, total_tiket, tanggal_pemesanan, nama_destinasi)
    SELECT NEW.id_pengguna, NEW.id_destinasi, NEW.jumlah_tiket, NEW.jumlah_tiket * D.harga_tiket, NEW.tanggal_pemesanan, 
           D.nama_destinasi
    FROM Destinasi D
    WHERE D.id_destinasi = NEW.id_destinasi;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.insert_laporan_pemesanan() OWNER TO postgres;

--
-- Name: update_laporan(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_laporan() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- Hapus data lama dari tabel Laporan
  DELETE FROM Laporan;

  -- Masukkan data terbaru ke tabel Laporan
  INSERT INTO Laporan (id_destinasi, nama_destinasi, total_pengunjung, total_tiket)
  SELECT 
    d.id_destinasi,
    d.nama_destinasi,
    COUNT(DISTINCT p.pengunjung_id) AS total_pengunjung,
    SUM(p.jumlah_tiket) AS total_tiket
  FROM Pemesanan p
  JOIN Destinasi d ON p.id_destinasi = d.id_destinasi
  GROUP BY d.id_destinasi, d.nama_destinasi
  ORDER BY total_tiket DESC;

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_laporan() OWNER TO postgres;

--
-- Name: update_total_tiket(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_total_tiket() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Menghitung total harga tiket berdasarkan jumlah tiket dan harga tiket dari Destinasi
    UPDATE pemesanan_tiket.Pemesanan
    SET total_tiket = NEW.jumlah_tiket * COALESCE(
        (SELECT harga_tiket FROM pemesanan_tiket.Destinasi WHERE id_destinasi = NEW.id_destinasi),
        0
    )
    WHERE id_pemesanan = NEW.id_pemesanan;

    -- Pastikan total_tiket telah dihitung dan diperbarui
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_total_tiket() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admin; Type: TABLE; Schema: pemesanan_tiket; Owner: postgres
--

CREATE TABLE pemesanan_tiket.admin (
    id_admin integer NOT NULL,
    nama_admin character varying(255) NOT NULL,
    email_admin character varying(255) NOT NULL,
    id_destinasi integer NOT NULL,
    total_tiket integer DEFAULT 0
);


ALTER TABLE pemesanan_tiket.admin OWNER TO postgres;

--
-- Name: admin_id_admin_seq; Type: SEQUENCE; Schema: pemesanan_tiket; Owner: postgres
--

CREATE SEQUENCE pemesanan_tiket.admin_id_admin_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pemesanan_tiket.admin_id_admin_seq OWNER TO postgres;

--
-- Name: admin_id_admin_seq; Type: SEQUENCE OWNED BY; Schema: pemesanan_tiket; Owner: postgres
--

ALTER SEQUENCE pemesanan_tiket.admin_id_admin_seq OWNED BY pemesanan_tiket.admin.id_admin;


--
-- Name: destinasi; Type: TABLE; Schema: pemesanan_tiket; Owner: postgres
--

CREATE TABLE pemesanan_tiket.destinasi (
    id_destinasi integer NOT NULL,
    nama_destinasi character varying(255) NOT NULL,
    lokasi character varying(255) NOT NULL,
    deskripsi_destinasi text NOT NULL,
    harga_tiket integer NOT NULL,
    kuota_tiket integer NOT NULL
);


ALTER TABLE pemesanan_tiket.destinasi OWNER TO postgres;

--
-- Name: destinasi_id_destinasi_seq; Type: SEQUENCE; Schema: pemesanan_tiket; Owner: postgres
--

CREATE SEQUENCE pemesanan_tiket.destinasi_id_destinasi_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pemesanan_tiket.destinasi_id_destinasi_seq OWNER TO postgres;

--
-- Name: destinasi_id_destinasi_seq; Type: SEQUENCE OWNED BY; Schema: pemesanan_tiket; Owner: postgres
--

ALTER SEQUENCE pemesanan_tiket.destinasi_id_destinasi_seq OWNED BY pemesanan_tiket.destinasi.id_destinasi;


--
-- Name: laporan_destinasi; Type: TABLE; Schema: pemesanan_tiket; Owner: postgres
--

CREATE TABLE pemesanan_tiket.laporan_destinasi (
    id_laporan integer NOT NULL,
    bulan integer NOT NULL,
    tahun integer NOT NULL,
    id_destinasi integer NOT NULL,
    total_kunjungan integer NOT NULL
);


ALTER TABLE pemesanan_tiket.laporan_destinasi OWNER TO postgres;

--
-- Name: laporan_destinasi_id_laporan_seq; Type: SEQUENCE; Schema: pemesanan_tiket; Owner: postgres
--

CREATE SEQUENCE pemesanan_tiket.laporan_destinasi_id_laporan_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pemesanan_tiket.laporan_destinasi_id_laporan_seq OWNER TO postgres;

--
-- Name: laporan_destinasi_id_laporan_seq; Type: SEQUENCE OWNED BY; Schema: pemesanan_tiket; Owner: postgres
--

ALTER SEQUENCE pemesanan_tiket.laporan_destinasi_id_laporan_seq OWNED BY pemesanan_tiket.laporan_destinasi.id_laporan;


--
-- Name: pemesanan; Type: TABLE; Schema: pemesanan_tiket; Owner: postgres
--

CREATE TABLE pemesanan_tiket.pemesanan (
    id_pemesanan integer NOT NULL,
    tanggal_pemesanan date NOT NULL,
    tanggal_kunjungan date NOT NULL,
    jumlah_tiket integer NOT NULL,
    id_pengguna integer NOT NULL,
    id_destinasi integer NOT NULL,
    total_tiket integer DEFAULT 0 NOT NULL
);


ALTER TABLE pemesanan_tiket.pemesanan OWNER TO postgres;

--
-- Name: pemesanan_id_pemesanan_seq; Type: SEQUENCE; Schema: pemesanan_tiket; Owner: postgres
--

CREATE SEQUENCE pemesanan_tiket.pemesanan_id_pemesanan_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pemesanan_tiket.pemesanan_id_pemesanan_seq OWNER TO postgres;

--
-- Name: pemesanan_id_pemesanan_seq; Type: SEQUENCE OWNED BY; Schema: pemesanan_tiket; Owner: postgres
--

ALTER SEQUENCE pemesanan_tiket.pemesanan_id_pemesanan_seq OWNED BY pemesanan_tiket.pemesanan.id_pemesanan;


--
-- Name: pengunjung; Type: TABLE; Schema: pemesanan_tiket; Owner: postgres
--

CREATE TABLE pemesanan_tiket.pengunjung (
    id_pengguna integer NOT NULL,
    nama character varying(255) NOT NULL,
    alamat character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    no_telp character varying(15) NOT NULL
);


ALTER TABLE pemesanan_tiket.pengunjung OWNER TO postgres;

--
-- Name: pengunjung_id_pengguna_seq; Type: SEQUENCE; Schema: pemesanan_tiket; Owner: postgres
--

CREATE SEQUENCE pemesanan_tiket.pengunjung_id_pengguna_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE pemesanan_tiket.pengunjung_id_pengguna_seq OWNER TO postgres;

--
-- Name: pengunjung_id_pengguna_seq; Type: SEQUENCE OWNED BY; Schema: pemesanan_tiket; Owner: postgres
--

ALTER SEQUENCE pemesanan_tiket.pengunjung_id_pengguna_seq OWNED BY pemesanan_tiket.pengunjung.id_pengguna;


--
-- Name: view_pendapatan_per_destinasi; Type: VIEW; Schema: pemesanan_tiket; Owner: postgres
--

CREATE VIEW pemesanan_tiket.view_pendapatan_per_destinasi AS
 SELECT d.id_destinasi,
    d.nama_destinasi,
    d.lokasi,
    count(p.id_pemesanan) AS total_pemesanan,
    EXTRACT(month FROM p.tanggal_pemesanan) AS bulan_pemesanan,
    EXTRACT(year FROM p.tanggal_pemesanan) AS tahun_pemesanan
   FROM (pemesanan_tiket.pemesanan p
     JOIN pemesanan_tiket.destinasi d ON ((p.id_destinasi = d.id_destinasi)))
  GROUP BY d.id_destinasi, d.nama_destinasi, d.lokasi, (EXTRACT(month FROM p.tanggal_pemesanan)), (EXTRACT(year FROM p.tanggal_pemesanan))
  ORDER BY (count(p.id_pemesanan)) DESC;


ALTER VIEW pemesanan_tiket.view_pendapatan_per_destinasi OWNER TO postgres;

--
-- Name: admin; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin (
    id_admin integer NOT NULL,
    nama_admin character varying(255) NOT NULL,
    email_admin character varying(255) NOT NULL,
    id_destinasi integer NOT NULL
);


ALTER TABLE public.admin OWNER TO postgres;

--
-- Name: admin_id_admin_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.admin_id_admin_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.admin_id_admin_seq OWNER TO postgres;

--
-- Name: admin_id_admin_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.admin_id_admin_seq OWNED BY public.admin.id_admin;


--
-- Name: destinasi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.destinasi (
    id_destinasi integer NOT NULL,
    nama_destinasi character varying(255) NOT NULL,
    lokasi character varying(255) NOT NULL,
    deskripsi_destinasi text NOT NULL,
    harga_tiket integer NOT NULL,
    kuota_tiket integer NOT NULL
);


ALTER TABLE public.destinasi OWNER TO postgres;

--
-- Name: destinasi_id_destinasi_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.destinasi_id_destinasi_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.destinasi_id_destinasi_seq OWNER TO postgres;

--
-- Name: destinasi_id_destinasi_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.destinasi_id_destinasi_seq OWNED BY public.destinasi.id_destinasi;


--
-- Name: laporan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.laporan (
    id_laporan integer NOT NULL,
    pengunjung_id integer NOT NULL,
    id_destinasi integer NOT NULL,
    jumlah_tiket integer NOT NULL,
    total_tiket integer NOT NULL,
    tanggal_pemesanan date NOT NULL,
    nama_destinasi character varying(255)
);


ALTER TABLE public.laporan OWNER TO postgres;

--
-- Name: laporan_id_laporan_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.laporan_id_laporan_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.laporan_id_laporan_seq OWNER TO postgres;

--
-- Name: laporan_id_laporan_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.laporan_id_laporan_seq OWNED BY public.laporan.id_laporan;


--
-- Name: pemesanan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pemesanan (
    id_pemesanan integer NOT NULL,
    tanggal_pemesanan date NOT NULL,
    tanggal_kunjungan date NOT NULL,
    jumlah_tiket integer NOT NULL,
    total_tiket integer NOT NULL,
    status_pemesanan integer NOT NULL,
    id_pengguna integer NOT NULL,
    id_destinasi integer NOT NULL
);


ALTER TABLE public.pemesanan OWNER TO postgres;

--
-- Name: pemesanan_id_pemesanan_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pemesanan_id_pemesanan_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pemesanan_id_pemesanan_seq OWNER TO postgres;

--
-- Name: pemesanan_id_pemesanan_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pemesanan_id_pemesanan_seq OWNED BY public.pemesanan.id_pemesanan;


--
-- Name: pengunjung; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pengunjung (
    id_pengguna integer NOT NULL,
    nama character varying(255) NOT NULL,
    alamat character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    no_telp character varying(15) NOT NULL
);


ALTER TABLE public.pengunjung OWNER TO postgres;

--
-- Name: pengunjung_id_pengguna_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pengunjung_id_pengguna_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pengunjung_id_pengguna_seq OWNER TO postgres;

--
-- Name: pengunjung_id_pengguna_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pengunjung_id_pengguna_seq OWNED BY public.pengunjung.id_pengguna;


--
-- Name: view_pemesanan_destinasi; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_pemesanan_destinasi AS
 SELECT p.id_pemesanan,
    p.tanggal_pemesanan,
    p.tanggal_kunjungan,
    p.jumlah_tiket,
    p.total_tiket,
    p.status_pemesanan,
    p.id_pengguna,
    d.id_destinasi,
    d.nama_destinasi
   FROM (public.pemesanan p
     JOIN public.destinasi d ON ((p.id_destinasi = d.id_destinasi)));


ALTER VIEW public.view_pemesanan_destinasi OWNER TO postgres;

--
-- Name: admin id_admin; Type: DEFAULT; Schema: pemesanan_tiket; Owner: postgres
--

ALTER TABLE ONLY pemesanan_tiket.admin ALTER COLUMN id_admin SET DEFAULT nextval('pemesanan_tiket.admin_id_admin_seq'::regclass);


--
-- Name: destinasi id_destinasi; Type: DEFAULT; Schema: pemesanan_tiket; Owner: postgres
--

ALTER TABLE ONLY pemesanan_tiket.destinasi ALTER COLUMN id_destinasi SET DEFAULT nextval('pemesanan_tiket.destinasi_id_destinasi_seq'::regclass);


--
-- Name: laporan_destinasi id_laporan; Type: DEFAULT; Schema: pemesanan_tiket; Owner: postgres
--

ALTER TABLE ONLY pemesanan_tiket.laporan_destinasi ALTER COLUMN id_laporan SET DEFAULT nextval('pemesanan_tiket.laporan_destinasi_id_laporan_seq'::regclass);


--
-- Name: pemesanan id_pemesanan; Type: DEFAULT; Schema: pemesanan_tiket; Owner: postgres
--

ALTER TABLE ONLY pemesanan_tiket.pemesanan ALTER COLUMN id_pemesanan SET DEFAULT nextval('pemesanan_tiket.pemesanan_id_pemesanan_seq'::regclass);


--
-- Name: pengunjung id_pengguna; Type: DEFAULT; Schema: pemesanan_tiket; Owner: postgres
--

ALTER TABLE ONLY pemesanan_tiket.pengunjung ALTER COLUMN id_pengguna SET DEFAULT nextval('pemesanan_tiket.pengunjung_id_pengguna_seq'::regclass);


--
-- Name: admin id_admin; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin ALTER COLUMN id_admin SET DEFAULT nextval('public.admin_id_admin_seq'::regclass);


--
-- Name: destinasi id_destinasi; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.destinasi ALTER COLUMN id_destinasi SET DEFAULT nextval('public.destinasi_id_destinasi_seq'::regclass);


--
-- Name: laporan id_laporan; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.laporan ALTER COLUMN id_laporan SET DEFAULT nextval('public.laporan_id_laporan_seq'::regclass);


--
-- Name: pemesanan id_pemesanan; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pemesanan ALTER COLUMN id_pemesanan SET DEFAULT nextval('public.pemesanan_id_pemesanan_seq'::regclass);


--
-- Name: pengunjung id_pengguna; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pengunjung ALTER COLUMN id_pengguna SET DEFAULT nextval('public.pengunjung_id_pengguna_seq'::regclass);


--
-- Data for Name: admin; Type: TABLE DATA; Schema: pemesanan_tiket; Owner: postgres
--

COPY pemesanan_tiket.admin (id_admin, nama_admin, email_admin, id_destinasi, total_tiket) FROM stdin;
\.


--
-- Data for Name: destinasi; Type: TABLE DATA; Schema: pemesanan_tiket; Owner: postgres
--

COPY pemesanan_tiket.destinasi (id_destinasi, nama_destinasi, lokasi, deskripsi_destinasi, harga_tiket, kuota_tiket) FROM stdin;
1	Air Terjun Sipiso-piso	Tapanuli Utara	Air terjun terbesar di Sumatera Utara yang memiliki pemandangan indah.	150000	400
2	Danau Toba	Tapanuli Utara	Danau terbesar di Indonesia dengan pemandangan alam yang sangat memukau.	250000	350
3	Bukit Simarjarunjung	Tapanuli Utara	Bukit yang menawarkan pemandangan spektakuler Danau Toba dan sekitarnya.	120000	300
4	Pantai Parbaba	Tapanuli Utara	Pantai berpasir putih dengan suasana tenang yang cocok untuk berlibur.	100000	500
5	Pulau Samosir	Tapanuli Utara	Pulau di tengah Danau Toba dengan keindahan alam yang luar biasa.	300000	250
6	Salib Kasih	Tapanuli Utara	Wisata Rohani didaerah tinggi dengan bangunan tinggi yang berbentuk salib.	50000	50
\.


--
-- Data for Name: laporan_destinasi; Type: TABLE DATA; Schema: pemesanan_tiket; Owner: postgres
--

COPY pemesanan_tiket.laporan_destinasi (id_laporan, bulan, tahun, id_destinasi, total_kunjungan) FROM stdin;
1	12	2024	1	1
2	12	2024	2	1
\.


--
-- Data for Name: pemesanan; Type: TABLE DATA; Schema: pemesanan_tiket; Owner: postgres
--

COPY pemesanan_tiket.pemesanan (id_pemesanan, tanggal_pemesanan, tanggal_kunjungan, jumlah_tiket, id_pengguna, id_destinasi, total_tiket) FROM stdin;
1	2024-12-01	2024-12-05	2	1	1	300000
2	2024-12-02	2024-12-06	3	2	2	750000
\.


--
-- Data for Name: pengunjung; Type: TABLE DATA; Schema: pemesanan_tiket; Owner: postgres
--

COPY pemesanan_tiket.pengunjung (id_pengguna, nama, alamat, email, no_telp) FROM stdin;
1	Anastasya	Jl. Aekristop No. 1	putri@gmail.com	081234567890
2	Nokatri	Jl. Balige No. 2	budi@gmail.com	081234567891
3	Amel	Jl. Aekristop No. 90	amel@gmail.com	085243954890
\.


--
-- Data for Name: admin; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admin (id_admin, nama_admin, email_admin, id_destinasi) FROM stdin;
\.


--
-- Data for Name: destinasi; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.destinasi (id_destinasi, nama_destinasi, lokasi, deskripsi_destinasi, harga_tiket, kuota_tiket) FROM stdin;
1	Air Terjun Sipiso-piso	Tapanuli Utara	Air terjun terbesar di Sumatera Utara yang memiliki pemandangan indah.	150000	400
2	Danau Toba	Tapanuli Utara	Danau terbesar di Indonesia dengan pemandangan alam yang sangat memukau.	250000	350
3	Bukit Simarjarunjung	Tapanuli Utara	Bukit yang menawarkan pemandangan spektakuler Danau Toba dan sekitarnya.	120000	300
4	Pantai Parbaba	Tapanuli Utara	Pantai berpasir putih dengan suasana tenang yang cocok untuk berlibur.	100000	500
5	Pulau Samosir	Tapanuli Utara	Pulau di tengah Danau Toba dengan keindahan alam yang luar biasa.	300000	250
6	Taman Simalungun	Tapanuli Utara	Taman wisata dengan flora dan fauna yang langka serta pemandangan alam hijau.	180000	200
7	Pantai Lumban Bul-Bul	Tapanuli Utara	Pantai yang tenang dengan air jernih dan pemandangan luar biasa.	130000	400
8	Air Terjun Efrata	Tapanuli Utara	Air terjun yang menyegarkan dengan alam sekitar yang hijau.	180000	450
9	Bukit Lawang	Tapanuli Utara	Bukit yang memiliki pemandangan indah dan jalur trekking menarik untuk para petualang.	175000	250
10	Desa Tomok	Tapanuli Utara	Desa yang terkenal dengan kebudayaan Batak dan tempat wisata sejarah di sekitar Danau Toba.	100000	350
11	Pusuk Buhit	Tapanuli Utara	Gunung yang dianggap sakral oleh masyarakat Batak dengan pemandangan yang memukau.	220000	200
12	Pantai Sibolga	Tapanuli Utara	Pantai yang indah dan tenang dengan panorama laut lepas.	150000	400
13	Kawasan Hutan Lindung Sipirok	Tapanuli Utara	Kawasan hutan tropis dengan berbagai spesies flora dan fauna.	200000	300
14	Pulau Mursala	Tapanuli Utara	Pulau yang terkenal dengan air terjun di tepi pantai dan pemandangan eksotis.	250000	150
15	Pemandian Air Panas Tarutung	Tapanuli Utara	Sumber air panas alami yang dipercaya memiliki khasiat penyembuhan.	120000	200
16	Danau Siombak	Tapanuli Utara	Danau yang terletak di kaki bukit dengan suasana yang sangat damai.	100000	450
17	Bukit Batu Parbubu	Tapanuli Utara	Bukit dengan pemandangan luar biasa dari ketinggian dan udara yang sejuk.	140000	500
18	Taman Wisata Alam Batang Toru	Tapanuli Utara	Taman wisata alam yang terkenal dengan keanekaragaman hayati dan pemandangan pegunungan.	180000	350
19	Pantai Tumijur	Tapanuli Utara	Pantai berpasir hitam dengan pemandangan laut yang memukau.	120000	300
20	Taman Nasional Gunung Leuser	Tapanuli Utara	Taman nasional yang melindungi berbagai spesies langka dan habitat alami.	200000	250
21	Situs Megalitikum Batu Gantung	Tapanuli Utara	Situs bersejarah yang menyimpan peninggalan batu megalitik dari zaman prasejarah.	150000	350
22	Desa Huta Siallagan	Tapanuli Utara	Desa wisata dengan budaya Batak yang masih kental, serta situs sejarah yang menarik.	130000	400
23	Pantai Ujung Batu	Tapanuli Utara	Pantai dengan batu-batu besar yang menarik dan pemandangan yang menawan.	170000	500
24	Situs Raja Batak	Tapanuli Utara	Situs sejarah yang terkenal dengan peninggalan kerajaan Batak purba.	200000	300
25	Pantai Gulo-Gulo	Tapanuli Utara	Pantai yang tenang dengan ombak kecil dan cocok untuk bersantai.	140000	450
26	Desa Pangururan	Tapanuli Utara	Desa yang terletak di Pulau Samosir dengan pemandangan Danau Toba yang indah.	150000	350
27	Kampung Batak	Tapanuli Utara	Kampung yang menggambarkan kehidupan tradisional masyarakat Batak dengan rumah adat dan budaya yang masih lestari.	100000	400
28	Tebing Tinggi	Tapanuli Utara	Tempat wisata alam dengan tebing-tebing batu yang menjulang tinggi dan pemandangan sekitar yang sangat memukau.	180000	300
29	Bukit Panggul	Tapanuli Utara	Bukit yang menawarkan pemandangan luas Danau Toba dari ketinggian.	200000	500
30	Pantai Siosar	Tapanuli Utara	Pantai indah dengan pasir putih dan panorama laut yang memukau.	150000	400
31	Gunung Pusuk Buhit	Tapanuli Utara	Gunung sakral dengan pemandangan luar biasa dan legenda yang kuat di kalangan masyarakat Batak.	210000	250
32	Air Terjun Singa	Tapanuli Utara	Air terjun yang sangat besar dengan suara gemuruh air yang khas.	220000	300
33	Taman Nasional Batang Toru	Tapanuli Utara	Taman nasional yang menyimpan keindahan alam dan flora fauna langka.	250000	200
34	Desa Ambarita	Tapanuli Utara	Desa wisata yang memiliki sejarah kerajaan Batak dengan situs batu kursi raja.	120000	350
35	Pantai Gok-gok	Tapanuli Utara	Pantai yang tenang dengan ombak kecil dan pasir putih.	150000	400
36	Gunung Sinabung	Tapanuli Utara	Gunung yang masih aktif dan menawarkan pemandangan dari puncaknya.	200000	250
37	Air Terjun Simangumban	Tapanuli Utara	Air terjun yang terletak di hutan tropis dan dikelilingi oleh pepohonan hijau.	180000	300
38	Situs Batu Sada	Tapanuli Utara	Situs bersejarah yang memiliki batu besar dengan cerita mitologi lokal.	120000	400
39	Desa Lumban Sitorang	Tapanuli Utara	Desa wisata yang terletak di sekitar Danau Toba dengan kebudayaan Batak yang kuat.	150000	350
40	Bukit Paropo	Tapanuli Utara	Bukit yang memiliki pemandangan luar biasa dari Danau Toba dengan udara yang sejuk.	170000	450
41	Pantai Cermin	Tapanuli Utara	Pantai yang tenang dengan pemandangan laut yang indah.	130000	400
42	Danau Parsaoran	Tapanuli Utara	Danau kecil yang menawarkan ketenangan dan pemandangan alam sekitarnya.	100000	450
43	Taman Rusa Batang Toru	Tapanuli Utara	Taman yang dilengkapi dengan area konservasi rusa dan flora yang indah.	200000	300
44	Pantai Indah Kuta	Tapanuli Utara	Pantai dengan pasir putih dan ombak yang cocok untuk berselancar.	150000	500
45	Pantai Indah Kuta	Tapanuli Utara	Pantai dengan pasir putih dan ombak yang cocok untuk berselancar.	150000	500
46	Situs Batu Sada	Tapanuli Utara	Situs bersejarah yang memiliki batu besar dengan cerita mitologi lokal.	120000	400
47	Taman Wisata Alam Batang Toru	Tapanuli Utara	Taman wisata alam yang terkenal dengan keanekaragaman hayati dan pemandangan pegunungan.	180000	350
48	Danau Parba	Tapanuli Utara	Danau yang terletak di kaki gunung dengan pemandangan alam yang menenangkan.	100000	500
49	Bukit Tanjung Karang	Tapanuli Utara	Bukit yang menawarkan pemandangan luar biasa ke arah Danau Toba.	170000	400
50	Taman Rekreasi Sipirok	Tapanuli Utara	Taman rekreasi dengan fasilitas bermain dan pemandangan alam yang menyegarkan.	140000	450
\.


--
-- Data for Name: laporan; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.laporan (id_laporan, pengunjung_id, id_destinasi, jumlah_tiket, total_tiket, tanggal_pemesanan, nama_destinasi) FROM stdin;
1	1	3	2	400000	2024-12-04	Bukit Simarjarunjung
2	1	48	2	200000	2024-12-04	Danau Parba
3	2	50	3	420000	2024-12-05	Taman Rekreasi Sipirok
4	1	43	5	1000000	2024-12-06	Taman Rusa Batang Toru
\.


--
-- Data for Name: pemesanan; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pemesanan (id_pemesanan, tanggal_pemesanan, tanggal_kunjungan, jumlah_tiket, total_tiket, status_pemesanan, id_pengguna, id_destinasi) FROM stdin;
\.


--
-- Data for Name: pengunjung; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pengunjung (id_pengguna, nama, alamat, email, no_telp) FROM stdin;
1	Anastasya	Jl. Aekristop No. 1	putri@gmail.com	081234567890
2	Nokatri	Jl. Balige No. 2	budi@gmail.com	081234567891
3	Chelsia	Jl. Tarutung No. 3	cici@gmail.com	081234567892
4	Andi	Jl. Siantar No. 4	andi@example.com	081234567893
5	Rina	Jl. Silaen No. 5	rina@example.com	081234567894
6	Fajar	Jl. Sipoholon No. 6	fajar@example.com	081234567895
7	Dita	Jl. Medan No. 7	dita@example.com	081234567896
8	Alam	Jl. Laguboti No. 8	alam@example.com	081234567897
9	Indah	Jl. Sigumpar No. 9	indah@example.com	081234567898
10	Sari	Jl. Silimbat No. 10	sari@example.com	081234567899
11	Rizki	Jl. Tarutung No. 11	rizky@example.com	081234567900
12	Eka	Jl. Siborongborong No. 12	eka@gmail.com	081234567901
13	Lia	Jl. Tarutung No. 13	lia@gmail.com	081234567902
14	Gilang	Jl. Pangaribuan No. 14	gilang@gmail.com	081234567903
15	Tia	Jl. Bahal No. 15	tia@gmail.com	081234567904
16	Budi	Jl. Parapat No. 16	budi@gmail.com	081234567905
17	Cahya	Jl. Sipoholon No. 17	cahya@gmail.com	081234567906
18	Dani	Jl. Pahae No. 18	dani@gmail.com	081234567907
19	Luna	Jl. Balige No. 19	luna@gmail.com	081234567908
20	Farhan	Jl. Huta No. 20	farhan@gmail.com	081234567909
21	Ari	Jl. Sisingamangaraja No. 21	ari@gmail.com	081234567910
22	Fina	Jl. Dolok Sanggul No. 22	fina@gmail.com	081234567911
23	Arief	Jl. Lumban Dolok No. 23	arief@gmail.com	081234567912
24	Nina	Jl. Pematang Siantar No. 24	nina@gmail.com	081234567913
25	Tomi	Jl. Nainggolan No. 25	tomi@gmail.com	081234567914
26	Alya	Jl. Samosir No. 26	alya@gmail.com	081234567915
27	Raka	Jl. Lumban Raya No. 27	raka@gmail.com	081234567916
28	Novi	Jl. Lumban Silintong No. 28	novi@gmail.com	081234567917
29	Vina	Jl. Dolok Merangir No. 29	vina@gmail.com	081234567918
30	Kiki	Jl. Parbubu No. 30	kiki@gmail.com	081234567919
31	Rama	Jl. Gonting No. 31	rama@gmail.com	081234567920
32	Fikri	Jl. Ujung No. 32	fikri@gmail.com	081234567921
33	Cinta	Jl. Hutasiantar No. 33	cinta@gmail.com	081234567922
34	Yuli	Jl. Huta Holbung No. 34	yuli@gmail.com	081234567923
35	Eka	Jl. Sihombing No. 35	eka2@gmail.com	081234567924
36	Tania	Jl. Buntu No. 36	tania@gmail.com	081234567925
37	Rian	Jl. Sipangolu No. 37	rian@gmail.com	081234567926
38	Della	Jl. Dolok Lumban No. 38	della@gmail.com	081234567927
39	Gita	Jl. Siopat Suhu No. 39	gita@gmail.com	081234567928
40	Adita	Jl. Lumban Ginting No. 40	adita@gmail.com	081234567929
41	Azka	Jl. Parbubu No. 41	azka@gmail.com	081234567930
42	Anis	Jl. Borbor No. 42	anis@gmail.com	081234567931
43	Kaisar	Jl. Sisingamangaraja No. 43	kaisar@gmail.com	081234567932
44	Mirza	Jl. Sipoholon No. 44	mirza@gmail.com	081234567933
45	Feri	Jl. Nainggolan No. 45	feri@gmail.com	081234567934
46	Wira	Jl. Huta Parsaoran No. 46	wira@gmail.com	081234567935
47	Bintang	Jl. Tarutung No. 47	bintang@gmail.com	081234567936
48	Tari	Jl. Pematang Siantar No. 48	tari@gmail.com	081234567937
49	Siska	Jl. Gonting No. 49	siska@gmail.com	081234567938
50	Putra	Jl. Lumban Silintong No. 50	putra@gmail.com	081234567939
\.


--
-- Name: admin_id_admin_seq; Type: SEQUENCE SET; Schema: pemesanan_tiket; Owner: postgres
--

SELECT pg_catalog.setval('pemesanan_tiket.admin_id_admin_seq', 1, false);


--
-- Name: destinasi_id_destinasi_seq; Type: SEQUENCE SET; Schema: pemesanan_tiket; Owner: postgres
--

SELECT pg_catalog.setval('pemesanan_tiket.destinasi_id_destinasi_seq', 1, false);


--
-- Name: laporan_destinasi_id_laporan_seq; Type: SEQUENCE SET; Schema: pemesanan_tiket; Owner: postgres
--

SELECT pg_catalog.setval('pemesanan_tiket.laporan_destinasi_id_laporan_seq', 2, true);


--
-- Name: pemesanan_id_pemesanan_seq; Type: SEQUENCE SET; Schema: pemesanan_tiket; Owner: postgres
--

SELECT pg_catalog.setval('pemesanan_tiket.pemesanan_id_pemesanan_seq', 2, true);


--
-- Name: pengunjung_id_pengguna_seq; Type: SEQUENCE SET; Schema: pemesanan_tiket; Owner: postgres
--

SELECT pg_catalog.setval('pemesanan_tiket.pengunjung_id_pengguna_seq', 1, false);


--
-- Name: admin_id_admin_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admin_id_admin_seq', 1, false);


--
-- Name: destinasi_id_destinasi_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.destinasi_id_destinasi_seq', 1, false);


--
-- Name: laporan_id_laporan_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.laporan_id_laporan_seq', 4, true);


--
-- Name: pemesanan_id_pemesanan_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pemesanan_id_pemesanan_seq', 1, false);


--
-- Name: pengunjung_id_pengguna_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pengunjung_id_pengguna_seq', 1, false);


--
-- Name: admin admin_pkey; Type: CONSTRAINT; Schema: pemesanan_tiket; Owner: postgres
--

ALTER TABLE ONLY pemesanan_tiket.admin
    ADD CONSTRAINT admin_pkey PRIMARY KEY (id_admin);


--
-- Name: destinasi destinasi_pkey; Type: CONSTRAINT; Schema: pemesanan_tiket; Owner: postgres
--

ALTER TABLE ONLY pemesanan_tiket.destinasi
    ADD CONSTRAINT destinasi_pkey PRIMARY KEY (id_destinasi);


--
-- Name: laporan_destinasi laporan_destinasi_pkey; Type: CONSTRAINT; Schema: pemesanan_tiket; Owner: postgres
--

ALTER TABLE ONLY pemesanan_tiket.laporan_destinasi
    ADD CONSTRAINT laporan_destinasi_pkey PRIMARY KEY (id_laporan);


--
-- Name: pemesanan pemesanan_pkey; Type: CONSTRAINT; Schema: pemesanan_tiket; Owner: postgres
--

ALTER TABLE ONLY pemesanan_tiket.pemesanan
    ADD CONSTRAINT pemesanan_pkey PRIMARY KEY (id_pemesanan);


--
-- Name: pengunjung pengunjung_pkey; Type: CONSTRAINT; Schema: pemesanan_tiket; Owner: postgres
--

ALTER TABLE ONLY pemesanan_tiket.pengunjung
    ADD CONSTRAINT pengunjung_pkey PRIMARY KEY (id_pengguna);


--
-- Name: admin admin_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin
    ADD CONSTRAINT admin_pkey PRIMARY KEY (id_admin);


--
-- Name: destinasi destinasi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.destinasi
    ADD CONSTRAINT destinasi_pkey PRIMARY KEY (id_destinasi);


--
-- Name: laporan laporan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.laporan
    ADD CONSTRAINT laporan_pkey PRIMARY KEY (id_laporan);


--
-- Name: pemesanan pemesanan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pemesanan
    ADD CONSTRAINT pemesanan_pkey PRIMARY KEY (id_pemesanan);


--
-- Name: pengunjung pengunjung_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pengunjung
    ADD CONSTRAINT pengunjung_pkey PRIMARY KEY (id_pengguna);


--
-- Name: pemesanan after_pemesanan_insert_update_harga; Type: TRIGGER; Schema: pemesanan_tiket; Owner: postgres
--

CREATE TRIGGER after_pemesanan_insert_update_harga AFTER INSERT ON pemesanan_tiket.pemesanan FOR EACH ROW EXECUTE FUNCTION public.update_total_tiket();


--
-- Name: pemesanan insert_pemesanan; Type: TRIGGER; Schema: pemesanan_tiket; Owner: postgres
--

CREATE TRIGGER insert_pemesanan AFTER INSERT ON pemesanan_tiket.pemesanan FOR EACH ROW EXECUTE FUNCTION pemesanan_tiket.insert_laporan_pemesanan();


--
-- Name: pemesanan after_pemesanan_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER after_pemesanan_insert AFTER INSERT ON public.pemesanan FOR EACH ROW EXECUTE FUNCTION public.insert_laporan_pemesanan();


--
-- Name: admin admin_id_destinasi_fkey; Type: FK CONSTRAINT; Schema: pemesanan_tiket; Owner: postgres
--

ALTER TABLE ONLY pemesanan_tiket.admin
    ADD CONSTRAINT admin_id_destinasi_fkey FOREIGN KEY (id_destinasi) REFERENCES public.destinasi(id_destinasi);


--
-- Name: laporan_destinasi laporan_destinasi_id_destinasi_fkey; Type: FK CONSTRAINT; Schema: pemesanan_tiket; Owner: postgres
--

ALTER TABLE ONLY pemesanan_tiket.laporan_destinasi
    ADD CONSTRAINT laporan_destinasi_id_destinasi_fkey FOREIGN KEY (id_destinasi) REFERENCES public.destinasi(id_destinasi);


--
-- Name: pemesanan pemesanan_id_destinasi_fkey; Type: FK CONSTRAINT; Schema: pemesanan_tiket; Owner: postgres
--

ALTER TABLE ONLY pemesanan_tiket.pemesanan
    ADD CONSTRAINT pemesanan_id_destinasi_fkey FOREIGN KEY (id_destinasi) REFERENCES public.destinasi(id_destinasi);


--
-- Name: pemesanan pemesanan_id_pengguna_fkey; Type: FK CONSTRAINT; Schema: pemesanan_tiket; Owner: postgres
--

ALTER TABLE ONLY pemesanan_tiket.pemesanan
    ADD CONSTRAINT pemesanan_id_pengguna_fkey FOREIGN KEY (id_pengguna) REFERENCES public.pengunjung(id_pengguna);


--
-- Name: admin admin_id_destinasi_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin
    ADD CONSTRAINT admin_id_destinasi_fkey FOREIGN KEY (id_destinasi) REFERENCES public.destinasi(id_destinasi);


--
-- Name: laporan laporan_id_destinasi_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.laporan
    ADD CONSTRAINT laporan_id_destinasi_fkey FOREIGN KEY (id_destinasi) REFERENCES public.destinasi(id_destinasi);


--
-- Name: laporan laporan_pengunjung_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.laporan
    ADD CONSTRAINT laporan_pengunjung_id_fkey FOREIGN KEY (pengunjung_id) REFERENCES public.pengunjung(id_pengguna);


--
-- Name: pemesanan pemesanan_id_destinasi_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pemesanan
    ADD CONSTRAINT pemesanan_id_destinasi_fkey FOREIGN KEY (id_destinasi) REFERENCES public.destinasi(id_destinasi);


--
-- Name: pemesanan pemesanan_id_pengguna_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pemesanan
    ADD CONSTRAINT pemesanan_id_pengguna_fkey FOREIGN KEY (id_pengguna) REFERENCES public.pengunjung(id_pengguna);


--
-- Name: SCHEMA pemesanan_tiket; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA pemesanan_tiket TO admin;
GRANT USAGE ON SCHEMA pemesanan_tiket TO pengunjung;


--
-- Name: TABLE destinasi; Type: ACL; Schema: pemesanan_tiket; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE pemesanan_tiket.destinasi TO admin;
GRANT SELECT ON TABLE pemesanan_tiket.destinasi TO pengunjung;


--
-- Name: TABLE laporan_destinasi; Type: ACL; Schema: pemesanan_tiket; Owner: postgres
--

GRANT ALL ON TABLE pemesanan_tiket.laporan_destinasi TO admin;
GRANT SELECT ON TABLE pemesanan_tiket.laporan_destinasi TO pengunjung;


--
-- Name: TABLE pemesanan; Type: ACL; Schema: pemesanan_tiket; Owner: postgres
--

GRANT ALL ON TABLE pemesanan_tiket.pemesanan TO admin;
GRANT SELECT ON TABLE pemesanan_tiket.pemesanan TO pengunjung;


--
-- PostgreSQL database dump complete
--

