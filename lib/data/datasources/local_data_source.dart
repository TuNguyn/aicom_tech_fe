import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/tech_user_model.dart';

abstract class LocalDataSource {
  Future<void> cacheUser(TechUserModel user);
  Future<TechUserModel?> getCachedUser();
  Future<void> clearAuthCache();
}

class LocalDataSourceImpl implements LocalDataSource {
  final Box<dynamic> authBox;

  LocalDataSourceImpl(this.authBox);

  @override
  Future<void> cacheUser(TechUserModel user) async {
    try {
      await authBox.put(AppConstants.jwtTokenKey, user.token);
      await authBox.put(AppConstants.techUserKey, user.toJson());
    } catch (e) {
      throw CacheException('Failed to cache user: $e');
    }
  }

  @override
  Future<TechUserModel?> getCachedUser() async {
    try {
      final dynamic rawUserData = authBox.get(AppConstants.techUserKey);

      if (rawUserData != null) {
        final Map<String, dynamic> userData =
            Map<String, dynamic>.from(rawUserData as Map);

        return TechUserModel.fromJson(
          userData,
          userData['token'] as String,
        );
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached user: $e');
    }
  }

  @override
  Future<void> clearAuthCache() async {
    try {
      await authBox.clear();
    } catch (e) {
      throw CacheException('Failed to clear auth cache: $e');
    }
  }
}
