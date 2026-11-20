class Task {
  const Task({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.ownerId,
  });

  final String id;
  final String title;
  final bool isCompleted;
  final String ownerId;

  Task copyWith({String? title, bool? isCompleted}) => Task(
    id: id,
    title: title ?? this.title,
    isCompleted: isCompleted ?? this.isCompleted,
    ownerId: ownerId,
  );
}
