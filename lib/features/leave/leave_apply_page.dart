import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/api/api_client.dart';
import 'leave_models.dart';
import 'leave_repository.dart';

class LeaveApplyPage extends ConsumerStatefulWidget {
  const LeaveApplyPage({super.key});

  @override
  ConsumerState<LeaveApplyPage> createState() => _LeaveApplyPageState();
}

class _LeaveApplyPageState extends ConsumerState<LeaveApplyPage> {
  LeaveBalance? _selected;
  DateTime? _start;
  DateTime? _end;
  final _reason = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? (_start ?? DateTime.now().add(const Duration(days: 1))) : (_end ?? _start ?? DateTime.now().add(const Duration(days: 1)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
        if (_end != null && _end!.isBefore(picked)) _end = picked;
      } else {
        _end = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (_selected == null || _start == null || _end == null) {
      setState(() => _error = 'Please choose a leave type and dates.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(leaveRepositoryProvider).apply(
            leaveTypeId: _selected!.leaveTypeId,
            startDate: DateFormat('yyyy-MM-dd').format(_start!),
            endDate: DateFormat('yyyy-MM-dd').format(_end!),
            reason: _reason.text.trim().isEmpty ? null : _reason.text.trim(),
          );
      ref.invalidate(myLeaveProvider);
      ref.invalidate(leaveBalancesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leave application submitted.')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _error = ApiClient.describeError(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final balances = ref.watch(leaveBalancesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Apply for Leave')),
      body: balances.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (list) => SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Leave type', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<LeaveBalance>(
                value: _selected,
                hint: const Text('Select leave type'),
                isExpanded: true,
                items: list
                    .map((b) => DropdownMenuItem(
                          value: b,
                          child: Text('${b.leaveTypeName}  (${b.daysRemaining} left)'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selected = v),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _DatePickerField(
                      label: 'Start date',
                      value: _start,
                      onTap: () => _pickDate(isStart: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DatePickerField(
                      label: 'End date',
                      value: _end,
                      onTap: () => _pickDate(isStart: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Reason (optional)', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(controller: _reason, maxLines: 3, decoration: const InputDecoration(hintText: 'e.g. Family event')),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Submit application'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({required this.label, required this.value, required this.onTap});
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, suffixIcon: const Icon(Icons.calendar_today, size: 18)),
        child: Text(value == null ? 'Choose…' : DateFormat('d MMM yyyy').format(value!)),
      ),
    );
  }
}
