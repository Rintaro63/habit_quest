import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const HabitQuestApp());
}

class HabitQuestApp extends StatelessWidget {
  const HabitQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Quest',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const HabitHomePage(),
    );
  }
}

class HabitHomePage extends StatefulWidget {
  const HabitHomePage({super.key});

  @override
  State<HabitHomePage> createState() => _HabitHomePageState();
}

class _HabitHomePageState extends State<HabitHomePage> {
  int level = 1;
  int exp = 0;
  int expToNext = 100;

  String todayQuest = '腹筋20回';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      level = prefs.getInt('level') ?? 1;
      exp = prefs.getInt('exp') ?? 0;
      expToNext = prefs.getInt('expToNext') ?? 100;
      todayQuest = prefs.getString('quest') ?? '腹筋20回';
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('level', level);
    await prefs.setInt('exp', exp);
    await prefs.setInt('expToNext', expToNext);
    await prefs.setString('quest', todayQuest);
  }

  Future<void> _resetData() async {
  final prefs = await SharedPreferences.getInstance();

  setState(() {
    level = 1;
    exp = 0;
    expToNext = 100;
    todayQuest = '腹筋20回';
  });

  await prefs.setInt('level', level);
  await prefs.setInt('exp', exp);
  await prefs.setInt('expToNext', expToNext);
  await prefs.setString('quest', todayQuest);
  }

  void _completeQuest() {
    const int gainedExp = 10;

    setState(() {
      exp += gainedExp;
      if (exp >= expToNext) {
        exp -= expToNext;
        level += 1;
        // 必要ならここでexpToNextを上げていくロジックを入れる
      }
    });

    _saveData();
  }

  Future<void> _editQuest() async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => QuestEditDialog(current: todayQuest),
    );
    if (result != null && result.trim().isNotEmpty) {
      setState(() {
        todayQuest = result.trim();
      });
      _saveData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double progress = expToNext == 0 ? 0 : exp / expToNext;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Quest'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 編集ボタンは上にまとめる
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _editQuest,
                child: const Text('クエスト編集'),
              ),
            ),

            // LV & EXP
            Text(
              'LV：$level',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('EXP：$exp / $expToNext'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
            ),

            const SizedBox(height: 32),

            // 今日のクエスト
            const Text(
              '今日のクエスト：',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '「$todayQuest」',
              style: const TextStyle(fontSize: 18),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _resetData,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    'リセット',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 8),

            // クエスト達成ボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _completeQuest,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'クエスト達成',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuestEditDialog extends StatefulWidget {
  final String current;

  const QuestEditDialog({super.key, required this.current});

  @override
  State<QuestEditDialog> createState() => _QuestEditDialogState();
}

class _QuestEditDialogState extends State<QuestEditDialog> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.current);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('クエストを編集'),
      content: TextField(
        controller: controller,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () =>
              Navigator.pop(context, controller.text.trim()),
          child: const Text('保存'),
        ),
      ],
    );
  }
}
