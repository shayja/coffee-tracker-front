// import 'package:bloc_test/bloc_test.dart';
// import 'package:coffee_tracker/core/error/failures.dart';
// import 'package:coffee_tracker/features/coffee_tracker/domain/entities/coffee_tracker_entry.dart';
// import 'package:coffee_tracker/features/coffee_tracker/domain/usecases/add_coffee_entry.dart';
// import 'package:coffee_tracker/features/coffee_tracker/domain/usecases/get_daily_coffee_tracker_log.dart';
// import 'package:coffee_tracker/features/coffee_tracker/presentation/bloc/coffee_tracker_bloc.dart';
// import 'package:coffee_tracker/features/coffee_tracker/presentation/bloc/coffee_tracker_event.dart';
// import 'package:coffee_tracker/features/coffee_tracker/presentation/bloc/coffee_tracker_state.dart';
// import 'package:dartz/dartz.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
// import 'package:mockito/annotations.dart';

// import 'coffee_tracker_bloc_test.mocks.dart';

// @GenerateMocks([AddCoffeeEntry, GetDailyCoffeeTrackerLog])
// void main() {
//   late CoffeeTrackerBloc bloc;
//   late MockAddCoffeeEntry mockAddCoffeeEntry;
//   late MockGetDailyCoffeeTrackerLog mockGetDailyCoffeeTrackerLog;

//   setUp(() {
//     mockAddCoffeeEntry = MockAddCoffeeEntry();
//     mockGetDailyCoffeeTrackerLog = MockGetDailyCoffeeTrackerLog();

//     bloc = CoffeeTrackerBloc(
//       addCoffeeEntry: mockAddCoffeeEntry,
//       getDailyLog: mockGetDailyCoffeeTrackerLog,
//     );
//   });

//   final tTimestamp = DateTime(2025, 8, 2, 15, 0);
//   final tEntries = <CoffeeTrackerEntry>[
//     CoffeeTrackerEntry(timestamp: tTimestamp),
//   ];

//   test('initial state should be CoffeeTrackerInitial', () {
//     expect(bloc.state, equals(CoffeeTrackerInitial()));
//   });

//   blocTest<CoffeeTrackerBloc, CoffeeTrackerState>(
//     'emits [Loading, Loaded] when LoadDailyCoffeeLog is added and data is fetched',
//     build: () {
//       when(
//         mockGetDailyCoffeeTrackerLog.call(),
//       ).thenAnswer((_) async => Right(tEntries));
//       return bloc;
//     },
//     act: (bloc) => bloc.add(LoadDailyCoffeeLog()),
//     expect: () => [CoffeeTrackerLoading(), CoffeeTrackerLoaded(tEntries)],
//   );

//   blocTest<CoffeeTrackerBloc, CoffeeTrackerState>(
//     'emits [Loading, Error] when LoadDailyCoffeeLog fails',
//     build: () {
//       when(
//         mockGetDailyCoffeeTrackerLog.call(),
//       ).thenAnswer((_) async => Left(CacheFailure()));
//       return bloc;
//     },
//     act: (bloc) => bloc.add(LoadDailyCoffeeLog()),
//     expect: () => [CoffeeTrackerLoading(), isA<CoffeeTrackerError>()],
//   );

//   blocTest<CoffeeTrackerBloc, CoffeeTrackerState>(
//     'emits [Loading, Loaded] when AddCoffeeCup is added successfully',
//     build: () {
//       when(
//         mockAddCoffeeEntry.call(tTimestamp),
//       ).thenAnswer((_) async => const Right(null));
//       when(
//         mockGetDailyCoffeeTrackerLog.call(),
//       ).thenAnswer((_) async => Right(tEntries));
//       return bloc;
//     },
//     act: (bloc) => bloc.add(AddCoffeeCup(timestamp: tTimestamp)),
//     expect: () => [CoffeeTrackerLoading(), CoffeeTrackerLoaded(tEntries)],
//   );

//   blocTest<CoffeeTrackerBloc, CoffeeTrackerState>(
//     'emits [Loading, Error] when AddCoffeeCup fails',
//     build: () {
//       when(
//         mockAddCoffeeEntry.call(tTimestamp),
//       ).thenAnswer((_) async => Left(CacheFailure()));
//       return bloc;
//     },
//     act: (bloc) => bloc.add(AddCoffeeCup(timestamp: tTimestamp)),
//     expect: () => [CoffeeTrackerLoading(), isA<CoffeeTrackerError>()],
//   );
// }
