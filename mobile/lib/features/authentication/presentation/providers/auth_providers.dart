import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turota_mobile/core/providers/core_providers.dart';
import 'package:turota_mobile/features/authentication/data/data_sources/auth_data_source.dart';
import 'package:turota_mobile/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:turota_mobile/features/authentication/domain/repositories/auth_repository.dart';

final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthDataSource(apiClient);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authDataSourceProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthRepositoryImpl(dataSource, tokenStorage);
});

final currentUserProvider = FutureProvider((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return repository.getCurrentUser();
});
