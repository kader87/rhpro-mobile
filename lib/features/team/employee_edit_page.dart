import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/util/date_format.dart';
import 'employee_models.dart';
import 'employee_providers.dart';

const _roles = ['EMPLOYEE', 'MANAGER', 'ADMIN'];

class EmployeeEditPage extends ConsumerStatefulWidget {
  const EmployeeEditPage({super.key, this.employee});

  final EmployeeSummary? employee;

  @override
  ConsumerState<EmployeeEditPage> createState() => _EmployeeEditPageState();
}

class _EmployeeEditPageState extends ConsumerState<EmployeeEditPage> {
  late final _firstName = TextEditingController(text: widget.employee?.firstName);
  late final _lastName = TextEditingController(text: widget.employee?.lastName);
  late final _email = TextEditingController(text: widget.employee?.email);
  late final _department = TextEditingController(text: widget.employee?.department);
  late final _phone = TextEditingController(text: widget.employee?.phone);
  final _employeeId = TextEditingController();
  late String _role = widget.employee?.role ?? 'EMPLOYEE';
  DateTime _dateOfJoining = DateTime.now();
  bool _submitting = false;
  String? _error;

  bool get _isCreate => widget.employee == null;

  Future<void> _submit() async {
    if ([_firstName, _lastName, _email, _department].any((c) => c.text.trim().isEmpty) ||
        (_isCreate && _employeeId.text.trim().isEmpty)) {
      setState(() => _error = 'Champs obligatoires manquants.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final api = ref.read(employeeApiProvider);
      if (_isCreate) {
        await api.create(
          firstName: _firstName.text.trim(),
          lastName: _lastName.text.trim(),
          email: _email.text.trim(),
          role: _role,
          department: _department.text.trim(),
          employeeId: _employeeId.text.trim(),
          dateOfJoining: formatDateIso(_dateOfJoining),
          phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        );
      } else {
        await api.update(
          widget.employee!.id,
          firstName: _firstName.text.trim(),
          lastName: _lastName.text.trim(),
          email: _email.text.trim(),
          role: _role,
          department: _department.text.trim(),
          phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isCreate ? 'Nouvel employé' : 'Modifier l\'employé')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _firstName, decoration: const InputDecoration(labelText: 'Prénom *')),
          const SizedBox(height: 12),
          TextField(controller: _lastName, decoration: const InputDecoration(labelText: 'Nom *')),
          const SizedBox(height: 12),
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email *')),
          const SizedBox(height: 12),
          TextField(controller: _department, decoration: const InputDecoration(labelText: 'Département *')),
          const SizedBox(height: 12),
          TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Téléphone')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _role,
            decoration: const InputDecoration(labelText: 'Rôle'),
            items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (v) => setState(() => _role = v!),
          ),
          if (_isCreate) ...[
            const SizedBox(height: 12),
            TextField(controller: _employeeId, decoration: const InputDecoration(labelText: 'Matricule *')),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date d\'entrée'),
              subtitle: Text(formatDateDisplay(_dateOfJoining)),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dateOfJoining,
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _dateOfJoining = picked);
              },
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
