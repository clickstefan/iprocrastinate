import 'dart:html' as html;
import 'dart:convert';
import 'dart:async';

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

  // Convert Task to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
      'isSelected': isSelected,
    };
  }

  // Create Task from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      text: json['text'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      isCompleted: json['isCompleted'] as bool? ?? false,
      isSelected: json['isSelected'] as bool? ?? false,
    );
  }
}

class NotificationSettings {
  bool enabled;
  List<String> times;
  List<int> weekdays;

  NotificationSettings({
    this.enabled = false,
    List<String>? times,
    List<int>? weekdays,
  })  : times = times ?? ['09:00'],
        weekdays = weekdays ?? [1, 2, 3, 4, 5]; // Mon-Fri by default

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'times': times,
      'weekdays': weekdays,
    };
  }

  // Create from JSON
  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enabled: json['enabled'] as bool? ?? false,
      times: (json['times'] as List<dynamic>?)?.cast<String>() ?? ['09:00'],
      weekdays:
          (json['weekdays'] as List<dynamic>?)?.cast<int>() ?? [1, 2, 3, 4, 5],
    );
  }
}

class iProcrastinateApp {
  List<Task> tasks = [];
  int completedCount = 0;
  NotificationSettings notificationSettings = NotificationSettings();

  late html.Element taskCounter;
  late html.InputElement taskInput;
  late html.Element taskList;
  late html.ButtonElement addTaskBtn;
  late html.ButtonElement completeTaskBtn;
  late html.ButtonElement clearAllBtn;

  // Notification UI elements
  late html.CheckboxInputElement notificationToggle;
  late html.Element notificationConfig;
  late html.Element timePickers;
  late html.ButtonElement addTimeBtn;
  late html.Element notificationStatus;

  void init() {
    // Get DOM elements
    taskCounter = html.querySelector('#taskCounter')!;
    taskInput = html.querySelector('#taskInput') as html.InputElement;
    taskList = html.querySelector('#taskList')!;
    addTaskBtn = html.querySelector('#addTaskBtn') as html.ButtonElement;
    completeTaskBtn =
        html.querySelector('#completeTaskBtn') as html.ButtonElement;
    clearAllBtn = html.querySelector('#clearAllBtn') as html.ButtonElement;

    // Get notification DOM elements
    notificationToggle =
        html.querySelector('#notificationToggle') as html.CheckboxInputElement;
    notificationConfig = html.querySelector('#notificationConfig')!;
    timePickers = html.querySelector('#timePickers')!;
    addTimeBtn = html.querySelector('#addTimeBtn') as html.ButtonElement;
    notificationStatus = html.querySelector('#notificationStatus')!;

    // Set up event listeners
    addTaskBtn.onClick.listen((_) => addTask());
    completeTaskBtn.onClick.listen((_) => completeSelectedTask());
    clearAllBtn.onClick.listen((_) => clearAllTasks());

    // Notification event listeners
    notificationToggle.onChange.listen((_) {
      print('Notification toggle clicked: ${notificationToggle.checked}');
      toggleNotifications();
    });
    addTimeBtn.onClick.listen((_) {
      print('Add time button clicked');
      addTimeSlot();
    });

    // Set up event delegation for remove buttons
    timePickers.onClick.listen((event) {
      final target = event.target as html.Element?;
      if (target?.getAttribute('data-action') == 'remove') {
        removeTimeSlot(target!);
      }
    });

    taskInput.onKeyPress.listen((event) {
      if (event.keyCode == 13) {
        // Enter key
        addTask();
      }
    });

    // Load saved data
    loadFromStorage();
    updateUI();
    updateNotificationUI();

    print('iProcrastinate web app initialized!');
    print('Notification toggle element: ${notificationToggle}');
    print('Notification config element: ${notificationConfig}');
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
    try {
      // Save tasks as JSON
      final taskDataList = tasks.map((task) => task.toJson()).toList();
      final tasksJson = jsonEncode(taskDataList);
      html.window.localStorage['iprocrastinate_tasks'] = tasksJson;

      // Save completed count
      html.window.localStorage['iprocrastinate_completed_count'] =
          completedCount.toString();

      // Save notification settings
      final notificationJson = jsonEncode(notificationSettings.toJson());
      html.window.localStorage['iprocrastinate_notifications'] =
          notificationJson;

      print('Tasks saved to localStorage: ${tasks.length} tasks');
    } catch (e) {
      print('Error saving to storage: $e');
    }
  }

  void loadFromStorage() {
    try {
      // Load completed count
      final completedCountStr =
          html.window.localStorage['iprocrastinate_completed_count'];
      if (completedCountStr != null) {
        completedCount = int.tryParse(completedCountStr) ?? 0;
      }

      // Load tasks from JSON
      final tasksJsonStr = html.window.localStorage['iprocrastinate_tasks'];
      if (tasksJsonStr != null && tasksJsonStr.isNotEmpty) {
        final List<dynamic> tasksJsonList = jsonDecode(tasksJsonStr);
        tasks = tasksJsonList
            .map((taskJson) => Task.fromJson(taskJson as Map<String, dynamic>))
            .toList();

        // Reset selected state on load (don't persist selection across sessions)
        for (var task in tasks) {
          task.isSelected = false;
        }

        print('Tasks loaded from localStorage: ${tasks.length} tasks');
      } else {
        tasks = [];
        print('No saved tasks found, starting fresh');
      }

      // Load notification settings
      final notificationJsonStr =
          html.window.localStorage['iprocrastinate_notifications'];
      if (notificationJsonStr != null && notificationJsonStr.isNotEmpty) {
        final notificationJson =
            jsonDecode(notificationJsonStr) as Map<String, dynamic>;
        notificationSettings = NotificationSettings.fromJson(notificationJson);
        print('Notification settings loaded');
      }
    } catch (e) {
      print('Error loading from storage: $e');
      tasks = [];
      completedCount = 0;
      notificationSettings = NotificationSettings();
    }
  }

  // Notification Methods
  Future<void> toggleNotifications() async {
    if (notificationToggle.checked == true) {
      // Show configuration immediately
      notificationConfig.style.display = 'block';
      notificationStatus.text = 'Requesting notification permission...';

      // Request permission
      final permission = await requestNotificationPermission();
      if (permission) {
        notificationSettings.enabled = true;
        notificationStatus.text =
            'Notifications enabled! You\'ll receive reminders at selected times.';
        scheduleNotifications();
      } else {
        notificationSettings.enabled = false;
        notificationStatus.text =
            'Permission denied. You can still configure times, but notifications won\'t work until you enable them in browser settings.';
      }
    } else {
      notificationSettings.enabled = false;
      notificationConfig.style.display = 'none';
      notificationStatus.text =
          'Click "Enable reminders" to set up notifications';
      cancelNotifications();
    }
    saveToStorage();
  }

  Future<bool> requestNotificationPermission() async {
    try {
      if (html.Notification.supported) {
        final permission = await html.Notification.requestPermission();
        return permission == 'granted';
      }
      return false;
    } catch (e) {
      print('Error requesting notification permission: $e');
      return false;
    }
  }

  void addTimeSlot() {
    final timePickerHtml = '''
      <div class="time-picker-item">
        <input type="time" class="time-input" value="12:00">
        <button class="remove-time-btn" data-action="remove">×</button>
      </div>
    ''';
    timePickers.insertAdjacentHtml('beforeend', timePickerHtml);
    updateNotificationTimes();
  }

  void removeTimeSlot(html.Element button) {
    if (timePickers.children.length > 1) {
      button.parent?.remove();
      updateNotificationTimes();
    }
  }

  void updateNotificationTimes() {
    final timeInputs = timePickers.querySelectorAll('.time-input');
    notificationSettings.times = timeInputs
        .map((input) => (input as html.InputElement).value ?? '09:00')
        .toList();
    saveToStorage();
    scheduleNotifications();
  }

  void updateNotificationUI() {
    notificationToggle.checked = notificationSettings.enabled;
    notificationConfig.style.display =
        notificationSettings.enabled ? 'block' : 'none';

    // Update time pickers
    timePickers.children.clear();
    for (final time in notificationSettings.times) {
      final timePickerHtml = '''
        <div class="time-picker-item">
          <input type="time" class="time-input" value="$time">
          <button class="remove-time-btn" data-action="remove">×</button>
        </div>
      ''';
      timePickers.insertAdjacentHtml('beforeend', timePickerHtml);
    }

    // Add event listeners to time inputs
    for (final input in timePickers.querySelectorAll('.time-input')) {
      (input as html.InputElement)
          .onChange
          .listen((_) => updateNotificationTimes());
    }

    // Update weekday checkboxes
    final weekdayInputs =
        html.querySelectorAll('.weekday-item input[type="checkbox"]');
    for (final input in weekdayInputs) {
      final checkbox = input as html.CheckboxInputElement;
      final day = int.parse(checkbox.value ?? '0');
      checkbox.checked = notificationSettings.weekdays.contains(day);
      checkbox.onChange.listen((_) => updateWeekdays());
    }

    // Update status
    if (notificationSettings.enabled) {
      notificationStatus.text =
          'Notifications enabled! You\'ll receive reminders at selected times.';
    } else {
      notificationStatus.text =
          'Click "Enable reminders" to set up notifications';
    }
  }

  void updateWeekdays() {
    final weekdayInputs =
        html.querySelectorAll('.weekday-item input[type="checkbox"]');
    notificationSettings.weekdays.clear();
    for (final input in weekdayInputs) {
      final checkbox = input as html.CheckboxInputElement;
      if (checkbox.checked == true) {
        final day = int.parse(checkbox.value ?? '0');
        notificationSettings.weekdays.add(day);
      }
    }
    saveToStorage();
    scheduleNotifications();
  }

  void scheduleNotifications() {
    if (!notificationSettings.enabled) return;

    // For this implementation, we'll use simple setTimeout
    // In a production app, you'd want a service worker for true background notifications
    Timer.periodic(Duration(minutes: 1), (timer) {
      checkAndSendNotification();
    });
  }

  void cancelNotifications() {
    // In this implementation, we rely on the enabled flag
    // A full implementation would track and cancel specific timers
  }

  void checkAndSendNotification() {
    if (!notificationSettings.enabled) return;

    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final currentWeekday = now.weekday % 7; // Convert to 0=Sunday format

    if (notificationSettings.times.contains(currentTime) &&
        notificationSettings.weekdays.contains(currentWeekday)) {
      sendNotification();
    }
  }

  Future<void> sendNotification() async {
    if (!html.Notification.supported) {
      print('Notifications not supported');
      return;
    }

    final activeTasks = tasks.where((task) => !task.isCompleted).length;
    final message = activeTasks > 0
        ? 'You have $activeTasks active tasks. Time to be productive!'
        : 'Great job! All tasks completed. Add new ones to stay productive!';

    try {
      // Check if service worker is available
      final serviceWorker = html.window.navigator.serviceWorker;
      if (serviceWorker != null) {
        final registration = await serviceWorker.ready;
        if (registration != null) {
          // Use service worker notification
          final options = {
            'body': message,
            'icon': 'icon-192.png',
            'tag': 'iprocrastinate-reminder',
            'requireInteraction': false,
            'silent': false,
          };

          // Call showNotification with proper syntax
          final jsRegistration = registration as dynamic;
          await jsRegistration.showNotification('iProcrastinate Reminder', options);
          print('Service worker notification sent: $message');
          return;
        }
      }

      // Fallback to direct notification if no service worker
      final notification = html.Notification(
        'iProcrastinate Reminder',
        body: message,
        icon: 'icon-192.png',
        tag: 'iprocrastinate-reminder',
      );

      // Auto-close after 5 seconds
      Timer(Duration(seconds: 5), () {
        notification.close();
      });

      print('Direct notification sent: $message');
    } catch (e) {
      print('Error sending notification: $e');

      // Try one more fallback approach
      try {
        print('Attempting fallback notification...');
        final notification = html.Notification(
          'iProcrastinate Reminder',
          body: message,
          icon: 'icon-192.png',
        );
        print('Fallback notification created successfully');
      } catch (fallbackError) {
        print('Fallback notification also failed: $fallbackError');
      }
    }
  }
}
