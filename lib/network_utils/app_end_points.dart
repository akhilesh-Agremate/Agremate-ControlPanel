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
  static const uploadDocumentFiles = "/document/upload-files";
  static const updateProfile = "/User/";
  static const getMyPropertyList = "/Property/list-by-user";
  static const landlordDetails = "/Landlord/landlord-details";
  static const userBootstrap = "/User/me/bootstrap";
  static const verifyPan = "/Zoop/pan-verification";
  static const allProperties = "/Property/all";
  static const allPropertyDetails = '/properties/all-details';
  static const allTenants = '/AdminDashboard/tenants';
  static const allLandlordDetails = '/AdminDashboard/landlords';
  static const currentUserDetails = '/User/current-user-details';
  static const allDocuments = '/documents/all-details';
  static const String uploadFile = '/Files/upload';
  static const String amenities  = '/Amenities';
  static const String config = '/Config';
  static const String financeOverview = '/AdminDashboard/finance/overview';
  static const String financeProperties = '/AdminDashboard/finance/properties';
  static String financePropertyDetail(String id) =>
      '/AdminDashboard/finance/properties/$id';
  static const String adminControlSettings = '/AdminDashboard/admin-control/settings';
  static const String landlordContactAccessStatus =
      '/AdminDashboard/landlord-contact-access';
  static const String getRoles = '/UserRole/get-roles';
  static const String adminDashboardUsers = '/AdminDashboard/users';
  static const String maintenanceRequestStatuses = "/MaintenanceRequests/statuses";
  static const String maintenanceRequestUpdateStatus = "/MaintenanceRequests/update-status";

  static String softDeleteDocument(String id) => "/Document/soft-delete/$id";
  static const String rentalAgreements = '/AdminDashboard/rental-agreements';
  static String deleteDocument(String id) => "/Document/$id";
  static String adminServiceDetail(String id) => '/AdminDashboard/services/$id';
  static String adminServiceMessages(String id) => '/AdminDashboard/services/$id/messages';
  static const String documentCategories = '/admindashboard/document-categories';
  static const String entitiesByCategory = '/admindashboard/entities-by-category';
  static const String getPropertyDocumentByPropertyId =
      '/Document/get-property-document-by-propertyId';
  static const String createArticle = '/Article/create';
  static const String articleGrantAccess = '/Article/grant-access';
}

