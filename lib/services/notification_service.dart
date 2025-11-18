import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for iOS
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final platform = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    await platform?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  // Schedule meal reminder notifications
  Future<void> scheduleMealReminders({
    required int breakfastHour,
    required int lunchHour,
    required int dinnerHour,
  }) async {
    await cancelAllNotifications();

    // Breakfast reminder
    await _scheduleDailyNotification(
      id: 1,
      title: 'Good Morning! 🌅',
      body: 'Time to log your breakfast and start your day strong!',
      hour: breakfastHour,
      minute: 0,
    );

    // Lunch reminder
    await _scheduleDailyNotification(
      id: 2,
      title: 'Lunch Time! 🍽️',
      body: 'Don\'t forget to log your lunch meal!',
      hour: lunchHour,
      minute: 0,
    );

    // Dinner reminder
    await _scheduleDailyNotification(
      id: 3,
      title: 'Dinner Time! 🌙',
      body: 'Log your dinner to complete today\'s tracking!',
      hour: dinnerHour,
      minute: 0,
    );

    // Evening review reminder
    await _scheduleDailyNotification(
      id: 4,
      title: 'Daily Review 📊',
      body: 'Review your progress and maintain your streak!',
      hour: 21,
      minute: 0,
    );
  }

  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'meal_reminders',
          'Meal Reminders',
          channelDescription: 'Reminders to log your meals',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // Show achievement unlocked notification
  Future<void> showAchievementNotification({
    required String title,
    required String description,
    required int points,
  }) async {
    await _notifications.show(
      999,
      '🏆 Achievement Unlocked!',
      '$title - You earned $points points!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'achievements',
          'Achievements',
          channelDescription: 'Achievement unlock notifications',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // Show streak milestone notification
  Future<void> showStreakNotification(int streak) async {
    String message;
    if (streak == 7) {
      message = 'You\'ve maintained a week-long streak! 🔥';
    } else if (streak == 30) {
      message = 'Amazing! A full month of consistency! 🎉';
    } else if (streak == 100) {
      message = 'Legendary! 100 days of dedication! 👑';
    } else {
      message = 'Keep up the great work! Current streak: $streak days 🔥';
    }

    await _notifications.show(
      998,
      'Streak Milestone! 🔥',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'streaks',
          'Streaks',
          channelDescription: 'Streak milestone notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // Show weight goal notification
  Future<void> showWeightGoalNotification({
    required double weightLost,
    required double targetWeight,
    required double currentWeight,
  }) async {
    final remaining = (currentWeight - targetWeight).abs();

    await _notifications.show(
      997,
      'Weight Progress! 🎯',
      'You\'ve lost ${weightLost.toStringAsFixed(1)}kg! Only ${remaining.toStringAsFixed(1)}kg to go!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'weight_goals',
          'Weight Goals',
          channelDescription: 'Weight goal progress notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // Show motivational notification
  Future<void> showMotivationalNotification(String message) async {
    await _notifications.show(
      996,
      'Daily Motivation 💪',
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'motivation',
          'Motivation',
          channelDescription: 'Daily motivational messages',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}
