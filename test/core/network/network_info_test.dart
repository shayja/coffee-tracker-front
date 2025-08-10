import 'package:coffee_tracker/core/network/network_info.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'network_info_test.mocks.dart';

@GenerateMocks([Connectivity])
void main() {
  late MockConnectivity mockConnectivity;
  late NetworkInfoImpl networkInfo;

  setUp(() {
    mockConnectivity = MockConnectivity();
    networkInfo = NetworkInfoImpl(mockConnectivity);
  });

  group('isConnected', () {
    test('should return true when connectivity includes wifi', () async {
      // arrange
      when(
        mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => [ConnectivityResult.wifi]);
      // act
      final result = await networkInfo.isConnected;
      // assert
      expect(result, true);
    });

    test('should return true when connectivity includes mobile', () async {
      // arrange
      when(
        mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => [ConnectivityResult.mobile]);
      // act
      final result = await networkInfo.isConnected;
      // assert
      expect(result, true);
    });

    test('should return false when connectivity is none', () async {
      // arrange
      when(
        mockConnectivity.checkConnectivity(),
      ).thenAnswer((_) async => [ConnectivityResult.none]);
      // act
      final result = await networkInfo.isConnected;
      // assert
      expect(result, false);
    });

    test('should return false when connectivity is empty list', () async {
      // arrange
      when(mockConnectivity.checkConnectivity()).thenAnswer((_) async => []);
      // act
      final result = await networkInfo.isConnected;
      // assert
      expect(result, false);
    });
  });
}
