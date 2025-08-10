// lib/injection_container.dart
import 'package:coffee_tracker/features/coffee_tracker/domain/usecases/delete_coffee_entry.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/usecases/edit_coffee_entry.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

import 'core/network/network_info.dart';
import 'features/coffee_tracker/data/repositories/coffee_repository_impl.dart';
import 'features/coffee_tracker/domain/repositories/coffee_tracker_repository.dart';
import 'features/coffee_tracker/domain/usecases/add_coffee_entry.dart';
import 'features/coffee_tracker/domain/usecases/get_daily_coffee_tracker_log.dart';
import 'features/coffee_tracker/presentation/bloc/coffee_tracker_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Coffee Tracker
  // Use cases
  sl.registerLazySingleton<AddCoffeeEntryUseCase>(
    () => AddCoffeeEntryUseCase(sl()),
  );
  sl.registerLazySingleton<EditCoffeeEntryUseCase>(
    () => EditCoffeeEntryUseCase(sl()),
  );
  sl.registerLazySingleton<DeleteCoffeeEntryUseCase>(
    () => DeleteCoffeeEntryUseCase(sl()),
  );
  sl.registerLazySingleton<GetDailyCoffeeTrackerLog>(
    () => GetDailyCoffeeTrackerLog(sl()),
  );

  // Bloc
  sl.registerFactory(
    () => CoffeeTrackerBloc(
      addCoffeeEntry: sl(),
      getLogByDate: sl(),
      editCoffeeEntry: sl(),
      deleteCoffeeEntry: sl(),
    ),
  );

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => Connectivity());

  // Repository
  sl.registerLazySingleton<CoffeerRepository>(
    () => CoffeerRepositoryImpl(sharedPreferences: sl()),
  );
}
