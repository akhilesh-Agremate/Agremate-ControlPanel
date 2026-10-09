class AppEndpoints {
  const AppEndpoints._();
  static const api = "/api";
  static const v1 = "/v1";
  static const checkAccess = '/AdminDashboard/check-access';
  static const userLogin = "/User/login";
  static const userPhoneNumberOTP = "/User/phone-number-otp";
  static const userVerifyOTP = "/User/confirm-signup";
  static const userSignUp = "/User/sign-up";
  static const userConfirmSignUp = "/User/confirm-signup";
  static const userLogout = "/User/logout";
  static const userSocialLoginCallback = "/User/callback";
  static const createTenantProperty = "/Property/create-tennat-property";
  static const getUserProfile = "/User/";
  static const createOwnerProperty = "/Property";
  static const updateOwnerProperty = "/Property/";
  static const String adminDashboardOverview = "/AdminDashboard/overview";
  static const String adminDashboardRentCollections =
      "/AdminDashboard/rent-collections";
  static const String adminDashboardPendingPayments =
      "/AdminDashboard/pending-payments";
  static const String adminDashboardProperties = "/AdminDashboard/properties";
  static const String adminDashboardPropertyStats =
      "/AdminDashboard/properties/stats";
  static const String adminDashboardServices = "/AdminDashboard/services";
  static const String adminDashboardRecentActivity =
      "/AdminDashboard/recent-activity";
  static const String adminDashboardSubscriptions =
      "/AdminDashboard/subscriptions";
  static const String adminDashboardExpiredSubscriptions =
      "/AdminDashboard/subscriptions/expired";

  static const userForgotPassword = "/User/forgot-password";
  static const amenitiesList = "/Amenities/amenities";
  static const uploadDoc = "/Document/UploadFiles";
  static const updateProfile = "/User/";
  static const getMyPropertyList = "/Property/list-by-user";
  static const verifyPan = "/Zoop/pan-verification";
  static const allProperties = "/Property/all";
  static const allPropertyDetails = '/properties/all-details';
  static const allTenants = '/AdminDashboard/tenants';
  static const allLandlordDetails = '/AdminDashboard/landlords';
  static const currentUserDetails = '/User/current-user-details';
  static const landlordSubscriptionSummary = '/landlord-subscription/summary';
  static const allDocuments = '/documents/all-details';
  static const String uploadFile = '/Files/upload';
  static const String amenities  = '/Amenities';
  static const String config = '/Config';
  static const String financeOverview = '/AdminDashboard/finance/overview';
  static const String financeProperties = '/AdminDashboard/finance/properties';
  static String financePropertyDetail(String id) =>
      '/AdminDashboard/finance/properties/$id';
  static const String adminControlSettings = '/AdminDashboard/admin-control/settings';
}
