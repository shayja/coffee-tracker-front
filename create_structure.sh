#!/bin/bash

# Script to create a folder structure and starter Dart files for a Flutter feature including test folders and empty test files
# Usage:
# chmod +x create_structure.sh
# ./create_structure.sh

# Change this to your feature name
FEATURE_NAME="coffee_tracker"
CAP_FEATURE_NAME="$(tr '[:lower:]' '[:upper:]' <<< ${FEATURE_NAME:0:1})${FEATURE_NAME:1}"

# Base paths
LIB_BASE="lib/features/$FEATURE_NAME"
TEST_BASE="test/features/$FEATURE_NAME"

# Create folder structure
folders=(
  "$LIB_BASE/data/datasources"
  "$LIB_BASE/data/models"
  "$LIB_BASE/data/repositories"
  "$LIB_BASE/domain/entities"
  "$LIB_BASE/domain/repositories"
  "$LIB_BASE/domain/usecases"
  "$LIB_BASE/presentation/bloc"
  "$LIB_BASE/presentation/pages"
  "$LIB_BASE/presentation/widgets"
  "lib/core/error"
  "lib/core/network"
  "lib/core/usecases"
  "lib/core/util"
  "$TEST_BASE/data/datasources"
  "$TEST_BASE/data/repositories"
  "$TEST_BASE/domain/usecases"
  "$TEST_BASE/presentation/bloc"
  "$TEST_BASE/presentation/pages"
  "$TEST_BASE/presentation/widgets"
  "test/core/util"
  "test/core/usecases"
)

for folder in "${folders[@]}"; do
  mkdir -p "$folder"
done

echo "📁 Folder structure created."

# Starter Dart files (you can customize or extend this list)
touch "$LIB_BASE/domain/entities/${FEATURE_NAME}_entry.dart"
echo "class ${CAP_FEATURE_NAME}Entry {}" > "$LIB_BASE/domain/entities/${FEATURE_NAME}_entry.dart"

touch "$LIB_BASE/domain/repositories/${FEATURE_NAME}_repository.dart"
echo "abstract class ${CAP_FEATURE_NAME}Repository {}" > "$LIB_BASE/domain/repositories/${FEATURE_NAME}_repository.dart"

touch "$LIB_BASE/domain/usecases/get_daily_${FEATURE_NAME}_log.dart"
cat > "$LIB_BASE/domain/usecases/get_daily_${FEATURE_NAME}_log.dart" <<EOF
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/${FEATURE_NAME}_entry.dart';
import '../repositories/${FEATURE_NAME}_repository.dart';

class GetDaily${CAP_FEATURE_NAME}Log {
  final ${CAP_FEATURE_NAME}Repository repository;

  GetDaily${CAP_FEATURE_NAME}Log(this.repository);

  Future<Either<Failure, List<${CAP_FEATURE_NAME}Entry>>> call() {
    return repository.getDailyLog();
  }
}
EOF

touch "$LIB_BASE/presentation/bloc/${FEATURE_NAME}_event.dart"
cat > "$LIB_BASE/presentation/bloc/${FEATURE_NAME}_event.dart" <<EOF
import 'package:equatable/equatable.dart';

abstract class ${CAP_FEATURE_NAME}Event extends Equatable {
  const ${CAP_FEATURE_NAME}Event();

  @override
  List<Object> get props => [];
}

class Add${CAP_FEATURE_NAME}Entry extends ${CAP_FEATURE_NAME}Event {}
class Load${CAP_FEATURE_NAME}Log extends ${CAP_FEATURE_NAME}Event {}
EOF

touch "$LIB_BASE/presentation/bloc/${FEATURE_NAME}_state.dart"
cat > "$LIB_BASE/presentation/bloc/${FEATURE_NAME}_state.dart" <<EOF
import 'package:equatable/equatable.dart';

abstract class ${CAP_FEATURE_NAME}State extends Equatable {
  const ${CAP_FEATURE_NAME}State();

  @override
  List<Object> get props => [];
}

class ${CAP_FEATURE_NAME}Initial extends ${CAP_FEATURE_NAME}State {}
class ${CAP_FEATURE_NAME}Loaded extends ${CAP_FEATURE_NAME}State {}
class ${CAP_FEATURE_NAME}Error extends ${CAP_FEATURE_NAME}State {}
EOF

touch "$LIB_BASE/presentation/bloc/${FEATURE_NAME}_bloc.dart"
cat > "$LIB_BASE/presentation/bloc/${FEATURE_NAME}_bloc.dart" <<EOF
import 'package:flutter_bloc/flutter_bloc.dart';
import '${FEATURE_NAME}_event.dart';
import '${FEATURE_NAME}_state.dart';

class ${CAP_FEATURE_NAME}Bloc extends Bloc<${CAP_FEATURE_NAME}Event, ${CAP_FEATURE_NAME}State> {
  ${CAP_FEATURE_NAME}Bloc() : super(${CAP_FEATURE_NAME}Initial()) {
    on<Add${CAP_FEATURE_NAME}Entry>((event, emit) {
      // Add logic
    });

    on<Load${CAP_FEATURE_NAME}Log>((event, emit) {
      // Load logic
    });
  }
}
EOF

# Create empty test files to start with
touch "$TEST_BASE/domain/usecases/get_daily_${FEATURE_NAME}_log_test.dart"
echo "// TODO: Add unit tests for GetDaily${CAP_FEATURE_NAME}Log" > "$TEST_BASE/domain/usecases/get_daily_${FEATURE_NAME}_log_test.dart"

touch "$TEST_BASE/presentation/bloc/${FEATURE_NAME}_bloc_test.dart"
echo "// TODO: Add bloc tests for ${CAP_FEATURE_NAME}Bloc" > "$TEST_BASE/presentation/bloc/${FEATURE_NAME}_bloc_test.dart"

touch "$TEST_BASE/data/repositories/${FEATURE_NAME}_repository_impl_test.dart"
echo "// TODO: Add repository tests for ${CAP_FEATURE_NAME}RepositoryImpl" > "$TEST_BASE/data/repositories/${FEATURE_NAME}_repository_impl_test.dart"

echo "✅ Starter Dart files and empty test files created for feature '$FEATURE_NAME'."
