// lib/injection_container.dart

// External packages
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'package:coffee_tracker/core/auth/auth_interceptor.dart';
import 'package:coffee_tracker/core/auth/auth_service.dart';
import 'package:coffee_tracker/core/auth/biometric_service.dart';
import 'package:coffee_tracker/core/config/app_config.dart';
import 'package:coffee_tracker/core/data/datasources/generic_kv_remote_data_source.dart';
import 'package:coffee_tracker/core/data/repositories/generic_kv_repository_impl.dart';
import 'package:coffee_tracker/core/network/network_info.dart';
import 'package:coffee_tracker/core/utils/api_utils.dart';

// Features
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
import 'package:coffee_tracker/features/coffee_tracker/domain/repositories/generic_kv_repository.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/usecases/add_coffee_entry.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/usecases/delete_coffee_entry.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/usecases/edit_coffee_entry.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/usecases/get_coffee_selections.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/usecases/get_daily_coffee_tracker_log.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/bloc/coffee_tracker_bloc.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/bloc/coffee_types_bloc.dart';
import 'package:coffee_tracker/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:coffee_tracker/features/settings/data/datasources/settings_remote_data_source.dart';
import 'package:coffee_tracker/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:coffee_tracker/features/settings/domain/repositories/settings_repository.dart';
import 'package:coffee_tracker/features/settings/domain/usecases/get_settings.dart';
import 'package:coffee_tracker/features/settings/domain/usecases/update_setting.dart';
import 'package:coffee_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:coffee_tracker/features/statistics/data/datasources/statistics_remote_data_source.dart';
import 'package:coffee_tracker/features/statistics/data/repositories/statistics_repository_impl.dart';
import 'package:coffee_tracker/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:coffee_tracker/features/statistics/domain/usecases/get_statistics.dart';
import 'package:coffee_tracker/features/statistics/presentation/bloc/statistics_bloc.dart';
import 'package:coffee_tracker/features/user/data/datasources/user_remote_data_source.dart';
import 'package:coffee_tracker/features/user/data/repositories/user_repository_impl.dart';
import 'package:coffee_tracker/features/user/domain/repositories/user_repository.dart';
import 'package:coffee_tracker/features/user/presentation/bloc/user_bloc.dart';

final sl = GetIt.instance;

Future<void> initCore() async {
  // External dependencies first (lowest level)
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton<http.Client>(() => http.Client());

  // Core services
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  sl.registerLazySingleton<AuthService>(
    () => AuthService(
      client: sl<http.Client>(),
      storage: sl<FlutterSecureStorage>(),
      baseUrl: AppConfig.baseUrl,
    ),
  );

  sl.registerLazySingleton<ApiUtils>(() => ApiUtils(sl<AuthService>()));

  sl.registerLazySingleton<InterceptedClient>(
    () => InterceptedClient.build(
      interceptors: [AuthInterceptor(sl<AuthService>())],
    ),
  );

  sl.registerLazySingleton(() => BiometricService());
}

Future<void> initFeatures() async {
  // Features - Coffee Tracker
  sl.registerLazySingleton<CoffeeTrackerRemoteDataSource>(
    () => CoffeeTrackerRemoteDataSourceImpl(
      client: sl<InterceptedClient>(),
      baseUrl: AppConfig.baseUrl,
      authService: sl(),
      apiHelper: sl(),
    ),
  );

  sl.registerLazySingleton<GenericKVRemoteDataSource>(
    () => GenericKVRemoteDataSourceImpl(
      client: sl<InterceptedClient>(),
      baseUrl: AppConfig.baseUrl,
      authService: sl(),
      apiHelper: sl(),
    ),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(authService: sl()),
  );

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

  sl.registerLazySingleton<GenericKVRepository>(
    () => GenericKVRepositoryImpl(remoteDataSource: sl()),
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
  sl.registerLazySingleton<GetCoffeeSelectionsUseCase>(
    () => GetCoffeeSelectionsUseCase(sl<GenericKVRepository>()),
  );

  // Blocs
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

  sl.registerFactory<CoffeeTypesBloc>(
    () => CoffeeTypesBloc(sl<GetCoffeeSelectionsUseCase>()),
  );

  // Features - Statistics
  sl.registerLazySingleton<StatisticsRemoteDataSource>(
    () => StatisticsRemoteDataSourceImpl(
      client: sl<InterceptedClient>(),
      baseUrl: AppConfig.baseUrl,
      authService: sl(),
      apiHelper: sl(),
    ),
  );

  sl.registerLazySingleton<StatisticsRepository>(
    () => StatisticsRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(
      client: sl<InterceptedClient>(),
      baseUrl: AppConfig.baseUrl,
      authService: sl(),
      apiHelper: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetStatistics(sl()));

  sl.registerFactory(() => StatisticsBloc(getStatistics: sl()));

  // Features - Settings
  sl.registerLazySingleton<SettingsRemoteDataSource>(
    () => SettingsRemoteDataSourceImpl(
      client: sl<InterceptedClient>(),
      baseUrl: AppConfig.baseUrl,
      authService: sl(),
      apiHelper: sl(),
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
}
