import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseTodoTestPage extends StatefulWidget {
  const SupabaseTodoTestPage({super.key});

  @override
  State<SupabaseTodoTestPage> createState() => _SupabaseTodoTestPageState();
}

class _SupabaseTodoTestPageState extends State<SupabaseTodoTestPage> {
  final _future = Supabase.instance.client
      .from('todos')
      .select();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Todos Test'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
            return const Center(child: Text('No todos found. Make sure the table "todos" exists and has data.'));
          }
          
          final todos = snapshot.data as List;
          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: ((context, index) {
              final todo = todos[index];
              return ListTile(
                title: Text(todo['name'] ?? 'Unnamed Todo'),
              );
            }),
          );
        },
      ),
    );
  }
}
