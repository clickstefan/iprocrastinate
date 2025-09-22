import 'dart:html' as html;

void main() {
  iProcrastinateApp().init();
}

class Task {
  final String id;
  final String text;
  final DateTime createdAt;
  bool isCompleted;
  bool isSelected;

  Task({
    required this.id,
    required this.text,
    required this.createdAt,
    this.isCompleted = false,
    this.isSelected = false,
  });
}

class iProcrastinateApp {
  List<Task> tasks = [];
  int completedCount = 0;

  late html.Element taskCounter;
  late html.InputElement taskInput;
  late html.Element taskList;
  late html.ButtonElement addTaskBtn;
  late html.ButtonElement completeTaskBtn;
  late html.ButtonElement clearAllBtn;

  void init() {
    // Get DOM elements
    taskCounter = html.querySelector('#taskCounter')!;
    taskInput = html.querySelector('#taskInput') as html.InputElement;
    taskList = html.querySelector('#taskList')!;
    addTaskBtn = html.querySelector('#addTaskBtn') as html.ButtonElement;
    completeTaskBtn =
        html.querySelector('#completeTaskBtn') as html.ButtonElement;
    clearAllBtn = html.querySelector('#clearAllBtn') as html.ButtonElement;

    // Set up event listeners
    addTaskBtn.onClick.listen((_) => addTask());
    completeTaskBtn.onClick.listen((_) => completeSelectedTask());
    clearAllBtn.onClick.listen((_) => clearAllTasks());

    taskInput.onKeyPress.listen((event) {
      if (event.keyCode == 13) {
        // Enter key
        addTask();
      }
    });

    // Load saved data
    loadFromStorage();
    updateUI();

    print('iProcrastinate web app initialized!');
  }

  void addTask() {
    final text = taskInput.value?.trim() ?? '';
    if (text.isEmpty) return;

    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      createdAt: DateTime.now(),
    );

    tasks.add(task);
    taskInput.value = '';
    saveToStorage();
    updateUI();
  }

  void completeSelectedTask() {
    final selectedTask =
        tasks.where((task) => task.isSelected && !task.isCompleted).firstOrNull;
    if (selectedTask != null) {
      selectedTask.isCompleted = true;
      selectedTask.isSelected = false;
      completedCount++;
      saveToStorage();
      updateUI();
    }
  }

  void selectTask(String taskId) {
    // Deselect all tasks first
    for (var task in tasks) {
      task.isSelected = false;
    }

    // Select the clicked task
    final task = tasks.where((t) => t.id == taskId).firstOrNull;
    if (task != null && !task.isCompleted) {
      task.isSelected = true;
    }

    updateUI();
  }

  void clearAllTasks() {
    if (html.window.confirm('Are you sure you want to clear all tasks?')) {
      tasks.clear();
      saveToStorage();
      updateUI();
    }
  }

  void updateUI() {
    // Update counter
    taskCounter.text = completedCount.toString();

    // Update task list
    taskList.children.clear();

    if (tasks.isEmpty) {
      taskList.children.add(html.LIElement()
        ..className = 'empty-state'
        ..text = 'No tasks yet. Add one above!');
    } else {
      for (var task in tasks.reversed) {
        final taskElement = html.LIElement()
          ..className =
              'task-item ${task.isSelected ? 'selected' : ''} ${task.isCompleted ? 'completed' : ''}'
          ..onClick.listen((_) => selectTask(task.id));

        final taskText = html.SpanElement()
          ..className = 'task-text'
          ..text = task.text;

        final taskTime = html.SpanElement()
          ..className = 'task-time'
          ..text = _formatTime(task.createdAt);

        taskElement.children.addAll([taskText, taskTime]);
        taskList.children.add(taskElement);
      }
    }

    // Update button states
    final hasSelectedTask =
        tasks.any((task) => task.isSelected && !task.isCompleted);
    completeTaskBtn.disabled = !hasSelectedTask;
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void saveToStorage() {
    // Save to localStorage
    final taskData = tasks
        .map((task) => {
              'id': task.id,
              'text': task.text,
              'createdAt': task.createdAt.millisecondsSinceEpoch,
              'isCompleted': task.isCompleted,
            })
        .toList();

    html.window.localStorage['iprocrastinate_tasks'] = taskData.toString();
    html.window.localStorage['iprocrastinate_completed_count'] =
        completedCount.toString();
  }

  void loadFromStorage() {
    try {
      final completedCountStr =
          html.window.localStorage['iprocrastinate_completed_count'];
      if (completedCountStr != null) {
        completedCount = int.tryParse(completedCountStr) ?? 0;
      }

      // For now, start fresh each session - can implement proper JSON parsing later
      tasks = [];
    } catch (e) {
      print('Error loading from storage: $e');
      tasks = [];
      completedCount = 0;
    }
  }
}
