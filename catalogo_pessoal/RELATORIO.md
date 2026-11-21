# Trabalho final Mobile II — Catálogo Pessoal

## 1. Identificação e produto

**Estudante:** Mateus Dayson de Oliveira  
**Matrícula:** 0031595  
**Turma:** ADS — Turma de Quarta 2025/2026  
**Autoria:** trabalho individual.  
**Produto:** Catálogo Pessoal, aplicativo Flutter para leitores e estudantes que querem organizar livros e referências, acompanhar seu status e consultar seus próprios registros.

O fluxo principal é cadastro/login, catálogo vazio ou carregado, inclusão de referência manual ou por busca, edição de metadados e estado, exclusão e logout. Cada pessoa acessa apenas os registros associados à sua conta. Fotos escolhidas ou capturadas são armazenadas no cache local; não são enviadas ao Firestore.

O apêndice visual do PDF contém capturas reais das telas de login e cadastro obtidas no Android Emulator, sem envio de credenciais.

## 2. Repositório, versão e reprodução

- Repositório: https://github.com/olivdmt/Mobile
- Diretório do aplicativo: `catalogo_pessoal/`
- Branch publicada: `codex/m2-final-work`
- Tag do aplicativo/release: `m2-final-v1.0.0` (`5014c214dbc6f31172fb090abe621b27946f7a55`)
- Tag das evidências e testes adicionais: `m2-evidencia-v1.0.1` (`6f3166aa2feb0baaf749f5f74e1a031f6fe04210`)
- Versão Flutter: `1.0.0+1`
- Ambiente validado: Flutter 3.47.0, Dart 3.13.0, JDK Temurin 21.0.13, Gradle 8.14.3, Android Gradle Plugin 8.13.2, Kotlin Gradle Plugin 2.4.0, Android Build Tools 36.0.0, NDK 28.2.13676358 e Node.js/Firebase CLI para emuladores.

Reprodução a partir da tag:

```sh
git clone https://github.com/olivdmt/Mobile.git
cd Mobile/catalogo_pessoal
git checkout m2-final-v1.0.0
flutter pub get
flutter run
```

Para testar isoladamente com Firebase, inicie Auth e Firestore pelos emuladores. Em release, configure um keystore próprio por `android/key.properties` ou pelas quatro variáveis `ANDROID_KEYSTORE_PATH`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` e `ANDROID_KEY_PASSWORD`; nenhum segredo está no Git. Consulte `README.md` para detalhes.

## 3. Arquitetura, estados, serviço Web e offline

A tela/View delega o estado e os comandos ao ViewModel; o Repository aplica UID e coordena cache e Firebase Service; os Services convertem dados externos. Os pontos principais estão em `lib/screens/`, `lib/features/catalog/presentation/view_models/catalog_view_model.dart`, `lib/features/catalog/data/repositories/catalog_repository.dart` e `lib/features/catalog/data/services/firestore_catalog_service.dart`.

`CatalogStatus` cobre loading, success, empty e failure. Falhas exibem ação `retry()`. O teste de widget `test/lista_page_test.dart` verifica loading, erro com ação de retry e o banner de cache offline; o teste unitário do ViewModel cobre vazio, sucesso, falha e retomada. A busca Open Library está em `lib/features/books/data/open_library_book_repository.dart`: limita a seis resultados, tem timeout, converte os dados e trata HTTP inválido/503; o preenchimento manual continua disponível.

`SharedPreferencesCatalogCache` persiste o último catálogo por UID. A tela mostra o cache e sinaliza a origem; o teste widget verifica o item local e o aviso de que gravações exigem rede. Não há fila offline de escrita. HTTP claro está liberado somente para debug, para conectar o Android Emulator a `10.0.2.2`; o manifest de release não habilita tráfego claro.

## 4. Autenticação, CRUD, UID e segurança

Firebase Authentication controla cadastro, login, persistência de sessão, rotas autenticadas e logout. `AuthGate` responde ao estado da sessão; o logout remove cache privado do usuário. `lib/features/auth/` contém Services, Repositories e ViewModels.

O catálogo persiste em `itens_catalogo/{id}`. Cada documento contém `ownerId`; o Repository fornece o UID corrente e a consulta Firestore filtra por ele. `firestore.rules` exige identidade autenticada, igualdade entre UID e proprietário e campos/tipos permitidos. O conjunto de regras permite operações do proprietário e nega usuário diferente, anônimo e payload inválido. O teste integrado Android com Auth/Firestore Emulator percorreu cadastro, criação, edição e exclusão com sucesso.

## 5. Recurso nativo, privacidade e testes

`lib/features/catalog/data/services/catalog_photo_picker.dart` usa `image_picker`, limita resolução e qualidade, e solicita somente os dados necessários. A imagem fica como dado local em cache por UID e é removida no logout; não é enviada ao Firestore. Se a permissão da câmera for negada, `lib/screens/formulario_page.dart` oferece abrir a galeria ou seguir sem foto. `test/screens/formulario_page_test.dart` injeta uma câmera negada e verifica as duas alternativas. A negação é simulada por um fake de teste; a sequência com a permissão real do Android continua sem captura e deixa este critério parcial.

Resultados registrados:

- `flutter analyze`: sem issues.
- `flutter test`: 25 testes unitários e widget aprovados após esta revisão.
- Testes direcionados atualizados: `flutter test test/lista_page_test.dart test/screens/formulario_page_test.dart test/features/catalog_view_model_test.dart` — 11 testes aprovados. A suíte exercita loading, falha recuperável, cache offline e permissão de câmera negada.
- `npm run test:rules`: operação permitida ao dono e recusas de segurança aprovadas.
- `firebase emulators:exec --project demo-catalogo-pessoal --only auth,firestore "flutter test integration_test/catalog_crud_flow_test.dart -d emulator-5554 --dart-define=USE_FIREBASE_EMULATORS=true"`: aprovado (`+1: All tests passed!`), incluindo cadastro, create, update e delete.
- APK release instalado com sucesso no Android Emulator. A jornada acima confirmou a interação funcional em debug, conectada aos emuladores Firebase.
- Capturas reais de login e cadastro adicionadas ao apêndice visual do PDF.

## 6. Matriz dos 13 critérios

| Nº | Evidência e localização | Estado |
|---:|---|---|
| 1 | Identificação, problema, público, fluxo e autoria nesta seção; capturas de login/cadastro no apêndice visual | Atendido |
| 2 | Repositório, tag, hash, ambiente e passos de reprodução na seção 2 | Atendido |
| 3 | View → ViewModel → Repository → Service, caminhos na seção 3 | Atendido |
| 4 | `CatalogStatus`, `retry()`, `test/features/catalog_view_model_test.dart` e teste widget de loading/erro com retry em `test/lista_page_test.dart` | Atendido |
| 5 | `OpenLibraryBookRepository` e testes de sucesso, conversão e falha HTTP | Atendido |
| 6 | Cache local por UID e teste widget `test/lista_page_test.dart`, com banner de origem e aviso de escrita conectada | Atendido |
| 7 | Firebase Auth, `AuthGate`, persistência e logout; capturas de login/cadastro e jornada Android aprovada | Atendido |
| 8 | CRUD Firestore com ownerId; fluxo instrumentado Android aprovado | Atendido |
| 9 | `firestore.rules`; testes owner permitido, outro UID/anônimo/payload inválido negados | Atendido |
| 10 | `image_picker`, teste simulado da negação, alternativas e privacidade; falta a sequência com permissão real no Android | Parcial |
| 11 | `test/features/catalog_view_model_test.dart`, `open_library_book_repository_test.dart`; suíte Flutter aprovada | Atendido |
| 12 | `test/screens/`, `test/widgets/` e `integration_test/catalog_crud_flow_test.dart`; aprovado em Android | Atendido |
| 13 | Análise, versão, assinatura, APK/AAB, hashes, instalação e commit/tag na seção 7 | Atendido |

Os diagramas explicam fluxos e responsabilidades do código. O apêndice contém capturas reais do app no emulador para login e cadastro. Loading, erro, cache offline e diálogo de câmera negada foram executados em testes widget; o estado vazio também tem teste. O critério 10 permanece parcial porque a permissão real do Android não foi negada em uma captura do emulador.

## 7. Release, verificação e fontes

Foram gerados APK e AAB assinados com o keystore de release local. O APK foi verificado pelo `apksigner` com assinatura v2 válida; o AAB foi verificado pelo `jarsigner` e está assinado pelo certificado de upload indicado abaixo. Como a chave é privada e autoassinada, a ausência de uma cadeia de CA confiável é esperada. O segredo do keystore está ignorado pelo Git e não aparece neste documento.

| Artefato | Caminho no projeto | Tamanho | SHA-256 |
|---|---|---:|---|
| APK | `build/app/outputs/flutter-apk/app-release.apk` | 55.925.983 bytes | `BE59B756169977BBD488522D99344D91E73271AE31C35BAB28356001DF4404B1` |
| AAB | `build/app/outputs/bundle/release/app-release.aab` | 56.362.836 bytes | `3E333EC1E7CB99E06272FC80F9E67DFE64321BB14E01DA1C173C96A7E8F55D1F` |

Certificado do APK/AAB: `CN=Mateus Dayson de Oliveira`; impressão SHA-256 `098a3717d8aa17a4850d1319bf981e151e062b9a3e49d47ec85099d6e962471b`. Release do app: tag `m2-final-v1.0.0`, commit `5014c214dbc6f31172fb090abe621b27946f7a55`. Os testes e evidências adicionais desta revisão estão na tag remota `m2-evidencia-v1.0.1`, commit `6f3166aa2feb0baaf749f5f74e1a031f6fe04210`; essa revisão alterou testes/documentação, sem modificar o código executável usado para gerar APK/AAB. APK instalado no emulador com `adb install -r`.

Fontes técnicas consultadas: [Open Library Search API](https://openlibrary.org/dev/docs/api/search), [image_picker](https://pub.dev/packages/image_picker), [shared_preferences](https://pub.dev/packages/shared_preferences), [regras de segurança do Firestore](https://firebase.google.com/docs/firestore/security/get-started), [FlutterFire e emuladores](https://firebase.google.com/docs/emulator-suite/connect_auth) e [Kotlin Gradle Plugin: compatibilidade](https://kotlinlang.org/docs/gradle-configure-project.html).
