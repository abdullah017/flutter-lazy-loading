import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = ScrollController();
  bool hasMore = true; // Daha fazla veri olup olmadığına bakıyoruz.
  int page =
      1; // Sayfa numarası, verilerin hangi sayfasının alındığını takip eder.
  List<String> items = []; // Alınan verileri saklayan liste.
  bool isLoading =
      false; // Veri alım işlemi sırasında çalıştırılacak yükleniyor durumu.

  @override
  void initState() {
    super.initState();
    fetch(); // Sayfa başlatıldığında veri alma işlemine başlamak için fetch() çağrılır.

    // ListView'in ScrollController'ını dinler ve sayfanın sonuna geldiğinde daha fazla veri almak için fetch() çağrılır.
    controller.addListener(() {
      if (controller.position.maxScrollExtent == controller.offset) {
        fetch();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose(); // Sayfa kapatıldığında ScrollController'ı temizle.
    super.dispose();
  }

  Future fetch() async {
    if (isLoading || !hasMore) {
      return; // Veri alım işlemi sırasında veya daha fazla veri yoksa işlemi durdur.
    }

    const limit = 25; // Her sayfada alınacak maksimum veri sayısı.

    setState(() {
      isLoading =
          true; // Veri alım işlemi başladığında isLoading'u true yapar, yükleniyor göstergesini gösterir.
    });

    final url = Uri.parse(
        'https://jsonplaceholder.typicode.com/posts?_limit=$limit&_page=$page');
    try {
      final response = await http.get(url); // Verileri uzaktan API'den alır.

      if (response.statusCode == 200) {
        // İstek başarılı ise
        final List newItems = json.decode(response.body);
        setState(() {
          page++; // Sayfa numarasını bir artırır.
          isLoading =
              false; // Veri alım işlemi tamamlandığında isLoading'u false yapar, yükleniyor göstergesini gizler.
          if (newItems.length < limit) {
            hasMore =
                false; // Alınan veri sayısı, limit sayısından azsa daha fazla veri olmadığını belirtir.
          }
        });

        setState(() {
          items.addAll(newItems.map<String>((item) {
            final number = item['id'];
            return 'Item $number'; // Alınan her veriyi 'Item {id}' şeklinde bir stringe dönüştürüp listeye ekler.
          }).toList());
        });
      } else {
        // Hata durumu ile ilgili bir işlem yapabilirsiniz.
        print('Veri getirme hatası: ${response.statusCode}');
      }
    } catch (e) {
      // Hata durumu ile ilgili bir işlem yapabilirsiniz.
      print('Veri getirme hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        controller: controller, // ScrollController'ı ListView'e atanır.
        padding: const EdgeInsets.all(12),
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index < items.length) {
            // Eğer index, mevcut veri sayısından küçükse, veriyi görüntüler.
            final item = items[index];
            return ListTile(
              title: Text(item),
            );
          } else {
            // Aksi halde daha fazla veri varsa veya veri alım işlemi devam ediyorsa yükleniyor göstergesi gösterilir, aksi takdirde veri olmadığını belirten bir metin gösterilir.
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: isLoading
                    ? const CircularProgressIndicator()
                    : hasMore
                        ? const CircularProgressIndicator()
                        : const Text('NO MORE DATA'),
              ),
            );
          }
        },
      ),
    );
  }
}
