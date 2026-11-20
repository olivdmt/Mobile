# Catálogo Pessoal — Mobile II

Aplicativo Flutter para leitores organizarem livros e outras referências. A conta identifica o proprietário dos registros; o catálogo é salvo no Cloud Firestore e mantido em cache local por usuário. A busca opcional de livros consulta a Open Library. Fotografias escolhidas/capturadas permanecem no cache local e não são enviadas ao Firestore.

## Requisitos

- Flutter/Dart compatível com `pubspec.yaml` (`flutter --version`)
- JDK 17 ou superior (JDK 21 recomendado)
- Node.js e Firebase CLI para os testes/deploy de regras
- Projeto Firebase de desenvolvimento com Email/Senha habilitado e Cloud Firestore criado

## Executar

```sh
flutter pub get
flutter run
```

O projeto Firebase registrado nesta cópia é `catalogopessoal-54703`. Para desenvolvimento isolado, configure `.firebaserc` com o projeto de teste/emulador e rode:

```sh
firebase emulators:start --project demo-catalogo-pessoal --only auth,firestore
flutter run --dart-define=USE_FIREBASE_EMULATORS=true
```

No Android Emulator, o app usa `10.0.2.2`; em web/desktop usa `127.0.0.1`. Não use `demo-catalogo-pessoal` com credenciais ou dados de produção.

## Arquitetura e comportamento

`ListaPage` (View) renderiza lista, vazio, loading, falha e cache offline. `CatalogViewModel` coordena sessão, comandos e estados. `CatalogRepository` aplica UID, mantém cache, reconcilia a foto local e acessa `FirestoreCatalogService`. Os documentos estão em `itens_catalogo/{id}` e carregam `ownerId`, título, categoria, descrição, status, favorito e timestamps. Regras em `firestore.rules` permitem CRUD somente ao proprietário e validam campos/tipos; o índice composto está em `firestore.indexes.json`.

`OpenLibraryBookRepository` chama `https://openlibrary.org/search.json`, limita a busca a seis resultados e trata timeout, falha HTTP e resposta inválida. A falha não impede cadastro manual. A câmera/galeria usam `image_picker`; a recusa da câmera oferece galeria ou continuidade sem foto. As imagens são reduzidas e serializadas no cache privado por UID. Logout remove esse cache.

## Testes e qualidade

```sh
flutter analyze
flutter test
npm ci
npm run test:rules
```

O fluxo instrumentado cobre cadastro, criação, edição e exclusão no emulador. HTTP claro fica habilitado somente no manifest debug para alcançar os emuladores locais; o manifest release não permite essa configuração.

```sh
firebase emulators:exec --project demo-catalogo-pessoal --only auth,firestore "flutter test integration_test/catalog_crud_flow_test.dart -d emulator-5554 --dart-define=USE_FIREBASE_EMULATORS=true"
```

`test/` contém testes unitários, de widget e das regras. Os testes de integração exigem dispositivo/emulador Android conectado e os emuladores Firebase ativos.

## Release Android

```sh
flutter build apk --release
flutter build appbundle --release
```

Sem configuração, os builds usam a chave debug e servem apenas para instalação local. Para distribuição assinada, gere uma chave própria com `keytool`, mantenha `upload-keystore.jks` e `key.properties` fora do Git e preencha `android/key.properties` (ou defina `ANDROID_KEYSTORE_PATH`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` e `ANDROID_KEY_PASSWORD`). Nunca publique as senhas. Artefatos esperados: `build/app/outputs/flutter-apk/app-release.apk` e `build/app/outputs/bundle/release/app-release.aab`. O release desta versão foi assinado com chave de upload privada, verificado com `apksigner`/`jarsigner` e instalado no emulador. Os SHA-256 e a versão remota são registrados no relatório final.

## Rastreamento da entrega

Versão do app: `1.0.0+1`. Repositório: [olivdmt/Mobile](https://github.com/olivdmt/Mobile), subdiretório `catalogo_pessoal/`. A versão tagueada e os hashes de release são informados no relatório final. As credenciais de assinatura ficam fora do Git.
