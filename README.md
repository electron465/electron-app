# App Client — Compra ahora, paga en cuotas

App móvil (Flutter) para clientes de un modelo BNPL tipo Cashea: el usuario tiene una
**línea de crédito por niveles**, compra en **tiendas aliadas** pagando una **inicial**
y el resto en **cuotas sin intereses** cada N días, y paga sus cuotas desde la app.

## Stack

| Tema | Elección |
|---|---|
| Estado | `flutter_bloc` (Bloc para flujos con eventos/transformers, Cubit para el resto) |
| Arquitectura | Clean Architecture, organizada **por feature** |
| DI | `get_it` (`lib/core/di/injection.dart`) |
| Navegación | `go_router` con `StatefulShellRoute` (tabs) y redirect por sesión |
| Red | `dio` envuelto en `ApiClient` + interceptor de auth |
| Errores | `fpdart` `Either<Failure, T>` + helper `guard()` |
| Almacenamiento seguro | `flutter_secure_storage` (token) |
| Tests | `bloc_test` + `mocktail` |

## Estructura

```
lib/
├── main.dart                 # bootstrap: intl, DI, BlocObserver
├── app/app.dart              # MaterialApp.router + AuthBloc global
├── core/
│   ├── bloc/                 # AppBlocObserver (logs / crash reporting)
│   ├── config/env.dart       # variables por --dart-define
│   ├── di/injection.dart     # registro de dependencias
│   ├── error/                # exceptions (data) → failures (dominio) vía guard()
│   ├── mock/mock_backend.dart# "servidor" en memoria para desarrollar sin API
│   ├── network/              # ApiClient (Dio) + AuthInterceptor
│   ├── router/               # rutas, router y shell con bottom nav
│   ├── storage/              # TokenStorage
│   ├── theme/                # colores, espaciados, ThemeData
│   ├── usecase/              # contrato UseCase<T, Params>
│   ├── utils/                # formatters (dinero en centavos, fechas)
│   └── widgets/              # componentes reutilizables
└── features/
    ├── auth/      # login teléfono + OTP, sesión global
    ├── credit/    # línea de crédito, nivel, simulador de cuotas (Home)
    ├── stores/    # tiendas aliadas con búsqueda (debounce)
    ├── orders/    # compras y sus cuotas
    ├── payments/  # pagar una cuota (Pago Móvil, transferencia, tarjeta)
    └── profile/   # datos del usuario y logout
```

Cada feature sigue las mismas capas:

```
feature/
├── domain/        # Dart puro: entities, repositories (contratos), usecases
├── data/          # models (fromJson), datasources (API + Mock), repositories impl
└── presentation/  # bloc|cubit, pages, widgets
```

**Regla de dependencias:** `presentation → domain ← data`. El dominio no importa Flutter
ni Dio; la UI nunca ve excepciones, solo `Failure`.

## Convenciones

- **Dinero en centavos (`int`)**, nunca `double`. Se formatea solo al mostrar.
- **Estados:** `sealed class` para pantallas de carga (`Loading/Loaded/Error`) y
  clase única con `status` enum + `copyWith` para formularios/flujos.
- **Blocs de pantalla** se registran como `factory` y se crean en el builder de la
  ruta; solo `AuthBloc` es global.
- **Rutas** siempre vía `Routes` (`lib/core/router/routes.dart`), nunca strings sueltos.
- Lógica de negocio en el dominio y testeable (ej. `CreditLine.simulate`).

## Ejecutar

```bash
flutter pub get
flutter run                       # usa datos mock (OTP demo: 123456)
```

Contra una API real:

```bash
flutter run \
  --dart-define=FLAVOR=prod \
  --dart-define=API_BASE_URL=https://api.tudominio.com/v1 \
  --dart-define=USE_MOCKS=false
```

## Calidad

```bash
flutter analyze
flutter test
```

## Agregar una feature nueva

1. `domain/`: entidad, contrato de repositorio y use case(s).
2. `data/`: model con `fromJson`, datasource real + mock, `RepositoryImpl` usando `guard()`.
3. `presentation/`: Cubit/Bloc + página.
4. Registrar todo en `core/di/injection.dart` y la ruta en `core/router/`.
5. Tests del dominio y del Cubit/Bloc.

## Próximos pasos sugeridos

- Onboarding/KYC (foto de cédula + selfie) y aprobación de línea.
- Pago en tienda con QR y checkout online.
- Progreso de nivel / puntos por pagar a tiempo.
- Notificaciones push de vencimiento de cuotas.
- Refresh token, flavors nativos, i18n (`flutter gen-l10n`), Crashlytics/Sentry, CI.
