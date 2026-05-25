import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TelaPaises(),
    );
  }
}

class TelaPaises extends StatefulWidget {
  const TelaPaises({super.key});

  @override
  State<TelaPaises> createState() => _TelaPaisesState();
}

class _TelaPaisesState extends State<TelaPaises> {
  List paises = [];
  List paisesFiltrados = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    buscarPaises();
  }

  Future<void> buscarPaises() async {
    final resposta = await http.get(
      Uri.parse(
        'https://restcountries.com/v3.1/all?fields=name,capital,region,flags,population',
      ),
    );

    if (resposta.statusCode == 200) {
      final dados = jsonDecode(resposta.body);

      setState(() {
        paises = dados;
        paisesFiltrados = dados;
        carregando = false;
      });
    }
  }

  void pesquisarPais(String texto) {
    setState(() {
      paisesFiltrados = paises.where((pais) {
        final nome = pais['name']['common'].toString().toLowerCase();
        return nome.contains(texto.toLowerCase());
      }).toList();
    });
  }

  String formatarPopulacao(dynamic numero) {
    return numero.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
    );
  }

  void abrirDetalhes(dynamic pais) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaDetalhesPais(pais: pais),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeaf4ff),
      appBar: AppBar(
        title: const Text('Países do Mundo'),
        centerTitle: true,
        backgroundColor: const Color(0xffA9A9A9),
        foregroundColor: Colors.white,
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: pesquisarPais,
              decoration: const InputDecoration(
                hintText: 'Pesquisar país',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: paisesFiltrados.length,
              itemBuilder: (context, index) {
                final pais = paisesFiltrados[index];

                final nome = pais['name']['common'] ?? 'Sem nome';
                final capital = pais['capital'] != null
                    ? pais['capital'][0]
                    : 'Sem capital';
                final regiao = pais['region'] ?? 'Sem região';
                final populacao = pais['population'] ?? 0;
                final bandeira = pais['flags']['png'] ?? '';

                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 4,
                  child: ListTile(
                    onTap: () => abrirDetalhes(pais),
                    leading: Image.network(
                      bandeira,
                      width: 55,
                    ),
                    title: Text(
                      nome,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Capital: $capital\n'
                          'Região: $regiao\n'
                          'População: ${formatarPopulacao(populacao)}',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TelaDetalhesPais extends StatelessWidget {
  final dynamic pais;

  const TelaDetalhesPais({super.key, required this.pais});

  String formatarPopulacao(dynamic numero) {
    return numero.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final nome = pais['name']['common'] ?? 'Sem nome';
    final nomeOficial = pais['name']['official'] ?? 'Sem nome oficial';
    final capital =
    pais['capital'] != null ? pais['capital'][0] : 'Sem capital';
    final regiao = pais['region'] ?? 'Sem região';
    final populacao = pais['population'] ?? 0;
    final bandeira = pais['flags']['png'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xffeaf4ff),
      appBar: AppBar(
        title: Text(nome),
        backgroundColor: const Color(0xffA9A9A9),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Image.network(
                  bandeira,
                  width: 220,
                ),
                const SizedBox(height: 20),
                Text(
                  nome,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  nomeOficial,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 25),
                InfoPais(titulo: 'Capital', valor: capital),
                InfoPais(titulo: 'Região', valor: regiao),
                InfoPais(
                  titulo: 'População',
                  valor: '${formatarPopulacao(populacao)} habitantes',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InfoPais extends StatelessWidget {
  final String titulo;
  final String valor;

  const InfoPais({
    super.key,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffe0f2fe),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            '$titulo: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(valor),
          ),
        ],
      ),
    );
  }
}