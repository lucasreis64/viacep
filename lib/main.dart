import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(CEPApp());
}

class CEPApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consulta de CEP',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController cepController = TextEditingController();
  List<CEP> ceps = [];

  Future<void> fetchCEP() async {
    final cep = cepController.text;
    final response =
        await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));

    if (response.statusCode == 200) {
      final cepData = CEP.fromMap(response.body);

      // Verificar se o CEP já existe na lista
      if (!ceps.contains(cepData)) {
        setState(() {
          ceps.add(cepData);
        });
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('CEP não encontrado'),
            content: Text('O CEP informado não foi encontrado.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consulta de CEP'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: cepController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'CEP'),
            ),
            ElevatedButton(
              onPressed: fetchCEP,
              child: Text('Consultar CEP'),
            ),
            SizedBox(height: 16),
            Text('CEPs cadastrados:'),
            Expanded(
              child: ListView.builder(
                itemCount: ceps.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(ceps[index].cep),
                    subtitle: Text(ceps[index].localidade),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CEP {
  final String cep;
  final String localidade;

  CEP({
    required this.cep,
    required this.localidade,
  });

  factory CEP.fromMap(Map<String, dynamic> map) {
    return CEP(
      cep: map['cep'] ?? '',
      localidade: map['localidade'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cep': cep,
      'localidade': localidade,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CEP && other.cep == cep;
  }

  @override
  int get hashCode => cep.hashCode;
}
