import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tiaraprojek/models/mproduk.dart'; 
import 'package:tiaraprojek/models/api.dart';
import 'package:tiaraprojek/ui/produk_page.dart';
import 'package:tiaraprojek/ui/produk_form.dart'; 

class ProdukDetail extends StatelessWidget {
  final Mproduk produk;
  const ProdukDetail({Key? key, required this.produk}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    String urlGambar = "${BaseUrl.fotoUrl}${produk.foto}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView( 
        child: Column(
          children: [
            
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey[200],
              child: (produk.foto != null && produk.foto != '')
                  ? Image.network(
                      urlGambar,
                      fit: BoxFit.contain,
          
                      headers: const {
                        "Access-Control-Allow-Origin": "*",
                      },
                      errorBuilder: (context, error, stackTrace) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.broken_image, size: 80, color: Colors.red),
                          const SizedBox(height: 10),
                          const Text("Gambar Gagal Dimuat", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: SelectableText(
                              urlGambar, 
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
            ),
            
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Card(
                elevation: 2,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.shopping_bag, color: Colors.blue),
                      title: const Text("Nama Produk"),
                      subtitle: Text(produk.nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.qr_code, color: Colors.blue),
                      title: const Text("Kode Produk"),
                      subtitle: Text(produk.kode),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.money, color: Colors.blue),
                      title: const Text("Harga"),
                      subtitle: Text("Rp ${produk.harga}", 
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, 
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProdukForm(produk: produk)),
                    );
                  },
                  label: const Text("EDIT"),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, 
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  ),
                  onPressed: () => _konfirmasiHapus(context),
                  label: const Text("HAPUS"),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _konfirmasiHapus(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Data"),
        content: Text("Yakin ingin menghapus ${produk.nama}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              try {
                final response = await http.post(
                  Uri.parse(BaseUrl.delete),
                  body: {"id": produk.id}, 
                );
                
                if (response.statusCode == 200) {
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const ProdukPage()),
                      (route) => false,
                    );
                  }
                }
              } catch (e) {
                debugPrint("Error hapus: $e");
              }
            }, 
            child: const Text("Ya, Hapus", style: TextStyle(color: Colors.red))
          ),
        ],
      )
    );
  }
}