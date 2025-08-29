// lib/injection_container.dart

import 'package:coffee_tracker/core/auth/biometric_service.dart';
import 'package:coffee_tracker/core/config/app_config.dart';
import 'package:coffee_tracker/features/auth/domain/usecases/biometric_login.dart';
import 'package:coffee_tracker/features/auth/domain/usecases/enable_biometric_login.dart';
import 'package:coffee_tracker/features/auth/domain/usecases/logout.dart';
import 'package:coffee_tracker/features/statistics/data/datasources/statistics_remote_data_source.dart';
import 'package:coffee_tracker/features/statistics/data/repositories/statistics_repository_impl.dart';
import 'package:coffee_tracker/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:coffee_tracker/features/statistics/domain/usecases/get_statistics.dart';
import 'package:coffee_tracker/features/statistics/presentation/bloc/statistics_bloc.dart';
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

  // Register AuthService
  sl.registerLazySingleton<AuthService>(
    () => AuthService(
      client: sl<http.Client>(),
      storage: sl<FlutterSecureStorage>(),
      baseUrl: AppConfig.baseUrl,
    ),
  );

  // HTTP Client with interceptor
  sl.registerLazySingleton(
    () => InterceptedClient.build(interceptors: [AuthInterceptor(sl())]),
  );

  //! Features - Coffee Tracker
  sl.registerLazySingleton<CoffeeTrackerRemoteDataSource>(
    () => CoffeeTrackerRemoteDataSourceImpl(
      client: sl(),
      baseUrl: AppConfig.baseUrl,
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
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
      authService: sl(),
      biometricService: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => AddCoffeeEntryUseCase(sl()));
  sl.registerLazySingleton(() => EditCoffeeEntryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCoffeeEntryUseCase(sl()));
  sl.registerLazySingleton(() => GetDailyCoffeeTrackerLog(sl()));

  sl.registerLazySingleton(() => RequestOtp(sl()));
  sl.registerLazySingleton(() => VerifyOtp(sl()));
  sl.registerLazySingleton(() => IsAuthenticated(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  sl.registerLazySingleton(() => BiometricLogin(sl()));
  sl.registerLazySingleton(() => EnableBiometricLogin(sl()));

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
    () => AuthBloc(
      requestOtp: sl(),
      verifyOtp: sl(),
      isAuthenticated: sl(),
      logout: sl(),
      biometricLogin: sl(),
      enableBiometricLogin: sl(),
      authService: sl(),
    ),
  );

  //! Features - Statistics
  sl.registerLazySingleton<StatisticsRemoteDataSource>(
    () => StatisticsRemoteDataSourceImpl(
      client: sl(),
      baseUrl: AppConfig.baseUrl,
      authService: sl(),
    ),
  );

  sl.registerLazySingleton<StatisticsRepository>(
    () => StatisticsRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetStatistics(sl()));

  sl.registerFactory(() => StatisticsBloc(getStatistics: sl()));

  //! Register BiometricService
  sl.registerLazySingleton(() => BiometricService());
}
