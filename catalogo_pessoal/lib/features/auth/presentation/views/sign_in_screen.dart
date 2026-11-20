import 'package:flutter/material.dart';

import 'package:catalogo_pessoal/features/auth/data/repositories/auth_repository.dart';
import 'package:catalogo_pessoal/features/auth/presentation/view_models/auth_form_view_model.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({required this.repository, super.key});

  final AuthRepository repository;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  late final AuthFormViewModel _viewModel;
  bool _creatingAccount = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _viewModel = AuthFormViewModel(widget.repository);
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Informe o e-mail.';
    if (!email.contains('@')) return 'Confira o e-mail informado.';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Informe a senha.';
    if (value.length < 6) return 'Use pelo menos 6 caracteres.';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_creatingAccount) {
      await _viewModel.signUp(_email.text.trim(), _password.text);
    } else {
      await _viewModel.signIn(_email.text.trim(), _password.text);
    }
    if (!mounted) return;
    final failure = _viewModel.failure;
    if (failure != null) _showMessage(failure.publicMessage);
  }

  Future<void> _sendReset() async {
    final email = _email.text.trim();
    if (_validateEmail(email) != null) {
      _showMessage('Informe um e-mail válido para receber as instruções.');
      return;
    }
    await _viewModel.requestPasswordReset(email);
    if (!mounted) return;
    if (_viewModel.failure == null) {
      _showMessage(
        'Se houver uma conta compatível, enviaremos instruções para esse endereço.',
      );
    } else {
      _showMessage(_viewModel.failure!.publicMessage);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo Pessoal')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AnimatedBuilder(
                animation: _viewModel,
                builder: (context, _) => Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.auto_stories,
                        size: 56,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _creatingAccount ? 'Criar conta' : 'Entrar no catálogo',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _password,
                        obscureText: _obscurePassword,
                        autofillHints: _creatingAccount
                            ? const [AutofillHints.newPassword]
                            : const [AutofillHints.password],
                        textInputAction: _creatingAccount
                            ? TextInputAction.next
                            : TextInputAction.done,
                        onFieldSubmitted: (_) {
                          if (!_creatingAccount) _submit();
                        },
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? 'Mostrar senha'
                                : 'Ocultar senha',
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: _validatePassword,
                      ),
                      if (_creatingAccount) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmation,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            labelText: 'Confirme a senha',
                            prefixIcon: Icon(Icons.lock_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirme a senha.';
                            }
                            if (value != _password.text) {
                              return 'As senhas não conferem.';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _viewModel.isLoading ? null : _submit,
                        child: _viewModel.isLoading
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(_creatingAccount ? 'Cadastrar' : 'Entrar'),
                      ),
                      if (!_creatingAccount)
                        TextButton(
                          onPressed: _viewModel.isLoading ? null : _sendReset,
                          child: const Text('Esqueci minha senha'),
                        ),
                      TextButton(
                        onPressed: _viewModel.isLoading
                            ? null
                            : () => setState(() {
                                _creatingAccount = !_creatingAccount;
                                _viewModel.clearFailure();
                              }),
                        child: Text(
                          _creatingAccount
                              ? 'Já tenho uma conta. Entrar'
                              : 'Criar uma conta',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
