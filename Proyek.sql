CREATE TABLE Pengunjung
(
  id_pengguna INT NOT NULL,
<<<<<<< HEAD
  nama VARCHAR(255) NOT NULL,
  alamat VARCHAR(255) NOT NULL,  
  email VARCHAR(255) NOT NULL,   
  no_telp VARCHAR(15) NOT NULL,  
  PRIMARY KEY (id_pengguna)
);

CREATE TABLE Pemesanan
(
  id_pemesanan INT NOT NULL,
  tanggal_pemesanan DATE NOT NULL,  
=======
  nama INT NOT NULL,
  alamat INT NOT NULL,
  email INT NOT NULL,
  no_telp INT NOT NULL,
  PRIMARY KEY (id_pengguna)
);


CREATE TABLE Pemesanan
(
  id_pemesanan INT NOT NULL,
  tanggal_pemesanan___ INT NOT NULL,
>>>>>>> cd809c36fda5a409f9b2492006d412572a922d99
  jumlah_tiket INT NOT NULL,
  total_tiket INT NOT NULL,
  status_pemesanan INT NOT NULL,
  id_pengguna INT NOT NULL,
  PRIMARY KEY (id_pemesanan),
  FOREIGN KEY (id_pengguna) REFERENCES Pengunjung(id_pengguna)
);

CREATE TABLE Destinasi
(
  id_destinasi INT NOT NULL,
<<<<<<< HEAD
  nama_destinasi VARCHAR(255) NOT NULL,  
  lokasi VARCHAR(255) NOT NULL,  
  deskripsi_destinasi TEXT NOT NULL,
=======
  nama_destinasi INT NOT NULL,
  lokasi INT NOT NULL,
  deskripsi_destinasi INT NOT NULL,
>>>>>>> cd809c36fda5a409f9b2492006d412572a922d99
  harga_tiket INT NOT NULL,
  kuota_tiket INT NOT NULL,
  PRIMARY KEY (id_destinasi)
);

CREATE TABLE Admin
(
  id_admin INT NOT NULL,
<<<<<<< HEAD
  nama_admin VARCHAR(255) NOT NULL,  
  email_admin VARCHAR(255) NOT NULL, 
=======
  nama_admin INT NOT NULL,
  email_admin INT NOT NULL,
>>>>>>> cd809c36fda5a409f9b2492006d412572a922d99
  id_destinasi INT NOT NULL,
  PRIMARY KEY (id_admin),
  FOREIGN KEY (id_destinasi) REFERENCES Destinasi(id_destinasi)
);

CREATE TABLE Laporan
(
  id_pengguna INT NOT NULL,
  id_destinasi INT NOT NULL,
  PRIMARY KEY (id_pengguna, id_destinasi),
  FOREIGN KEY (id_pengguna) REFERENCES Pengunjung(id_pengguna),
  FOREIGN KEY (id_destinasi) REFERENCES Destinasi(id_destinasi)
);
<<<<<<< HEAD

-- data dummy
INSERT INTO Pengunjung (id_pengguna, nama, alamat, email, no_telp) VALUES
(1, 'Anastasya', 'Jl. Aekristop No. 1', 'putri@gmail.com', '081234567890'),
(2, 'Nokatri', 'Jl. Balige No. 2', 'budi@gmail.com', '081234567891'),
(3, 'Chelsia', 'Jl. Tarutung No. 3', 'cici@gmail.com', '081234567892'),
(4, 'Andi', 'Jl. Siantar No. 4', 'andi@example.com', '081234567893'),
(5, 'Rina', 'Jl. Silaen No. 5', 'rina@example.com', '081234567894'),
(6, 'Fajar', 'Jl. Sipoholon No. 6', 'fajar@example.com', '081234567895'),
(7, 'Dita', 'Jl. Medan No. 7', 'dita@example.com', '081234567896'),
(8, 'Alam', 'Jl. Laguboti No. 8', 'alam@example.com', '081234567897'),
(9, 'Indah', 'Jl. Sigumpar No. 9', 'indah@example.com', '081234567898'),
(10, 'Sari', 'Jl. Silimbat No. 10', 'sari@example.com', '081234567899'),
(11, 'Rizki', 'Jl. Tarutung No. 11', 'rizky@example.com', '081234567900'),
(12, 'Eka', 'Jl. Siborongborong No. 12', 'eka@gmail.com', '081234567901'),
(13, 'Lia', 'Jl. Tarutung No. 13', 'lia@gmail.com', '081234567902'),
(14, 'Gilang', 'Jl. Pangaribuan No. 14', 'gilang@gmail.com', '081234567903'),
(15, 'Tia', 'Jl. Bahal No. 15', 'tia@gmail.com', '081234567904'),
(16, 'Budi', 'Jl. Parapat No. 16', 'budi@gmail.com', '081234567905'),
(17, 'Cahya', 'Jl. Sipoholon No. 17', 'cahya@gmail.com', '081234567906'),
(18, 'Dani', 'Jl. Pahae No. 18', 'dani@gmail.com', '081234567907'),
(19, 'Luna', 'Jl. Balige No. 19', 'luna@gmail.com', '081234567908'),
(20, 'Farhan', 'Jl. Huta No. 20', 'farhan@gmail.com', '081234567909'),
(21, 'Ari', 'Jl. Sisingamangaraja No. 21', 'ari@gmail.com', '081234567910'),
(22, 'Fina', 'Jl. Dolok Sanggul No. 22', 'fina@gmail.com', '081234567911'),
(23, 'Arief', 'Jl. Lumban Dolok No. 23', 'arief@gmail.com', '081234567912'),
(24, 'Nina', 'Jl. Pematang Siantar No. 24', 'nina@gmail.com', '081234567913'),
(25, 'Tomi', 'Jl. Nainggolan No. 25', 'tomi@gmail.com', '081234567914'),
(26, 'Alya', 'Jl. Samosir No. 26', 'alya@gmail.com', '081234567915'),
(27, 'Raka', 'Jl. Lumban Raya No. 27', 'raka@gmail.com', '081234567916'),
(28, 'Novi', 'Jl. Lumban Silintong No. 28', 'novi@gmail.com', '081234567917'),
(29, 'Vina', 'Jl. Dolok Merangir No. 29', 'vina@gmail.com', '081234567918'),
(30, 'Kiki', 'Jl. Parbubu No. 30', 'kiki@gmail.com', '081234567919'),
(31, 'Rama', 'Jl. Gonting No. 31', 'rama@gmail.com', '081234567920'),
(32, 'Fikri', 'Jl. Ujung No. 32', 'fikri@gmail.com', '081234567921'),
(33, 'Cinta', 'Jl. Hutasiantar No. 33', 'cinta@gmail.com', '081234567922'),
(34, 'Yuli', 'Jl. Huta Holbung No. 34', 'yuli@gmail.com', '081234567923'),
(35, 'Eka', 'Jl. Sihombing No. 35', 'eka2@gmail.com', '081234567924'),
(36, 'Tania', 'Jl. Buntu No. 36', 'tania@gmail.com', '081234567925'),
(37, 'Rian', 'Jl. Sipangolu No. 37', 'rian@gmail.com', '081234567926'),
(38, 'Della', 'Jl. Dolok Lumban No. 38', 'della@gmail.com', '081234567927'),
(39, 'Gita', 'Jl. Siopat Suhu No. 39', 'gita@gmail.com', '081234567928'),
(40, 'Adita', 'Jl. Lumban Ginting No. 40', 'adita@gmail.com', '081234567929'),
(41, 'Azka', 'Jl. Parbubu No. 41', 'azka@gmail.com', '081234567930'),
(42, 'Anis', 'Jl. Borbor No. 42', 'anis@gmail.com', '081234567931'),
(43, 'Kaisar', 'Jl. Sisingamangaraja No. 43', 'kaisar@gmail.com', '081234567932'),
(44, 'Mirza', 'Jl. Sipoholon No. 44', 'mirza@gmail.com', '081234567933'),
(45, 'Feri', 'Jl. Nainggolan No. 45', 'feri@gmail.com', '081234567934'),
(46, 'Wira', 'Jl. Huta Parsaoran No. 46', 'wira@gmail.com', '081234567935'),
(47, 'Bintang', 'Jl. Tarutung No. 47', 'bintang@gmail.com', '081234567936'),
(48, 'Tari', 'Jl. Pematang Siantar No. 48', 'tari@gmail.com', '081234567937'),
(49, 'Siska', 'Jl. Gonting No. 49', 'siska@gmail.com', '081234567938'),
(50, 'Putra', 'Jl. Lumban Silintong No. 50', 'putra@gmail.com', '081234567939');
SELECT * FROM pengunjung;

INSERT INTO Pemesanan (id_pemesanan, tanggal_pemesanan, jumlah_tiket, total_tiket, status_pemesanan, id_pengguna) VALUES
(1, '2024-12-01', 2, 200000, 1, 1),
(2, '2024-12-02', 3, 300000, 2, 2),
(3, '2024-12-03', 1, 100000, 1, 3),
(4, '2024-12-04', 4, 400000, 3, 4),
(5, '2024-12-05', 2, 200000, 2, 5),
(6, '2024-12-06', 5, 500000, 1, 6),
(7, '2024-12-07', 6, 600000, 3, 7),
(8, '2024-12-08', 1, 100000, 2, 8),
(9, '2024-12-09', 3, 300000, 1, 9),
(10, '2024-12-10', 2, 200000, 2, 10),
(11, '2024-12-11', 4, 400000, 3, 11),
(12, '2024-12-12', 1, 100000, 1, 12),
(13, '2024-12-13', 3, 300000, 2, 13),
(14, '2024-12-14', 2, 200000, 1, 14),
(15, '2024-12-15', 5, 500000, 3, 15),
(16, '2024-12-16', 2, 200000, 1, 16),
(17, '2024-12-17', 4, 400000, 3, 17),
(18, '2024-12-18', 3, 300000, 2, 18),
(19, '2024-12-19', 6, 600000, 1, 19),
(20, '2024-12-20', 3, 300000, 2, 20),
(21, '2024-12-21', 1, 100000, 1, 21),
(22, '2024-12-22', 4, 400000, 3, 22),
(23, '2024-12-23', 2, 200000, 2, 23),
(24, '2024-12-24', 3, 300000, 1, 24),
(25, '2024-12-25', 5, 500000, 3, 25),
(26, '2024-12-26', 1, 100000, 2, 26),
(27, '2024-12-27', 2, 200000, 1, 27),
(28, '2024-12-28', 3, 300000, 2, 28),
(29, '2024-12-29', 4, 400000, 1, 29),
(30, '2024-12-30', 5, 500000, 3, 30),
(31, '2024-12-31', 2, 200000, 2, 31),
(32, '2025-01-01', 6, 600000, 1, 32),
(33, '2025-01-02', 1, 100000, 3, 33),
(34, '2025-01-03', 4, 400000, 2, 34),
(35, '2025-01-04', 2, 200000, 1, 35),
(36, '2025-01-05', 3, 300000, 3, 36),
(37, '2025-01-06', 1, 100000, 2, 37),
(38, '2025-01-07', 5, 500000, 3, 38),
(39, '2025-01-08', 4, 400000, 1, 39),
(40, '2025-01-09', 3, 300000, 2, 40),
(41, '2025-01-10', 2, 200000, 3, 41),
(42, '2025-01-11', 6, 600000, 1, 42),
(43, '2025-01-12', 3, 300000, 2, 43),
(44, '2025-01-13', 5, 500000, 3, 44),
(45, '2025-01-14', 4, 400000, 1, 45),
(46, '2025-01-15', 2, 200000, 2, 46),
(47, '2025-01-16', 3, 300000, 1, 47),
(48, '2025-01-17', 4, 400000, 3, 48),
(49, '2025-01-18', 1, 100000, 2, 49),
(50, '2025-01-19', 2, 200000, 1, 50);
SELECT * FROM pemesanan;


INSERT INTO Destinasi (id_destinasi, nama_destinasi, lokasi, deskripsi_destinasi, harga_tiket, kuota_tiket) VALUES
(1, 'Air Terjun Sipiso-piso', 'Tapanuli Utara', 'Air terjun terbesar di Sumatera Utara yang memiliki pemandangan indah.', 150000, 400),
(2, 'Danau Toba', 'Tapanuli Utara', 'Danau terbesar di Indonesia dengan pemandangan alam yang sangat memukau.', 250000, 350),
(3, 'Bukit Simarjarunjung', 'Tapanuli Utara', 'Bukit yang menawarkan pemandangan spektakuler Danau Toba dan sekitarnya.', 120000, 300),
(4, 'Pantai Parbaba', 'Tapanuli Utara', 'Pantai berpasir putih dengan suasana tenang yang cocok untuk berlibur.', 100000, 500),
(5, 'Pulau Samosir', 'Tapanuli Utara', 'Pulau di tengah Danau Toba dengan keindahan alam yang luar biasa.', 300000, 250),
(6, 'Taman Simalungun', 'Tapanuli Utara', 'Taman wisata dengan flora dan fauna yang langka serta pemandangan alam hijau.', 180000, 200),
(7, 'Pantai Lumban Bul-Bul', 'Tapanuli Utara', 'Pantai yang tenang dengan air jernih dan pemandangan luar biasa.', 130000, 400),
(8, 'Air Terjun Efrata', 'Tapanuli Utara', 'Air terjun yang menyegarkan dengan alam sekitar yang hijau.', 180000, 450),
(9, 'Bukit Lawang', 'Tapanuli Utara', 'Bukit yang memiliki pemandangan indah dan jalur trekking menarik untuk para petualang.', 175000, 250),
(10, 'Desa Tomok', 'Tapanuli Utara', 'Desa yang terkenal dengan kebudayaan Batak dan tempat wisata sejarah di sekitar Danau Toba.', 100000, 350),
(11, 'Pusuk Buhit', 'Tapanuli Utara', 'Gunung yang dianggap sakral oleh masyarakat Batak dengan pemandangan yang memukau.', 220000, 200),
(12, 'Pantai Sibolga', 'Tapanuli Utara', 'Pantai yang indah dan tenang dengan panorama laut lepas.', 150000, 400),
(13, 'Kawasan Hutan Lindung Sipirok', 'Tapanuli Utara', 'Kawasan hutan tropis dengan berbagai spesies flora dan fauna.', 200000, 300),
(14, 'Pulau Mursala', 'Tapanuli Utara', 'Pulau yang terkenal dengan air terjun di tepi pantai dan pemandangan eksotis.', 250000, 150),
(15, 'Pemandian Air Panas Tarutung', 'Tapanuli Utara', 'Sumber air panas alami yang dipercaya memiliki khasiat penyembuhan.', 120000, 200),
(16, 'Danau Siombak', 'Tapanuli Utara', 'Danau yang terletak di kaki bukit dengan suasana yang sangat damai.', 100000, 450),
(17, 'Bukit Batu Parbubu', 'Tapanuli Utara', 'Bukit dengan pemandangan luar biasa dari ketinggian dan udara yang sejuk.', 140000, 500),
(18, 'Taman Wisata Alam Batang Toru', 'Tapanuli Utara', 'Taman wisata alam yang terkenal dengan keanekaragaman hayati dan pemandangan pegunungan.', 180000, 350),
(19, 'Pantai Tumijur', 'Tapanuli Utara', 'Pantai berpasir hitam dengan pemandangan laut yang memukau.', 120000, 300),
(20, 'Taman Nasional Gunung Leuser', 'Tapanuli Utara', 'Taman nasional yang melindungi berbagai spesies langka dan habitat alami.', 200000, 250),
(21, 'Situs Megalitikum Batu Gantung', 'Tapanuli Utara', 'Situs bersejarah yang menyimpan peninggalan batu megalitik dari zaman prasejarah.', 150000, 350),
(22, 'Desa Huta Siallagan', 'Tapanuli Utara', 'Desa wisata dengan budaya Batak yang masih kental, serta situs sejarah yang menarik.', 130000, 400),
(23, 'Pantai Ujung Batu', 'Tapanuli Utara', 'Pantai dengan batu-batu besar yang menarik dan pemandangan yang menawan.', 170000, 500),
(24, 'Situs Raja Batak', 'Tapanuli Utara', 'Situs sejarah yang terkenal dengan peninggalan kerajaan Batak purba.', 200000, 300),
(25, 'Pantai Gulo-Gulo', 'Tapanuli Utara', 'Pantai yang tenang dengan ombak kecil dan cocok untuk bersantai.', 140000, 450),
(26, 'Desa Pangururan', 'Tapanuli Utara', 'Desa yang terletak di Pulau Samosir dengan pemandangan Danau Toba yang indah.', 150000, 350),
(27, 'Kampung Batak', 'Tapanuli Utara', 'Kampung yang menggambarkan kehidupan tradisional masyarakat Batak dengan rumah adat dan budaya yang masih lestari.', 100000, 400),
(28, 'Tebing Tinggi', 'Tapanuli Utara', 'Tempat wisata alam dengan tebing-tebing batu yang menjulang tinggi dan pemandangan sekitar yang sangat memukau.', 180000, 300),
(29, 'Bukit Panggul', 'Tapanuli Utara', 'Bukit yang menawarkan pemandangan luas Danau Toba dari ketinggian.', 200000, 500),
(30, 'Pantai Siosar', 'Tapanuli Utara', 'Pantai indah dengan pasir putih dan panorama laut yang memukau.', 150000, 400),
(31, 'Gunung Pusuk Buhit', 'Tapanuli Utara', 'Gunung sakral dengan pemandangan luar biasa dan legenda yang kuat di kalangan masyarakat Batak.', 210000, 250),
(32, 'Air Terjun Singa', 'Tapanuli Utara', 'Air terjun yang sangat besar dengan suara gemuruh air yang khas.', 220000, 300),
(33, 'Taman Nasional Batang Toru', 'Tapanuli Utara', 'Taman nasional yang menyimpan keindahan alam dan flora fauna langka.', 250000, 200),
(34, 'Desa Ambarita', 'Tapanuli Utara', 'Desa wisata yang memiliki sejarah kerajaan Batak dengan situs batu kursi raja.', 120000, 350),
(35, 'Pantai Gok-gok', 'Tapanuli Utara', 'Pantai yang tenang dengan ombak kecil dan pasir putih.', 150000, 400),
(36, 'Gunung Sinabung', 'Tapanuli Utara', 'Gunung yang masih aktif dan menawarkan pemandangan dari puncaknya.', 200000, 250),
(37, 'Air Terjun Simangumban', 'Tapanuli Utara', 'Air terjun yang terletak di hutan tropis dan dikelilingi oleh pepohonan hijau.', 180000, 300),
(38, 'Situs Batu Sada', 'Tapanuli Utara', 'Situs bersejarah yang memiliki batu besar dengan cerita mitologi lokal.', 120000, 400),
(39, 'Desa Lumban Sitorang', 'Tapanuli Utara', 'Desa wisata yang terletak di sekitar Danau Toba dengan kebudayaan Batak yang kuat.', 150000, 350),
(40, 'Bukit Paropo', 'Tapanuli Utara', 'Bukit yang memiliki pemandangan luar biasa dari Danau Toba dengan udara yang sejuk.', 170000, 450),
(41, 'Pantai Cermin', 'Tapanuli Utara', 'Pantai yang tenang dengan pemandangan laut yang indah.', 130000, 400),
(42, 'Danau Parsaoran', 'Tapanuli Utara', 'Danau kecil yang menawarkan ketenangan dan pemandangan alam sekitarnya.', 100000, 450),
(43, 'Taman Rusa Batang Toru', 'Tapanuli Utara', 'Taman yang dilengkapi dengan area konservasi rusa dan flora yang indah.', 200000, 300),
(44, 'Pantai Indah Kuta', 'Tapanuli Utara', 'Pantai dengan pasir putih dan ombak yang cocok untuk berselancar.', 150000, 500),
(45, 'Pantai Indah Kuta', 'Tapanuli Utara', 'Pantai dengan pasir putih dan ombak yang cocok untuk berselancar.', 150000, 500),
(46, 'Situs Batu Sada', 'Tapanuli Utara', 'Situs bersejarah yang memiliki batu besar dengan cerita mitologi lokal.', 120000, 400),
(47, 'Taman Wisata Alam Batang Toru', 'Tapanuli Utara', 'Taman wisata alam yang terkenal dengan keanekaragaman hayati dan pemandangan pegunungan.', 180000, 350),
(48, 'Danau Parba', 'Tapanuli Utara', 'Danau yang terletak di kaki gunung dengan pemandangan alam yang menenangkan.', 100000, 500),
(49, 'Bukit Tanjung Karang', 'Tapanuli Utara', 'Bukit yang menawarkan pemandangan luar biasa ke arah Danau Toba.', 170000, 400),
(50, 'Taman Rekreasi Sipirok', 'Tapanuli Utara', 'Taman rekreasi dengan fasilitas bermain dan pemandangan alam yang menyegarkan.', 140000, 450);

-- penggunaan view 
CREATE VIEW ViewPemesanan AS
SELECT 
    p.id_pemesanan,
    p.tanggal_pemesanan,
    pg.nama AS nama_pengunjung,
    p.jumlah_tiket,
    p.total_tiket,
    CASE 
        WHEN p.status_pemesanan = 1 THEN 'Pending'
        WHEN p.status_pemesanan = 2 THEN 'Confirmed'
        WHEN p.status_pemesanan = 3 THEN 'Cancelled'
        ELSE 'Unknown'
    END AS status_pemesanan
FROM Pemesanan p
JOIN Pengunjung pg ON p.id_pengguna = pg.id_pengguna;
SELECT * FROM ViewPemesanan;

-- trigger 
-- Fungsi untuk otomatis menambahkan data ke tabel Laporan
CREATE OR REPLACE FUNCTION insert_laporan_dengan_pemesanan()
RETURNS TRIGGER AS $$
BEGIN
  -- Memasukkan data ke tabel Laporan berdasarkan pemesanan baru
  INSERT INTO Laporan (pengunjung_id, destinasi_id)
  VALUES (NEW.id_pengguna, NEW.destinasi_id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger yang akan dipicu setelah insert pada tabel Pemesanan
CREATE TRIGGER after_insert_pemesanan
AFTER INSERT ON Pemesanan
FOR EACH ROW
EXECUTE FUNCTION insert_laporan_dengan_pemesanan();

=======
>>>>>>> cd809c36fda5a409f9b2492006d412572a922d99
