// lib/screens/tasks_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import '../models/models.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  Priority? _filter;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(children: [
          // ── Header ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('My Tasks',
                      style: TextStyle(color: AppColors.textPrimary,
                          fontSize: 26, fontWeight: FontWeight.w800)),
                  Text('${p.pending.length} pending · ${p.completed.length} done',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                ]),
                GestureDetector(
                  onTap: () => _showAddSheet(context, p),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientAccent,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(
                          color: AppColors.accent.withOpacity(0.4),
                          blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: const Icon(Icons.add_rounded, color: AppColors.bg, size: 26),
                  ),
                ),
              ],
            ),
          ),

          // ── Priority filter ─────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: _FilterRow(
              selected: _filter,
              onSelect: (f) => setState(() => _filter = f),
            ),
          ),

          // ── Tabs ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Container(
              decoration: BoxDecoration(
                  color: AppColors.card, borderRadius: BorderRadius.circular(14)),
              child: TabBar(
                controller: _tabs,
                indicator: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(12)),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.bg,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                dividerColor: Colors.transparent,
                tabs: const [Tab(text: 'Pending'), Tab(text: 'Completed')],
              ),
            ),
          ),

          // ── Lists ────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _TaskList(
                  tasks: _applyFilter(p.pending),
                  provider: p,
                  isEmpty: p.pending.isEmpty,
                  emptyMsg: 'No pending tasks! 🎉',
                ),
                _TaskList(
                  tasks: _applyFilter(p.completed),
                  provider: p,
                  isEmpty: p.completed.isEmpty,
                  emptyMsg: 'Complete tasks to see them here',
                  isCompleted: true,
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  List<Task> _applyFilter(List<Task> list) =>
      _filter == null ? list : list.where((t) => t.priority == _filter).toList();

  void _showAddSheet(BuildContext ctx, AppProvider p, [Task? existing]) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _TaskSheet(p: p, existing: existing),
    );
  }
}

// ── Filter Row ────────────────────────────────────────────────
class _FilterRow extends StatelessWidget {
  final Priority? selected;
  final ValueChanged<Priority?> onSelect;
  const _FilterRow({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final dummy = Task(id: '', title: '', deadline: DateTime.now());
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        _Chip('All', null, selected == null, AppColors.textSecondary, onSelect),
        const SizedBox(width: 8),
        ...Priority.values.map((pr) {
          dummy.priority = pr;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _Chip(dummy.priorityLabel, pr, selected == pr,
                dummy.priorityColor, onSelect),
          );
        }),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Priority? value;
  final bool active;
  final Color color;
  final ValueChanged<Priority?> onTap;
  const _Chip(this.label, this.value, this.active, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(active ? null : value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? color : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? color : color.withOpacity(0.3)),
        ),
        child: Text(label,
            style: TextStyle(
                color: active ? AppColors.bg : color,
                fontWeight: FontWeight.w700, fontSize: 12)),
      ),
    );
  }
}

// ── Task List ─────────────────────────────────────────────────
class _TaskList extends StatelessWidget {
  final List<Task> tasks;
  final AppProvider provider;
  final bool isEmpty, isCompleted;
  final String emptyMsg;

  const _TaskList({required this.tasks, required this.provider,
      required this.isEmpty, required this.emptyMsg, this.isCompleted = false});

  @override
  Widget build(BuildContext context) {
    if (isEmpty) {
      return EmptyView(
        emoji: isCompleted ? '📝' : '🎉',
        title: isCompleted ? 'Nothing completed yet' : 'All clear!',
        body: emptyMsg,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _TaskCard(
        task: tasks[i],
        provider: provider,
        onEdit: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: AppColors.surface,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            builder: (_) => _TaskSheet(p: provider, existing: tasks[i]),
          );
        },
      ),
    );
  }
}

// ── Task Card ─────────────────────────────────────────────────
class _TaskCard extends StatelessWidget {
  final Task task;
  final AppProvider provider;
  final VoidCallback onEdit;
  const _TaskCard({required this.task, required this.provider, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final overdue = !task.done && task.deadline.isBefore(DateTime.now());
    final days = task.deadline.difference(DateTime.now()).inDays;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: overdue ? AppColors.red.withOpacity(0.35)
                           : task.priorityColor.withOpacity(0.18)),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Checkbox
            GestureDetector(
              onTap: () => provider.toggleTask(task.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(top: 2),
                width: 24, height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.done ? AppColors.green : Colors.transparent,
                  border: Border.all(
                      color: task.done ? AppColors.green : task.priorityColor,
                      width: 2),
                ),
                child: task.done
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(task.title,
                  style: TextStyle(
                      color: task.done ? AppColors.textSecondary : AppColors.textPrimary,
                      fontWeight: FontWeight.w700, fontSize: 14,
                      decoration: task.done ? TextDecoration.lineThrough : null)),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(task.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
              const SizedBox(height: 6),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: AppColors.cardLight,
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(task.subject,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ),
                const SizedBox(width: 8),
                Icon(Icons.calendar_today_rounded, size: 11,
                    color: overdue ? AppColors.red : AppColors.textSecondary),
                const SizedBox(width: 3),
                Text(
                  task.done
                      ? DateFormat('MMM d').format(task.deadline)
                      : overdue ? 'Overdue'
                      : days == 0 ? 'Due today'
                      : DateFormat('MMM d').format(task.deadline),
                  style: TextStyle(
                      color: overdue && !task.done ? AppColors.red : AppColors.textSecondary,
                      fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ]),
            ])),
            // Actions
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              PriBadge(label: task.priorityLabel, color: task.priorityColor),
              const SizedBox(height: 8),
              Row(children: [
                GestureDetector(onTap: onEdit,
                    child: const Icon(Icons.edit_outlined,
                        color: AppColors.textSecondary, size: 17)),
                const SizedBox(width: 12),
                GestureDetector(onTap: () => provider.deleteTask(task.id),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.red, size: 17)),
              ]),
            ]),
          ]),
        ),
        // Priority stripe
        Container(
          height: 3,
          decoration: BoxDecoration(
            color: task.priorityColor.withOpacity(0.45),
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18)),
          ),
        ),
      ]),
    );
  }
}

// ── Add/Edit Sheet ────────────────────────────────────────────
class _TaskSheet extends StatefulWidget {
  final AppProvider p;
  final Task? existing;
  const _TaskSheet({required this.p, this.existing});

  @override
  State<_TaskSheet> createState() => _TaskSheetState();
}

class _TaskSheetState extends State<_TaskSheet> {
  late TextEditingController _title, _desc;
  late Priority _priority;
  late DateTime _deadline;
  late String _subject;

  static const _subjects = ['General','Math','Science','History',
      'Language','Programming','Art','Other'];

  @override
  void initState() {
    super.initState();
    final t = widget.existing;
    _title    = TextEditingController(text: t?.title ?? '');
    _desc     = TextEditingController(text: t?.description ?? '');
    _priority = t?.priority ?? Priority.medium;
    _deadline = t?.deadline ?? DateTime.now().add(const Duration(days: 1));
    _subject  = t?.subject ?? 'General';
  }

  @override
  void dispose() {
    _title.dispose(); _desc.dispose(); super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 18),
            Text(widget.existing == null ? 'Add Task' : 'Edit Task',
                style: const TextStyle(color: AppColors.textPrimary,
                    fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),

            TextField(controller: _title,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Task Title *',
                    prefixIcon: Icon(Icons.task_alt_rounded, color: AppColors.accent))),
            const SizedBox(height: 10),
            TextField(controller: _desc, maxLines: 2,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(labelText: 'Description (optional)',
                    prefixIcon: Icon(Icons.notes_rounded, color: AppColors.textSecondary))),
            const SizedBox(height: 14),

            // Subject
            const Text('Subject', style: TextStyle(
                color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: _subjects.map((s) {
              final sel = _subject == s;
              return GestureDetector(
                onTap: () => setState(() => _subject = s),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.accent : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(s, style: TextStyle(
                      color: sel ? AppColors.bg : AppColors.textSecondary,
                      fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              );
            }).toList()),
            const SizedBox(height: 14),

            // Priority
            const Text('Priority', style: TextStyle(
                color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(children: Priority.values.map((pr) {
              final dummy = Task(id: '', title: '', deadline: DateTime.now(), priority: pr);
              final sel = _priority == pr;
              return Expanded(child: GestureDetector(
                onTap: () => setState(() => _priority = pr),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? dummy.priorityColor : dummy.priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: dummy.priorityColor.withOpacity(0.4)),
                  ),
                  child: Center(child: Text(dummy.priorityLabel, style: TextStyle(
                      color: sel ? Colors.white : dummy.priorityColor,
                      fontWeight: FontWeight.w700, fontSize: 12))),
                ),
              ));
            }).toList()),
            const SizedBox(height: 14),

            // Deadline
            GestureDetector(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _deadline,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                        colorScheme: const ColorScheme.dark(primary: AppColors.accent)),
                    child: child!,
                  ),
                );
                if (d != null) setState(() => _deadline = d);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: AppColors.cardLight,
                    borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  const Icon(Icons.calendar_month_rounded,
                      color: AppColors.accent, size: 20),
                  const SizedBox(width: 10),
                  Text('Deadline: ${DateFormat('EEE, MMM d, yyyy').format(_deadline)}',
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                ]),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(widget.existing == null ? 'Add Task' : 'Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_title.text.trim().isEmpty) {
      showSnack(context, 'Please enter a task title', error: true);
      return;
    }
    if (widget.existing != null) {
      widget.existing!
        ..title       = _title.text.trim()
        ..description = _desc.text.trim()
        ..priority    = _priority
        ..deadline    = _deadline
        ..subject     = _subject;
      widget.p.updateTask(widget.existing!);
    } else {
      widget.p.addTask(Task(
        id: widget.p.newId(),
        title: _title.text.trim(),
        description: _desc.text.trim(),
        priority: _priority,
        deadline: _deadline,
        subject: _subject,
      ));
    }
    Navigator.pop(context);
    showSnack(context,
        widget.existing == null ? 'Task added! ✅' : 'Task updated!',
        success: true);
  }
}
