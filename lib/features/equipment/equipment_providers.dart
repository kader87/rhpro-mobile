import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'equipment_api.dart';
import 'equipment_models.dart';

final equipmentApiProvider = Provider((ref) => EquipmentApi(ref.watch(dioProvider)));

final equipmentItemsProvider = FutureProvider.autoDispose<List<EquipmentItem>>(
  (ref) => ref.watch(equipmentApiProvider).items(),
);

final equipmentPurchasesProvider = FutureProvider.autoDispose<List<EquipmentPurchase>>(
  (ref) => ref.watch(equipmentApiProvider).purchases(),
);

final myEquipmentProvider = FutureProvider.autoDispose<List<EquipmentAssignment>>(
  (ref) => ref.watch(equipmentApiProvider).myAssignments(),
);

final allEquipmentAssignmentsProvider = FutureProvider.autoDispose<List<EquipmentAssignment>>(
  (ref) => ref.watch(equipmentApiProvider).allAssignments(),
);
