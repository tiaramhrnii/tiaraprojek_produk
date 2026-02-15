class Mproduk {
  final String id;
  final String kode;
  final String nama;
  final int harga;
  final String? foto;

  Mproduk({
    required this.id,
    required this.kode,
    required this.nama,
    required this.harga,
    this.foto,
  });

  factory Mproduk.fromJson(Map<String, dynamic> json) {
    return Mproduk(

      id: json['id']?.toString() ?? '0',
      
      kode: (json['kode'] ?? json['kode_elektro'] ?? '-').toString(), 
      
      nama: (json['nama'] ?? json['nama_elektro'] ?? 'Tanpa Nama').toString(),
      
      harga: int.tryParse(json['harga']?.toString() ?? '0') ?? 0,
      
      foto: json['foto']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "kode": kode,
      "nama": nama,
      "harga": harga,
      "foto": foto,
    };
  }
}