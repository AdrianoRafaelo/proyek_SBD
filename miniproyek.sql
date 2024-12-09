CREATE SCHEMA pemesanan_tiket;

CREATE TABLE pemesanan_tiket.Pengunjung
(
  id_pengguna SERIAL PRIMARY KEY,
  nama VARCHAR(255) NOT NULL,
  alamat VARCHAR(255) NOT NULL,  
  email VARCHAR(255) NOT NULL,   
  no_telp VARCHAR(15) NOT NULL
);

CREATE TABLE pemesanan_tiket.Pemesanan
(
  id_pemesanan SERIAL PRIMARY KEY,
  tanggal_pemesanan DATE NOT NULL,
  tanggal_kunjungan DATE NOT NULL,
  jumlah_tiket INT NOT NULL,
  id_pengguna INT NOT NULL,
  id_destinasi INT NOT NULL,
  FOREIGN KEY (id_pengguna) REFERENCES Pengunjung(id_pengguna),
  FOREIGN KEY (id_destinasi) REFERENCES Destinasi(id_destinasi)
);

CREATE TABLE pemesanan_tiket.Destinasi
(
  id_destinasi SERIAL PRIMARY KEY,
  nama_destinasi VARCHAR(255) NOT NULL,  
  lokasi VARCHAR(255) NOT NULL,  
  deskripsi_destinasi TEXT NOT NULL,
  harga_tiket INT NOT NULL,
  kuota_tiket INT NOT NULL
);

CREATE TABLE pemesanan_tiket.Admin
(
  id_admin SERIAL PRIMARY KEY,  
  nama_admin VARCHAR(255) NOT NULL,  
  email_admin VARCHAR(255) NOT NULL, 
  id_destinasi INT NOT NULL,
  total_tiket INT DEFAULT 0,
  FOREIGN KEY (id_destinasi) REFERENCES Destinasi(id_destinasi)
);

CREATE TABLE pemesanan_tiket.Laporan_Destinasi (
  id_laporan SERIAL PRIMARY KEY,
  bulan INT NOT NULL,
  tahun INT NOT NULL,
  id_destinasi INT NOT NULL,
  total_kunjungan INT NOT NULL,
  FOREIGN KEY (id_destinasi) REFERENCES Destinasi(id_destinasi)
);

-- data dummy 
INSERT INTO pemesanan_tiket.Pengunjung (id_pengguna, nama, alamat, email, no_telp) VALUES
(1, 'Anastasya', 'Jl. Aekristop No. 1', 'putri@gmail.com', '081234567890'),
(2, 'Nokatri', 'Jl. Balige No. 2', 'budi@gmail.com', '081234567891'),
(3, 'Amel', 'Jl. Aekristop No. 90', 'amel@gmail.com', '085243954890');

SELECT * FROM pemesanan_tiket.Pemesanan;
INSERT INTO pemesanan_tiket.Pemesanan (tanggal_pemesanan, tanggal_kunjungan, jumlah_tiket, id_pengguna, id_destinasi) VALUES
('2024-12-01', '2024-12-05', 2, 1, 1),
('2024-12-02', '2024-12-06', 3, 2, 2);
TRUNCATE TABLE pemesanan_tiket.laporan_destinasi RESTART IDENTITY;

INSERT INTO pemesanan_tiket.Destinasi (id_destinasi, nama_destinasi, lokasi, deskripsi_destinasi, harga_tiket, kuota_tiket) VALUES
(1, 'Air Terjun Sipiso-piso', 'Tapanuli Utara', 'Air terjun terbesar di Sumatera Utara yang memiliki pemandangan indah.', 150000, 400),
(2, 'Danau Toba', 'Tapanuli Utara', 'Danau terbesar di Indonesia dengan pemandangan alam yang sangat memukau.', 250000, 350),
(3, 'Bukit Simarjarunjung', 'Tapanuli Utara', 'Bukit yang menawarkan pemandangan spektakuler Danau Toba dan sekitarnya.', 120000, 300),
(4, 'Pantai Parbaba', 'Tapanuli Utara', 'Pantai berpasir putih dengan suasana tenang yang cocok untuk berlibur.', 100000, 500),
(5, 'Pulau Samosir', 'Tapanuli Utara', 'Pulau di tengah Danau Toba dengan keindahan alam yang luar biasa.', 300000, 250);
SELECT * FROM pemesanan_tiket.Destinasi;

-- penggunaan View
CREATE VIEW pemesanan_tiket.view_pendapatan_per_destinasi AS
SELECT 
    d.id_destinasi,
    d.nama_destinasi,
    d.lokasi,
    COUNT(p.id_pemesanan) AS total_pemesanan,
    EXTRACT(MONTH FROM p.tanggal_pemesanan) AS bulan_pemesanan,
    EXTRACT(YEAR FROM p.tanggal_pemesanan) AS tahun_pemesanan
FROM 
    pemesanan_tiket.Pemesanan p
JOIN 
    pemesanan_tiket.Destinasi d ON p.id_destinasi = d.id_destinasi
GROUP BY 
    d.id_destinasi, d.nama_destinasi, d.lokasi, EXTRACT(MONTH FROM p.tanggal_pemesanan), EXTRACT(YEAR FROM p.tanggal_pemesanan)
ORDER BY 
    total_pemesanan DESC;  

SELECT * FROM pemesanan_tiket.view_pendapatan_per_destinasi;

-- penggunaan trigger
-- Trigger for inserting laporan_pemesanan
CREATE OR REPLACE FUNCTION pemesanan_tiket.insert_laporan_pemesanan()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

-- Create Trigger for pemesanan
CREATE TRIGGER insert_pemesanan
AFTER INSERT ON pemesanan_tiket.Pemesanan
FOR EACH ROW
EXECUTE FUNCTION pemesanan_tiket.insert_laporan_pemesanan();

-- melakukan pengecekan apakah trigger telah sukses atau tidak
INSERT INTO pemesanan_tiket.Pemesanan (tanggal_pemesanan, tanggal_kunjungan, jumlah_tiket, id_pengguna, id_destinasi) 
VALUES ('2024-12-05', '2025-01-08', 2, 1, 1),
('2024-12-05', '2025-01-01', 2, 1, 1),
('2024-12-05', '2025-01-07', 1, 1, 3);

select * from pemesanan_tiket.Laporan_Destinasi;
select * from pemesanan_tiket.Pemesanan;

-- harga tiket
CREATE OR REPLACE FUNCTION update_total_tiket()
RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

-- Trigger untuk memanggil fungsi update_total_tiket setelah pemesanan baru dimasukkan
CREATE TRIGGER after_pemesanan_insert_update_harga
AFTER INSERT ON pemesanan_tiket.Pemesanan
FOR EACH ROW
EXECUTE FUNCTION update_total_tiket();

-- penggunaan authorization
GRANT USAGE ON SCHEMA pemesanan_tiket TO admin;
CREATE ROLE admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON pemesanan_tiket.destinasi TO admin;
SET ROLE admin;
SELECT * FROM pemesanan_tiket.destinasi WHERE id_destinasi = 6;
INSERT INTO pemesanan_tiket.destinasi (id_destinasi, nama_destinasi, lokasi, deskripsi_destinasi, harga_tiket, kuota_tiket) VALUES
(6, 'Salib Kasih', 'Tapanuli Utara', 'Wisata Rohani didaerah tinggi dengan bangunan tinggi yang berbentuk salib.', 50000, 50);
RESET ROLE;

GRANT ALL ON pemesanan_tiket.laporan_destinasi TO admin;
GRANT ALL ON pemesanan_tiket.pemesanan TO admin;
SET ROLE admin;
SELECT * FROM pemesanan_tiket.pemesanan WHERE tanggal_kunjungan = '2025-01-01';
INSERT INTO pemesanan_tiket.Pemesanan (tanggal_pemesanan, tanggal_kunjungan, jumlah_tiket, id_pengguna, id_destinasi) 
VALUES ('2024-12-09', '2025-01-01', 2, 1, 1);
RESET ROLE;

GRANT ALL ON pemesanan_tiket.laporan_destinasi TO admin;
SELECT * FROM pemesanan_tiket.laporan_destinasi;

GRANT USAGE ON SCHEMA pemesanan_tiket TO pengunjung;
CREATE ROLE pengunjung;
GRANT SELECT ON pemesanan_tiket.destinasi TO pengunjung;
GRANT SELECT ON pemesanan_tiket.laporan_destinasi TO pengunjung;
GRANT SELECT ON pemesanan_tiket.pemesanan TO pengunjung;
SET ROLE pengunjung;
RESET ROLE;

SELECT * FROM pemesanan_tiket.destinasi;
SELECT * FROM pemesanan_tiket.laporan_destinasi;
SELECT * FROM pemesanan_tiket.pemesanan;

-- Penggunaan Stored Procedure
CREATE OR REPLACE PROCEDURE pemesanan_tiket.pemesanan_tiket(
    p_id_pengguna INT,
    p_id_destinasi INT,
    p_jumlah_tiket INT,
    p_tanggal_pemesanan DATE,
    p_tanggal_kunjungan DATE
)
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

-- pengujian procedure
CALL pemesanan_tiket.pemesanan_tiket(1, 2, 3, '2024-12-10', '2025-01-15');
CALL pemesanan_tiket.pemesanan_tiket(1, 3, 1, '2024-12-09', '2025-01-28');
CALL pemesanan_tiket.pemesanan_tiket(3, 6, 51, '2024-12-09', '2025-01-09');
CALL pemesanan_tiket.pemesanan_tiket(3, 6, 50, '2024-12-09', '2025-01-09');

SELECT * FROM pemesanan_tiket.pemesanan;
SELECT * FROM pemesanan_tiket.destinasi;

-- penambahan kuota
CREATE OR REPLACE PROCEDURE pemesanan_tiket.tambah_kuota_tiket(
    p_id_destinasi INT,
    p_tambah_kuota INT
)
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

-- pengujian procedure nya berfungsi dengan baik atau tidak
CALL pemesanan_tiket.tambah_kuota_tiket(6, 50);  

SELECT * FROM pemesanan_tiket.destinasi;

-- cursor
DO $$
DECLARE
    kuota_ready_cursor CURSOR FOR
    SELECT id_tiket, nama_destinasi, kuota_tiket
    FROM Tiket
    WHERE kuota_tiket > 0;

    tiket_row RECORD;
BEGIN
    OPEN kuota_ready_cursor;
    LOOP
        FETCH NEXT FROM kuota_ready_cursor INTO tiket_row;
        EXIT WHEN NOT FOUND;

        -- Cetak informasi tiket
        RAISE NOTICE 'ID: %, Destinasi: %, Kuota: %',
            tiket_row.id_tiket, tiket_row.nama_destinasi, tiket_row.kuota_tiket;
    END LOOP;
    CLOSE kuota_ready_cursor;
END $$;

