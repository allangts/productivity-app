import 'package:flutter/material.dart';

class ProjectManagementScreen extends StatefulWidget {
  @override
  _ProjectManagementScreenState createState() =>
      _ProjectManagementScreenState();
}

class _ProjectManagementScreenState extends State<ProjectManagementScreen> {
  List<String> projects = []; // Lista dinâmica de projetos
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(projectName),
          content: TextFormField(
            decoration: InputDecoration(
              labelText: 'Detalhes do Projeto',
            ),
            maxLines: null,
            keyboardType: TextInputType.multiline,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _projectController.dispose();
    super.dispose();
  }
}

