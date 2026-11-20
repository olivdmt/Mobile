# Relatório final — Mobile II

> Rascunho de trabalho, não é ainda o PDF de submissão. Preencher a versão remota (tag/hash), anexar capturas próprias e resultados finais de release antes de exportar. Não usar evidências de exemplo fictício.

## 1. Identificação e produto

**Estudante:** Mateus Dayson de Oliveira
**Matrícula:** 0031595
**Turma:** ADS – Turma de Quarta 2025/2026
**Aplicativo:** Catálogo Pessoal
**Problema e público:** leitores e estudantes que precisam organizar livros e referências, acompanhar status e consultar os próprios registros por conta autenticada.
**Fluxo:** cadastro/login → catálogo vazio/carregado/cache → cadastrar ou buscar livro → detalhe/edição/favorito/status → exclusão → logout.

## 2. Repositório, versão e reprodução

**Repositório configurado:** https://github.com/olivdmt/Mobile
**Subdiretório:** `catalogo_pessoal/`
**Tag ou hash remoto avaliado:** PENDENTE — publicar a revisão e anotar o identificador remoto exato.
**Versão do app:** 1.0.0+1
**Ambiente validado:** Flutter 3.47.0 / Dart 3.13.0; Node usado para suíte Firestore; emulador Firestore local.
**Reprodução:** `flutter pub get`, `flutter run`; emuladores com `firebase emulators:start --project demo-catalogo-pessoal --only auth,firestore` e `flutter run --dart-define=USE_FIREBASE_EMULATORS=true`.

## 3. Matriz de evidências

| Nº | Critério | Implementação/evidência no projeto | Estado da evidência |
|---:|---|---|---|
| 1 | Produto, autoria, problema, público e fluxo | Esta seção e telas `lib/screens/` | Capturas próprias pendentes |
| 2 | Repositório e versão reproduzível | URL acima; `pubspec.yaml`, `firebase.json`, README | Hash/tag remotos pendentes |
| 3 | MVVM observável | `ListaPage` → `CatalogViewModel` → `CatalogRepository` → `FirestoreCatalogService` | Código presente |
| 4 | Loading, sucesso, vazio, erro, recuperação | `CatalogStatus`, `ListaPage`, `retry()` | Teste VM presente; capturas pendentes |
| 5 | Serviço externo e falhas | `OpenLibraryBookRepository`, VM de busca; fallback de preenchimento manual | Testes com resposta e HTTP 503 presentes |
| 6 | Cache/offline | `SharedPreferencesCatalogCache`, dados por UID, banner cache; escrita requer conexão | Código presente; captura offline pendente |
| 7 | Sessão e logout | Firebase Auth, `AuthGate`, `SignedInCatalogScreen`; logout remove cache privado | Testes de sessão existentes |
| 8 | CRUD e vínculo UID | `itens_catalogo`, serviço/repositório; query e criação associados ao UID | Regras permitem CRUD dono; teste instrumentado preparado |
| 9 | Segurança permitida/negada | `firestore.rules`; teste com dono, outro UID, anônimo, campos inválidos | `npm run test:rules` aprovado |
| 10 | Recurso nativo | `image_picker`, câmera/galeria, recusa com alternativa; foto somente em cache local | Implementação presente; captura em Android pendente |
| 11 | Unitários | `test/features/catalog_view_model_test.dart`, `open_library_book_repository_test.dart` | `flutter test`: 23 testes aprovados |
| 12 | Widget e integração | `test/screens/`, `integration_test/catalog_crud_flow_test.dart` | Widget aprovado; fluxo instrumentado ainda não executado |
| 13 | Análise e release | versão em `pubspec.yaml`, artefatos esperados no README | `flutter analyze` aprovado; builds bloqueados pela versão Java local; não atestar APK/AAB |

## 4. Arquitetura, serviço e offline

A View desenha catálogo e formulários. `CatalogViewModel` controla estados, erros, UID e comandos. `CatalogRepository` é o ponto de orquestração entre cache e Firestore; `FirestoreCatalogService` converte documentos. A busca externa usa Open Library com consulta limitada a seis resultados, timeout e tratamento de erros. O cache local recupera o catálogo antes da conexão remota, identificando sua origem e data. O app permite leitura do último cache offline e informa que alterações precisam de conexão; não implementa fila de sincronização de escrita.

## 5. Autenticação, CRUD e regras

Firebase Authentication usa e-mail/senha e mantém a sessão. As telas autenticadas são construídas pelo `AuthGate`. Cada item tem `ownerId`, e consultas filtram pelo UID corrente. `firestore.rules` valida campos, tamanhos e tipos; impede troca do proprietário e nega leitura/escrita de outras contas. O teste de regras comprova operações do dono e nega as tentativas de terceiros, anônimos e payloads inválidos.

## 6. Recurso nativo, privacidade e testes

A câmera e galeria usam `image_picker`. Se a permissão da câmera for negada, o fluxo oferece a galeria ou continuação sem foto. A foto é redimensionada e guardada no cache local segmentado por UID; não é enviada ao Firestore e o cache é removido no logout. Testes unitários cobrem transições do catálogo, falha/repetição, UID e conversão/resposta externa. Testes widget existentes cobrem telas e formulário. O teste instrumentado cobre cadastro, criação, edição e exclusão via emuladores e precisa ser executado em dispositivo/emulador antes da entrega.

## 7. Análise, versão, assinatura e fontes

Análise local executada: `flutter analyze` sem issues. Testes: `flutter test` aprovado; `npm run test:rules` aprovado. Regras/índices publicados no projeto `catalogopessoal-54703`. Versão: 1.0.0+1. Ainda faltam execução do teste instrumentado, APK/AAB atualizados, instalação do APK, chave de release própria, hashes, tag/hash remoto e capturas legíveis. O JDK instalado nesta máquina é 25; Gradle 8.13 requer JDK compatível e o build foi impedido pelo ambiente. O keystore não deve ser compartilhado ou versionado.

**Fontes técnicas:** documentação da [API Search da Open Library](https://openlibrary.org/dev/docs/api/search), [image_picker](https://pub.dev/packages/image_picker), [shared_preferences](https://pub.dev/packages/shared_preferences), [Flutter: migração Android Gradle Plugin](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin) e [regras do Firestore](https://firebase.google.com/docs/firestore/security/get-started).
