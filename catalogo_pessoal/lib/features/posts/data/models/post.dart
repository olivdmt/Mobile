import 'dart:convert';

/// Representação tipada de um post da API JSONPlaceholder.
class Post {
  final int id;
  final int userId;
  final String title;
  final String body;

  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final userId = json['userId'];
    final title = json['title'];
    final body = json['body'];

    if (id is! int || userId is! int || title is! String || body is! String) {
      throw const FormatException('Post contém campos ausentes ou inválidos.');
    }

    return Post(id: id, userId: userId, title: title, body: body);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'body': body,
  };

  static List<Post> listFromJson(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! List) {
      throw const FormatException('Esperada uma lista de posts.');
    }

    return decoded
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException(
              'Post da lista possui formato inválido.',
            );
          }
          return Post.fromJson(item);
        })
        .toList(growable: false);
  }
}
