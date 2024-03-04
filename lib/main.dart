import 'package:flutter/material.dart';
import 'task_screen.dart'; // Importe a classe RoutineScreen
import 'finance_screen.dart'; // Importe a classe FinanceScreen
import 'project_details_screen.dart'; // Importe a classe ProjectDetailsScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciamento de Projetos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text('HomePage'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProjectManagementScreen()),
                );
              },
              child: Text('Projetos'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TaskScreen()),
                );
              },
              child: Text('Tarefas'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FinanceScreen()),
                );
              },
              child: Text('Finanças'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectManagementScreen extends StatefulWidget {
  @override
  _ProjectManagementScreenState createState() =>
      _ProjectManagementScreenState();
}

class _ProjectManagementScreenState extends State<ProjectManagementScreen> {
  List<String> projects = [];
  TextEditingController _projectController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciamento de Projetos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _projectController,
                    decoration: InputDecoration(
                      labelText: 'Novo Projeto',
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    _addProject(_projectController.text);
                    _projectController.clear();
                  },
                  child: Text('Adicionar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: projects.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(projects[index]),
                  onTap: () {
                    _showProjectDetails(context, projects[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addProject(String projectName) {
    setState(() {
      projects.add(projectName);
    });
  }

  void _showProjectDetails(BuildContext context, String projectName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailsScreen(projectName),
      ),
    );
  }

  @override
  void dispose() {
    _projectController.dispose();
    super.dispose();
  }
}
