import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'candidate_api.dart';
import 'candidate_models.dart';

final candidateApiProvider = Provider((ref) => CandidateApi(ref.watch(dioProvider)));

final candidatesProvider = FutureProvider.autoDispose<List<Candidate>>((ref) => ref.watch(candidateApiProvider).all());
