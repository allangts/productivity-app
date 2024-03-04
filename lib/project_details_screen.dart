import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final String projectName;

  ProjectDetailsScreen(this.projectName);

  @override
  _ProjectDetailsScreenState createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final TextEditingController _notesController = TextEditingController();
  String _selectedDuration = '25 minutos';
  bool _isRunning = false;
  int _durationInSeconds = 25 * 60; // Tempo inicial: 25 minutos
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = _getNotesKey(widget.projectName);
    String notes = prefs.getString(key) ?? '';
    setState(() {
      _notesController.text = notes;
    });
  }

  Future<void> _saveNotes(String notes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = _getNotesKey(widget.projectName);
    await prefs.setString(key, notes);
  }

  String _getNotesKey(String projectName) {
    return 'notes_$projectName';
  }

  void _startTimer() {
    _isRunning = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_durationInSeconds > 0) {
          _durationInSeconds--;
        } else {
          _timer!.cancel();
          _isRunning = false;
        }
      });
    });
  }

  void _stopTimer() {
    _isRunning = false;
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName),
        actions: [
          DropdownButton<String>(
            value: _selectedDuration,
            onChanged: (String? newValue) {
              setState(() {
                _selectedDuration = newValue!;
                _durationInSeconds = int.parse(newValue.split(' ')[0]) * 60;
              });
            },
            items: <String>['25 minutos', '10 minutos', '5 minutos']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          IconButton(
            icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              if (_isRunning) {
                _stopTimer();
              } else {
                _startTimer();
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Center(
            child: Text(
              _formatDuration(_durationInSeconds),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _notesController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                labelText: 'Anotações',
                border: OutlineInputBorder(),
              ),
              onChanged: _saveNotes,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _notesController.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
