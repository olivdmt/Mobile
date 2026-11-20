import 'package:catalogo_pessoal/features/auth/data/repositories/auth_repository.dart';
import 'package:catalogo_pessoal/features/auth/data/services/firebase_auth_service.dart';
import 'package:catalogo_pessoal/features/auth/presentation/views/auth_gate.dart';
import 'package:catalogo_pessoal/features/tasks/data/repositories/task_repository.dart';
import 'package:catalogo_pessoal/features/tasks/data/services/firestore_task_service.dart';
import 'package:catalogo_pessoal/features/catalog/data/repositories/catalog_repository.dart';
import 'package:catalogo_pessoal/features/catalog/data/services/firestore_catalog_service.dart';
import 'package:catalogo_pessoal/features/catalog/data/services/local_catalog_cache.dart';
import 'package:catalogo_pessoal/features/catalog/data/services/catalog_photo_picker.dart';
import 'package:catalogo_pessoal/features/books/data/open_library_book_repository.dart';
import 'package:catalogo_pessoal/firebase_options.dart';
import 'package:catalogo_pessoal/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _useFirebaseEmulators = bool.fromEnvironment(
  'USE_FIREBASE_EMULATORS',
  defaultValue: false,
);
const _configuredFirebaseEmulatorHost = String.fromEnvironment(
  'FIREBASE_EMULATOR_HOST',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (_useFirebaseEmulators) {
      final defaultHost = defaultTargetPlatform == TargetPlatform.android
          ? '10.0.2.2'
          : '127.0.0.1';
      final host = _configuredFirebaseEmulatorHost.isEmpty
          ? defaultHost
          : _configuredFirebaseEmulatorHost;
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);
      FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    }

    final repository = FirebaseAuthRepository(
      FirebaseAuthService(FirebaseAuth.instance),
    );
    final taskRepository = FirestoreTaskRepository(
      FirestoreTaskService(FirebaseFirestore.instance),
      repository,
    );
    final catalogRepository = FirestoreCatalogRepository(
      FirestoreCatalogService(FirebaseFirestore.instance),
      SharedPreferencesCatalogCache(SharedPreferencesAsync()),
    );
    runApp(
      CatalogoApp(
        authRepository: repository,
        taskRepository: taskRepository,
        catalogRepository: catalogRepository,
        bookSearchRepository: OpenLibraryBookRepository(),
        photoPicker: ImagePickerCatalogPhotoPicker(),
      ),
    );
  } catch (error, stackTrace) {
    debugPrint('Firebase initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
    runApp(const CatalogoApp(configurationNeeded: true));
  }
}

class CatalogoApp extends StatelessWidget {
  const CatalogoApp({
    this.authRepository,
    this.taskRepository,
    this.catalogRepository,
    this.bookSearchRepository,
    this.photoPicker,
    this.configurationNeeded = false,
    super.key,
  });

  final AuthRepository? authRepository;
  final TaskRepository? taskRepository;
  final CatalogRepository? catalogRepository;
  final BookSearchRepository? bookSearchRepository;
  final CatalogPhotoPicker? photoPicker;
  final bool configurationNeeded;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Catálogo Pessoal',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.lightTheme,
    home:
        authRepository != null &&
            taskRepository != null &&
            catalogRepository != null
        ? AuthGate(
            repository: authRepository!,
            taskRepository: taskRepository!,
            catalogRepository: catalogRepository!,
            bookSearchRepository: bookSearchRepository!,
            photoPicker: photoPicker!,
          )
        : configurationNeeded
        ? const FirebaseSetupScreen()
        : const Scaffold(body: Center(child: CircularProgressIndicator())),
  );
}

class FirebaseSetupScreen extends StatelessWidget {
  const FirebaseSetupScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Configurar Firebase')),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_outlined, size: 56),
                SizedBox(height: 20),
                Text(
                  'O app precisa de uma configuração Firebase de desenvolvimento.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 12),
                Text(
                  'Rode `flutterfire configure` e selecione o projeto de '
                  'desenvolvimento para gerar lib/firebase_options.dart. '
                  'Habilite Email/Password em Authentication no Firebase '
                  'Console e crie o banco Cloud Firestore. Para usar os '
                  'emuladores, inicie-os com '
                  '`firebase emulators:start --project ID_DO_PROJETO '
                  '--only auth,firestore` e execute o app com '
                  '`--dart-define=USE_FIREBASE_EMULATORS=true`. Não conecte este '
                  'build a um projeto de produção.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
