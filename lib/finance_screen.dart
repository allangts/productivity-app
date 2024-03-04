import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Import necessário para usar jsonEncode e jsonDecode

// Classe para representar uma entrada ou despesa financeira
class FinancialEntry {
  final String name;
  final double value;

  FinancialEntry(this.name, this.value);

  // Método para converter um objeto FinancialEntry em um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }

  // Método para criar um objeto FinancialEntry a partir de um mapa JSON
  factory FinancialEntry.fromJson(Map<String, dynamic> json) {
    return FinancialEntry(
      json['name'],
      json['value'],
    );
  }
}

// Tela principal para gerenciar finanças
class FinanceScreen extends StatefulWidget {
  @override
  _FinanceScreenState createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  // Mapa para armazenar entradas e despesas por data (mes e ano)
  Map<String, List<FinancialEntry>> _financialData = {};

  TextEditingController _nameController = TextEditingController();
  TextEditingController _valueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFinancialData(); // Carregar os dados financeiros ao iniciar a tela
  }

  @override
  void dispose() {
    _saveFinancialData(); // Salvar os dados financeiros ao fechar a tela
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciar Finanças'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  DropdownButton<int>(
                    value: _selectedMonth,
                    onChanged: (value) {
                      setState(() {
                        _selectedMonth = value!;
                      });
                    },
                    items: List.generate(12, (index) => index + 1)
                        .map((month) => DropdownMenuItem(
                          child: Text(month.toString()),
                          value: month,
                        ))
                        .toList(),
                  ),
                  SizedBox(width: 20),
                  DropdownButton<int>(
                    value: _selectedYear,
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value!;
                      });
                    },
                    items: List.generate(7, (index) => DateTime.now().year + index)
                        .map((year) => DropdownMenuItem(
                          child: Text(year.toString()),
                          value: year,
                        ))
                        .toList(),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Valor Total de Entradas: ${_calculateTotal(_selectedMonth, _selectedYear, isExpense: false).toStringAsFixed(2)}',
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Valor Total de Despesas: ${_calculateTotal(_selectedMonth, _selectedYear, isExpense: true).toStringAsFixed(2)}',
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Saldo: ${(_calculateTotal(_selectedMonth, _selectedYear, isExpense: false) - (-(_calculateTotal(_selectedMonth, _selectedYear, isExpense: true)))).toStringAsFixed(2)}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                ),
              ),
              TextField(
                controller: _valueController,
                decoration: InputDecoration(
                  labelText: 'Valor',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Adicionar entrada de dinheiro
                  _addEntry();
                },
                child: Text('Adicionar Entrada'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Adicionar despesa
                  _addExpense();
                },
                child: Text('Adicionar Despesa'),
              ),
              SizedBox(height: 20),
              Text('Lista de Entradas: '),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _getFinancialList(_selectedMonth, _selectedYear, isExpense: false),
              ),
              SizedBox(height: 20),
              Text('Lista de Despesas: '),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _getFinancialList(_selectedMonth, _selectedYear, isExpense: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para adicionar entrada de dinheiro
  void _addEntry() {
    double value = double.tryParse(_valueController.text) ?? 0.0;
    String key = '$_selectedMonth/$_selectedYear';
    setState(() {
      if (!_financialData.containsKey(key)) {
        _financialData[key] = [];
      }
      _financialData[key]?.add(FinancialEntry(_nameController.text, value));
    });
    _clearTextFields();
  }

  // Método para adicionar despesa
  void _addExpense() {
    double value = double.tryParse(_valueController.text) ?? 0.0;
    String key = '$_selectedMonth/$_selectedYear';
    setState(() {
      if (!_financialData.containsKey(key)) {
        _financialData[key] = [];
      }
      _financialData[key]?.add(FinancialEntry(_nameController.text, -value)); // Despesas são representadas como valores negativos
    });
    _clearTextFields();
  }

  // Método para obter a lista de widgets de entrada ou despesa financeira
  List<Widget> _getFinancialList(int month, int year, {required bool isExpense}) {
    String key = '$month/$year';
    return (_financialData[key] ?? [])
        .where((entry) => (isExpense && entry.value < 0) || (!isExpense && entry.value >= 0))
        .map((entry) => Text('${entry.name}: ${entry.value.toStringAsFixed(2)}'))
        .toList();
  }

  // Método para limpar os campos de texto
  void _clearTextFields() {
    _nameController.clear();
    _valueController.clear();
  }

  // Método para calcular o valor total de entradas ou despesas
  double _calculateTotal(int month, int year, {required bool isExpense}) {
    String key = '$month/$year';
    return (_financialData[key] ?? [])
        .where((entry) => (isExpense && entry.value < 0) || (!isExpense && entry.value >= 0))
        .map((entry) => entry.value)
        .fold(0.0, (prev, curr) => prev + curr);
  }

  // Método para salvar os dados financeiros no SharedPreferences
  Future<void> _saveFinancialData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('financialData', jsonEncode(_financialData));
  }

// Método para carregar os dados financeiros salvos no SharedPreferences
Future<void> _loadFinancialData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? data = prefs.getString('financialData');
  print('Dados carregados do SharedPreferences:');
  print(data);
  
  if (data != null) {
    Map<String, dynamic> decodedData = jsonDecode(data);
    _financialData = decodedData.map((key, value) {
      return MapEntry(key, (value as List<dynamic>).map((entry) {
        return FinancialEntry(entry['name'], entry['value'].toDouble());
      }).toList());
    });
    setState(() {});
    print('Dados convertidos e atribuídos com sucesso.');
  } else {
    print('Nenhum dado encontrado no SharedPreferences.');
  }
}

void main() {
  runApp(MaterialApp(
    home: FinanceScreen(),
  ));
}
}