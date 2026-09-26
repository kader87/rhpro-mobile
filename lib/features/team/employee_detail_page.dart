import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/util/date_format.dart';
import 'employee_providers.dart';

class EmployeeDetailPage extends ConsumerWidget {
  const EmployeeDetailPage({super.key, required this.employeeId});

  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employee = ref.watch(employeeDetailProvider(employeeId));

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: employee.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (e) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                child: Text(e.firstName.isNotEmpty ? e.firstName[0] : '?', style: const TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(height: 16),
            Center(child: Text(e.fullName, style: Theme.of(context).textTheme.headlineSmall)),
            Center(child: Text(e.role, style: Theme.of(context).textTheme.bodyMedium)),
            const SizedBox(height: 24),
            _InfoTile(icon: Icons.email_outlined, label: 'Email', value: e.email),
            if (e.phone != null) _InfoTile(icon: Icons.phone_outlined, label: 'Téléphone', value: e.phone!),
            if (e.department != null) _InfoTile(icon: Icons.apartment_outlined, label: 'Département', value: e.department!),
            if (e.employeeId != null) _InfoTile(icon: Icons.badge_outlined, label: 'Matricule', value: e.employeeId!),
            if (e.managerName != null) _InfoTile(icon: Icons.supervisor_account_outlined, label: 'Manager', value: e.managerName!),
            if (e.employmentContractType != null)
              _InfoTile(icon: Icons.description_outlined, label: 'Contrat', value: e.employmentContractType!),
            if (e.dateOfJoining != null)
              _InfoTile(icon: Icons.event_outlined, label: 'Date d\'entrée', value: formatDateDisplay(e.dateOfJoining!)),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
