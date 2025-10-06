import 'package:coffee_tracker/features/coffee_tracker/domain/usecases/get_coffee_selections.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/bloc/coffee_tracker_event.dart';
import 'package:coffee_tracker/features/coffee_tracker/presentation/bloc/coffee_tracker_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoffeeTypesBloc extends Bloc<LoadCoffeeTypes, SelectOptionsState> {
  final GetCoffeeSelectionsUseCase getCoffeeTypesUseCase;

  CoffeeTypesBloc(this.getCoffeeTypesUseCase) : super(SelectOptionsInitial()) {
    on<LoadCoffeeTypes>((event, emit) async {
      emit(SelectOptionsLoading());
      final result = await getCoffeeTypesUseCase.execute(event.language);

      result.fold(
        (failure) => emit(SelectOptionsError(failure.toString())),
        (options) =>
            emit(SelectOptionsLoaded(options.coffeeTypes, options.sizes)),
      );
    });
  }
}
