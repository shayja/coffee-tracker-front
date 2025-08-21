// lib/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_interceptor/http_interceptor.dart';

import 'core/network/network_info.dart';
import 'core/auth/auth_service.dart';
import 'core/auth/auth_interceptor.dart';
import 'features/coffee_tracker/data/datasources/coffee_tracker_remote_data_source.dart';
import 'features/coffee_tracker/data/repositories/coffee_repository_impl.dart';
import 'features/coffee_tracker/domain/repositories/coffee_tracker_repository.dart';
import 'features/coffee_tracker/domain/usecases/add_coffee_entry.dart';
import 'features/coffee_tracker/domain/usecases/edit_coffee_entry.dart';
import 'features/coffee_tracker/domain/usecases/delete_coffee_entry.dart';
import 'features/coffee_tracker/domain/usecases/get_daily_coffee_tracker_log.dart';
import 'features/coffee_tracker/presentation/bloc/coffee_tracker_bloc.dart';

import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/request_otp.dart';
import 'features/auth/domain/usecases/verify_otp.dart';
import 'features/auth/domain/usecases/is_authenticated.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External dependencies first (lowest level)
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => http.Client());

  //! Core services
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  // 3. Register AuthService with explicit dependencies
  sl.registerLazySingleton<AuthService>(
    () => AuthService(
      client: sl<http.Client>(),
      storage: sl<FlutterSecureStorage>(),
    ),
  );

  // HTTP Client with interceptor
  sl.registerLazySingleton(
    () => InterceptedClient.build(
      interceptors: [AuthInterceptor(sl())],
      retryPolicy: ExpiredTokenRetryPolicy(),
    ),
  );

  //! Features - Coffee Tracker
  // Data sources (must come before repository)
  sl.registerLazySingleton<CoffeeTrackerRemoteDataSource>(
    () => CoffeeTrackerRemoteDataSourceImpl(
      client: sl(),
      baseUrl: 'http://localhost:3000',
      authService: sl(),
    ),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(authService: sl()),
  );

  // Repository
  sl.registerLazySingleton<CoffeeTrackerRepository>(
    () => CoffeeRepositoryImpl(
      remoteDataSource: sl(),
      sharedPreferences: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => AddCoffeeEntryUseCase(sl()));
  sl.registerLazySingleton(() => EditCoffeeEntryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCoffeeEntryUseCase(sl()));
  sl.registerLazySingleton(() => GetDailyCoffeeTrackerLog(sl()));

  sl.registerLazySingleton(() => RequestOtp(sl()));
  sl.registerLazySingleton(() => VerifyOtp(sl()));
  sl.registerLazySingleton(() => IsAuthenticated(sl()));

  // Bloc (factory because we want new instance per screen)
  sl.registerFactory(
    () => CoffeeTrackerBloc(
      addCoffeeEntry: sl(),
      getLogByDate: sl(),
      editCoffeeEntry: sl(),
      deleteCoffeeEntry: sl(),
    ),
  );

  sl.registerFactory(
    () => AuthBloc(requestOtp: sl(), verifyOtp: sl(), isAuthenticated: sl()),
  );
}

class ExpiredTokenRetryPolicy extends RetryPolicy {
  @override
  Future<bool> shouldAttemptRetryOnResponse(http.BaseResponse response) async {
    return response.statusCode == 401;
  }
}
