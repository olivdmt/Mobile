import 'package:catalogo_pessoal/features/posts/data/models/post.dart';
import 'package:catalogo_pessoal/features/posts/data/services/posts_api_service.dart';

abstract interface class PostsRepository {
  Future<List<Post>> listar({int? userId});
}

class PostsRepositoryRemoto implements PostsRepository {
  final PostsApiService _service;

  const PostsRepositoryRemoto(this._service);

  @override
  Future<List<Post>> listar({int? userId}) =>
      _service.buscarPosts(userId: userId);
}
