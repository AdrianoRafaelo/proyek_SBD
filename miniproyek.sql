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
  total_tiket INT NOT NULL DEFAULT 0,
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

-- data dummy
INSERT INTO Pengunjung (id_pengguna, nama, alamat, email, no_telp) VALUES
(1, 'Anastasya', 'Jl. Aekristop No. 1', 'putri@gmail.com', '081234567890'),
(2, 'Nokatri', 'Jl. Balige No. 2', 'budi@gmail.com', '081234567891');

SELECT * FROM Pemesanan;
INSERT INTO Pemesanan (tanggal_pemesanan, tanggal_kunjungan, jumlah_tiket, id_pengguna, id_destinasi) VALUES
('2024-12-01', '2024-12-05', 2, 1, 1),
('2024-12-02', '2024-12-06', 3, 2, 2);

INSERT INTO Destinasi (id_destinasi, nama_destinasi, lokasi, deskripsi_destinasi, harga_tiket, kuota_tiket) VALUES
(1, 'Air Terjun Sipiso-piso', 'Tapanuli Utara', 'Air terjun terbesar di Sumatera Utara yang memiliki pemandangan indah.', 150000, 400),
(2, 'Danau Toba', 'Tapanuli Utara', 'Danau terbesar di Indonesia dengan pemandangan alam yang sangat memukau.', 250000, 350),
(3, 'Bukit Simarjarunjung', 'Tapanuli Utara', 'Bukit yang menawarkan pemandangan spektakuler Danau Toba dan sekitarnya.', 120000, 300),
(4, 'Pantai Parbaba', 'Tapanuli Utara', 'Pantai berpasir putih dengan suasana tenang yang cocok untuk berlibur.', 100000, 500),
(5, 'Pulau Samosir', 'Tapanuli Utara', 'Pulau di tengah Danau Toba dengan keindahan alam yang luar biasa.', 300000, 250);
SELECT * FROM Destinasi;

-- penggunaan view
CREATE VIEW view_pendapatan_per_destinasi AS
SELECT 
    d.id_destinasi,
    d.nama_destinasi,
    d.lokasi,
    SUM(p.total_tiket) AS total_pendapatan,
    COUNT(p.id_pemesanan) AS total_pemesanan,
    EXTRACT(MONTH FROM p.tanggal_pemesanan) AS bulan_pemesanan,
    EXTRACT(YEAR FROM p.tanggal_pemesanan) AS tahun_pemesanan
FROM 
    Pemesanan p
JOIN 
    Destinasi d ON p.id_destinasi = d.id_destinasi
GROUP BY 
    d.id_destinasi, d.nama_destinasi, d.lokasi, EXTRACT(MONTH FROM p.tanggal_pemesanan), EXTRACT(YEAR FROM p.tanggal_pemesanan)
ORDER BY 
    total_pendapatan DESC;

SELECT * FROM view_pendapatan_per_destinasi;

-- penggunaan trigger
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
INSERT INTO Pemesanan (tanggal_pemesanan, tanggal_kunjungan, jumlah_tiket, total_tiket,id_pengguna, id_destinasi) 
VALUES ('2024-12-05', '2025-01-08', 2, 50000, 1, 1),
('2024-12-05', '2025-01-01', 2, 225000, 1, 1),
('2024-12-05', '2025-01-07', 1, 300000, 1, 3);

select * from Laporan_Destinasi;
select * from Pemesanan;

-- kuota tiket
-- Membuat fungsi untuk mengurangi kuota tiket
CREATE OR REPLACE FUNCTION update_kuota_tiket()
RETURNS TRIGGER AS $$
BEGIN
    -- Mengurangi kuota tiket destinasi sesuai dengan jumlah tiket yang dipesan pada pemesanan
    UPDATE Destinasi
    SET kuota_tiket = kuota_tiket - NEW.jumlah_tiket
    WHERE id_destinasi = NEW.id_destinasi;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Membuat trigger yang memanggil fungsi update_kuota_tiket setelah pemesanan baru dimasukkan
CREATE TRIGGER after_pemesanan_insert_update_kuota
AFTER INSERT ON Pemesanan
FOR EACH ROW
EXECUTE FUNCTION update_kuota_tiket();

-- pengecekan
INSERT INTO Pemesanan (tanggal_pemesanan, tanggal_kunjungan, jumlah_tiket, total_tiket, status_pemesanan, id_pengguna, id_destinasi) 
VALUES ('2024-12-06', '2025-01-29', 2, 350000, 4, 1, 1)

SELECT * FROM Pemesanan;
SELECT id_destinasi, kuota_tiket FROM Destinasi;

-- harga tiket
-- Menambah kolom total_tiket jika belum ada
-- Fungsi untuk menghitung total harga tiket
CREATE OR REPLACE FUNCTION update_total_tiket()
RETURNS TRIGGER AS $$
BEGIN
    -- Menghitung total harga tiket berdasarkan harga tiket dan jumlah tiket
    UPDATE Pemesanan
    SET total_tiket = NEW.jumlah_tiket * (SELECT harga_tiket FROM Destinasi WHERE id_destinasi = NEW.id_destinasi)
    WHERE id_pemesanan = NEW.id_pemesanan;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger untuk memanggil fungsi update_total_tiket setelah pemesanan baru dimasukkan
CREATE TRIGGER after_pemesanan_insert_update_harga
AFTER INSERT ON Pemesanan
FOR EACH ROW
EXECUTE FUNCTION update_total_tiket();


-- penggunaan authorization


-- Penggunaan Stored Procedure
 	