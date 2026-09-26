import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'talent_api.dart';
import 'talent_models.dart';

final talentApiProvider = Provider((ref) => TalentApi(ref.watch(dioProvider)));

final myInterviewsProvider = FutureProvider.autoDispose<List<Interview>>((ref) => ref.watch(talentApiProvider).myInterviews());

final allInterviewsProvider = FutureProvider.autoDispose<List<Interview>>((ref) => ref.watch(talentApiProvider).allInterviews());

final trainingsProvider = FutureProvider.autoDispose<List<Training>>((ref) => ref.watch(talentApiProvider).trainings());

final myEnrollmentsProvider = FutureProvider.autoDispose<List<TrainingEnrollment>>((ref) => ref.watch(talentApiProvider).myEnrollments());

final skillsProvider = FutureProvider.autoDispose<List<Skill>>((ref) => ref.watch(talentApiProvider).skills());

final mySkillsProvider = FutureProvider.autoDispose<List<EmployeeSkill>>((ref) => ref.watch(talentApiProvider).mySkills());
