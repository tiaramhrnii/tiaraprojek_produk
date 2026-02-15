import 'dart:io';
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:tiaraprojek/models/api.dart';
import 'package:tiaraprojek/models/mproduk.dart';
import 'package:tiaraprojek/ui/produk_page.dart';

class ProdukForm extends StatefulWidget {
  final Mproduk? produk;
  const ProdukForm({Key? key, this.produk}) : super(key: key);

  @override
  _ProdukFormState createState() => _ProdukFormState();
}

class _ProdukFormState extends State<ProdukForm> {
  final _kodeController = TextEditingController();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  
  XFile? _pickedFile; 
  Uint8List? _webImage; 
  final picker = ImagePicker(); 

  @override
  void initState() {
    super.initState();
    if (widget.produk != null) {
      _kodeController.text = widget.produk!.kode;
      _namaController.text = widget.produk!.nama;
      _hargaController.text = widget.produk!.harga.toString();
    }
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        var f = await pickedFile.readAsBytes();
        setState(() {
          _webImage = f;
          _pickedFile = pickedFile;
        });
      } else {
        setState(() {
          _pickedFile = pickedFile;
        });
      }
    }
  }

  Future simpanData() async {
    if (_kodeController.text.isEmpty || _namaController.text.isEmpty || _hargaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua field harus diisi!")),
      );
      return;
    }

    String url = widget.produk == null ? BaseUrl.create : BaseUrl.update;
    var request = http.MultipartRequest('POST', Uri.parse(url));
    
    request.fields['kode'] = _kodeController.text;
    request.fields['kode_elektro'] = _kodeController.text;
    
    request.fields['nama'] = _namaController.text;
    request.fields['nama_elektro'] = _namaController.text;
    
    request.fields['harga'] = _hargaController.text;

    if (widget.produk != null) {
      request.fields['id'] = widget.produk!.id;
    }

    if (_pickedFile != null) {
      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'foto',
          _webImage!,
          filename: _pickedFile!.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath('foto', _pickedFile!.path));
      }
    }

    try {
      var response = await request.send();
      
      var responseData = await response.stream.bytesToString();
      print("Server Response: $responseData");

      if (response.statusCode == 200) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ProdukPage()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menyimpan data ke server")),
        );
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.produk == null ? "Tambah Produk" : "Ubah Produk"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            TextField(
              controller: _kodeController, 
              decoration: const InputDecoration(
                labelText: "Kode Produk",
                border: OutlineInputBorder(),
              )
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _namaController, 
              decoration: const InputDecoration(
                labelText: "Nama Produk",
                border: OutlineInputBorder(),
              )
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _hargaController, 
              decoration: const InputDecoration(
                labelText: "Harga",
                border: OutlineInputBorder(),
              ), 
              keyboardType: TextInputType.number
            ),
            const SizedBox(height: 20),
            const Text("Foto Produk:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: getImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _pickedFile != null
                    ? (kIsWeb 
                        ? Image.memory(_webImage!, fit: BoxFit.cover) 
                        : Image.file(File(_pickedFile!.path), fit: BoxFit.cover)) 
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                            Text("Klik untuk pilih foto dari galeri"),
                          ],
                        )
                      ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: simpanData, 
                child: const Text("SIMPAN PRODUK", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}