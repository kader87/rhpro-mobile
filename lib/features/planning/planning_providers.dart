import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'planning_api.dart';
import 'planning_models.dart';

final planningApiProvider = Provider((ref) => PlanningApi(ref.watch(dioProvider)));

final myPlanningProvider = FutureProvider.autoDispose<List<ScheduledShift>>((ref) async {
  final user = ref.watch(authControllerProvider).value;
  if (user == null) return [];
  return ref.watch(planningApiProvider).forEmployee(user.id);
});
