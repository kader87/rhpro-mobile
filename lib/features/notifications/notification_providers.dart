import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'notification_api.dart';
import 'notification_models.dart';

final notificationApiProvider = Provider((ref) => NotificationApi(ref.watch(dioProvider)));

final notificationsProvider = FutureProvider.autoDispose<List<AppNotification>>(
  (ref) => ref.watch(notificationApiProvider).all(),
);

final unreadNotificationCountProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.watch(notificationApiProvider).unreadCount(),
);
