import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:e_commerce_flutter/src/core/services/auth_service.dart';
import 'package:e_commerce_flutter/src/model/user_model.dart';

class AuthController extends GetxController {
  Rxn<UserModel> currentUser = Rxn<UserModel>();
  RxBool isLoading = false.obs;
  RxnString errorMessage = RxnString();
  RxBool isLogin = true.obs;

  bool get isLoggedIn => currentUser.value != null;
  bool get isAdmin => currentUser.value?.isAdmin ?? false;

  @override
  void onInit() {
    super.onInit();
    _hydrate();
  }

  Future<void> _hydrate() async {
    if (!AuthService.isLoggedIn) return;
    currentUser.value = await AuthService.currentProfile();
  }

  void toggleAuthMode() {
    isLogin.value = !isLogin.value;
    errorMessage.value = null;
  }

  Future<bool> signIn(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      currentUser.value = await AuthService.signIn(
        email: email,
        password: password,
      );
      return true;
    } on AuthException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      currentUser.value = await AuthService.signUp(
        email: email,
        password: password,
        name: name,
      );
      return true;
    } on AuthException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await AuthService.signOut();
    currentUser.value = null;
  }
}
