import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
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

// One signature color per section keeps the long menu readable at a glance.
const _personalColor = Color(0xFF4F46E5); // indigo
const _managerColor = Color(0xFF7C3AED); // violet
const _crmColor = Color(0xFFD97706); // amber
const _equipmentColor = Color(0xFF0D9488); // teal
const _adminColor = Color(0xFFDC2626); // red
const _superAdminColor = Color(0xFF334155); // slate

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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _GreetingHeader(name: user?.fullName ?? '', role: user?.role ?? ''),
          const SizedBox(height: 20),
          _MenuTile(
            icon: Icons.event_available,
            color: _personalColor,
            label: 'Mes absences',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AbsencesPage())),
          ),
          _MenuTile(
            icon: Icons.calendar_month,
            color: _personalColor,
            label: 'Mon planning',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlanningPage())),
          ),
          _MenuTile(
            icon: Icons.access_time,
            color: _personalColor,
            label: 'Mes feuilles de temps',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TimesheetsPage())),
          ),
          _MenuTile(
            icon: Icons.folder_open,
            color: _personalColor,
            label: 'Mes documents',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DocumentsPage())),
          ),
          _MenuTile(
            icon: Icons.devices_other_outlined,
            color: _personalColor,
            label: 'Mon matériel',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyEquipmentPage())),
          ),
          _MenuTile(
            icon: Icons.event_note_outlined,
            color: _personalColor,
            label: 'Mes entretiens',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InterviewsPage())),
          ),
          _MenuTile(
            icon: Icons.school_outlined,
            color: _personalColor,
            label: 'Formations',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TrainingsPage())),
          ),
          _MenuTile(
            icon: Icons.star_outline,
            color: _personalColor,
            label: 'Compétences',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SkillsPage())),
          ),
          _MenuTile(
            icon: Icons.account_tree_outlined,
            color: _personalColor,
            label: 'Organigramme',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OrgChartPage())),
          ),
          _MenuTile(
            icon: Icons.support_agent_outlined,
            color: _personalColor,
            label: 'Support',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SupportPage())),
          ),
          if (user != null && _managerRoles.contains(user.role)) ...[
            const _SectionHeader(label: 'Espace manager', color: _managerColor, icon: Icons.supervisor_account),
            _MenuTile(
              icon: Icons.fact_check_outlined,
              color: _managerColor,
              label: 'Approbations',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ApprovalsPage())),
            ),
            _MenuTile(
              icon: Icons.groups_outlined,
              color: _managerColor,
              label: 'Mon équipe',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TeamPage())),
            ),
            _MenuTile(
              icon: Icons.bar_chart_outlined,
              color: _managerColor,
              label: 'Rapports',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReportsPage())),
            ),
            _MenuTile(
              icon: Icons.person_search_outlined,
              color: _managerColor,
              label: 'Recrutement',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CandidatesPage())),
            ),
            _MenuTile(
              icon: Icons.receipt_long_outlined,
              color: _managerColor,
              label: 'Facturation',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BillingPage())),
            ),
            const _SectionHeader(label: 'CRM', color: _crmColor, icon: Icons.handshake),
            _MenuTile(
              icon: Icons.business_outlined,
              color: _crmColor,
              label: 'Clients',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ClientsPage())),
            ),
            _MenuTile(
              icon: Icons.work_outline,
              color: _crmColor,
              label: 'Activités',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ActivitiesPage())),
            ),
            _MenuTile(
              icon: Icons.assignment_ind_outlined,
              color: _crmColor,
              label: 'Affectations aux activités',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ActivityAssignmentsPage())),
            ),
            _MenuTile(
              icon: Icons.handshake_outlined,
              color: _crmColor,
              label: 'Prospects',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProspectsPage())),
            ),
            const _SectionHeader(label: 'Équipements', color: _equipmentColor, icon: Icons.inventory_2),
            _MenuTile(
              icon: Icons.inventory_2_outlined,
              color: _equipmentColor,
              label: 'Gestion des équipements',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EquipmentAdminPage())),
            ),
          ],
          if (user != null && _adminRoles.contains(user.role)) ...[
            const _SectionHeader(label: 'Administration', color: _adminColor, icon: Icons.admin_panel_settings),
            _MenuTile(
              icon: Icons.badge_outlined,
              color: _adminColor,
              label: 'Employés',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EmployeesAdminPage())),
            ),
            _MenuTile(
              icon: Icons.admin_panel_settings_outlined,
              color: _adminColor,
              label: 'Administration RH',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HrAdminPage())),
            ),
            _MenuTile(
              icon: Icons.workspace_premium_outlined,
              color: _adminColor,
              label: 'Abonnement',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionPage())),
            ),
          ],
          if (user != null && user.role == 'SUPER_ADMIN') ...[
            const _SectionHeader(label: 'Super admin', color: _superAdminColor, icon: Icons.shield_outlined),
            _MenuTile(
              icon: Icons.corporate_fare_outlined,
              color: _superAdminColor,
              label: 'Comptes clients',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CustomerAccountsPage())),
            ),
            _MenuTile(
              icon: Icons.local_offer_outlined,
              color: _superAdminColor,
              label: 'Codes promo',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PromoCodesPage())),
            ),
            _MenuTile(
              icon: Icons.mark_email_unread_outlined,
              color: _superAdminColor,
              label: 'Messagerie support',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SupportInboxPage())),
            ),
          ],
        ],
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.name, required this.role});

  final String name;
  final String role;

  static const _roleLabels = {
    'EMPLOYEE': 'Employé·e',
    'MANAGER': 'Manager',
    'ADMIN': 'Administrateur',
    'SUPER_ADMIN': 'Super admin',
  };

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isEmpty
        ? '?'
        : name.trim().split(RegExp(r'\s+')).map((p) => p[0]).take(2).join().toUpperCase();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_personalColor, Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour $name',
                  style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(_roleLabels[role] ?? role, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.color, required this.icon});

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.6),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.label, required this.color, required this.onTap});

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: SectionIcon(icon: icon, color: color),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
