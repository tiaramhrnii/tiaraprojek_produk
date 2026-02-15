import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tiaraprojek/models/mproduk.dart'; 
import 'package:tiaraprojek/models/api.dart'; 
import 'package:tiaraprojek/ui/produk_form.dart';
import 'package:tiaraprojek/ui/produk_detail.dart';

class ProdukPage extends StatefulWidget {
  const ProdukPage({Key? key}) : super(key: key);

  @override
  _ProdukPageState createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  
  Future<List<Mproduk>> fetchProduk() async {
    try {
      final response = await http.get(Uri.parse(BaseUrl.list));

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Mproduk.fromJson(data)).toList();
      } else {
        throw Exception('Gagal memuat data');
      }
    } catch (e) {
      throw Exception('Koneksi Error: $e');
    }
  }

  Future<void> _onRefresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Produk'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProdukForm()),
              ).then((value) => setState(() {})); 
            },
          ),
        ],
      ),
      
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: FutureBuilder<List<Mproduk>>(
          future: fetchProduk(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Gagal mengambil data database"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Tidak ada data produk"));
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Mproduk item = snapshot.data![index];
                return ItemProduk(produk: item);
              },
            );
          },
        ),
      ),
    );
  }
}

class ItemProduk extends StatelessWidget {
  final Mproduk produk;
  const ItemProduk({Key? key, required this.produk}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    String thumbUrl = "${BaseUrl.baseUrl}/uploads/${produk.foto}";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProdukDetail(produk: produk)),
        );
      },
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(10),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 60,
              height: 60,
              color: Colors.grey[100],
              child: produk.foto != null && produk.foto != ''
                  ? Image.network(
                      thumbUrl,
                      fit: BoxFit.cover,
                      
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
                    )
                  : const Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          ),
          title: Text(
            produk.nama, 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Kode: ${produk.kode}"),
              Text(
                "Rp ${produk.harga}", 
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)
              ),
            ],
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }
}