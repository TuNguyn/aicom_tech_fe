/// Utility class for handling timezone conversions and date/time formatting
///
/// IMPORTANT: This class handles bidirectional timezone conversion:
/// - toLocalTime(): Converts UTC from server → Local time for DISPLAY
/// - toUTC(): Converts Local time → UTC for SENDING to server
///
/// The backend stores all timestamps in UTC 0. Always use toUTC() before
/// sending DateTime to the API to ensure proper storage and querying.  
class TimezoneUtils {
  // Special microsecond value to mark DateTimes as already converted
  // This prevents double conversion errors
  static const int _conversionMarker = 999999;

  /// Convert UTC DateTime from server to local timezone
  /// If timezone conversion fails, returns the original DateTime
  ///
  /// [serverDateTime] - DateTime từ server (thường là UTC)
  /// [fallbackToOriginal] - Có fallback về giờ gốc khi không parse được timezone không
  ///
  /// Returns: DateTime theo timezone hệ thống hoặc giờ gốc từ server
  static DateTime toLocalTime(
    DateTime serverDateTime, {
    bool fallbackToOriginal = true,
  }) {
    try {
      // CRITICAL FIX: Check if DateTime is already in local timezone
      // This prevents double conversion when parseJsonDateTime() has already converted to local
      if (!serverDateTime.isUtc &&
          serverDateTime.timeZoneOffset == DateTime.now().timeZoneOffset) {
        // Already in local timezone, return as-is
        return serverDateTime;
      }

      // Nếu DateTime đã có timezone info, convert sang local
      if (serverDateTime.isUtc) {
        final localTime = serverDateTime.toLocal();
        //AppUtils.log('$_tag Converted UTC to local: ${serverDateTime.toIso8601String()} -> ${localTime.toIso8601String()}');
        return localTime;
      }

      // Nếu DateTime không có timezone info, giả định là UTC và convert
      final utcTime = DateTime.utc(
        serverDateTime.year,
        serverDateTime.month,
        serverDateTime.day,
        serverDateTime.hour,
        serverDateTime.minute,
        serverDateTime.second,
        serverDateTime.millisecond,
        serverDateTime.microsecond,
      );

      final localTime = utcTime.toLocal();
      //AppUtils.log('$_tag Assumed UTC and converted to local: ${serverDateTime.toIso8601String()} -> ${localTime.toIso8601String()}');
      return localTime;
    } catch (e) {
      //AppUtils.log('$_tag Failed to convert timezone: $e');

      if (fallbackToOriginal) {
        //AppUtils.log('$_tag Fallback to original server time: ${serverDateTime.toIso8601String()}');
        return serverDateTime;
      } else {
        // Fallback về current time nếu không muốn dùng server time
        final now = DateTime.now();
        //AppUtils.log('$_tag Fallback to current time: ${now.toIso8601String()}');
        return now;
      }
    }
  }

  /// Format DateTime theo định dạng 12h với timezone local
  ///
  /// [dateTime] - DateTime cần format
  /// [includeDate] - Có bao gồm ngày tháng không
  /// [includeSeconds] - Có bao gồm giây không
  ///
  /// Returns: String formatted time/date
  static String formatLocalTime(
    DateTime dateTime, {
    bool includeDate = false,
    bool includeSeconds = false,
  }) {
    try {
      final localTime = toLocalTime(dateTime);

      // Format time part - fix cho 12h format
      int displayHour = localTime.hour;
      if (displayHour > 12) {
        displayHour = displayHour - 12;
      } else if (displayHour == 0) {
        displayHour = 12;
      }

      final hour = displayHour.toString().padLeft(2, '0');
      final minute = localTime.minute.toString().padLeft(2, '0');
      final period = localTime.hour >= 12 ? 'PM' : 'AM';

      String timeString = '$hour:$minute';
      if (includeSeconds) {
        final second = localTime.second.toString().padLeft(2, '0');
        timeString = '$timeString:$second';
      }
      timeString = '$timeString $period';

      if (includeDate) {
        final month = localTime.month.toString().padLeft(2, '0');
        final day = localTime.day.toString().padLeft(2, '0');
        final year = localTime.year.toString();
        return '$month/$day/$year - $timeString';
      }

      return timeString;
    } catch (e) {
      //AppUtils.log('$_tag Failed to format time: $e');
      // Fallback về format cơ bản
      final fallbackHour = dateTime.hour > 12
          ? dateTime.hour - 12
          : (dateTime.hour == 0 ? 12 : dateTime.hour);
      final fallbackPeriod = dateTime.hour >= 12 ? 'PM' : 'AM';
      return '${fallbackHour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $fallbackPeriod';
    }
  }

  /// Format DateTime thành ngày tháng năm
  ///
  /// [dateTime] - DateTime cần format
  /// [separator] - Ký tự phân cách (default: '/')
  ///
  /// Returns: String formatted date (MM/dd/yyyy)
  static String formatLocalDate(DateTime dateTime, {String separator = '/'}) {
    try {
      final localTime = toLocalTime(dateTime);
      final month = localTime.month.toString().padLeft(2, '0');
      final day = localTime.day.toString().padLeft(2, '0');
      final year = localTime.year.toString();
      return '$month$separator$day$separator$year';
    } catch (e) {
      //AppUtils.log('$_tag Failed to format date: $e');
      // Fallback format
      final month = dateTime.month.toString().padLeft(2, '0');
      final day = dateTime.day.toString().padLeft(2, '0');
      final year = dateTime.year.toString();
      return '$month$separator$day$separator$year';
    }
  }

  /// Tính wait time theo phút từ thời điểm tạo đến hiện tại (local time)
  ///
  /// [createdTime] - Thời điểm tạo (assumed to be already in local time from parseJsonDateTime)
  ///
  /// Returns: Số phút chờ đợi
  static int calculateWaitTimeMinutes(DateTime createdTime) {
    try {
      // CRITICAL FIX: createdTime from models is ALREADY in local time (from parseJsonDateTime)
      // toLocalTime() is now idempotent, so calling it is safe but unnecessary
      // We use it here for safety, but it will return immediately if already local
      final localCreatedTime = toLocalTime(createdTime);
      final now = DateTime.now();
      final difference = now.difference(localCreatedTime);
      final minutes = difference.inMinutes;

      return minutes.isNegative ? 0 : minutes;
    } catch (e) {
      // Fallback calculation
      final now = DateTime.now();
      final difference = now.difference(createdTime);
      return difference.inMinutes.isNegative ? 0 : difference.inMinutes;
    }
  }

  /// Check if current device supports timezone detection
  ///
  /// Returns: true if timezone can be detected, false otherwise
  static bool canDetectTimezone() {
    try {
      final now = DateTime.now();
      final utc = now.toUtc();
      return now != utc; // If they're different, timezone is working
    } catch (e) {
      //AppUtils.log('$_tag Timezone detection failed: $e');
      return false;
    }
  }

  /// Get current timezone offset in hours
  ///
  /// Returns: Timezone offset in hours (e.g., +7 for ICT)
  static String getTimezoneOffset() {
    try {
      final now = DateTime.now();
      final offset = now.timeZoneOffset;
      final hours = offset.inHours;
      final minutes = offset.inMinutes.remainder(60);

      final sign = hours >= 0 ? '+' : '';
      if (minutes == 0) {
        return '$sign$hours';
      } else {
        return '$sign$hours:${minutes.abs().toString().padLeft(2, '0')}';
      }
    } catch (e) {
      //AppUtils.log('$_tag Failed to get timezone offset: $e');
      return '+0';
    }
  }

  /// Get timezone name
  ///
  /// Returns: Timezone name (e.g., "ICT", "UTC+7")
  static String getTimezoneName() {
    try {
      final now = DateTime.now();
      final timezoneName = now.timeZoneName;

      if (timezoneName.isNotEmpty) {
        return timezoneName;
      } else {
        return 'UTC${getTimezoneOffset()}';
      }
    } catch (e) {
      //AppUtils.log('$_tag Failed to get timezone name: $e');
      return 'Local';
    }
  }

  // ============================================================================
  // UTC CONVERSION FOR API CALLS
  // ============================================================================
  //
  // IMPORTANT: These methods convert local DateTime to UTC before sending to API
  // The backend stores all timestamps in UTC 0, so we must convert before sending.
  //

  /// Check if a DateTime has already been converted to UTC
  ///
  /// This uses a special microsecond marker to prevent double conversion.
  /// If the DateTime's microsecond value is our special marker (999999),
  /// it means this DateTime was already converted.
  ///
  /// [dateTime] - The DateTime to check
  /// Returns: true if already converted to UTC, false otherwise
  static bool isAlreadyConverted(DateTime dateTime) {
    return dateTime.microsecond == _conversionMarker;
  }

  /// Convert local DateTime to UTC for sending to API
  ///
  /// **Usage in datasources:**
  /// ```dart
  /// final localCreatedAt = DateTime.now();
  /// final utcCreatedAt = TimezoneUtils.toUTC(localCreatedAt);
  ///
  /// await dioClient.post('/tickets', data: {
  ///   'createdAt': utcCreatedAt.toIso8601String(),
  /// });
  /// ```
  ///
  /// **Usage in query params:**
  /// ```dart
  /// final startDate = DateTime(2025, 1, 1);
  /// final utcStart = TimezoneUtils.toUTC(startDate);
  ///
  /// await dioClient.get('/tickets', queryParameters: {
  ///   'startDate': utcStart.toIso8601String(),
  /// });
  /// ```
  ///
  /// [localDateTime] - DateTime in local timezone (from device)
  /// Returns: DateTime in UTC with conversion marker to prevent double conversion
  static DateTime toUTC(DateTime localDateTime) {
    try {
      // Safety check: if already UTC, return as-is
      if (localDateTime.isUtc) {
        return _markAsConverted(localDateTime);
      }

      // Safety check: if already converted (has our marker), return as-is
      if (isAlreadyConverted(localDateTime)) {
        return localDateTime;
      }

      // Get the device's timezone offset
      final offset = localDateTime.timeZoneOffset;

      // Subtract the offset to get UTC time
      // Example: If local is 14:00 +7, UTC should be 07:00
      // So we subtract 7 hours: 14:00 - 7 = 07:00 UTC
      final utcTime = localDateTime.subtract(offset);

      // Create UTC DateTime and mark as converted
      final convertedUtc = DateTime.utc(
        utcTime.year,
        utcTime.month,
        utcTime.day,
        utcTime.hour,
        utcTime.minute,
        utcTime.second,
        utcTime.millisecond,
        _conversionMarker, // Special marker to prevent double conversion
      );

      return convertedUtc;
    } catch (e) {
      //AppUtils.log('$_tag Failed to convert to UTC: $e');
      // Fallback: if conversion fails, try to return UTC version
      if (localDateTime.isUtc) {
        return localDateTime;
      }
      return DateTime.utc(
        localDateTime.year,
        localDateTime.month,
        localDateTime.day,
        localDateTime.hour,
        localDateTime.minute,
        localDateTime.second,
        localDateTime.millisecond,
      );
    }
  }

  /// Convert a local DateTime object to UTC (alternative name for clarity)
  ///
  /// This is an alias for toUTC() with a more explicit name.
  /// Use whichever name is clearer in your context.
  ///
  /// [localDateTime] - DateTime in local timezone
  /// Returns: DateTime in UTC
  static DateTime convertToUTC(DateTime localDateTime) {
    return toUTC(localDateTime);
  }

  /// Mark a DateTime as already converted by setting microsecond to special value
  ///
  /// Internal helper method used by toUTC()
  ///
  /// [dateTime] - The UTC DateTime to mark
  /// Returns: Same DateTime with conversion marker
  static DateTime _markAsConverted(DateTime dateTime) {
    if (dateTime.microsecond == _conversionMarker) {
      return dateTime;
    }

    return DateTime.utc(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
      dateTime.millisecond,
      _conversionMarker,
    );
  }

  /// Remove conversion marker from a DateTime
  ///
  /// Use this if you need to "reset" a DateTime that was marked as converted.
  /// Generally not needed in normal usage.
  ///
  /// [dateTime] - The DateTime to clear
  /// Returns: DateTime with microsecond reset to 0
  static DateTime clearConversionMarker(DateTime dateTime) {
    if (!isAlreadyConverted(dateTime)) {
      return dateTime;
    }

    return DateTime.utc(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
      dateTime.millisecond,
      0, // Clear the marker
    );
  }

  /// Get the current device timezone information
  ///
  /// Returns a map with timezone details:
  /// - 'name': Timezone name (e.g., "ICT")
  /// - 'offset': Offset string (e.g., "+7")
  /// - 'offsetHours': Offset in hours as int
  /// - 'offsetMinutes': Offset minutes component
  ///
  /// Example:
  /// ```dart
  /// final tzInfo = TimezoneUtils.getDeviceTimezone();
  /// print('Device timezone: ${tzInfo['name']} (UTC${tzInfo['offset']})');
  /// ```
  static Map<String, dynamic> getDeviceTimezone() {
    try {
      final now = DateTime.now();
      final offset = now.timeZoneOffset;
      final hours = offset.inHours;
      final minutes = offset.inMinutes.remainder(60);

      return {
        'name': getTimezoneName(),
        'offset': getTimezoneOffset(),
        'offsetHours': hours,
        'offsetMinutes': minutes,
        'isUtc': hours == 0 && minutes == 0,
      };
    } catch (e) {
      return {
        'name': 'Unknown',
        'offset': '+0',
        'offsetHours': 0,
        'offsetMinutes': 0,
        'isUtc': true,
      };
    }
  }

  /// Get hybrid date range for ticket filtering
  ///
  /// Returns (earliestDate, latestDate) that covers:
  /// - OS local "today" 00:00 to 23:59
  /// - Server UTC "today" 00:00 to 23:59
  ///
  /// This ensures newly created tickets appear immediately even when
  /// OS date differs from server UTC date due to timezone offset.
  ///
  /// **Problem Solved:**
  /// When OS time is Nov 4, 11:30 PM (UTC-6) but server UTC is Nov 5, 06:30 AM,
  /// newly created tickets get saved with server date (Nov 5). Without hybrid range,
  /// these tickets won't appear in the list because the filter only uses OS date (Nov 4).
  ///
  /// **Examples:**
  /// ```
  /// UTC-6: OS Time:       Nov 4, 11:30 PM (UTC-6)
  ///        Server UTC:    Nov 5, 06:30 AM (UTC+0)
  ///        Local Date:    Nov 4
  ///        UTC Date:      Nov 5
  ///        Hybrid Range:  Nov 4 to Nov 6 (covers both dates)
  ///
  /// UTC+7: OS Time:       Nov 5, 06:30 AM (UTC+7)
  ///        Server UTC:    Nov 4, 11:30 PM (UTC+0)
  ///        Local Date:    Nov 5
  ///        UTC Date:      Nov 4
  ///        Hybrid Range:  Nov 4 to Nov 6 (covers both dates)
  /// ```
  ///
  /// Returns: Tuple of (earliestDateStr, upperBoundDateStr) in YYYY-MM-DD format
  static (String, String) getHybridTodayRange() {
    try {
      // Get OS local today at 00:00:00
      final localNow = DateTime.now();
      final localToday = DateTime(localNow.year, localNow.month, localNow.day);

      // Get server UTC today at 00:00:00 UTC
      final utcNow = DateTime.now().toUtc();
      final utcToday = DateTime.utc(utcNow.year, utcNow.month, utcNow.day);

      // Create date-only integers for comparison (YYYYMMDD format)
      final localDateInt =
          localToday.year * 10000 + localToday.month * 100 + localToday.day;
      final utcDateInt =
          utcToday.year * 10000 + utcToday.month * 100 + utcToday.day;

      // Find earliest and latest dates by comparing date values
      // This works for BOTH positive and negative timezone offsets
      final earliestDate = localDateInt <= utcDateInt ? localToday : utcToday;
      final latestDate = localDateInt >= utcDateInt ? localToday : utcToday;

      // Add 2 days to latest for exclusive upper bound
      // nestjs-paginate uses $btw with exclusive upper bound: [earliest, upperBound)
      // We need +2 days because:
      // - If earliest=Nov4, latest=Nov5 → range [Nov4, Nov6) includes both Nov4 and Nov5
      // - If earliest=latest=Nov4 → range [Nov4, Nov6) covers Nov4 and Nov5 (in case of date changes)
      // - The upper bound is EXCLUSIVE, so Nov6 means "up to but not including Nov6"
      final upperBound = latestDate.add(const Duration(days: 2));

      // Format as YYYY-MM-DD
      final earliestStr =
          '${earliestDate.year.toString().padLeft(4, '0')}-${earliestDate.month.toString().padLeft(2, '0')}-${earliestDate.day.toString().padLeft(2, '0')}';
      final upperBoundStr =
          '${upperBound.year.toString().padLeft(4, '0')}-${upperBound.month.toString().padLeft(2, '0')}-${upperBound.day.toString().padLeft(2, '0')}';

      return (earliestStr, upperBoundStr);
    } catch (e) {
      // Fallback to simple today range
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      final todayStr =
          '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final tomorrowStr =
          '${tomorrow.year.toString().padLeft(4, '0')}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';

      return (todayStr, tomorrowStr);
    }
  }

  // ============================================================================
  // MODEL PARSING HELPERS
  // ============================================================================
  //
  // Helper methods for parsing DateTime from JSON in model classes
  //

  /// Parse DateTime from JSON string and convert to local timezone
  ///
  /// **Use this in model fromJson() methods** to automatically convert
  /// UTC timestamps from server to local time for display.
  ///
  /// **Example:**
  /// ```dart
  /// factory TicketModel.fromJson(Map<String, dynamic> json) {
  ///   return TicketModel(
  ///     createdAt: TimezoneUtils.parseJsonDateTime(json['createdAt']),
  ///     updatedAt: TimezoneUtils.parseJsonDateTime(json['updatedAt']),
  ///   );
  /// }
  /// ```
  ///
  /// [jsonValue] - DateTime string from JSON (UTC format from server)
  /// Returns: DateTime in local timezone for display
  static DateTime parseJsonDateTime(dynamic jsonValue) {
    if (jsonValue == null) {
      throw ArgumentError('DateTime value cannot be null');
    }

    try {
      String dateString = jsonValue.toString().trim();

      final hasZSuffix = dateString.endsWith('Z') || dateString.endsWith('z');
      final hasTimezoneOffset =
          dateString.contains('+') ||
          (dateString.contains('-') && dateString.lastIndexOf('-') > 10);

      if (!hasZSuffix && !hasTimezoneOffset) {
        // Check if it's a date-only format (YYYY-MM-DD)
        final dateOnlyPattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
        if (dateOnlyPattern.hasMatch(dateString)) {
          // Convert date-only format to full ISO format
          dateString = '${dateString}T00:00:00Z';
        } else {
          // Server timestamp has no timezone info - assume UTC and add 'Z'
          dateString = '${dateString}Z';
        }
      }

      // Now parse will correctly interpret as UTC
      final utcDateTime = DateTime.parse(dateString);

      // Convert UTC to local timezone for display
      return utcDateTime.toLocal();
    } catch (e) {
      throw FormatException(
        'Failed to parse DateTime from JSON: $jsonValue - Error: $e',
      );
    }
  }

  /// Lấy date range cho một ngày bất kỳ (được chọn từ lịch)
  /// Trả về (startDate, endDate) dùng local date — khớp logic với fetchTodayCount()
  static (DateTime, DateTime) getHybridDateRange(DateTime selectedDate) {
    final start = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      0, 0, 0,
    );
    final end = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      23, 59, 59,
    );
    return (start, end);
  }

  /// Parse optional DateTime from JSON string and convert to local timezone
  ///
  /// Same as parseJsonDateTime but returns null if jsonValue is null.
  ///
  /// **Example:**
  /// ```dart
  /// factory UserModel.fromJson(Map<String, dynamic> json) {
  ///   return UserModel(
  ///     lastLoginAt: TimezoneUtils.parseJsonDateTimeOrNull(json['lastLoginAt']),
  ///   );
  /// }
  /// ```
  ///
  /// [jsonValue] - DateTime string from JSON or null
  /// Returns: DateTime in local timezone or null
  static DateTime? parseJsonDateTimeOrNull(dynamic jsonValue) {
    if (jsonValue == null) {
      return null;
    }

    try {
      return parseJsonDateTime(jsonValue);
    } catch (e) {
      return null;
    }
  }

  // ============================================================================
  // TIMESTAMP CONVERSION FOR API CALLS
  // ============================================================================
  //
  // IMPORTANT: These methods convert date strings to millisecond timestamps
  // for API endpoints that require Unix epoch time in milliseconds
  //

  /// Convert a date string to UTC timestamp in milliseconds
  ///
  /// This method parses a date string (like "2025-10-16") and converts it to
  /// milliseconds since Unix epoch (Jan 1, 1970) in UTC timezone.
  ///
  /// **Usage in datasources:**
  /// ```dart
  /// final dateFrom = "2025-10-16";
  /// final timestampFrom = TimezoneUtils.dateToTimestamp(dateFrom);
  /// // timestampFrom = 1760659200000
  ///
  /// await dioClient.get('/reports/from/$timestampFrom/to/$timestampTo');
  /// ```
  ///
  /// [dateString] - Date string in format 'yyyy-MM-dd' or ISO 8601 format
  /// [endOfDay] - If true, sets time to 23:59:59.999 (end of day), default is false (00:00:00)
  /// Returns: Milliseconds since Unix epoch in UTC
  /// Throws: FormatException if dateString cannot be parsed
  static int dateToTimestamp(String dateString, {bool endOfDay = false}) {
    try {
      // Parse the date string
      DateTime parsedDate = DateTime.parse(dateString);

      // If the parsed date has time components, use them
      // Otherwise, set to start or end of day
      if (parsedDate.hour == 0 &&
          parsedDate.minute == 0 &&
          parsedDate.second == 0 &&
          parsedDate.millisecond == 0) {
        if (endOfDay) {
          // Set to end of day: 23:59:59.999
          parsedDate = DateTime(
            parsedDate.year,
            parsedDate.month,
            parsedDate.day,
            23,
            59,
            59,
            999,
          );
        }
      }

      // Convert to UTC if not already
      final utcDate = parsedDate.isUtc ? parsedDate : toUTC(parsedDate);

      // Convert to milliseconds since epoch
      return utcDate.millisecondsSinceEpoch;
    } catch (e) {
      throw FormatException(
        'Failed to convert date string to timestamp: $dateString. Error: $e',
      );
    }
  }

  /// Convert a DateTime object to UTC timestamp in milliseconds
  ///
  /// This is a convenience method that converts a DateTime directly to
  /// milliseconds since Unix epoch in UTC timezone.
  ///
  /// **Usage:**
  /// ```dart
  /// final date = DateTime(2025, 10, 16);
  /// final timestamp = TimezoneUtils.dateTimeToTimestamp(date);
  /// // timestamp = 1760659200000
  /// ```
  ///
  /// [dateTime] - DateTime object to convert
  /// Returns: Milliseconds since Unix epoch in UTC
  static int dateTimeToTimestamp(DateTime dateTime) {
    try {
      // Convert to UTC if not already
      final utcDate = dateTime.isUtc ? dateTime : toUTC(dateTime);

      // Convert to milliseconds since epoch
      return utcDate.millisecondsSinceEpoch;
    } catch (e) {
      throw FormatException(
        'Failed to convert DateTime to timestamp: $dateTime. Error: $e',
      );
    }
  }

  /// Convert a timestamp in milliseconds back to DateTime in local timezone
  ///
  /// This method converts milliseconds since Unix epoch back to a DateTime
  /// object in the local timezone for display purposes.
  ///
  /// **Usage:**
  /// ```dart
  /// final timestamp = 1760659200000;
  /// final date = TimezoneUtils.timestampToDateTime(timestamp);
  /// // date = DateTime in local timezone
  /// ```
  ///
  /// [timestamp] - Milliseconds since Unix epoch
  /// Returns: DateTime in local timezone
  static DateTime timestampToDateTime(int timestamp) {
    try {
      // Create UTC DateTime from milliseconds
      final utcDate = DateTime.fromMillisecondsSinceEpoch(
        timestamp,
        isUtc: true,
      );

      // Convert to local timezone
      return toLocalTime(utcDate);
    } catch (e) {
      throw FormatException(
        'Failed to convert timestamp to DateTime: $timestamp. Error: $e',
      );
    }
  }
}
