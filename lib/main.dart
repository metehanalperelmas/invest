import 'Models/Crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

class CryptoListPage extends StatefulWidget {

  @override
  _CryptoListPageState createState() => _CryptoListPageState();
}

class _CryptoListPageState extends State<CryptoListPage> {
  List<Crypto> cryptoList = [];
  Timer? timer;
  Crypto? usdtCrypto;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchCryptoList() async {
    final response = await http.get(Uri.parse('https://www.paribu.com/ticker'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> coinData = json.decode(response.body);

      final cryptoEntry = coinData.entries.firstWhere(
            (entry) => entry.key == 'USDT_TL',
        orElse: () => MapEntry('', null),
      );

      if (cryptoEntry.value != null) {
        final String name = cryptoEntry.key;
        final String image = '';
        final double currentPrice = cryptoEntry.value['last'].toDouble();

        setState(() {
          usdtCrypto = Crypto(
            name: name,
            image: image,
            current_price: currentPrice,
          );
        });
      }
    } else {
      print('Failed to fetch crypto list');
    }
  }

  void startTimer() {
    fetchCryptoList();
    timer = Timer.periodic(Duration(seconds: 5), (_) {
      fetchCryptoList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crypto List'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          if (usdtCrypto != null)
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(bottom: 16.0),
              child: Text(
                '${usdtCrypto!.name} - ${usdtCrypto!.current_price?.toStringAsFixed(3)}',
                style: TextStyle(fontSize: 20),
              ),
            ),


        ],
      ),
    );
  }
}

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    home: CryptoListPage(),
  ));
}



