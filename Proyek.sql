CREATE TABLE Pengunjung
(
  id_pengguna INT NOT NULL,
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
  nama_destinasi INT NOT NULL,
  lokasi INT NOT NULL,
  deskripsi_destinasi INT NOT NULL,
  harga_tiket INT NOT NULL,
  kuota_tiket INT NOT NULL,
  PRIMARY KEY (id_destinasi)
);

CREATE TABLE Admin
(
  id_admin INT NOT NULL,
  nama_admin INT NOT NULL,
  email_admin INT NOT NULL,
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
