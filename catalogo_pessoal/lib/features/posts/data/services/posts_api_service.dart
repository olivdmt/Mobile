import 'dart:async';
import 'dart:convert';

import 'package:catalogo_pessoal/features/posts/data/models/post.dart';
import 'package:http/http.dart' as http;

enum ApiFailureKind { timeout, transport, http, format }

/// Erro controlado da fronteira HTTP, sem dependência da interface.
class ApiException implements Exception {
  final String message;
  final ApiFailureKind kind;
  final int? statusCode;

  const ApiException(this.message, {required this.kind, this.statusCode});

  @override
  String toString() => statusCode == null
      ? 'ApiException: $message'
      : 'ApiException: $message (HTTP $statusCode)';
}

/// Consome JSONPlaceholder. O proprietário do [client] é responsável por fechá-lo.
class PostsApiService {
  static const _baseUrl = 'jsonplaceholder.typicode.com';

  final http.Client _client;
  final Duration timeout;

  PostsApiService({
    required http.Client client,
    this.timeout = const Duration(seconds: 8),
  }) : _client = client;

  Future<List<Post>> buscarPosts({int? userId}) async {
    final uri = Uri.https(
      _baseUrl,
      '/posts',
      userId == null ? null : {'userId': '$userId'},
    );

    try {
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(timeout);

      if (response.statusCode != 200) {
        throw ApiException(
          'A API recusou a operação.',
          kind: ApiFailureKind.http,
          statusCode: response.statusCode,
        );
      }

      final body = utf8.decode(response.bodyBytes);
      return Post.listFromJson(body);
    } on TimeoutException {
      throw const ApiException(
        'Tempo de resposta excedido.',
        kind: ApiFailureKind.timeout,
      );
    } on http.ClientException {
      throw const ApiException(
        'Falha de conexão com o serviço.',
        kind: ApiFailureKind.transport,
      );
    } on FormatException {
      throw const ApiException(
        'A API retornou dados em formato inválido.',
        kind: ApiFailureKind.format,
      );
    }
  }
}
