# Trabalho final Mobile II — Catálogo Pessoal

## 1. Identificação e produto

**Estudante:** Mateus Dayson de Oliveira  
**Matrícula:** 0031595  
**Turma:** ADS — Turma de Quarta 2025/2026  
**Autoria:** trabalho individual.  
**Produto:** Catálogo Pessoal, aplicativo Flutter para leitores e estudantes que querem organizar livros e referências, acompanhar seu status e consultar seus próprios registros.

O fluxo principal é cadastro/login, catálogo vazio ou carregado, inclusão de referência manual ou por busca, edição de metadados e estado, exclusão e logout. Cada pessoa acessa apenas os registros associados à sua conta. Fotos escolhidas ou capturadas são armazenadas no cache local; não são enviadas ao Firestore.

### Escopo, limitações e evolução

**Implementado:** autenticação, catálogo pessoal com CRUD por UID, busca Open Library, cache local de leitura, foto em cache privado, testes unitários/widget e fluxo integrado. **Limite funcional:** gravações exigem conexão; não há fila de sincronização offline. **Evolução:** sincronização de escrita com resolução de conflitos e cache para consultas externas.

O apêndice visual contém capturas reais de login, cadastro e das quatro operações CRUD no Android Emulator com Firebase Emulator Suite. O usuário de teste tem endereço `example.test` e não usa credenciais pessoais.

## 2. Repositório, versão e reprodução

- Repositório: https://github.com/olivdmt/Mobile
- Diretório do aplicativo: `catalogo_pessoal/`
- Branch publicada: `codex/m2-final-report`
- Versão do aplicativo avaliada: tag `m2-final-v1.1.1`, commit `9269620c6429a1a6ac1ef7fb98a2e73c988753d5`.
- Revisão final deste relatório e teste widget adicional: tag de entrega `m2-final-v1.1.2`.
- Proveniência do release binário: `m2-final-v1.0.0` (`5014c214dbc6f31172fb090abe621b27946f7a55`); a revisão final não altera código executável, conforme comparação entre tags.
- Versão Flutter: `1.0.0+1`
- Ambiente validado: Flutter 3.47.0, Dart 3.13.0, JDK Temurin 21.0.13, Gradle 8.14.3, Android Gradle Plugin 8.13.2, Kotlin Gradle Plugin 2.4.0, Android Build Tools 36.0.0, NDK 28.2.13676358 e Node.js/Firebase CLI para emuladores.

Reprodução a partir da tag:

```sh
git clone https://github.com/olivdmt/Mobile.git
cd Mobile/catalogo_pessoal
git checkout m2-final-v1.1.2
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

**Cenário A/B nas regras:** no Firestore Emulator local (`demo-catalogo-pessoal`, `127.0.0.1:8080`), Alice (`uid=alice`) cria e consulta `itens_catalogo/item-1` com `ownerId=alice`; a operação é permitida. Bob (`uid=bob`) tenta ler o mesmo documento; o backend nega a leitura. Uma tentativa de Alice de transferir o `ownerId` para Bob também é negada. As regras são avaliadas no backend em cada requisição, independentemente das restrições da interface. Em `firestore.rules`, `signedIn` está na linha 4, `ownsExisting` nas linhas 8–11, `ownsIncoming` nas linhas 13–16 e as permissões de `itens_catalogo` nas linhas 76–88. O teste `test/firestore_rules.test.mjs` declara Alice/Bob nas linhas 33–34 e verifica create/read/update/delete e as recusas do catálogo nas linhas 90–118.

## 5. Recurso nativo, privacidade e testes

`lib/features/catalog/data/services/catalog_photo_picker.dart` usa `image_picker`, limita resolução e qualidade, e solicita somente os dados necessários. A imagem fica como dado local em cache por UID e é removida no logout; não é enviada ao Firestore. Se a permissão da câmera for negada, `lib/screens/formulario_page.dart` oferece abrir a galeria ou seguir sem foto. `test/screens/formulario_page_test.dart` cobre as duas alternativas com uma câmera negada simulada. Além do teste, o fluxo foi executado no Android Emulator: a permissão foi negada no diálogo real do sistema e o app mostrou o fallback. As duas capturas estão no apêndice visual do PDF.

Resultados verificados nesta revisão (27–28/11/2026):

- `dart format --output=none --set-exit-if-changed lib test integration_test` (revisão anterior): `Formatted 53 files (0 changed)`; nesta revisão, `dart format integration_test/catalog_crud_flow_test.dart integration_test/driver.dart` formatou os dois arquivos do fluxo de captura.
- `flutter analyze --no-pub`: `No issues found! (ran in 20.4s)`.
- `flutter test --no-pub --reporter expanded --concurrency=1` (28/11/2026): `+28: All tests passed!`.
- Cenários unitários relevantes: transições loading/empty/success e proveniência do cache; falha no stream e retry; create/update/delete e limpeza de cache por UID; conversão de resposta Open Library e falha 503; restauração de sessão e logout.
- Cenários widget: estado vazio; itens carregados; loading/erro/retry/cache offline; validação do formulário; modo edição; câmera negada com alternativas. `test/evidence_states_test.dart` verifica cache offline, resultado Open Library simulado e erro HTTP 503 com retry; as verificações estão resumidas na página 12, sem serem apresentadas como capturas do app.

O fluxo integrado foi executado nesta revisão no Pixel 9a API 36 com Auth/Firestore Emulator local: cadastro de usuário de teste, criação, leitura, edição e exclusão. `integration_test/driver.dart` salvou as quatro telas em `output/evidencias/crud/`; elas aparecem nas páginas 9–10. A integração terminou com `+1: All tests passed!`. Em 28/11/2026, `flutter test --no-pub test/evidence_states_test.dart` passou nos três cenários widget detalhados na página 12. Open Library usa `MockClient` (sem chamada ao vivo); os outros casos verificam o catálogo em cache e o estado HTTP 503 com retry.
## 6. Matriz dos 13 critérios

| Nº | Evidência no PDF | Arquivo, classe ou regra | Evidência disponível |
|---:|---|---|---|
| 1 | p.1–2, seção 1; p.8, figuras 5–6 | `RELATORIO.md`, seção 1; `lib/features/auth/presentation/views/sign_in_screen.dart`; telas de cadastro | Produto, problema, público, autoria e fluxo |
| 2 | p.1–2, seção 2; p.7, reprodução | `README.md`; `pubspec.yaml`; tag `m2-final-v1.1.1`, commit `9269620c6429a1a6ac1ef7fb98a2e73c988753d5` | Repositório, ambiente e comandos |
| 3 | p.2, figura 1 e tabela de rastreabilidade | `lib/screens/lista_page.dart`; `lib/features/catalog/presentation/view_models/catalog_view_model.dart`; `lib/features/catalog/data/repositories/catalog_repository.dart`; `lib/features/catalog/data/services/firestore_catalog_service.dart` | View → ViewModel → Repository → Service |
| 4 | p.3, estados; p.5 e p.12 | `catalog_view_model.dart`; `test/lista_page_test.dart`; `test/features/catalog_view_model_test.dart`; `test/evidence_states_test.dart` | Estados e retry verificados por testes |
| 5 | p.3, seção serviço; p.5 e p.12 | `lib/features/books/data/open_library_book_repository.dart`; `test/features/open_library_book_repository_test.dart`; `test/evidence_states_test.dart` | Conversão e HTTP 503 com MockClient; sem chamada ao vivo |
| 6 | p.3, estratégia offline; p.5 e p.12 | `lib/features/catalog/data/services/local_catalog_cache.dart`; `test/lista_page_test.dart`; `test/features/catalog_view_model_test.dart`; `test/evidence_states_test.dart` | Cache por UID e origem verificadas em teste |
| 7 | p.4, figura 3; p.8, figuras 5–6 | `lib/features/auth/`; `test/features/auth_session_view_model_test.dart`; `AuthGate` | Login/cadastro capturados; sessão/logout cobertos por teste |
| 8 | p.4; p.9–10, figuras 7–10 | `lib/features/catalog/data/repositories/catalog_repository.dart`; `lib/features/catalog/data/services/firestore_catalog_service.dart`; `integration_test/catalog_crud_flow_test.dart`; `integration_test/driver.dart`; `output/evidencias/crud/*.png` | Create/read/update/delete no Android Emulator com Firebase Emulator; quatro capturas reais |
| 9 | p.4, tabela A/B e linhas 76–88 | `firestore.rules:4–16,76–88`; `test/firestore_rules.test.mjs:33–34,90–118` | Alice permitida; Bob, anônimo e payload inválido negados |
| 10 | p.5; p.11 | `lib/features/catalog/data/services/catalog_photo_picker.dart`; `lib/screens/formulario_page.dart`; `test/screens/formulario_page_test.dart` | Permissão Android real negada, alternativas e privacidade |
| 11 | p.5, saída do Flutter Test | `test/features/catalog_view_model_test.dart`; `test/features/open_library_book_repository_test.dart`; `test/models/item_catalogo_test.dart`; `test/evidence_states_test.dart` | Suíte atual: 28 testes aprovados |
| 12 | p.5, resultados; p.9–10, p.12 | `test/lista_page_test.dart`; `test/evidence_states_test.dart`; `test/screens/`; `test/widgets/`; `integration_test/catalog_crud_flow_test.dart`; `integration_test/driver.dart` | Widget e integração aprovados; quatro capturas CRUD |
| 13 | p.5 e p.7, artefatos e hashes | `build/app/outputs/flutter-apk/app-release.apk`; `build/app/outputs/bundle/release/app-release.aab`; `android/app/build.gradle.kts` | Hashes/assinatura registrados; instalação ocorreu na revisão anterior |

A matriz localiza as evidências e distingue teste automatizado, captura real e lacuna visual. Ela não atribui nota; a avaliação final cabe à rubrica.

Os diagramas explicam fluxos e responsabilidades do código. O apêndice contém capturas reais para login, cadastro, criação, leitura, edição, exclusão, solicitação de câmera e fallback após a negação real. Loading, erro e cache offline são comprovados pelos testes; o estado vazio tem teste widget.

## 7. Release, verificação e fontes

Foram gerados APK e AAB assinados com o keystore de release local. O APK foi verificado pelo `apksigner` com assinatura v2 válida; o AAB foi verificado pelo `jarsigner` e está assinado pelo certificado de upload indicado abaixo. Como a chave é privada e autoassinada, a ausência de uma cadeia de CA confiável é esperada. O segredo do keystore está ignorado pelo Git e não aparece neste documento.

| Artefato | Caminho no projeto | Tamanho | SHA-256 |
|---|---|---:|---|
| APK | `build/app/outputs/flutter-apk/app-release.apk` | 55.925.983 bytes | `BE59B756169977BBD488522D99344D91E73271AE31C35BAB28356001DF4404B1` |
| AAB | `build/app/outputs/bundle/release/app-release.aab` | 56.362.836 bytes | `3E333EC1E7CB99E06272FC80F9E67DFE64321BB14E01DA1C173C96A7E8F55D1F` |

Certificado do APK/AAB: `CN=Mateus Dayson de Oliveira`; impressão SHA-256 `098a3717d8aa17a4850d1319bf981e151e062b9a3e49d47ec85099d6e962471b`. Os binários foram gerados na tag `m2-final-v1.0.0`, commit `5014c214dbc6f31172fb090abe621b27946f7a55`. A comparação entre a tag de release e a avaliação final mostra árvores idênticas para `lib/` (`eee66528a332afa4774242b79ab39d97a0f2900c`) e `android/` (`46fd4c203f8f44dd7a8a74195f4a832944d19cf8`), além do mesmo blob `pubspec.yaml` (`5fe22cda7ae3327e0130835a74aadc8f96b276b0`). Portanto, as mudanças finais em testes, capturas e documentação não alteram o código usado nos binários. A tag de entrega `m2-final-v1.1.2` inclui esta revisão do relatório, PDF, teste widget e os arquivos versionados da integração CRUD.

### Decisão técnica, dificuldade e solução

Decisão técnica: o cache atende leitura offline, separado por UID; escritas exigem rede. Dificuldade e solução no ambiente de integração: **sintoma** — o Firebase Emulator avisava que o projeto solicitado (`demo-catalogo-pessoal`) diferia do ID configurado no app (`catalogopessoal-54703`); **causa** — o comando de teste usava um ID de demonstração diferente de `firebase_options.dart`; **correção** — ajustei o comando reproduzível para usar o mesmo ID do app e confirmei que o Emulator iniciou sem o aviso de divergência. A limpeza do cache no logout também está coberta pelos testes de sessão e ViewModel.

### Declaração de autoria

Declaro que este trabalho foi desenvolvido individualmente e que as evidências descritas correspondem aos arquivos e resultados indicados neste relatório.

**Mateus Dayson de Oliveira · Matrícula 0031595**  
Assinatura do autor: ____________________________________  Data: ____/____/2026

Fontes técnicas consultadas: [Open Library Search API](https://openlibrary.org/dev/docs/api/search), [image_picker](https://pub.dev/packages/image_picker), [shared_preferences](https://pub.dev/packages/shared_preferences), [regras de segurança do Firestore](https://firebase.google.com/docs/firestore/security/get-started), [FlutterFire e emuladores](https://firebase.google.com/docs/emulator-suite/connect_auth) e [Kotlin Gradle Plugin: compatibilidade](https://kotlinlang.org/docs/gradle-configure-project.html).
