import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<Reminder> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await NotificationService.loadAll();
    if (!mounted) return;
    setState(() {
      _items = list;
      _loading = false;
    });
  }

  Future<void> _persist() async {
    await NotificationService.saveAll(_items);
  }

  Future<void> _toggle(Reminder r, bool value) async {
    if (value) {
      final ok = await NotificationService.requestPermission();
      if (!ok) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please allow notifications to enable reminders')),
        );
        return;
      }
    }
    setState(() => r.on = value);
    await _persist();
    if (value) {
      await NotificationService.schedule(r);
    } else {
      await NotificationService.cancel(r.id);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text(value ? 'Reminder enabled ✅' : 'Reminder turned off')),
    );
  }

  String _fmtTime(int h, int m) =>
      '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

  String _repeatLabel(Reminder r) {
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (r.repeat == 'daily') {
      return 'Daily at ${_fmtTime(r.hour, r.minute)}';
    }
    return 'Weekly · ${days[r.weekday]} ${_fmtTime(r.hour, r.minute)}';
  }

  // ---------------- CREATE / EDIT SHEET ----------------
  Future<void> _openSheet({Reminder? existing}) async {
    final isNew = existing == null;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final bodyCtrl = TextEditingController(text: existing?.body ?? '');
    String repeat = existing?.repeat ?? 'daily';
    int weekday = existing?.weekday ?? 1;
    TimeOfDay time = TimeOfDay(
      hour: existing?.hour ?? 9,
      minute: existing?.minute ?? 0,
    );
    bool alarmSound = existing?.useAlarmSound ?? true;
    bool vibrate = existing?.vibrate ?? true;

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(isNew ? 'New reminder' : 'Edit reminder',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // Title
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Message
                  TextField(
                    controller: bodyCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Repeat
                  const Text('Repeat',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13.5)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _chip('Daily', repeat == 'daily',
                          () => setSheet(() => repeat = 'daily')),
                      _chip('Weekly', repeat == 'weekly',
                          () => setSheet(() => repeat = 'weekly')),
                    ],
                  ),

                  // Weekday chips
                  if (repeat == 'weekly') ...[
                    const SizedBox(height: 16),
                    const Text('Day',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13.5)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (int i = 1; i <= 7; i++)
                          _dayChip(
                            ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                                [i - 1],
                            weekday == i,
                            () => setSheet(() => weekday = i),
                          ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Time
                  const Text('Time',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13.5)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: time,
                      );
                      if (picked != null) setSheet(() => time = picked);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            _fmtTime(time.hour, time.minute),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                          const Spacer(),
                          const Text('Pick',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Sound toggle
                  SwitchListTile(
                    value: alarmSound,
                    onChanged: (v) => setSheet(() => alarmSound = v),
                    activeColor: AppColors.primary,
                    title: const Text('Alarm sound',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text(
                        'Rings like an alarm with your alarm tone'),
                    secondary: const Icon(Icons.music_note_outlined,
                        color: AppColors.primary),
                  ),

                  // Vibrate toggle
                  SwitchListTile(
                    value: vibrate,
                    onChanged: (v) => setSheet(() => vibrate = v),
                    activeColor: AppColors.primary,
                    title: const Text('Vibrate',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle:
                        const Text('Phone vibrates when the alarm rings'),
                    secondary: const Icon(Icons.vibration,
                        color: AppColors.primary),
                  ),

                  const SizedBox(height: 12),
                  const Text(
                    '💡 Notifications work best on the installed Android/iOS app.',
                    style: TextStyle(
                        color: AppColors.textMuted, fontSize: 11.5),
                  ),
                  const SizedBox(height: 16),

                  // Buttons
                  Row(
                    children: [
                      if (!isNew)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context, {'delete': true});
                            },
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Delete'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              foregroundColor: AppColors.error,
                              side:
                                  const BorderSide(color: AppColors.error),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      if (!isNew) const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            foregroundColor: AppColors.textMuted,
                            side: BorderSide(color: Colors.grey.shade400),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (titleCtrl.text.trim().isEmpty) return;
                            Navigator.pop(context, {
                              'title': titleCtrl.text.trim(),
                              'body': bodyCtrl.text.trim(),
                              'repeat': repeat,
                              'weekday': weekday,
                              'hour': time.hour,
                              'minute': time.minute,
                              'useAlarmSound': alarmSound,
                              'vibrate': vibrate,
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Save',
                              style:
                                  TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (result == null) return;

    if (result['delete'] == true && existing != null) {
      await NotificationService.cancel(existing.id);
      setState(() => _items.removeWhere((r) => r.id == existing.id));
      await _persist();
      return;
    }

    if (result['delete'] == true) return;

    if (isNew) {
      final newId = DateTime.now().millisecondsSinceEpoch % 1000000;
      final r = Reminder(
        id: newId,
        title: result['title'],
        body: result['body'],
        repeat: result['repeat'],
        weekday: result['weekday'],
        hour: result['hour'],
        minute: result['minute'],
        on: true,
        vibrate: result['vibrate'] ?? true,
        useAlarmSound: result['useAlarmSound'] ?? true,
      );
      setState(() => _items.add(r));
      await _persist();
      await NotificationService.schedule(r);
    } else {
      existing!.title = result['title'];
      existing.body = result['body'];
      existing.repeat = result['repeat'];
      existing.weekday = result['weekday'];
      existing.hour = result['hour'];
      existing.minute = result['minute'];
      existing.vibrate = result['vibrate'] ?? true;
      existing.useAlarmSound = result['useAlarmSound'] ?? true;
      setState(() {});
      await _persist();
      if (existing.on) await NotificationService.schedule(existing);
    }
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected
                  ? AppColors.primary
                  : Colors.grey.withValues(alpha: 0.35)),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : AppColors.text,
                fontWeight: FontWeight.w600,
                fontSize: 13)),
      ),
    );
  }

  Widget _dayChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected
                  ? AppColors.primary
                  : Colors.grey.withValues(alpha: 0.35)),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : AppColors.text,
                fontSize: 12,
                fontWeight: FontWeight.w700)),
      ),
    );
  }

  // ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00695C), Color(0xFF00897B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.notifications_active,
                          color: Colors.white, size: 42),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Stay on track',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text(
                                'Gentle reminders help you complete your career journey.',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12.5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.fromLTRB(4, 4, 4, 8),
                  child: Text('Your reminders',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                ),
                ..._items.map(_reminderTile),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _openSheet(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Create reminder'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'Notifications work best on the installed Android/iOS app. '
                    'On web, allow notifications in your browser.',
                    style: TextStyle(
                        color: AppColors.textMuted, fontSize: 11.5),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
    );
  }

  Widget _reminderTile(Reminder r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openSheet(existing: r),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  r.repeat == 'daily'
                      ? Icons.wb_sunny_outlined
                      : Icons.calendar_today_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14.5)),
                    const SizedBox(height: 2),
                    Text(_repeatLabel(r),
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              Switch(
                value: r.on,
                onChanged: (v) => _toggle(r, v),
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}