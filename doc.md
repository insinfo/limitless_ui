# Building a Professional Full-Stack Dart Application with AngularDart, `limitless_ui`, `essential_core`, and `shelf`

This guide shows how to design and build a serious full-stack Dart application using:

- `ngdart: 8.0.0-dev.4`
- `ngforms: 5.0.0-dev.3`
- `ngrouter: 4.0.0-dev.3`
- `ngtest: ^5.0.0-dev.3`
- `build_runner: ^2.4.12`
- `build_test: ^2.2.2`
- `build_web_compilers: ^4.0.11`
- `limitless_ui`
- `essential_core: ^1.1.0`
- `shelf` on the backend
- optionally `shelf_router`, `shelf_cors_headers`, `eloquent`, and `get_it`



This is not a toy setup. The goal is a structure that can support real CRUD modules, shared DTOs and filters, route guards and auth middleware, browser tests and backend integration tests, multi-isolate production deployment, and long-term maintainability.

Important terminology note: in Dart servers, "multithreaded" usually means **multi-isolate**. Dart isolates do not share memory the way native OS threads do. That is the correct mental model for scalable Dart backend processes.

## 1. What you are building

The target system has three packages:

```text
my_app/
  backend/
  frontend/
  core/
```

Each package has a clear purpose:

- `core`: shared contracts, DTOs, serialization helpers, generic filters, table response objects, shared exceptions, and low-level reusable models.
- `frontend`: AngularDart web application using `limitless_ui` and `essential_core`.
- `backend`: `shelf` REST API, route registration, middleware, database access, auth, and production bootstrap.

This separation solves a common problem in full-stack projects: frontend and backend drift apart when request and response contracts are duplicated manually. With a shared `core`, the same types can be reused in both layers.

## 2. Why this stack is strong

This stack is a good fit when you want:

- one language across the whole system;
- strongly typed request and response contracts;
- a clean separation between transport, domain logic, and persistence;
- a component-based frontend with real business UI widgets;
- a backend that stays explicit and debuggable instead of hiding too much behind framework magic.

What each piece contributes:

- `ngdart`: Angular-style component architecture for Dart in the browser.
- `ngforms`: AngularDart forms and value accessors.
- `ngrouter`: route definitions, navigation, and route guards.
- `limitless_ui`: reusable application UI such as datatables, selects, typeahead, modals, tabs, toasts, wizards, pagination, and more.
- `essential_core`: generic reusable models such as `Filters`, `DataFrame<T>`, and shared low-level contracts.
- `shelf`: a small and explicit HTTP transport layer.
- `shelf_router`: organized route mapping.
- `eloquent`: a SQL-oriented repository layer when you want a Laravel-style query builder in Dart.
- `get_it`: pragmatic dependency injection and service registration.

The result is a stack that remains understandable even as the application grows.

## 3. Recommended monorepo structure

Start with this layout:

```text
my_app/
  backend/
    bin/
    lib/
    test/
    pubspec.yaml
  frontend/
    web/
    lib/
    test/
    build.yaml
    dart_test.yaml
    pubspec.yaml
  core/
    lib/
    test/
    pubspec.yaml
```

As the application grows, evolve to:

```text
my_app/
  backend/
    bin/server.dart
    lib/src/
      shared/
        app_config.dart
        bootstrap.dart
        routes.dart
        middleware/
        di/
        extensions/
      modules/
        projects/
          projects_routes.dart
          controllers/
          repositories/
          services/
        users/
          users_routes.dart
          controllers/
          repositories/
          services/
    test/
  frontend/
    web/
      main.dart
      index.html
      style.scss
    lib/src/
      app/
      routes/
      shared/
        di/
        services/
        guards/
        components/
        pipes/
        directives/
      modules/
        dashboard/
        projects/
        users/
    test/
  core/
    lib/
      src/
        dto/
        models/
        filters/
        exceptions/
        utils/
      core.dart
    test/
```

That layout maps cleanly to ownership boundaries and is easy to scale.

## 4. Step-by-step package setup

Create the three packages and wire them together.

Recommended order:

1. Create `core` first.
2. Add shared DTOs and filters.
3. Create `backend` and depend on `core`.
4. Create `frontend` and depend on `core`, `limitless_ui`, and `essential_core`.
5. Add one vertical slice end to end before expanding to more modules.

The first vertical slice is more valuable than scaffolding ten empty modules. A slice such as `projects` or `users` forces you to validate the shared DTO shape, backend route design, repository API, frontend service design, AngularDart route integration, `limitless_ui` page composition, and test strategy.

## 5. Designing the shared `core` package

The shared `core` package is one of the most important structural decisions in this architecture.

It should contain:

- DTOs that go over HTTP;
- lightweight domain models safe for both frontend and backend;
- serialization contracts;
- typed API errors;
- reusable filters;
- paginated or tabular response wrappers;
- utilities that are not browser-only or server-only.

It should not contain:

- `dart:html`;
- `dart:io`;
- direct database code;
- AngularDart components;
- `shelf` request/response objects;
- backend-only config or frontend-only browser helpers.

Example `core/pubspec.yaml`:

```yaml
name: my_app_core
description: Shared contracts for frontend and backend.
version: 1.0.0

environment:
  sdk: ^3.6.0

dependencies:
  essential_core: ^1.1.0

dev_dependencies:
  test: ^1.25.9
```

Example DTO:

```dart
class ProjectDto {
  final int? id;
  final String name;
  final String status;
  final DateTime? createdAt;

  ProjectDto({
    this.id,
    required this.name,
    required this.status,
    this.createdAt,
  });

  factory ProjectDto.fromMap(Map<String, dynamic> map) {
    return ProjectDto(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      status: map['status'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'status': status,
        'createdAt': createdAt?.toIso8601String(),
      };
}
```

Example typed API problem:

```dart
class ApiProblem {
  final int status;
  final String title;
  final String detail;

  ApiProblem({
    required this.status,
    required this.title,
    required this.detail,
  });

  factory ApiProblem.fromMap(Map<String, dynamic> map) {
    return ApiProblem(
      status: map['status'] as int? ?? 500,
      title: map['title'] as String? ?? 'Unexpected error',
      detail: map['detail'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'status': status,
        'title': title,
        'detail': detail,
      };
}
```

Example export barrel:

```dart
library my_app_core;

export 'src/dto/project_dto.dart';
export 'src/exceptions/api_problem.dart';
```

## 6. Frontend package setup

Example `frontend/pubspec.yaml`:

```yaml
name: my_app_frontend
publish_to: none

environment:
  sdk: ^3.6.0

dependencies:
  ngdart: 8.0.0-dev.4
  ngforms: 5.0.0-dev.3
  ngrouter: 4.0.0-dev.3
  limitless_ui: ^1.0.0-dev.4
  essential_core: ^1.1.0
  my_app_core:
    path: ../core

dev_dependencies:
  build_runner: ^2.4.12
  build_test: ^2.2.2
  build_web_compilers: ^4.0.11
  ngtest: ^5.0.0-dev.3
  test: ^1.25.9
  sass_builder: ^2.2.1
```

If you are developing against a local checkout of `limitless_ui`:

```yaml
dependencies:
  limitless_ui:
    path: ../limitless_ui
```

Why these dependencies are grouped this way:

- AngularDart runtime packages go in `dependencies`.
- Browser build and test tools go in `dev_dependencies`.
- `sass_builder` remains a development dependency for the application root because the app is compiling its own Sass.

## 7. Frontend entry point and root app

Minimal entry point:

```dart
import 'package:ngdart/angular.dart';
import 'package:my_app_frontend/src/app/app_component.template.dart' as ng;

void main() {
  runApp(ng.AppComponentNgFactory);
}
```

If you need locale setup, global DI, or app configuration, do that here before calling `runApp`.

Example with locale initialization:

```dart
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:ngdart/angular.dart';
import 'package:my_app_frontend/src/app/app_component.template.dart' as ng;
import 'package:my_app_frontend/src/shared/di/di.dart';

Future<void> main() async {
  await initializeDateFormatting('en_US');
  Intl.defaultLocale = 'en_US';
  runApp(ng.AppComponentNgFactory, createInjector: injector);
}
```

Root component:

```dart
import 'package:ngdart/angular.dart';
import 'package:ngrouter/ngrouter.dart';
import 'package:my_app_frontend/src/routes/app_routes.dart';

@Component(
  selector: 'my-app',
  templateUrl: 'app_component.html',
  styleUrls: ['app_component.css'],
  directives: [coreDirectives, RouterOutlet],
  exports: [AppRoutes],
)
class AppComponent {}
```

Template:

```html
<router-outlet [routes]="AppRoutes.all"></router-outlet>
```

That is intentionally small. Keep the root component thin and move real business UI into route pages or shell components.

## 8. AngularDart routing for real applications

For non-trivial AngularDart applications, use explicit `RouteDefinition` objects and generated component factories.

Example route registry:

```dart
import 'package:ngrouter/ngrouter.dart';
import 'package:my_app_frontend/src/pages/dashboard/dashboard_page.template.dart'
    as dashboard_template;
import 'package:my_app_frontend/src/pages/projects/projects_page.template.dart'
    as projects_template;
import 'package:my_app_frontend/src/pages/not_found/not_found_page.template.dart'
    as not_found_template;

class AppRoutes {
  static final dashboard = RouteDefinition(
    routePath: RoutePath(path: 'dashboard'),
    component: dashboard_template.DashboardPageNgFactory,
    useAsDefault: true,
  );

  static final projects = RouteDefinition(
    routePath: RoutePath(path: 'projects'),
    component: projects_template.ProjectsPageNgFactory,
  );

  static final notFound = RouteDefinition(
    routePath: RoutePath(path: 'not-found'),
    component: not_found_template.NotFoundPageNgFactory,
  );

  static final all = <RouteDefinition>[
    dashboard,
    projects,
    notFound,
    RouteDefinition.redirect(path: '.+', redirectTo: 'not-found'),
  ];
}
```

Why this pattern is preferable:

- route ownership stays explicit;
- build-time generated factories remain visible and debuggable;
- large applications can segment route maps by module;
- it works cleanly with guards and nested route shells.

## 9. Dependency injection on the frontend

As the application grows, do not instantiate services manually inside components. Use AngularDart dependency injection or an application injector factory.

Typical frontend DI responsibilities:

- API client;
- auth service;
- feature services;
- route hooks;
- app config.

Example injector:

```dart
import 'package:ngdart/angular.dart';
import 'package:ngrouter/ngrouter.dart';
import 'package:my_app_frontend/src/shared/guards/auth_guard.dart';
import 'package:my_app_frontend/src/shared/services/api_client.dart';
import 'package:my_app_frontend/src/modules/projects/services/project_service.dart';

@GenerateInjector([
  ClassProvider(ApiClient),
  ClassProvider(ProjectService),
  ClassProvider(RouterHook, useClass: AuthGuard),
])
final InjectorFactory injector = self.injector$Injector;
```

## 10. Styling and Sass in AngularDart

AngularDart components should point to generated `.css` files in `styleUrls`, even when the actual source is `.scss`.

Example:

```dart
@Component(
  selector: 'projects-page',
  templateUrl: 'projects_page.html',
  styleUrls: ['projects_page.css'],
)
class ProjectsPage {}
```

Actual file on disk:

```text
projects_page.scss
```

AngularDart consumes CSS at component compilation time. `sass_builder` generates the CSS from your SCSS. Keeping `.scss` directly in `styleUrls` is the wrong pattern for this toolchain.

Example frontend `build.yaml`:

```yaml
targets:
  $default:
    builders:
      ngdart:
        generate_for:
          exclude:
            - "web/assets/**"
            - "web/scrollbar.css"
```

## 11. Building serious UI with `limitless_ui`

`limitless_ui` becomes most valuable when you treat it as an application-level toolkit rather than a bag of isolated widgets.

Common patterns:

- `li-datatable` for index pages;
- `li-select`, `li-multi-select`, and `li-typeahead` for forms;
- `li-modal` or `li-offcanvas` for edit flows;
- `li-toast` and `LiToastService` for feedback;
- `li-pagination` and `Filters` for paginated data.

Example page component:

```dart
import 'package:essential_core/essential_core.dart';
import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:my_app_core/my_app_core.dart';
import 'package:my_app_frontend/src/modules/projects/services/project_service.dart';

@Component(
  selector: 'projects-page',
  templateUrl: 'projects_page.html',
  styleUrls: ['projects_page.css'],
  directives: [coreDirectives, LiDatatableComponent],
)
class ProjectsPage implements OnInit {
  final ProjectService _service;

  ProjectsPage(this._service);

  final Filters filters = Filters(limit: 10, offset: 0);

  late final DatatableSettings settings = DatatableSettings(
    colsDefinitions: <DatatableCol>[
      DatatableCol(key: 'name', title: 'Name', sortingBy: 'name', enableSorting: true),
      DatatableCol(key: 'status', title: 'Status', sortingBy: 'status', enableSorting: true),
    ],
  );

  DataFrame<ProjectDto> frame = DataFrame<ProjectDto>(
    data: const [],
    totalRecords: 0,
  );

  bool loading = false;
  String? errorMessage;

  @override
  Future<void> ngOnInit() async {
    await load();
  }

  Future<void> load() async {
    loading = true;
    errorMessage = null;
    try {
      frame = await _service.list(filters);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      loading = false;
    }
  }
}
```

## 12. Frontend API client design

Do not let components call `http.get` directly. Centralize transport rules.

Your API client should usually handle:

- base URL construction;
- auth headers;
- JSON decoding;
- typed error conversion;
- multipart requests when needed.

Example base client:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app_core/my_app_core.dart';

class ApiClient {
  final String baseUrl;

  ApiClient(this.baseUrl);

  Uri uri(String path, {Map<String, dynamic>? queryParameters}) {
    return Uri.parse('$baseUrl$path').replace(
      queryParameters: queryParameters?.map(
        (k, v) => MapEntry(k, v?.toString()),
      ),
    );
  }

  Future<Map<String, String>> authHeaders() async {
    return {'Content-Type': 'application/json'};
  }

  Never _throwForError(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        throw ApiProblem.fromMap(decoded);
      }
    } catch (_) {}

    throw ApiProblem(
      status: response.statusCode,
      title: 'HTTP error',
      detail: response.body,
    );
  }

  Future<dynamic> getJson(String path,
      {Map<String, dynamic>? queryParameters}) async {
    final response = await http.get(
      uri(path, queryParameters: queryParameters),
      headers: await authHeaders(),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    _throwForError(response);
  }
}
```

Feature service:

```dart
import 'package:essential_core/essential_core.dart';
import 'package:my_app_core/my_app_core.dart';
import 'package:my_app_frontend/src/shared/services/api_client.dart';

class ProjectService {
  final ApiClient _api;

  ProjectService(this._api);

  Future<DataFrame<ProjectDto>> list(Filters filters) async {
    final json = await _api.getJson(
      '/api/projects',
      queryParameters: filters.getParams(),
    );
    return DataFrame<ProjectDto>.fromMapWithFactory(
      json,
      (map) => ProjectDto.fromMap(map),
    );
  }
}
```

## 13. Backend package setup

Example `backend/pubspec.yaml`:

```yaml
name: my_app_backend
publish_to: none

environment:
  sdk: ^3.6.0

dependencies:
  shelf: ^1.4.1
  shelf_router: ^1.1.4
  shelf_cors_headers: ^0.1.5
  eloquent: ^3.4.3
  get_it: ^8.0.3
  essential_core: ^1.1.0
  my_app_core:
    path: ../core

dev_dependencies:
  test: ^1.25.9
```

`shelf` does not force a heavy framework structure on you, so you need to define the right structure yourself. That is an advantage when used carefully.

## 14. Backend startup and multi-isolate bootstrap

The `salus` backend shows the right idea for a production-capable Dart server:

- parse command-line arguments;
- configure the app once per isolate;
- spawn multiple isolates when desired;
- use `shared: true` so all isolates can listen on the same port;
- keep shared mutable state outside process memory.

Example `bin/server.dart`:

```dart
import 'package:args/args.dart';
import 'package:my_app_backend/src/shared/bootstrap.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('address', abbr: 'a', defaultsTo: '0.0.0.0')
    ..addOption('port', abbr: 'p', defaultsTo: '8080')
    ..addOption('isolates', abbr: 'j', defaultsTo: '1');

  final parsed = parser.parse(args);

  await configureServer(
    parsed['address'] as String,
    int.parse(parsed['port'] as String),
    int.parse(parsed['isolates'] as String),
  );
}
```

## 15. Middleware pipeline design

A professional `shelf` app should push cross-cutting behavior into middleware instead of duplicating it in controllers.

Typical middleware concerns:

- request logging;
- CORS;
- exception-to-response mapping;
- authentication;
- database connection injection.

Example exception middleware:

```dart
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:my_app_core/my_app_core.dart';

Middleware exceptionMiddleware() {
  return (innerHandler) {
    return (request) async {
      try {
        return await innerHandler(request);
      } on ApiProblem catch (e) {
        return Response(
          e.status,
          body: jsonEncode(e.toMap()),
          headers: {'content-type': 'application/json'},
        );
      } catch (e) {
        final problem = ApiProblem(
          status: 500,
          title: 'Internal server error',
          detail: e.toString(),
        );
        return Response.internalServerError(
          body: jsonEncode(problem.toMap()),
          headers: {'content-type': 'application/json'},
        );
      }
    };
  };
}
```

## 16. Route modularization

Do not place the entire API in one route file.

Recommended layout:

```text
backend/lib/src/
  shared/
    routes.dart
  modules/
    projects/
      projects_routes.dart
      controllers/project_controller.dart
      repositories/project_repository.dart
```

Top-level route registry:

```dart
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:my_app_backend/src/modules/projects/projects_routes.dart';

void registerRoutes(Router app) {
  app.get('/', (Request request) => Response.ok('my_app'));
  app.mount('/api/projects', projectsRoutes());
}
```

## 17. Dependency injection in the backend

The `salus` backend uses `get_it`, which is a pragmatic and effective choice for a modular Dart backend.

Example:

```dart
import 'package:eloquent/eloquent.dart';
import 'package:get_it/get_it.dart';
import 'package:my_app_backend/src/db/database_service.dart';
import 'package:my_app_backend/src/modules/projects/repositories/project_repository.dart';

final ioc = GetIt.instance;

void setupDependencies() {
  if (!ioc.isRegistered<DatabaseService>()) {
    ioc.registerSingleton(DatabaseService());
  }

  if (!ioc.isRegistered<ProjectRepository>()) {
    ioc.registerFactory<ProjectRepository>(
      () => ProjectRepository(ioc<Connection>()),
    );
  }
}
```

Important multi-isolate rule: each isolate has its own registration state, connections, and services.

## 18. Database access with `eloquent`

`eloquent` is useful when you want SQL-backed business applications, a query builder instead of hand-assembled SQL, explicit repository boundaries, and connection pooling in one place.

Example repository:

```dart
import 'package:eloquent/eloquent.dart';
import 'package:my_app_core/my_app_core.dart';

class ProjectRepository {
  final Connection connection;

  ProjectRepository(this.connection);

  Future<List<ProjectDto>> findAll() async {
    final rows = await connection.table('projects').get();
    return rows
        .map((row) => ProjectDto.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }
}
```

## 19. Request flow end to end

One healthy way to reason about the system is to follow one request:

1. User opens `/projects` in the AngularDart app.
2. AngularDart router activates `ProjectsPage`.
3. `ProjectsPage` calls `ProjectService.list(filters)`.
4. `ProjectService` uses the shared API client.
5. API client sends `GET /api/projects`.
6. `shelf` pipeline receives the request.
7. Middleware runs.
8. Router dispatches to the feature route.
9. Controller invokes the repository.
10. Repository queries the database.
11. JSON response returns to the browser.
12. AngularDart binds the result to `li-datatable`.

## 20. Testing strategy

You need separate testing layers for separate risks.

### `core`

Test DTO serialization, filters, utilities, and shared errors.

### Frontend

Test AngularDart components with `ngtest`, browser behavior with `build_runner test`, and route/form interactions.

Example `frontend/dart_test.yaml`:

```yaml
platforms:
  - chrome
timeout: 2x
```

Useful frontend test command:

```bash
dart run build_runner test -- -p chrome -j 1
```

### Backend

Test middleware behavior, repository logic, route/controller integration, and request-to-response behavior with a real test handler.

## 21. Build and development workflow

A productive daily workflow:

1. Run backend in one terminal.
2. Run AngularDart build/watch or serve in another.
3. Keep shared DTOs in `core`.
4. Add backend contract first.
5. Implement frontend service second.
6. Bind UI third.
7. Add tests immediately after the first working path.

Typical backend command:

```bash
dart run bin/server.dart --address 0.0.0.0 --port 8080 --isolates 4
```

Typical frontend command:

```bash
dart run build_runner serve web:8081
```

## 22. Production deployment guidance

For production:

- build the AngularDart app to static assets;
- serve those assets behind Nginx or another reverse proxy;
- run the `shelf` API as a separate process;
- terminate TLS at the proxy;
- scale the backend with multiple isolates.

Do not rely on in-memory shared mutable state in a multi-isolate environment.

## 23. Common mistakes to avoid

- Putting shared DTOs in the frontend package instead of `core`.
- Calling raw HTTP directly from AngularDart components.
- Building the backend as one flat route file.
- Mixing SQL, validation, and HTTP response formatting in one controller method.
- Treating Dart isolates as shared-memory threads.
- Referencing `.scss` directly in AngularDart `styleUrls`.
- Rebuilding UI primitives that `limitless_ui` already provides.

## 24. Minimal starter blueprint

If you want the shortest viable structure that still scales later, start here:

```text
my_app/
  core/
    lib/
      src/dto/
      src/exceptions/
      core.dart
  backend/
    bin/server.dart
    lib/src/shared/bootstrap.dart
    lib/src/shared/routes.dart
    lib/src/shared/middleware/
    lib/src/modules/projects/
  frontend/
    web/main.dart
    web/index.html
    lib/src/app/
    lib/src/routes/
    lib/src/modules/projects/
    lib/src/shared/services/
```

## 25. Final recommendation

If you are building a serious Dart full-stack system today with AngularDart, the most defensible architecture is:

- `core` for shared contracts;
- AngularDart + `limitless_ui` on the frontend;
- `shelf` + `shelf_router` + middleware on the backend;
- `eloquent` for structured relational persistence when useful;
- multiple isolates in production instead of a single giant isolate.

That architecture is consistent with the `salus` reference and is substantially more maintainable than a flat all-in-one package.

## 26. Full `projects` CRUD example with real file layout

The fastest way to validate the whole stack is to implement a complete `projects` module.

Recommended file layout:

```text
my_app/
  core/
    lib/src/dto/project_dto.dart
    lib/core.dart
  backend/
    lib/src/modules/projects/
      projects_routes.dart
      controllers/project_controller.dart
      repositories/project_repository.dart
    test/projects/
      projects_routes_test.dart
  frontend/
    lib/src/modules/projects/
      pages/projects_page.dart
      pages/projects_page.html
      pages/projects_page.scss
      components/project_form_component.dart
      components/project_form_component.html
      components/project_form_component.scss
      services/project_service.dart
```

### Shared DTO

`core/lib/src/dto/project_dto.dart`

```dart
class ProjectDto {
  final int? id;
  final String name;
  final String status;
  final DateTime? createdAt;

  ProjectDto({
    this.id,
    required this.name,
    required this.status,
    this.createdAt,
  });

  factory ProjectDto.fromMap(Map<String, dynamic> map) {
    return ProjectDto(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      status: map['status'] as String? ?? 'draft',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'status': status,
        'createdAt': createdAt?.toIso8601String(),
      };
}
```

### Database table

Example PostgreSQL table:

```sql
create table projects (
  id bigserial primary key,
  name varchar(180) not null,
  status varchar(40) not null default 'draft',
  created_at timestamp not null default now()
);
```

### Repository

`backend/lib/src/modules/projects/repositories/project_repository.dart`

```dart
import 'package:eloquent/eloquent.dart';
import 'package:my_app_core/my_app_core.dart';

class ProjectRepository {
  final Connection connection;

  ProjectRepository(this.connection);

  Future<List<ProjectDto>> findAll() async {
    final rows = await connection.table('projects').orderBy('id', 'desc').get();
    return rows
        .map((row) => ProjectDto.fromMap({
              'id': row['id'],
              'name': row['name'],
              'status': row['status'],
              'createdAt': row['created_at']?.toString(),
            }))
        .toList();
  }

  Future<ProjectDto?> findById(int id) async {
    final row = await connection.table('projects').where('id', id).first();
    if (row == null) return null;
    return ProjectDto.fromMap({
      'id': row['id'],
      'name': row['name'],
      'status': row['status'],
      'createdAt': row['created_at']?.toString(),
    });
  }

  Future<ProjectDto> insert(ProjectDto dto) async {
    final id = await connection.table('projects').insertGetId({
      'name': dto.name,
      'status': dto.status,
    });
    return (await findById(id as int))!;
  }

  Future<ProjectDto?> update(int id, ProjectDto dto) async {
    final affected = await connection.table('projects').where('id', id).update({
      'name': dto.name,
      'status': dto.status,
    });
    if (affected == 0) return null;
    return findById(id);
  }

  Future<bool> delete(int id) async {
    final affected = await connection.table('projects').where('id', id).delete();
    return affected > 0;
  }
}
```

### Controller

`backend/lib/src/modules/projects/controllers/project_controller.dart`

```dart
import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:shelf/shelf.dart';
import 'package:my_app_core/my_app_core.dart';
import 'package:my_app_backend/src/modules/projects/repositories/project_repository.dart';

class ProjectController {
  final _repo = GetIt.instance<ProjectRepository>();

  Future<Response> list(Request request) async {
    final items = await _repo.findAll();
    return Response.ok(
      jsonEncode({
        'data': items.map((e) => e.toMap()).toList(),
        'totalRecords': items.length,
      }),
      headers: {'content-type': 'application/json'},
    );
  }

  Future<Response> getById(Request request, String id) async {
    final item = await _repo.findById(int.parse(id));
    if (item == null) {
      throw ApiProblem(status: 404, title: 'Not found', detail: 'Project not found');
    }
    return Response.ok(
      jsonEncode(item.toMap()),
      headers: {'content-type': 'application/json'},
    );
  }

  Future<Response> create(Request request) async {
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final dto = ProjectDto.fromMap(body);
    if (dto.name.trim().isEmpty) {
      throw ApiProblem(status: 400, title: 'Validation error', detail: 'Name is required');
    }
    final created = await _repo.insert(dto);
    return Response(
      201,
      body: jsonEncode(created.toMap()),
      headers: {'content-type': 'application/json'},
    );
  }

  Future<Response> update(Request request, String id) async {
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final dto = ProjectDto.fromMap(body);
    final updated = await _repo.update(int.parse(id), dto);
    if (updated == null) {
      throw ApiProblem(status: 404, title: 'Not found', detail: 'Project not found');
    }
    return Response.ok(
      jsonEncode(updated.toMap()),
      headers: {'content-type': 'application/json'},
    );
  }

  Future<Response> delete(Request request, String id) async {
    final ok = await _repo.delete(int.parse(id));
    if (!ok) {
      throw ApiProblem(status: 404, title: 'Not found', detail: 'Project not found');
    }
    return Response.ok(
      jsonEncode({'deleted': true}),
      headers: {'content-type': 'application/json'},
    );
  }
}
```

### Routes

`backend/lib/src/modules/projects/projects_routes.dart`

```dart
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:my_app_backend/src/modules/projects/controllers/project_controller.dart';

Handler projectsRoutes() {
  final router = Router();
  final controller = ProjectController();

  router.get('/', controller.list);
  router.get('/<id|[0-9]+>', controller.getById);
  router.post('/', controller.create);
  router.put('/<id|[0-9]+>', controller.update);
  router.delete('/<id|[0-9]+>', controller.delete);

  return router;
}
```

### Frontend service

`frontend/lib/src/modules/projects/services/project_service.dart`

```dart
import 'package:essential_core/essential_core.dart';
import 'package:my_app_core/my_app_core.dart';
import 'package:my_app_frontend/src/shared/services/api_client.dart';

class ProjectService {
  final ApiClient _api;

  ProjectService(this._api);

  Future<DataFrame<ProjectDto>> list(Filters filters) async {
    final json = await _api.getJson(
      '/api/projects',
      queryParameters: filters.getParams(),
    );
    return DataFrame<ProjectDto>.fromMapWithFactory(
      json,
      (map) => ProjectDto.fromMap(map),
    );
  }

  Future<ProjectDto> create(ProjectDto dto) async {
    final json = await _api.postJson('/api/projects', dto.toMap());
    return ProjectDto.fromMap(json as Map<String, dynamic>);
  }
}
```

### Frontend page

`frontend/lib/src/modules/projects/pages/projects_page.dart`

```dart
import 'package:essential_core/essential_core.dart';
import 'package:limitless_ui/limitless_ui.dart';
import 'package:ngdart/angular.dart';
import 'package:my_app_core/my_app_core.dart';
import 'package:my_app_frontend/src/modules/projects/services/project_service.dart';

@Component(
  selector: 'projects-page',
  templateUrl: 'projects_page.html',
  styleUrls: ['projects_page.css'],
  directives: [coreDirectives, LiDatatableComponent],
)
class ProjectsPage implements OnInit {
  final ProjectService _service;

  ProjectsPage(this._service);

  final filters = Filters(limit: 10, offset: 0);
  late final DatatableSettings settings = DatatableSettings(
    colsDefinitions: <DatatableCol>[
      DatatableCol(key: 'name', title: 'Name', enableSorting: true, sortingBy: 'name'),
      DatatableCol(key: 'status', title: 'Status', enableSorting: true, sortingBy: 'status'),
    ],
  );

  DataFrame<ProjectDto> frame = DataFrame<ProjectDto>(data: const [], totalRecords: 0);
  bool loading = false;

  @override
  Future<void> ngOnInit() async {
    await refresh();
  }

  Future<void> refresh() async {
    loading = true;
    try {
      frame = await _service.list(filters);
    } finally {
      loading = false;
    }
  }
}
```

### Frontend template

`frontend/lib/src/modules/projects/pages/projects_page.html`

```html
<section class="page-header mb-3">
  <h2>Projects</h2>
</section>

<li-datatable
  [data]="frame"
  [settings]="settings"
  [dataTableFilter]="filters">
</li-datatable>
```

### Backend route test

`backend/test/projects/projects_routes_test.dart`

```dart
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:test/test.dart';
import 'package:my_app_backend/src/modules/projects/projects_routes.dart';

void main() {
  test('mounts projects routes', () async {
    final app = Router()..mount('/api/projects', projectsRoutes());
    final response = await app(Request('GET', Uri.parse('http://localhost/api/projects/')));
    expect(response.statusCode, isNot(404));
  });
}
```

This example is intentionally simple, but it is already a real vertical slice: database table, repository, controller, routes, service, UI page, and test.

## 27. End-to-end JWT authentication tutorial

The cleanest JWT setup for this stack is:

- frontend stores the access token in an auth service;
- API client attaches `Authorization: Bearer <token>`;
- backend validates the JWT in middleware;
- private routes are mounted behind auth middleware;
- AngularDart route guards redirect unauthenticated users away from protected pages.

The `new_sali` reference shows a broader OIDC/auth ecosystem. For this guide, the simplest reusable baseline is direct bearer-token validation in `shelf`.

### JWT flow

1. User submits login form.
2. Frontend sends credentials to `/api/auth/login`.
3. Backend validates the credentials.
4. Backend signs a JWT and returns it.
5. Frontend stores the token.
6. API client includes the token in subsequent requests.
7. Backend middleware validates token signature, expiration, issuer, and audience when applicable.
8. Middleware stores decoded claims in request context.
9. Controllers and permission middleware read the claims.

### Backend login endpoint

Example `backend/lib/src/modules/auth/controllers/auth_controller.dart`

```dart
import 'dart:convert';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:shelf/shelf.dart';

class AuthController {
  final String jwtSecret;

  AuthController(this.jwtSecret);

  Future<Response> login(Request request) async {
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final username = body['username'] as String? ?? '';
    final password = body['password'] as String? ?? '';

    if (username != 'admin' || password != '123456') {
      return Response.forbidden(
        jsonEncode({'title': 'Invalid credentials', 'detail': 'Username or password is invalid'}),
        headers: {'content-type': 'application/json'},
      );
    }

    final claimSet = JwtClaim(
      issuer: 'my_app_backend',
      subject: username,
      maxAge: const Duration(hours: 8),
      otherClaims: <String, dynamic>{
        'roles': ['admin'],
      },
    );

    final token = issueJwtHS256(claimSet, jwtSecret);

    return Response.ok(
      jsonEncode({
        'accessToken': token,
        'tokenType': 'Bearer',
        'expiresIn': 28800,
      }),
      headers: {'content-type': 'application/json'},
    );
  }
}
```

### Backend JWT middleware

`backend/lib/src/shared/middleware/auth_middleware.dart`

```dart
import 'dart:convert';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:shelf/shelf.dart';

Middleware authMiddleware(String jwtSecret) {
  return (innerHandler) {
    return (request) async {
      final authHeader = request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response(
          401,
          body: jsonEncode({'title': 'Unauthorized', 'detail': 'Missing bearer token'}),
          headers: {'content-type': 'application/json'},
        );
      }

      final token = authHeader.substring('Bearer '.length).trim();

      try {
        final claimSet = verifyJwtHS256Signature(token, jwtSecret);
        claimSet.validate(issuer: 'my_app_backend');

        final next = request.change(context: {
          ...request.context,
          'jwt_claims': claimSet,
          'username': claimSet.subject,
        });

        return innerHandler(next);
      } catch (_) {
        return Response(
          401,
          body: jsonEncode({'title': 'Unauthorized', 'detail': 'Invalid or expired token'}),
          headers: {'content-type': 'application/json'},
        );
      }
    };
  };
}
```

### Mounting private routes

```dart
final privateApi = Pipeline()
    .addMiddleware(authMiddleware(jwtSecret))
    .addHandler(projectsRoutes());

app.mount('/api/projects', privateApi);
```

### Frontend auth service

`frontend/lib/src/shared/services/auth_service.dart`

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  String? _accessToken;

  String? get accessToken => _accessToken;
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

  Future<void> login(String baseUrl, String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Login failed');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    _accessToken = json['accessToken'] as String?;
  }

  void logout() {
    _accessToken = null;
  }
}
```

### API client with bearer token

```dart
class ApiClient {
  final String baseUrl;
  final AuthService authService;

  ApiClient(this.baseUrl, this.authService);

  Future<Map<String, String>> authHeaders() async {
    final headers = <String, String>{'content-type': 'application/json'};
    final token = authService.accessToken;
    if (token != null && token.isNotEmpty) {
      headers['authorization'] = 'Bearer $token';
    }
    return headers;
  }
}
```

### AngularDart route guard

```dart
import 'package:ngdart/angular.dart';
import 'package:ngrouter/ngrouter.dart';
import 'package:my_app_frontend/src/shared/services/auth_service.dart';

class AuthGuard extends RouterHook {
  final AuthService _authService;
  final Router _router;

  AuthGuard(this._authService, this._router);

  @override
  Future<NavigationResult> navigationPath(
    String path,
    NavigationParams? navigationParams,
  ) async {
    if (_authService.isAuthenticated) {
      return NavigationResult.allow;
    }

    _router.navigate('/login');
    return NavigationResult.block;
  }
}
```

### JWT operational notes

- Keep access tokens short-lived.
- If you need long-lived sessions, add refresh tokens.
- Never trust frontend role checks as real authorization.
- Validate permission on the backend even if the frontend hides buttons.
- If you move to OIDC later, keep the same structure: auth service, guarded routes, bearer token middleware, request-context claims.

## 28. Deployment guide with Nginx + systemd + isolates

The `new_sali` repository contains real-world Nginx and service-management material. The exact files there are project-specific, but the deployment model is reusable:

- frontend built to static files;
- `shelf` backend running as a Linux service;
- reverse proxy in Nginx;
- backend scaled using multiple isolates.

### Production topology

```text
Browser
  -> Nginx :443
    -> /            static AngularDart files
    -> /api/        shelf backend on localhost:8080
```

### Backend run command

```bash
dart run bin/server.dart --address 127.0.0.1 --port 8080 --isolates 4
```

### Example systemd service

`/etc/systemd/system/my_app_backend.service`

```ini
[Unit]
Description=My App Dart Backend
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/dart/my_app/backend
Environment=APP_ENV=production
Environment=DB_HOST=127.0.0.1
Environment=DB_PORT=5432
Environment=DB_NAME=my_app
Environment=DB_USER=my_app
Environment=DB_PASS=change_me
Environment=JWT_SECRET=change_me
ExecStart=/usr/bin/dart run bin/server.dart --address 127.0.0.1 --port 8080 --isolates 4
Restart=always
RestartSec=5
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
```

Commands:

```bash
sudo systemctl daemon-reload
sudo systemctl enable my_app_backend
sudo systemctl start my_app_backend
sudo systemctl status my_app_backend
```

### Example Nginx site

`/etc/nginx/sites-available/my_app.conf`

```nginx
server {
    listen 80;
    server_name myapp.example.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name myapp.example.com;

    ssl_certificate /etc/letsencrypt/live/myapp.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/myapp.example.com/privkey.pem;

    root /var/www/dart/my_app/frontend_build;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

Commands:

```bash
sudo ln -s /etc/nginx/sites-available/my_app.conf /etc/nginx/sites-enabled/my_app.conf
sudo nginx -t
sudo systemctl reload nginx
```

### Building the frontend for deployment

One common approach is:

```bash
dart run build_runner build --release
```

Then copy the generated frontend artifacts to a directory such as:

```text
/var/www/dart/my_app/frontend_build
```

### Production hardening checklist

- Run backend bound to `127.0.0.1`, not public `0.0.0.0`, when Nginx is the public entrypoint.
- Keep TLS termination in Nginx.
- Store secrets in environment variables or a proper secret store.
- Enable log rotation.
- Use `Restart=always` in `systemd`.
- Set `LimitNOFILE` high enough for production traffic.
- Monitor memory per isolate.
- Size DB pool according to isolate count.

### Isolate sizing guidance

A practical baseline:

- Start with `--isolates` near the number of CPU cores.
- Benchmark before increasing.
- Remember that each isolate may create its own DB connections.
- If you run 4 isolates with a pool of 10, your database may see up to 40 open connections.

### Deploy sequence

1. Publish backend code to server.
2. Run DB migrations.
3. Build frontend assets.
4. Copy frontend build to Nginx root.
5. Update systemd service if needed.
6. Restart backend service.
7. Reload Nginx.
8. Verify `/`, `/api/health`, login, and a protected page.

### Production verification checklist

- `curl -I https://myapp.example.com/`
- `curl -I https://myapp.example.com/api/health`
- login succeeds
- protected route rejects anonymous access
- datatable page loads real data
- logs show no repeated 500s after startup
