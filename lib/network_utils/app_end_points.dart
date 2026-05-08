class AppEndpoints {
  const AppEndpoints._();
  static const api = "/api";
  static const v1 = "/v1";
  static const userLogin = "/User/login";
  static const userPhoneNumberOTP = "/User/phone-number-otp";
  static const userVerifyOTP = "/User/confirm-signup";
  static const refreshToken = "/User/refresh-token";
  static const userSignUp = "/User/sign-up";
  static const userConfirmSignUp = "/User/confirm-signup";
  static const userLogout = "/User/logout";
  static const userSocialLoginCallback = "/User/callback";
  static const createTenantProperty = "/Property/create-tennat-property";
  static const getUserProfile = "/User/";
  static const createOwnerProperty = "/Property";
  static const updateOwnerProperty = "/Property/";

  static const userForgotPassword = "/User/forgot-password";
  // static const userConfirmForgotPassword = "/User/confirm-forgot-password";
  static const amenitiesList = "/Amenities/amenities";
  static const uploadDoc = "/Document/UploadFiles";
  static const updateProfile = "/User/";
  static const getMyPropertyList = "/Property/list-by-user";
  static const verifyPan = "/Zoop/pan-verification";
  static const allProperties = "/Property/all";
  static const allTenants = "/Tenant/get-all";
  static const allLandlords = "/Landlord";
  static const currentUserDetails = "/User/current-user-details";
}
