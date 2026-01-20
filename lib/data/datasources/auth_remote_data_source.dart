import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/tech_user_model.dart';
import '../models/employee_model.dart';

abstract class AuthRemoteDataSource {
  Future<TechUserModel> login(String username, String password);
  Future<TechUserModel> loginWithStore(String phone, String passCode, String storeId);
  Future<void> logout();
  Future<TechUserModel> refreshToken();
  Future<List<EmployeeModel>> getEmployeeWithPhone(String phone, String passCode);
  Future<TechUserModel> updateProfile(String id, Map<String, dynamic> data);
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
  Future<TechUserModel> loginWithStore(String phone, String passCode, String storeId) async {
    try {
      final response = await dioClient.post(
        '/auth/employee/login',
        data: {'phone': phone, 'passCode': passCode, 'storeId': storeId},
      );

      final accessToken = response.data['data']['access_token'] as String;
      final employeeJson = response.data['data']['employee'] as Map<String, dynamic>;

      return TechUserModel.fromLoginResponse(employeeJson, accessToken);
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
        '/auth/employee/lookup',
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

  @override
  Future<TechUserModel> updateProfile(String id, Map<String, dynamic> data) async {
    try {
      final response = await dioClient.put(
        '/tech-user/$id',
        data: data,
      );

      final userJson = response.data['data'] as Map<String, dynamic>;
      // Assuming the token is not refreshed on profile update, or if it is, handle it.
      // For now, we might need to retrieve the current token from somewhere or it might be in the response.
      // If the API doesn't return the token, we might need to pass the existing one.
      // Let's assume the response contains the updated user object.
      // We'll use an empty token for now as it's not provided in the update response typically,
      // but the model requires it. ideally we should get it from the state.
      // However, data source doesn't have access to state.
      // We will handle token preservation in the repository or notifier.
      return TechUserModel.fromJson(userJson, ''); 
    } on AuthException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'An unknown error occurred while updating profile: $e',
      );
    }
  }
}
