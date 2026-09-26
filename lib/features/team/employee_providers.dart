import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'employee_api.dart';
import 'employee_models.dart';

final employeeApiProvider = Provider((ref) => EmployeeApi(ref.watch(dioProvider)));

final myTeamProvider = FutureProvider.autoDispose<List<EmployeeSummary>>(
  (ref) => ref.watch(employeeApiProvider).myTeam(),
);

final employeeDetailProvider = FutureProvider.autoDispose.family<EmployeeSummary, String>(
  (ref, id) => ref.watch(employeeApiProvider).byId(id),
);

final allActiveEmployeesProvider = FutureProvider.autoDispose<List<EmployeeSummary>>(
  (ref) => ref.watch(employeeApiProvider).allActive(),
);

final departmentColleaguesProvider = FutureProvider.autoDispose<List<EmployeeSummary>>(
  (ref) => ref.watch(employeeApiProvider).departmentColleagues(),
);

final allUsersProvider = FutureProvider.autoDispose<List<EmployeeSummary>>(
  (ref) => ref.watch(employeeApiProvider).allUsers(),
);
