import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import 'add_homework.dart';

void main() {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeworkListPage()),
      GoRoute(path: '/add', builder: (context, state) => const AddHomeworkPage()),
    ],
  );
  runApp(
    BlocProvider(
      create: (_) => HomeworkBloc()..add(LoadHomeworks()),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: "Homework App",
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        routerConfig: router,
      ),
    ),
  );
}

class Homework {
  final String id;
  final String subject;
  final String title;
  final DateTime dueDate;
  final bool isDone;

  Homework({
    required this.id,
    required this.subject,
    required this.title,
    required this.dueDate,
    this.isDone = false,
  });

  Homework copyWith({bool? isDone}) => Homework(
    id: id,
    subject: subject,
    title: title,
    dueDate: dueDate,
    isDone: isDone ?? this.isDone,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'subject': subject,
    'title': title,
    'dueDate': dueDate.toIso8601String(),
    'isDone': isDone,
  };

  factory Homework.fromMap(Map<String, dynamic> map) => Homework(
    id: map['id'],
    subject: map['subject'],
    title: map['title'],
    dueDate: DateTime.parse(map['dueDate']),
    isDone: map['isDone'],
  );
}

abstract class HomeworkEvent {}
class AddHomework extends HomeworkEvent {
  final Homework homework;
  AddHomework(this.homework);
}
class ToggleHomework extends HomeworkEvent {
  final String id;
  ToggleHomework(this.id);
}
class LoadHomeworks extends HomeworkEvent {}

class HomeworkBloc extends Bloc<HomeworkEvent, List<Homework>> {
  HomeworkBloc() : super([]) {
    on<LoadHomeworks>(_load);
    on<AddHomework>(_add);
    on<ToggleHomework>(_toggle);
  }

  Future<void> _load(LoadHomeworks e, Emitter<List<Homework>> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('homeworks') ?? [];
    emit(list.map((s) => Homework.fromMap(json.decode(s))).toList());
  }

  Future<void> _save(List<Homework> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('homeworks', list.map((h) => json.encode(h.toMap())).toList());
  }

  Future<void> _add(AddHomework e, Emitter<List<Homework>> emit) async {
    final updated = [...state, e.homework];
    await _save(updated);
    emit(updated);
  }

  Future<void> _toggle(ToggleHomework e, Emitter<List<Homework>> emit) async {
    final updated = state.map((h) => h.id == e.id ? h.copyWith(isDone: !h.isDone) : h).toList();
    await _save(updated);
    emit(updated);
  }
}

class HomeworkListPage extends StatelessWidget {
  const HomeworkListPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Homework")),
      body: BlocBuilder<HomeworkBloc, List<Homework>>(
        builder: (context, list) {
          if (list.isEmpty) {
            return const Center(
              child: Text(
                "No homework yet.\nTap + to add one.",
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final hw = list[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  leading: Checkbox(
                    value: hw.isDone,
                    onChanged: (_) => context.read<HomeworkBloc>().add(ToggleHomework(hw.id)),
                  ),
                  title: Text(
                    hw.title,
                    style: TextStyle(decoration: hw.isDone ? TextDecoration.lineThrough : null),
                  ),
                  subtitle: Text("${hw.subject} — Due: ${hw.dueDate.toLocal().toString().split(' ')[0]}"),
                  trailing: hw.isDone
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.schedule, color: Colors.orange),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add'),
        icon: const Icon(Icons.add),
        label: const Text("Add"),
      ),
    );
  }
}
