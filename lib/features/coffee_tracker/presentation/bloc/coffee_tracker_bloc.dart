import 'package:coffee_tracker/features/coffee_tracker/domain/entities/coffee_tracker_entry.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/usecases/add_coffee_entry.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/usecases/delete_coffee_entry.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/usecases/edit_coffee_entry.dart';
import 'package:coffee_tracker/features/coffee_tracker/domain/usecases/get_daily_coffee_tracker_log.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/bloc/coffee_tracker_event.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/bloc/coffee_tracker_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class CoffeeTrackerBloc extends Bloc<CoffeeTrackerEvent, CoffeeTrackerState> {
  final AddCoffeeEntryUseCase addCoffeeEntry;
  final EditCoffeeEntryUseCase editCoffeeEntry;
  final GetDailyCoffeeTrackerLog getLogByDate;
  final DeleteCoffeeEntryUseCase deleteCoffeeEntry;

  DateTime currentDate = DateTime.now();

  CoffeeTrackerBloc({
    required this.addCoffeeEntry,
    required this.getLogByDate,
    required this.editCoffeeEntry,
    required this.deleteCoffeeEntry,
  }) : super(CoffeeTrackerInitial()) {
    on<AddCoffeeEntry>(_onAddCoffeeCup);
    on<LoadDailyCoffeeLog>(_onLoadDailyLog);
    on<EditCoffeeEntry>(_onEditCoffeeEntry);
    on<DeleteCoffeeEntry>(_onDeleteCoffeeEntry);
  }

  /// Strip time portion from DateTime for date-only comparison
  DateTime _stripTime(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  Future<void> _onAddCoffeeCup(
    AddCoffeeEntry event,
    Emitter<CoffeeTrackerState> emit,
  ) async {
    emit(CoffeeTrackerLoading());

    final entry = CoffeeTrackerEntry(
      id: const Uuid().v4(), // This is fine for client-side ID
      timestamp: event.timestamp,
      notes: event.notes,
    );

    final result = await addCoffeeEntry(AddCoffeeEntryParams(entry));
    final entryDate = _stripTime(event.timestamp);

    // Keep showing the same date unless the added entry belongs to current date
    final shouldRefreshDate = entryDate == currentDate
        ? currentDate
        : currentDate; // could be changed to entryDate if desired

    await result.fold(
      (failure) async => emit(CoffeeTrackerError('Failed to add entry')),
      (_) async => await _reloadLogForDate(
        date: shouldRefreshDate,
        emit: emit,
        onErrorMessage: 'Failed to reload data',
      ),
    );
  }

  Future<void> _onEditCoffeeEntry(
    EditCoffeeEntry event,
    Emitter<CoffeeTrackerState> emit,
  ) async {
    emit(CoffeeTrackerLoading());

    final result = await editCoffeeEntry(
      EditCoffeeEntryParams(oldEntry: event.oldEntry, newEntry: event.newEntry),
    );

    final updatedDate = _stripTime(event.newEntry.timestamp);

    // Keep showing the same date unless the edited entry belongs to current date
    final shouldRefreshDate = updatedDate == currentDate
        ? currentDate
        : currentDate; // could be changed to updatedDate if desired

    await result.fold(
      (failure) async => emit(CoffeeTrackerError('Failed to edit entry')),
      (_) async => await _reloadLogForDate(
        date: shouldRefreshDate,
        emit: emit,
        onErrorMessage: 'Failed to reload data',
      ),
    );
  }

  Future<void> _onDeleteCoffeeEntry(
    DeleteCoffeeEntry event,
    Emitter<CoffeeTrackerState> emit,
  ) async {
    emit(CoffeeTrackerLoading());

    final result = await deleteCoffeeEntry(
      DeleteCoffeeEntryParams(entry: event.entry),
    );

    await result.fold(
      (failure) async => emit(CoffeeTrackerError('Failed to delete entry')),
      (_) async => await _reloadLogForDate(date: currentDate, emit: emit),
    );
  }

  Future<void> _onLoadDailyLog(
    LoadDailyCoffeeLog event,
    Emitter<CoffeeTrackerState> emit,
  ) async {
    emit(CoffeeTrackerLoading());
    currentDate = _stripTime(event.date);
    await _reloadLogForDate(
      date: currentDate,
      emit: emit,
      onErrorMessage: 'Failed to load log',
    );
  }

  Future<void> _reloadLogForDate({
    required DateTime date,
    required Emitter<CoffeeTrackerState> emit,
    String onErrorMessage = 'Failed to reload log',
  }) async {
    final result = await getLogByDate(date);

    result.fold(
      (failure) => emit(CoffeeTrackerError(onErrorMessage)),
      (entries) => emit(CoffeeTrackerLoaded(entries)),
    );
  }
}
