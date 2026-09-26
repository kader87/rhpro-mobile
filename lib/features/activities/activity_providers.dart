import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'activity_api.dart';
import 'activity_models.dart';

final billableActivityApiProvider = Provider((ref) => BillableActivityApi(ref.watch(dioProvider)));

final billableActivitiesProvider = FutureProvider.autoDispose<List<BillableActivity>>(
  (ref) => ref.watch(billableActivityApiProvider).all(),
);

final activityAssignmentsProvider = FutureProvider.autoDispose<List<ActivityAssignment>>(
  (ref) => ref.watch(billableActivityApiProvider).assignments(),
);
