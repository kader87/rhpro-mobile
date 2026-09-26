import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../absences/absences_page.dart';
import '../activities/activities_page.dart';
import '../activities/activity_assignments_page.dart';
import '../approvals/approvals_page.dart';
import '../auth/auth_providers.dart';
import '../clients/clients_page.dart';
import '../crm/prospects_page.dart';
import '../documents/documents_page.dart';
import '../equipment/equipment_admin_page.dart';
import '../equipment/my_equipment_page.dart';
import '../finance/billing_page.dart';
import '../hr_admin/hr_admin_page.dart';
import '../notifications/notification_providers.dart';
import '../notifications/notifications_page.dart';
import '../org/org_chart_page.dart';
import '../planning/planning_page.dart';
import '../recruitment/candidates_page.dart';
import '../reports/reports_page.dart';
import '../superadmin/customer_accounts_page.dart';
import '../superadmin/promo_codes_page.dart';
import '../superadmin/subscription_page.dart';
import '../support/support_inbox_page.dart';
import '../support/support_page.dart';
import '../talent/interviews_page.dart';
import '../talent/skills_page.dart';
import '../talent/trainings_page.dart';
import '../team/employees_admin_page.dart';
import '../team/team_page.dart';
import '../timesheets/timesheets_page.dart';

const _managerRoles = {'MANAGER', 'ADMIN', 'SUPER_ADMIN'};
const _adminRoles = {'ADMIN', 'SUPER_ADMIN'};

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('RH Pro'),
        actions: [
          IconButton(
            icon: Badge(
              label: unreadCount.maybeWhen(data: (c) => c > 0 ? Text('$c') : null, orElse: () => null),
              isLabelVisible: unreadCount.maybeWhen(data: (c) => c > 0, orElse: () => false),
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsPage())),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Bonjour ${user?.fullName ?? ''}', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          _MenuTile(
            icon: Icons.event_available,
            label: 'Mes absences',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AbsencesPage())),
          ),
          _MenuTile(
            icon: Icons.calendar_month,
            label: 'Mon planning',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlanningPage())),
          ),
          _MenuTile(
            icon: Icons.access_time,
            label: 'Mes feuilles de temps',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TimesheetsPage())),
          ),
          _MenuTile(
            icon: Icons.folder_open,
            label: 'Mes documents',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DocumentsPage())),
          ),
          _MenuTile(
            icon: Icons.devices_other_outlined,
            label: 'Mon matériel',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyEquipmentPage())),
          ),
          _MenuTile(
            icon: Icons.event_note_outlined,
            label: 'Mes entretiens',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InterviewsPage())),
          ),
          _MenuTile(
            icon: Icons.school_outlined,
            label: 'Formations',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TrainingsPage())),
          ),
          _MenuTile(
            icon: Icons.star_outline,
            label: 'Compétences',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SkillsPage())),
          ),
          _MenuTile(
            icon: Icons.account_tree_outlined,
            label: 'Organigramme',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OrgChartPage())),
          ),
          _MenuTile(
            icon: Icons.support_agent_outlined,
            label: 'Support',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SupportPage())),
          ),
          if (user != null && _managerRoles.contains(user.role)) ...[
            const SizedBox(height: 24),
            Text('Espace manager', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _MenuTile(
              icon: Icons.fact_check_outlined,
              label: 'Approbations',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ApprovalsPage())),
            ),
            _MenuTile(
              icon: Icons.groups_outlined,
              label: 'Mon équipe',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TeamPage())),
            ),
            _MenuTile(
              icon: Icons.bar_chart_outlined,
              label: 'Rapports',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReportsPage())),
            ),
            _MenuTile(
              icon: Icons.person_search_outlined,
              label: 'Recrutement',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CandidatesPage())),
            ),
            _MenuTile(
              icon: Icons.receipt_long_outlined,
              label: 'Facturation',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BillingPage())),
            ),
            const SizedBox(height: 24),
            Text('CRM', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _MenuTile(
              icon: Icons.business_outlined,
              label: 'Clients',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ClientsPage())),
            ),
            _MenuTile(
              icon: Icons.work_outline,
              label: 'Activités',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ActivitiesPage())),
            ),
            _MenuTile(
              icon: Icons.assignment_ind_outlined,
              label: 'Affectations aux activités',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ActivityAssignmentsPage())),
            ),
            _MenuTile(
              icon: Icons.handshake_outlined,
              label: 'Prospects',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProspectsPage())),
            ),
            const SizedBox(height: 24),
            Text('Équipements', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _MenuTile(
              icon: Icons.inventory_2_outlined,
              label: 'Gestion des équipements',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EquipmentAdminPage())),
            ),
          ],
          if (user != null && _adminRoles.contains(user.role)) ...[
            const SizedBox(height: 24),
            Text('Administration', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _MenuTile(
              icon: Icons.badge_outlined,
              label: 'Employés',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EmployeesAdminPage())),
            ),
            _MenuTile(
              icon: Icons.admin_panel_settings_outlined,
              label: 'Administration RH',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HrAdminPage())),
            ),
            _MenuTile(
              icon: Icons.workspace_premium_outlined,
              label: 'Abonnement',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionPage())),
            ),
          ],
          if (user != null && user.role == 'SUPER_ADMIN') ...[
            const SizedBox(height: 24),
            Text('Super admin', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _MenuTile(
              icon: Icons.corporate_fare_outlined,
              label: 'Comptes clients',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CustomerAccountsPage())),
            ),
            _MenuTile(
              icon: Icons.local_offer_outlined,
              label: 'Codes promo',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PromoCodesPage())),
            ),
            _MenuTile(
              icon: Icons.mark_email_unread_outlined,
              label: 'Messagerie support',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SupportInboxPage())),
            ),
          ],
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
