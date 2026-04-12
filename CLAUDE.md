# coffee_tracker — Frontend (Flutter)

## Status: Maintenance

## Actual Structure
```
lib/
├── core/                  # Cross-cutting — auth, network, theme, error, navigation
│   ├── auth/              # Auth state / tokens (shared across features)
│   ├── bloc/              # App-level blocs
│   ├── data/
│   │   ├── datasources/   # Base HTTP client, interceptors
│   │   └── repositories/  # Shared repo implementations
│   ├── error/             # Failure types, exceptions
│   ├── network/           # HTTP setup
│   ├── theme/
│   ├── usecases/          # Base UseCase interface
│   ├── utils/
│   └── widgets/           # Shared UI components
└── features/
    ├── auth/
    ├── coffee_tracker/    # Primary domain
    ├── settings/
    ├── statistics/
    └── user/
        └── [each: data/ domain/ presentation/]
```

**Inward rule:** `domain/` has zero Flutter imports. `data/` depends on `domain/` interfaces only. `presentation/` dispatches Events, renders States — nothing else.

**`core/` boundary:** Features may use `core/`. `core/` must NOT import from any feature. That's a circular dependency and an arch failure.

## State Management: Bloc
- Bloc only. Don't suggest Riverpod, Provider, or setState alternatives.
- Widgets dispatch Events, react to States. That's it.
- Business logic lives in the Bloc/Cubit — not in widgets, not in repositories.

## Rules
- No raw `dynamic`. Use typed models.
- DTOs handle API deserialization — never pass raw `Map<String, dynamic>` into domain.
- `copyWith` on all entities/models — immutability is the default.
- `BuildContext` never crosses an async gap without a mounted check.

## Watch For
- Logic in `build()` methods — extract to state or use case.
- `setState` in a widget that should be managed by the state layer.
- `FutureBuilder` / `StreamBuilder` used where a state notifier is more appropriate.

## API Integration
- Backend is Go on `localhost:8080` — DTOs must match backend JSON contract exactly.
- Isolate all HTTP calls in the `data/` layer. Domain never knows the transport.
