// lib/injection_container.dart

import 'package:coffee_tracker/core/auth/auth_interceptor.dart';
import 'package:coffee_tracker/core/auth/auth_service.dart';
import 'package:coffee_tracker/core/auth/biometric_service.dart';
import 'package:coffee_tracker/core/config/app_config.dart';
import 'package:coffee_tracker/core/network/network_info.dart';
import 'package:coffee_tracker/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:coffee_tracker/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:coffee_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:coffee_tracker/features/auth/domain/usecases/biometric_login.dart';
import 'package:coffee_tracker/features/auth/domain/usecases/enable_biometric_login.dart';
import 'package:coffee_tracker/features/auth/domain/usecases/is_authenticated.dart';
import 'package:coffee_tracker/features/auth/domain/usecases/logout.dart';
import 'package:coffee_tracker/features/auth/domain/usecases/request_otp.dart';
import 'package:coffee_tracker/features/auth/domain/usecases/verify_otp.dart';
import 'package:coffee_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:coffee_tracker/features/coffee_tracker/data/datasources/coffee_tracker_remote_data_source.dart';
import 'package:coffee_tracker/features/coffee_tracker/data/repositories/coffee_repository_impl.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/repositories/coffee_tracker_repository.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/usecases/add_coffee_entry.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/usecases/delete_coffee_entry.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/usecases/edit_coffee_entry.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/usecases/get_daily_coffee_tracker_log.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/bloc/coffee_tracker_bloc.dart';
import 'package:coffee_tracker/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:coffee_tracker/features/statistics/data/datasources/statistics_remote_data_source.dart';
import 'package:coffee_tracker/features/statistics/data/repositories/statistics_repository_impl.dart';
import 'package:coffee_tracker/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:coffee_tracker/features/statistics/domain/usecases/get_statistics.dart';
import 'package:coffee_tracker/features/statistics/presentation/bloc/statistics_bloc.dart';
import 'package:coffee_tracker/features/settings/data/datasources/settings_remote_data_source.dart';
import 'package:coffee_tracker/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:coffee_tracker/features/settings/domain/repositories/settings_repository.dart';
import 'package:coffee_tracker/features/settings/domain/usecases/get_settings.dart';
import 'package:coffee_tracker/features/settings/domain/usecases/update_setting.dart';
import 'package:coffee_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:coffee_tracker/features/tapering_journey/data/datasources/tapering_journey_remote_data_source.dart';
import 'package:coffee_tracker/features/tapering_journey/data/repositories/tapering_journey_repository_impl.dart';
import 'package:coffee_tracker/features/tapering_journey/domain/repositories/tapering_journey_repository.dart';
import 'package:coffee_tracker/features/tapering_journey/domain/usecases/create_tapering_journey.dart';
import 'package:coffee_tracker/features/tapering_journey/domain/usecases/delete_tapering_journey.dart';
import 'package:coffee_tracker/features/tapering_journey/domain/usecases/get_tapering_journeys.dart';
import 'package:coffee_tracker/features/tapering_journey/domain/usecases/update_tapering_journey.dart';
import 'package:coffee_tracker/features/tapering_journey/presentation/bloc/tapering_journey_bloc.dart';
import 'package:coffee_tracker/features/user/data/datasources/user_remote_data_source.dart';
import 'package:coffee_tracker/features/user/data/repositories/user_repository_impl.dart';
import 'package:coffee_tracker/features/user/domain/repositories/user_repository.dart';
import 'package:coffee_tracker/features/user/presentation/bloc/user_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_interceptor/http_interceptor.dart';

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
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: sl()),
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
  sl.registerFactory(() => UserBloc(userRepository: sl()));

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

  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(
      client: sl(),
      baseUrl: AppConfig.baseUrl,
      authService: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetStatistics(sl()));

  sl.registerFactory(() => StatisticsBloc(getStatistics: sl()));

  //! Features - Settings
  sl.registerLazySingleton<SettingsRemoteDataSource>(
    () => SettingsRemoteDataSourceImpl(
      client: sl(),
      baseUrl: AppConfig.baseUrl,
      authService: sl(),
    ),
  );

  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(prefs: sl()),
  );

  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetSettings(sl()));
  sl.registerLazySingleton(() => UpdateSetting(sl()));

  sl.registerFactory(
    () => SettingsBloc(getSettings: sl(), updateSetting: sl()),
  );

  //! Features - Tapering Journey
  sl.registerLazySingleton<TaperingJourneyRemoteDataSource>(
    () => TaperingJourneyRemoteDataSourceImpl(
      client: sl(),
      baseUrl: AppConfig.baseUrl,
      authService: sl(),
    ),
  );

  sl.registerLazySingleton<TaperingJourneyRepository>(
    () => TaperingJourneyRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton(() => CreateTaperingJourneyUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTaperingJourneyUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTaperingJourneyUseCase(sl()));
  sl.registerLazySingleton(() => GetTaperingJourneysUseCase(sl()));

  sl.registerFactory(
    () => TaperingJourneyBloc(
      createUseCase: sl(),
      updateUseCase: sl(),
      deleteUseCase: sl(),
      getJourneysUseCase: sl(),
    ),
  );

  //! Register BiometricService
  sl.registerLazySingleton(() => BiometricService());
}
