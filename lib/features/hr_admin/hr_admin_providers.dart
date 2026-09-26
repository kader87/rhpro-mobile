import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'hr_admin_api.dart';
import 'hr_admin_models.dart';

final hrAdminApiProvider = Provider((ref) => HrAdminApi(ref.watch(dioProvider)));

final holidaysProvider = FutureProvider.autoDispose<List<Holiday>>((ref) => ref.watch(hrAdminApiProvider).holidays());

final leavePolicyProvider = FutureProvider.autoDispose<LeavePolicy>((ref) => ref.watch(hrAdminApiProvider).leavePolicy());

final departmentsProvider = FutureProvider.autoDispose<List<Department>>((ref) => ref.watch(hrAdminApiProvider).departments());
