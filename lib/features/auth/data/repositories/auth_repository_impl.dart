import 'package:local_first/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:local_first/features/auth/domain/entities/user_entity.dart';
import 'package:local_first/features/auth/domain/repositories/auth_repository.dart';

/// AUTH feature - Data Layer: Repository Implementation
/// Concrete implementation of [AuthRepository] backed by the remote datasource.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource datasource;

  AuthRepositoryImpl(this.datasource);

  @override
  Future<String> sendOtp(String phone) => datasource.sendOtp(phone);

  @override
  Future<String> verifyOtp(String verificationId, String smsCode) =>
      datasource.verifyOtp(verificationId, smsCode);

  @override
  Future<void> upsertProfile(String uid, UserEntity entity) =>
      datasource.upsertUserProfile(uid, entity);

  @override
  Future<String> submitKyc({required String uid, required dynamic imageFile}) async {
    final url = await datasource.setKycDocument(uid, imageFile);
    await datasource.updateVerificationStatus(uid, 'pending');
    return url;
  }
}
