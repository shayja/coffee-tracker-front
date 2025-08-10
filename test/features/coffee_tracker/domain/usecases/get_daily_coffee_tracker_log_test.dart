// import 'package:coffee_tracker/features/coffee_tracker/domain/entities/coffee_tracker_entry.dart';
// import 'package:coffee_tracker/features/coffee_tracker/domain/repositories/coffee_tracker_repository.dart';
// import 'package:coffee_tracker/features/coffee_tracker/domain/usecases/get_daily_coffee_tracker_log.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
// import 'package:mockito/annotations.dart';
// import 'package:dartz/dartz.dart';

// import 'get_daily_coffee_tracker_log_test.mocks.dart';

// @GenerateMocks([CoffeerRepository])
// void main() {
//   late GetDailyCoffeeTrackerLog usecase;
//   late MockCoffeerRepository mockRepository;

//   setUp(() {
//     mockRepository = MockCoffeerRepository();
//     usecase = GetDailyCoffeeTrackerLog(mockRepository);
//   });

//   final tEntries = <CoffeeTrackerEntry>[];

//   test('should get list of coffee entries from repository', () async {
//     // arrange
//     when(mockRepository.getDailyLog()).thenAnswer((_) async => Right(tEntries));
//     // act
//     final result = await usecase.call();
//     // assert
//     expect(result, Right(tEntries));
//     verify(mockRepository.getDailyLog());
//     verifyNoMoreInteractions(mockRepository);
//   });
// }
