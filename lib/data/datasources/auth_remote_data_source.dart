import '../../core/network/dio_client.dart';
import '../../core/errors/exceptions.dart';
import '../models/tech_user_model.dart';
import '../models/employee_model.dart';

abstract class AuthRemoteDataSource {
  Future<TechUserModel> loginWithStore(String phone, String passCode, String storeId);
  Future<void> logout();
  Future<List<EmployeeModel>> getEmployeeWithPhone(String phone, String passCode);
  Future<TechUserModel> updateProfile(Map<String, dynamic> data);
  Future<TechUserModel> getEmployeeProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

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
  Future<TechUserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.patch(
        '/employee-app/profile',
        data: data,
      );

      // Check if response has data
      if (response.data == null) {
        throw ServerException(message: 'Empty response from server');
      }

      // Try to get data from response
      final responseData = response.data;
      Map<String, dynamic> userJson;

      // Check if response has 'data' field or is the data itself
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          userJson = responseData['data'] as Map<String, dynamic>;
        } else {
          userJson = responseData;
        }
      } else {
        throw ServerException(message: 'Invalid response format');
      }

      // Use fromLoginResponse as it handles store object properly
      return TechUserModel.fromLoginResponse(userJson, '');
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

  @override
  Future<TechUserModel> getEmployeeProfile() async {
    try {
      final response = await dioClient.get('/employee-app/profile');

      // Check if response has data
      if (response.data == null) {
        throw ServerException(message: 'Empty response from server');
      }

      // Try to get data from response
      final responseData = response.data;
      Map<String, dynamic> userJson;

      // Check if response has 'data' field or is the data itself
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data')) {
          userJson = responseData['data'] as Map<String, dynamic>;
        } else {
          userJson = responseData;
        }
      } else {
        throw ServerException(message: 'Invalid response format');
      }

      // Use fromLoginResponse as it handles store object properly
      return TechUserModel.fromLoginResponse(userJson, '');
    } on AuthException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'An unknown error occurred while fetching profile: $e',
      );
    }
  }
}
