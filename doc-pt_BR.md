# Construindo uma Aplicação Full Stack Profissional em Dart com AngularDart, `limitless_ui`, `essential_core` e `shelf`

Este guia mostra como desenhar e construir uma aplicação full stack séria em Dart usando:

- `ngdart: 8.0.0-dev.4`
- `ngforms: 5.0.0-dev.3`
- `ngrouter: 4.0.0-dev.3`
- `ngtest: ^5.0.0-dev.3`
- `build_runner: ^2.4.12`
- `build_test: ^2.2.2`
- `build_web_compilers: ^4.0.11`
- `limitless_ui`
- `essential_core: ^1.1.0`
- `shelf` no backend
- opcionalmente `shelf_router`, `shelf_cors_headers`, `eloquent` e `get_it`

A arquitetura recomendada aqui segue a mesma direção prática um monorepo com um pacote `core` compartilhado, um frontend AngularDart e um backend `shelf` modular capaz de escalar com múltiplos isolates.

Este não é um setup de demonstração simples. O objetivo é uma estrutura que consiga suportar módulos CRUD reais, DTOs e filtros reutilizáveis, guards de rota e middleware de autenticação, testes de browser e testes de integração no backend, deploy em produção com múltiplos isolates e manutenção de longo prazo.

Observação importante de terminologia: em servidores Dart, "multithread" normalmente significa **multi-isolate**. Isolates Dart não compartilham memória da mesma forma que threads nativas do sistema operacional. Esse é o modelo mental correto para backend escalável em Dart.

## Validação declarativa de formulários no `limitless_ui`

Para formulários AngularDart com `limitless_ui`, a direção recomendada agora é concentrar as validações simples e repetitivas no próprio componente, em vez de espalhar `invalid`, `errorText`, `class.is-invalid` e helpers manuais por toda a página.

Os blocos principais dessa API são:

- `liType`: preset de alto nível para `li-input`, útil para casos comuns como `cpf`, `email`, `phone` e `requiredText`.
- `liRules`: regras declarativas compostas por `LiRule.required()`, `LiRule.minLength(...)`, `LiRule.cpf()`, `LiRule.custom(...)` e outras.
- `liMessages`: sobrescrita por código de regra, como `required`, `cpf`, `requiredTrue` e `minLength`.
- `liValidationMode`: controla quando o erro aparece, com modos como `dirty`, `touchedOrDirty`, `submitted`, `submittedOrTouched` e `submittedOrTouchedOrDirty`. O padrão do pacote é `submittedOrTouchedOrDirty`.

Exemplo com `li-input`:

```html
<li-input
    label="CPF"
    liType="cpf"
    [liMessages]="{
      'required': 'Informe o CPF.',
      'cpf': 'Digite um CPF valido.'
    }"
    liValidationMode="submitted"
    [(ngModel)]="person.cpf">
</li-input>
```

Exemplo com selects e seleção múltipla:

```html
<li-select
    [dataSource]="departments"
    labelKey="label"
    valueKey="id"
    [liRules]="[LiRule.required()]"
    [liMessages]="{'required': 'Escolha um departamento.'}"
    liValidationMode="submitted"
    [(ngModel)]="person.departmentId">
</li-select>

<li-multi-select
    [dataSource]="channels"
    labelKey="label"
    valueKey="id"
    [liRules]="[
      LiRule.custom((value) =>
        value is Iterable && value.length >= 2
          ? null
          : 'Selecione ao menos 2 canais.')
    ]"
    liValidationMode="submitted"
    [(ngModel)]="person.channelIds">
</li-multi-select>
```

Exemplo com checkbox e rádio:

```html
<li-checkbox
    label="Aceito os termos"
    [required]="true"
    [liMessages]="{'requiredTrue': 'Confirme o aceite.'}"
    liValidationMode="submitted"
    [(ngModel)]="acceptedTerms">
</li-checkbox>

<li-radio-group
    [legend]="approvalLegend"
    [value]="approvalMode"
    [liRules]="[LiRule.required()]"
    [liMessages]="{'required': 'Selecione um modo de aprovação.'}"
    liValidationMode="submitted">
  ...
</li-radio-group>
```

Essa mesma base também vale para `li-date-picker`, `li-time-picker` e `li-file-upload`, com a vantagem de manter a precedência antiga:

- `invalid`, `dataInvalid` e `errorText` externos continuam tendo prioridade;
- `required`, `minLength`, `maxLength`, `pattern` e `validator` legado ainda funcionam onde já existiam;
- regras declarativas entram para reduzir verbosidade e centralizar mensagens.

Quando o formulário é maior, combine os campos com `liForm`:

```html
<form liForm #ui="liForm">
  <li-input liType="cpf" [(ngModel)]="person.cpf"></li-input>
  <li-select [liRules]="[LiRule.required()]" [(ngModel)]="person.departmentId"></li-select>
</form>
```

```dart
final isValid = await ui.validateAndFocusFirstInvalid();
```

Esse fluxo é o ponto de equilíbrio recomendado no projeto:

- regras universais ficam nos componentes;
- regras contextuais continuam na página ou no serviço;
- erros de backend ainda podem sobrescrever a mensagem final do campo.

## 1. O que você está construindo

O sistema alvo tem três pacotes:

```text
my_app/
  backend/
  frontend/
  core/
```

Cada pacote tem um propósito claro:

- `core`: contratos compartilhados, DTOs, helpers de serialização, filtros genéricos, objetos de resposta tabular, exceções compartilhadas e modelos reutilizáveis de baixo nível.
- `frontend`: aplicação web AngularDart usando `limitless_ui` e `essential_core`.
- `backend`: API REST com `shelf`, registro de rotas, middleware, acesso a banco, autenticação e bootstrap para produção.

Essa separação resolve um problema comum em projetos full stack: frontend e backend se desalinharem quando contratos de request e response são duplicados manualmente. Com um `core` compartilhado, os mesmos tipos podem ser reutilizados nas duas camadas.

## 2. Por que esse stack é forte

Esse stack é uma boa escolha quando você quer:

- uma única linguagem no sistema inteiro;
- contratos de request e response fortemente tipados;
- separação limpa entre transporte, lógica de domínio e persistência;
- um frontend baseado em componentes com widgets reais de negócio;
- um backend explícito e fácil de depurar, sem esconder demais o comportamento atrás de magia de framework.

O que cada peça entrega:

- `ngdart`: arquitetura de componentes no estilo Angular para Dart no navegador.
- `ngforms`: formulários e value accessors no AngularDart.
- `ngrouter`: definições de rota, navegação e guards.
- `limitless_ui`: UI reutilizável de aplicação como datatables, selects, typeahead, modais, tabs, toasts, wizards, paginação e mais.
- `essential_core`: modelos genéricos reutilizáveis como `Filters`, `DataFrame<T>` e contratos compartilhados de baixo nível.
- `shelf`: uma camada HTTP pequena e explícita.
- `shelf_router`: mapeamento organizado de rotas.
- `eloquent`: camada de queries SQL quando você quer um query builder ao estilo Laravel em Dart.
- `get_it`: injeção de dependência pragmática e registro de serviços.

O resultado é um stack que continua compreensível mesmo quando a aplicação cresce.

## 3. Estrutura de monorepo recomendada

Comece com este layout:

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

À medida que a aplicação crescer, evolua para:

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

Esse layout mapeia bem fronteiras de responsabilidade e escala com pouca fricção.

## 4. Setup dos pacotes passo a passo

Crie os três pacotes e conecte-os corretamente.

Ordem recomendada:

1. Crie primeiro `core`.
2. Adicione DTOs e filtros compartilhados.
3. Crie `backend` e faça-o depender de `core`.
4. Crie `frontend` e faça-o depender de `core`, `limitless_ui` e `essential_core`.
5. Implemente um slice vertical completo antes de expandir para mais módulos.

O primeiro slice vertical vale mais do que scaffoldar dez módulos vazios. Um slice como `projects` ou `users` força você a validar o formato dos DTOs compartilhados, o design das rotas do backend, a API do repositório, o design dos services do frontend, a integração do roteamento AngularDart, a composição de página com `limitless_ui` e a estratégia de testes.

## 5. Desenhando o pacote compartilhado `core`

O pacote `core` compartilhado é uma das decisões estruturais mais importantes dessa arquitetura.

Ele deve conter:

- DTOs que trafegam por HTTP;
- modelos de domínio leves e seguros para frontend e backend;
- contratos de serialização;
- erros tipados de API;
- filtros reutilizáveis;
- wrappers de resposta paginada ou tabular;
- utilitários que não dependam exclusivamente de navegador ou servidor.

Ele não deve conter:

- `dart:html`;
- `dart:io`;
- código direto de banco de dados;
- componentes AngularDart;
- objetos `Request` ou `Response` do `shelf`;
- configuração exclusiva do backend ou helpers exclusivos do browser.

Exemplo de `core/pubspec.yaml`:

```yaml
name: my_app_core
description: Contratos compartilhados entre frontend e backend.
version: 1.0.0

environment:
  sdk: ^3.6.0

dependencies:
  essential_core: ^1.1.0

dev_dependencies:
  test: ^1.25.9
```

Exemplo de DTO:

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

Exemplo de erro tipado:

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
      title: map['title'] as String? ?? 'Erro inesperado',
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

Exemplo de barrel export:

```dart
library my_app_core;

export 'src/dto/project_dto.dart';
export 'src/exceptions/api_problem.dart';
```

## 6. Setup do pacote frontend

Exemplo de `frontend/pubspec.yaml`:

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

Se você estiver desenvolvendo com um checkout local do `limitless_ui`:

```yaml
dependencies:
  limitless_ui:
    path: ../limitless_ui
```

Por que essas dependências ficam assim:

- pacotes de runtime AngularDart ficam em `dependencies`;
- ferramentas de build e teste do browser ficam em `dev_dependencies`;
- `sass_builder` permanece como dependência de desenvolvimento da aplicação raiz porque o app compila o próprio Sass.

## 7. Entry point do frontend e app raiz

Entry point mínimo:

```dart
import 'package:ngdart/angular.dart';
import 'package:my_app_frontend/src/app/app_component.template.dart' as ng;

void main() {
  runApp(ng.AppComponentNgFactory);
}
```

Se você precisar de locale global, DI ou configuração de app, faça isso aqui antes do `runApp`.

Exemplo com inicialização de locale:

```dart
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:ngdart/angular.dart';
import 'package:my_app_frontend/src/app/app_component.template.dart' as ng;
import 'package:my_app_frontend/src/shared/di/di.dart';

Future<void> main() async {
  await initializeDateFormatting('pt_BR');
  Intl.defaultLocale = 'pt_BR';
  runApp(ng.AppComponentNgFactory, createInjector: injector);
}
```

Componente raiz:

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

Isso é propositalmente pequeno. Mantenha o componente raiz fino e mova a UI real para páginas de rota ou componentes de shell.

## 8. Roteamento AngularDart para aplicações reais

Para aplicações AngularDart não triviais, use objetos `RouteDefinition` explícitos e factories geradas.

Exemplo de registro de rotas:

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

Por que esse padrão é melhor:

- a responsabilidade das rotas fica explícita;
- factories geradas em build permanecem visíveis e depuráveis;
- aplicações grandes conseguem segmentar mapas de rota por módulo;
- o padrão funciona bem com guards e shells de rota aninhados.

## 9. Injeção de dependência no frontend

À medida que a aplicação cresce, não instancie services manualmente dentro dos componentes. Use DI do AngularDart ou um injector de aplicação.

Responsabilidades típicas da DI no frontend:

- cliente da API;
- service de autenticação;
- services por feature;
- route hooks;
- config de aplicação.

Exemplo de injector:

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

## 10. Estilização e Sass no AngularDart

Componentes AngularDart devem apontar para arquivos `.css` gerados em `styleUrls`, mesmo quando a fonte real é `.scss`.

Exemplo:

```dart
@Component(
  selector: 'projects-page',
  templateUrl: 'projects_page.html',
  styleUrls: ['projects_page.css'],
)
class ProjectsPage {}
```

Arquivo real no disco:

```text
projects_page.scss
```

O AngularDart consome CSS em tempo de compilação do componente. `sass_builder` gera o CSS a partir do SCSS. Usar `.scss` diretamente em `styleUrls` é o padrão errado para esse toolchain.

Exemplo de `frontend/build.yaml`:

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

## 11. Construindo UI séria com `limitless_ui`

`limitless_ui` fica mais valioso quando você o trata como um toolkit de aplicação, e não como uma coleção solta de widgets.

Padrões comuns:

- `li-datatable` para páginas de listagem;
- `li-select`, `li-multi-select` e `li-typeahead` para formulários;
- `li-modal` ou `li-offcanvas` para fluxos de edição;
- `li-toast` e `LiToastService` para feedback;
- `li-pagination` e `Filters` para dados paginados.

Exemplo de componente de página:

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

## 12. Design do cliente de API no frontend

Não deixe componentes chamarem `http.get` diretamente. Centralize as regras de transporte.

Seu cliente de API normalmente deve cuidar de:

- construção da URL base;
- headers de autenticação;
- decodificação de JSON;
- conversão de erros em tipos consistentes;
- requests multipart quando necessário.

Exemplo de cliente base:

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
      title: 'Erro HTTP',
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

Service por feature:

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

## 13. Setup do pacote backend

Exemplo de `backend/pubspec.yaml`:

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

`shelf` não impõe uma estrutura pesada, então você precisa definir a estrutura correta por conta própria. Quando isso é feito direito, vira vantagem.

## 14. Inicialização do backend e bootstrap multi-isolate

Essa estrutura de backend mostra a direção correta para um servidor Dart pronto para produção:

- parse de argumentos de linha de comando;
- configuração da aplicação uma vez por isolate;
- spawn de múltiplos isolates quando desejado;
- uso de `shared: true` para todos escutarem na mesma porta;
- estado compartilhado mantido fora da memória do processo.

Exemplo de `bin/server.dart`:

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

## 15. Design do pipeline de middleware

Uma aplicação `shelf` profissional deve empurrar comportamento transversal para middleware, em vez de duplicá-lo em controllers.

Preocupações típicas de middleware:

- log de request;
- CORS;
- mapeamento de exceção para response;
- autenticação;
- injeção de conexão com banco.

Exemplo de middleware de exceção:

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
          title: 'Erro interno do servidor',
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

## 16. Modularização de rotas

Não coloque a API inteira em um único arquivo de rotas.

Layout recomendado:

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

Registro de rotas no topo:

```dart
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:my_app_backend/src/modules/projects/projects_routes.dart';

void registerRoutes(Router app) {
  app.get('/', (Request request) => Response.ok('my_app'));
  app.mount('/api/projects', projectsRoutes());
}
```

## 17. Injeção de dependências no backend

Usar `get_it` aqui é uma escolha pragmática e eficiente para um backend Dart modular.

Exemplo:

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

Regra importante em ambiente multi-isolate: cada isolate tem seu próprio estado de registro, conexões e services.

## 18. Acesso a banco com `eloquent`

`eloquent` é útil quando você quer aplicações de negócio baseadas em SQL, um query builder em vez de SQL montado à mão, fronteiras explícitas de repositório e pooling de conexão em um único lugar.

Exemplo de repositório:

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

## 19. Fluxo de request ponta a ponta

Uma forma saudável de raciocinar sobre o sistema é seguir um request completo:

1. O usuário abre `/projects` no app AngularDart.
2. O router do AngularDart ativa `ProjectsPage`.
3. `ProjectsPage` chama `ProjectService.list(filters)`.
4. `ProjectService` usa o cliente de API compartilhado.
5. O cliente envia `GET /api/projects`.
6. O pipeline `shelf` recebe a request.
7. Os middlewares são executados.
8. O router despacha para a rota da feature.
9. O controller invoca o repositório.
10. O repositório consulta o banco.
11. A response JSON volta para o browser.
12. O AngularDart faz o bind do resultado em `li-datatable`.

## 20. Estratégia de testes

Você precisa de camadas de teste diferentes para riscos diferentes.

### `core`

Teste DTOs, filtros, utilitários e erros compartilhados.

### Frontend

Teste componentes AngularDart com `ngtest`, comportamento de browser com `build_runner test` e interações de rota e formulário.

Exemplo de `frontend/dart_test.yaml`:

```yaml
platforms:
  - chrome
timeout: 2x
```

Comando útil de teste frontend:

```bash
dart run build_runner test -- -p chrome -j 1
```

### Backend

Teste middleware, repositórios, integração rota/controller e comportamento request-to-response com um handler real de teste.

## 21. Fluxo de build e desenvolvimento

Um fluxo diário produtivo:

1. Rode o backend em um terminal.
2. Rode o build/watch ou serve do AngularDart em outro.
3. Mantenha DTOs compartilhados em `core`.
4. Adicione primeiro o contrato do backend.
5. Implemente depois o service do frontend.
6. Faça o bind da UI em seguida.
7. Adicione testes logo depois do primeiro fluxo funcional.

Comando típico do backend:

```bash
dart run bin/server.dart --address 0.0.0.0 --port 8080 --isolates 4
```

Comando típico do frontend:

```bash
dart run build_runner serve web:8081 --delete-conflicting-outputs
```

Comando local alternativo quando `webdev` estiver disponível:

```bash
webdev serve web:8081 --auto refresh --hostname localhost -- --delete-conflicting-outputs
```

## 22. Orientações para deploy em produção

Em produção:

- compile o app AngularDart para assets estáticos;
- sirva esses assets atrás de Nginx ou outro reverse proxy;
- rode a API `shelf` como processo separado;
- termine TLS no proxy;
- escale o backend com múltiplos isolates.

Não confie em estado mutável compartilhado em memória em ambiente multi-isolate.

## 23. Erros comuns a evitar

- Colocar DTOs compartilhados dentro do frontend em vez de `core`.
- Fazer chamadas HTTP brutas diretamente de componentes AngularDart.
- Construir o backend como um único arquivo plano de rotas.
- Misturar SQL, validação e formatação HTTP no mesmo método de controller.
- Tratar isolates Dart como threads com memória compartilhada.
- Referenciar `.scss` diretamente em `styleUrls` do AngularDart.
- Recriar manualmente UI que `limitless_ui` já oferece.

## 24. Blueprint mínimo para começar

Se você quiser a estrutura mínima viável que ainda escale depois, comece aqui:

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

## 25. Recomendação final

Se você está construindo hoje um sistema full stack sério em Dart com AngularDart, a arquitetura mais defensável é:

- `core` para contratos compartilhados;
- AngularDart + `limitless_ui` no frontend;
- `shelf` + `shelf_router` + middleware no backend;
- `eloquent` para persistência relacional estruturada quando fizer sentido;
- múltiplos isolates em produção em vez de um único isolate gigante.

Essa arquitetura é muito mais sustentável do que uma aplicação achatada em um pacote único.

## 26. Exemplo completo de CRUD de `projects` com estrutura real de arquivos

A forma mais rápida de validar o stack inteiro é implementar um módulo completo de `projects`.

Estrutura recomendada:

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

### DTO compartilhado

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

### Tabela no banco

Exemplo de tabela PostgreSQL:

```sql
create table projects (
  id bigserial primary key,
  name varchar(180) not null,
  status varchar(40) not null default 'draft',
  created_at timestamp not null default now()
);
```

### Repositório

`backend/lib/src/modules/projects/repositories/project_repository.dart`

```dart
import 'package:eloquent/eloquent.dart';
import 'package:my_app_core/my_app_core.dart';

class ProjectRepository {
  final Connection connection;

  ProjectRepository(this.connection);

  Future<DataFrame<ProjectDto>> findAll({Filters? filters}) async {
    final query = connection.table('projects');
    final totalRecords = await query.count();

    final rows = await query
        .orderBy('id', 'desc')
        .offset(filters?.offset ?? 0)
        .limit(filters?.limit ?? 10)
        .get();

    final items = rows
        .map((row) => ProjectDto.fromMap({
              'id': row['id'],
              'name': row['name'],
              'status': row['status'],
              'createdAt': row['created_at']?.toString(),
            }))
        .toList();

    return DataFrame<ProjectDto>(
      data: items,
      totalRecords: totalRecords,
    );
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
      jsonEncode(items.toMap()),
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

### Rotas

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

### Service do frontend

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

### Página do frontend

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

### Template do frontend

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

### Teste de rota no backend

`backend/test/projects/projects_routes_test.dart`

```dart
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:test/test.dart';
import 'package:my_app_backend/src/modules/projects/projects_routes.dart';

void main() {
  test('monta rotas de projects', () async {
    final app = Router()..mount('/api/projects', projectsRoutes());
    final response = await app(Request('GET', Uri.parse('http://localhost/api/projects/')));
    expect(response.statusCode, isNot(404));
  });
}
```

Esse exemplo é simples de propósito, mas já é um slice vertical real: tabela, repositório, controller, rotas, service, página de UI e teste.

Observação importante: para listagens, retorne `DataFrame` já no repositório. Isso mantém paginação, `totalRecords` e compatibilidade com `li-datatable` e com `DataFrame.fromMapWithFactory(...)` no frontend.

## 27. Tutorial de autenticação JWT ponta a ponta

O setup mais limpo de JWT para esse stack é:

- frontend guarda o access token em um auth service;
- o cliente da API anexa `Authorization: Bearer <token>`;
- o backend valida o JWT em middleware;
- rotas privadas ficam montadas atrás de middleware de auth;
- route guards no AngularDart redirecionam usuários não autenticados para longe das páginas protegidas.

Em sistemas maiores, você pode adotar um ecossistema mais amplo de OIDC/auth. Para este guia, a baseline mais reaproveitável é validação direta de bearer token no `shelf`.

### Fluxo JWT

1. Usuário envia o formulário de login.
2. O frontend manda credenciais para `/api/auth/login`.
3. O backend valida as credenciais.
4. O backend assina um JWT e o retorna.
5. O frontend armazena o token.
6. O cliente da API inclui o token nas próximas requests.
7. O backend valida assinatura, expiração, issuer e audience quando necessário.
8. O middleware grava os claims no contexto da request.
9. Controllers e middleware de permissão leem os claims.

### Endpoint de login no backend

Exemplo `backend/lib/src/modules/auth/controllers/auth_controller.dart`

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

### Middleware JWT no backend

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

### Montando rotas privadas

```dart
final privateApi = Pipeline()
    .addMiddleware(authMiddleware(jwtSecret))
    .addHandler(projectsRoutes());

app.mount('/api/projects', privateApi);
```

### Auth service no frontend

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

### Cliente da API com bearer token

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

### Route guard no AngularDart

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

### Notas operacionais sobre JWT

- Mantenha access tokens com vida curta.
- Se precisar de sessão longa, adicione refresh tokens.
- Nunca confie em checagem de role no frontend como autorização real.
- Valide permissão no backend mesmo que o frontend esconda botões.
- Se você migrar para OIDC depois, mantenha a mesma estrutura: auth service, rotas protegidas, middleware bearer token e claims no contexto da request.

## 28. Guia de deploy com Nginx + systemd + isolates

Este modelo de deploy segue um arranjo prático de produção. Os arquivos exatos variam por projeto, mas o modelo geral é reaproveitável:

- frontend compilado em arquivos estáticos;
- backend `shelf` rodando como serviço Linux;
- proxy reverso em Nginx;
- backend escalado com múltiplos isolates.

### Topologia de produção

```text
Browser
  -> Nginx :443
    -> /            arquivos estáticos AngularDart
    -> /api/        backend shelf em localhost:8080
```

### Comando do backend

```bash
dart run bin/server.dart --address 127.0.0.1 --port 8080 --isolates 4
```

### Exemplo de serviço systemd

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

Comandos:

```bash
sudo systemctl daemon-reload
sudo systemctl enable my_app_backend
sudo systemctl start my_app_backend
sudo systemctl status my_app_backend
```

### Exemplo de site Nginx

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

Comandos:

```bash
sudo ln -s /etc/nginx/sites-available/my_app.conf /etc/nginx/sites-enabled/my_app.conf
sudo nginx -t
sudo systemctl reload nginx
```

### Build do frontend para deploy

Uma abordagem comum:

```bash
dart run build_runner build --release
```

Depois copie os artefatos gerados para um diretório como:

```text
/var/www/dart/my_app/frontend_build
```

### Checklist de endurecimento para produção

- Rode o backend em `127.0.0.1`, não em `0.0.0.0`, quando o Nginx for o entrypoint público.
- Mantenha a terminação TLS no Nginx.
- Guarde segredos em variáveis de ambiente ou secret store adequado.
- Habilite rotação de logs.
- Use `Restart=always` no `systemd`.
- Ajuste `LimitNOFILE` para produção.
- Monitore memória por isolate.
- Dimensione o pool de banco conforme a quantidade de isolates.

### Orientação de sizing para isolates

Uma baseline prática:

- Comece com `--isolates` próximo ao número de cores da máquina.
- Faça benchmark antes de aumentar.
- Lembre que cada isolate pode criar suas próprias conexões com banco.
- Se você rodar 4 isolates com pool de 10, o banco pode enxergar até 40 conexões abertas.

### Sequência de deploy

1. Publicar o código do backend no servidor.
2. Rodar migrations no banco.
3. Gerar build do frontend.
4. Copiar o build para o root servido pelo Nginx.
5. Atualizar o serviço `systemd`, se necessário.
6. Reiniciar o serviço do backend.
7. Recarregar o Nginx.
8. Verificar `/`, `/api/health`, login e uma página protegida.

### Checklist de verificação em produção

- `curl -I https://myapp.example.com/`
- `curl -I https://myapp.example.com/api/health`
- login funcionando
- rota protegida rejeitando acesso anônimo
- página com datatable carregando dados reais
- logs sem repetição de `500` após startup
