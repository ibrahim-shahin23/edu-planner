// lib/screens/tasks_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TaskPriority? _filterPriority;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ──────────────────────────────────────
            FadeInDown(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('My Tasks',
                            style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 26,
                                fontWeight: FontWeight.w800)),
                        Text(
                          '${provider.pendingTasks.length} pending · ${provider.completedTasks.length} done',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _showAddTaskSheet(context, provider),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppTheme.accentGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accent.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add_rounded,
                            color: AppTheme.primary, size: 26),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Priority Filter ──────────────────────────────
            FadeInDown(
              delay: const Duration(milliseconds: 100),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _PriorityFilter(
                  selected: _filterPriority,
                  onSelect: (p) =>
                      setState(() => _filterPriority = p),
                ),
              ),
            ),

            // ─── Tabs ─────────────────────────────────────────
            FadeInDown(
              delay: const Duration(milliseconds: 150),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: AppTheme.primary,
                    unselectedLabelColor: AppTheme.textSecondary,
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Pending'),
                      Tab(text: 'Completed'),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Task List ────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _TaskList(
                    tasks: _filterTasks(provider.pendingTasks),
                    provider: provider,
                    emptyMessage: 'No pending tasks! 🎉',
                  ),
                  _TaskList(
                    tasks: _filterTasks(provider.completedTasks),
                    provider: provider,
                    emptyMessage: 'Complete tasks to see them here',
                    isCompleted: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Task> _filterTasks(List<Task> tasks) {
    if (_filterPriority == null) return tasks;
    return tasks.where((t) => t.priority == _filterPriority).toList();
  }

  void _showAddTaskSheet(BuildContext context, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) => _AddTaskSheet(provider: provider),
    );
  }
}

// ─── Priority Filter ──────────────────────────────────────────
class _PriorityFilter extends StatelessWidget {
  final TaskPriority? selected;
  final ValueChanged<TaskPriority?> onSelect;

  const _PriorityFilter({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isSelected: selected == null,
            color: AppTheme.textSecondary,
            onTap: () => onSelect(null),
          ),
          const SizedBox(width: 8),
          ...TaskPriority.values.map((p) {
            final task = Task(
                id: '', title: '', deadline: DateTime.now(), priority: p);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: task.priorityLabel,
                isSelected: selected == p,
                color: task.priorityColor,
                onTap: () => onSelect(selected == p ? null : p),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primary : color,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ─── Task List ────────────────────────────────────────────────
class _TaskList extends StatelessWidget {
  final List<Task> tasks;
  final AppProvider provider;
  final String emptyMessage;
  final bool isCompleted;

  const _TaskList({
    required this.tasks,
    required this.provider,
    required this.emptyMessage,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return EmptyState(
        emoji: isCompleted ? '📝' : '🎉',
        title: isCompleted ? 'No completed tasks' : 'All clear!',
        subtitle: emptyMessage,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      itemCount: tasks.length,
      itemBuilder: (context, i) {
        final task = tasks[i];
        return FadeInUp(
          delay: Duration(milliseconds: i * 60),
          child: _TaskCard(
            task: task,
            provider: provider,
            onEdit: () => _showEditSheet(context, task, provider),
          ),
        );
      },
    );
  }

  void _showEditSheet(
      BuildContext context, Task task, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) => _AddTaskSheet(provider: provider, existingTask: task),
    );
  }
}

// ─── Task Card ────────────────────────────────────────────────
class _TaskCard extends StatelessWidget {
  final Task task;
  final AppProvider provider;
  final VoidCallback onEdit;

  const _TaskCard({
    required this.task,
    required this.provider,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue =
        !task.isCompleted && task.deadline.isBefore(DateTime.now());
    final daysLeft = task.deadline.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOverdue
              ? AppTheme.error.withOpacity(0.3)
              : task.priorityColor.withOpacity(0.15),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox
                GestureDetector(
                  onTap: () => provider.toggleTaskComplete(task.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 26,
                    height: 26,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted
                          ? AppTheme.success
                          : Colors.transparent,
                      border: Border.all(
                        color: task.isCompleted
                            ? AppTheme.success
                            : task.priorityColor,
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 16)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          color: task.isCompleted
                              ? AppTheme.textSecondary
                              : AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(task.description,
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(task.subject,
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11)),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.calendar_today_rounded,
                              size: 12,
                              color: isOverdue
                                  ? AppTheme.error
                                  : AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            task.isCompleted
                                ? DateFormat('MMM d').format(task.deadline)
                                : isOverdue
                                    ? 'Overdue'
                                    : daysLeft == 0
                                        ? 'Due today'
                                        : DateFormat('MMM d').format(task.deadline),
                            style: TextStyle(
                              color: isOverdue && !task.isCompleted
                                  ? AppTheme.error
                                  : AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    PriorityBadge(
                        label: task.priorityLabel,
                        color: task.priorityColor),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: onEdit,
                          child: const Icon(Icons.edit_outlined,
                              color: AppTheme.textSecondary, size: 18),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => provider.deleteTask(task.id),
                          child: const Icon(Icons.delete_outline_rounded,
                              color: AppTheme.error, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Priority accent bar at bottom
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: task.priorityColor.withOpacity(0.4),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Add/Edit Task Sheet ──────────────────────────────────────
class _AddTaskSheet extends StatefulWidget {
  final AppProvider provider;
  final Task? existingTask;

  const _AddTaskSheet({required this.provider, this.existingTask});

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TaskPriority _priority;
  late DateTime _deadline;
  late String _subject;

  static const subjects = [
    'General', 'Math', 'Science', 'History',
    'Language', 'Programming', 'Art', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    final t = widget.existingTask;
    _titleController = TextEditingController(text: t?.title ?? '');
    _descController = TextEditingController(text: t?.description ?? '');
    _priority = t?.priority ?? TaskPriority.medium;
    _deadline = t?.deadline ?? DateTime.now().add(const Duration(days: 1));
    _subject = t?.subject ?? 'General';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.existingTask == null ? 'Add New Task' : 'Edit Task',
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),

          // Title
          TextField(
            controller: _titleController,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Task Title',
              prefixIcon: Icon(Icons.task_alt_rounded, color: AppTheme.accent),
            ),
          ),
          const SizedBox(height: 12),

          // Description
          TextField(
            controller: _descController,
            style: const TextStyle(color: AppTheme.textPrimary),
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              prefixIcon: Icon(Icons.notes_rounded, color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(height: 16),

          // Subject
          const Text('Subject',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: subjects.map((s) {
              final isSelected = _subject == s;
              return GestureDetector(
                onTap: () => setState(() => _subject = s),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.accent
                        : AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(s,
                      style: TextStyle(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Priority
          const Text('Priority',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: TaskPriority.values.map((p) {
              final task = Task(
                  id: '', title: '', deadline: DateTime.now(), priority: p);
              final isSelected = _priority == p;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _priority = p),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? task.priorityColor
                          : task.priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: task.priorityColor.withOpacity(0.4)),
                    ),
                    child: Center(
                      child: Text(task.priorityLabel,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : task.priorityColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          )),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Deadline
          GestureDetector(
            onTap: () => _pickDate(context),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded,
                      color: AppTheme.accent, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Deadline: ${DateFormat('EEE, MMM d, yyyy').format(_deadline)}',
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: Text(widget.existingTask == null
                  ? 'Add Task'
                  : 'Save Changes'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(primary: AppTheme.accent),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) return;

    if (widget.existingTask != null) {
      final task = widget.existingTask!;
      task.title = _titleController.text.trim();
      task.description = _descController.text.trim();
      task.priority = _priority;
      task.deadline = _deadline;
      task.subject = _subject;
      widget.provider.updateTask(task);
    } else {
      final task = Task(
        id: widget.provider.generateId(),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        priority: _priority,
        deadline: _deadline,
        subject: _subject,
      );
      widget.provider.addTask(task);
    }
    Navigator.pop(context);
  }
}