CREATE TABLE Pengunjung
(
  id_pengguna SERIAL PRIMARY KEY,
  nama VARCHAR(255) NOT NULL,
  alamat VARCHAR(255) NOT NULL,  
  email VARCHAR(255) NOT NULL,   
  no_telp VARCHAR(15) NOT NULL
);

CREATE TABLE Pemesanan
(
  id_pemesanan SERIAL PRIMARY KEY,
  tanggal_pemesanan DATE NOT NULL,
  tanggal_kunjungan DATE NOT NULL,
  jumlah_tiket INT NOT NULL,
  total_tiket INT NOT NULL,
  status_pemesanan INT NOT NULL,
  id_pengguna INT NOT NULL,
  id_destinasi INT NOT NULL,
  FOREIGN KEY (id_pengguna) REFERENCES Pengunjung(id_pengguna),
  FOREIGN KEY (id_destinasi) REFERENCES Destinasi(id_destinasi)
);

CREATE TABLE Destinasi
(
  id_destinasi SERIAL PRIMARY KEY,
  nama_destinasi VARCHAR(255) NOT NULL,  
  lokasi VARCHAR(255) NOT NULL,  
  deskripsi_destinasi TEXT NOT NULL,
  harga_tiket INT NOT NULL,
  kuota_tiket INT NOT NULL
);

CREATE TABLE Admin
(
  id_admin SERIAL PRIMARY KEY,  
  nama_admin VARCHAR(255) NOT NULL,  
  email_admin VARCHAR(255) NOT NULL, 
  id_destinasi INT NOT NULL,
  FOREIGN KEY (id_destinasi) REFERENCES Destinasi(id_destinasi)
);

CREATE TABLE Laporan_Destinasi (
  id_laporan SERIAL PRIMARY KEY,
  bulan INT NOT NULL,
  tahun INT NOT NULL,
  id_destinasi INT NOT NULL,
  total_kunjungan INT NOT NULL,
  FOREIGN KEY (id_destinasi) REFERENCES Destinasi(id_destinasi)
);


ALTER TABLE Laporan
ADD COLUMN nama_destinasi VARCHAR(255);

-- data dummy
INSERT INTO Pengunjung (id_pengguna, nama, alamat, email, no_telp) VALUES
(1, 'Anastasya', 'Jl. Aekristop No. 1', 'putri@gmail.com', '081234567890'),
(2, 'Nokatri', 'Jl. Balige No. 2', 'budi@gmail.com', '081234567891');

SELECT * FROM Pemesanan;
INSERT INTO Pemesanan (tanggal_pemesanan, tanggal_kunjungan, jumlah_tiket, total_tiket, status_pemesanan, id_pengguna, id_destinasi) VALUES
('2024-12-01', '2024-12-05', 2, 200000, 1, 1, 1),
('2024-12-02', '2024-12-06', 3, 300000, 2, 2, 2);


INSERT INTO Destinasi (id_destinasi, nama_destinasi, lokasi, deskripsi_destinasi, harga_tiket, kuota_tiket) VALUES
(1, 'Air Terjun Sipiso-piso', 'Tapanuli Utara', 'Air terjun terbesar di Sumatera Utara yang memiliki pemandangan indah.', 150000, 400),
(2, 'Danau Toba', 'Tapanuli Utara', 'Danau terbesar di Indonesia dengan pemandangan alam yang sangat memukau.', 250000, 350),
(3, 'Bukit Simarjarunjung', 'Tapanuli Utara', 'Bukit yang menawarkan pemandangan spektakuler Danau Toba dan sekitarnya.', 120000, 300),
(4, 'Pantai Parbaba', 'Tapanuli Utara', 'Pantai berpasir putih dengan suasana tenang yang cocok untuk berlibur.', 100000, 500),
(5, 'Pulau Samosir', 'Tapanuli Utara', 'Pulau di tengah Danau Toba dengan keindahan alam yang luar biasa.', 300000, 250);

-- penggunaan view
CREATE VIEW view_pemesanan_destinasi AS
SELECT 
    p.id_pemesanan,
    p.tanggal_pemesanan,
    p.tanggal_kunjungan,
    p.jumlah_tiket,
    p.total_tiket,
    p.status_pemesanan,
    p.id_pengguna,
    d.id_destinasi,
    d.nama_destinasi
FROM 
    Pemesanan p
JOIN 
    Destinasi d ON p.id_destinasi = d.id_destinasi;

SELECT * FROM view_pemesanan_destinasi;

-- Membuat fungsi untuk trigger dimana akan menampilkan jumlah destinasi dikunjungi seberapa banyak selama satu bulan
CREATE OR REPLACE FUNCTION insert_laporan_pemesanan()
RETURNS TRIGGER AS $$
BEGIN
    -- menghitung pemesanan dengan destinasi tertentu yang berada dibulan dan tahun yang sama 
    INSERT INTO Laporan_Destinasi (bulan, tahun, id_destinasi, total_kunjungan)
    SELECT 
        EXTRACT(MONTH FROM NEW.tanggal_kunjungan),  
        EXTRACT(YEAR FROM NEW.tanggal_kunjungan),  
        NEW.id_destinasi,                           
        COUNT(*)                                    
    FROM Pemesanan
    WHERE id_destinasi = NEW.id_destinasi
    AND EXTRACT(MONTH FROM tanggal_kunjungan) = EXTRACT(MONTH FROM NEW.tanggal_kunjungan)
    AND EXTRACT(YEAR FROM tanggal_kunjungan) = EXTRACT(YEAR FROM NEW.tanggal_kunjungan)
    GROUP BY EXTRACT(MONTH FROM NEW.tanggal_kunjungan), EXTRACT(YEAR FROM NEW.tanggal_kunjungan), NEW.id_destinasi;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- memastikan trigger mengarah ke fungsi yang dibuat diatas
CREATE TRIGGER after_pemesanan_insert
AFTER INSERT ON Pemesanan
FOR EACH ROW
EXECUTE FUNCTION insert_laporan_pemesanan();

-- melakukan pengecekan apakah trigger telah sukses atau tidak
INSERT INTO Pemesanan (tanggal_pemesanan, tanggal_kunjungan, jumlah_tiket, total_tiket, status_pemesanan, id_pengguna, id_destinasi) 
VALUES ('2024-12-05', '2025-01-08', 2, 50000, 1, 1, 1),
('2024-12-05', '2025-01-01', 2, 225000, 1, 1, 1),
('2024-12-05', '2025-01-07', 1, 300000, 1, 2, 3);

select * from Laporan_Destinasi;
select * from Pemesanan;

-- Authorization 

CREATE ROLE admin;

CREATE ROLE pengunjung;

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL
);


-- Berikan akses penuh kepada role 'admin' ke semua tabel
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;

-- Berikan akses baca kepada role 'admin'
GRANT SELECT ON ALL TABLES IN SCHEMA public TO admin

-- Berikan akses untuk menambah data tetapi tidak menghapusnya
GRANT INSERT ON ALL TABLES IN SCHEMA public TO admin;

-- Berikan akses untuk mengupdate data
GRANT UPDATE ON ALL TABLES IN SCHEMA public TO admin;

-- Berikan akses untuk menghapus
GRANT DELETE ON ALL TABLES IN SCHEMA public TO admin;

-- Batasi akses ke tabel sensitif
REVOKE ALL ON TABLE users FROM pengunjung;

-- Buat pengguna baru dengan role 'pengunjung'
CREATE USER user_pengunjung WITH PASSWORD 'password123';
GRANT pengunjung TO user_pengunjung;

-- Buat pengguna baru dengan role 'admin'
CREATE USER user_admin WITH PASSWORD 'securepassword';
GRANT admin TO user_admin;

SET ROLE admin;
INSERT INTO Pemesanan (tanggal_pemesanan, tanggal_kunjungan, jumlah_tiket, total_tiket, status_pemesanan, id_pengguna, id_destinasi)
VALUES 
('2024-12-05', '2025-01-01', 2, 450000, 1, 1, 48);  

REVOKE ALL ON SEQUENCE pemesanan_id_pemesanan_seq FROM pengunjung;



RESET ROLE


SELECT rolname FROM pg_roles;