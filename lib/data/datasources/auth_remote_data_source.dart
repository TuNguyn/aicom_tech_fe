import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/tech_user_model.dart';
import '../models/employee_model.dart';

abstract class AuthRemoteDataSource {
  Future<TechUserModel> login(String username, String password);
  Future<void> logout();
  Future<TechUserModel> refreshToken();
  Future<List<EmployeeModel>> getEmployeeWithPhone(String phone, String passCode);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<TechUserModel> login(String username, String password) async {
    try {
      final response = await dioClient.post(
        '/auth/tech-login',
        data: {'username': username, 'password': password},
      );

      final accessToken = response.data['data']['access_token'] as String;
      final userJson = response.data['data']['user'] as Map<String, dynamic>;

      return TechUserModel.fromJson(userJson, accessToken);
    } on AuthException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'An unknown error occurred during login: $e',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dioClient.post('/auth/logout');
    } catch (e) {
      // Silent fail for logout
    }
  }

  @override
  Future<TechUserModel> refreshToken() async {
    try {
      final response = await dioClient.post('/auth/refresh-token');
      final accessToken = response.data['data']['access_token'] as String;
      final userJson = response.data['data']['user'] as Map<String, dynamic>;

      return TechUserModel.fromJson(userJson, accessToken);
    } catch (e) {
      throw AuthException(message: 'Failed to refresh token');
    }
  }

  @override
  Future<List<EmployeeModel>> getEmployeeWithPhone(String phone, String passCode) async {
    try {
      final response = await dioClient.post(
        '/auth/verify-employee',
        data: {'phone': phone, 'passCode': passCode},
      );

      final dataList = response.data['data'] as List<dynamic>;
      return dataList
          .map((json) => EmployeeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on AuthException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'An unknown error occurred while verifying employee: $e',
      );
    }
  }
}
