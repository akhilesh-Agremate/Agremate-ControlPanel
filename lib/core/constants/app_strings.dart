class AppStrings {
  AppStrings._();
  static const String notAvailable = 'N/A';
  static const String cancel = 'Cancel';
  static const String retry = 'Retry';
  static const String success = 'Success';
  static const String error = 'Error';
  static const String enabled = 'Enabled';
  static const String disabled = 'Disabled';
  static const String superAdmin = 'Super Admin';
  static const String landlord = 'Landlord';
  static const String tenant = 'Tenant';
  static const String editProfile = 'Edit Profile';
  static const String fullName = 'Full Name';
  static const String email = 'Email';
  static const String phone = 'Phone';
  static const String role = 'Role';
  static const String saveChanges = 'Save Changes';
  static const String logout = 'Logout';
  static const String logoutSubtitle = 'Sign out of your account';
  static const String logoutConfirmation = 'Are you sure you want to logout?';
  static const String registerNewAccount = 'Register New Account';
  static const String register = 'Register';
  static const String phoneNumber = 'Phone Number';
  static const String phonePrefix = '+91 ';
  static const String selectRole = 'Select a role';
  static const String loadingRoles = 'Loading roles...';
  static String failedToLoadRoles(String error) => 'Failed to load roles: $error';
  static const String accountRegistered = 'Account registered successfully!';
  static const String userCreated = 'User created successfully.';
  static const String adminControl = 'Admin Control';
  static const String adminControlSubtitle =
      'Manage platform-level settings and configurations.';
  static const String tenantVisibilitySettings = 'Tenant Visibility Settings';
  static const String landlordContactMask = 'Landlord Contact Mask';
  static const String landlordContactMaskDescription =
      "When enabled, tenant users will not see the landlord's contact details (phone number and email). Their information will be hidden across the platform.";
  static const String contactMaskEnabledMessage =
      'Landlord contact details hidden from tenants.';
  static const String contactMaskDisabledMessage =
      'Tenants can now view landlord contact details.';
  static const String updateSettingFailed =
      'Failed to update setting. Please try again.';
  static String phoneLengthError(int length) =>
      'Phone number must be exactly $length digits.';
  static const String otpRequired = 'OTP is required.';
  static String otpLengthError(int length) =>
      'Verification code must be $length digits.';
  static const String otpExpired = 'Invalid OTP. Code has expired.';
  static const String login = 'Login';
  static const String verifyOtp = 'Verify OTP';
  static const String loginSubtitle = 'Enter your phone number to continue';
  static const String countryCode = '+91';
  static const String sendOtp = 'Send OTP';
  static const String verificationCode = 'Verification Code';
  static const String verifyAndLogin = 'Verify & Login';
  static const String resendOtp = 'Resend OTP';
  static const String changeNumber = 'Change Number';
  static String otpSentTo(int length, String phone) =>
      'Enter the $length-digit code sent to $phone';
  static String enterOtpHint(int length) => 'Enter $length-digit OTP';
  static String resendOtpIn(String time) => 'Resend OTP in $time';
  static const String phoneRequired = 'Phone number is required.';
  static const String phoneInvalid = 'Enter a valid 10-digit phone number.';
  static const String roleRequired = 'Please select a role.';
  static const String emailOrPhoneRequired = 'Phone number or Email is required.';
  static const String emailOrPhoneInvalid = 'Enter a valid Email or 10-digit Phone number.';
  static const String passwordRequired = 'Password is required.';
  static const String passwordComplexity =
      r'Must be at least 6 chars and include uppercase, lowercase, number, and special char (@#$%&).';
  static const String notAuthorized =
      'This phone number is not authorized as Super Admin, Landlord, or Tenant.';
  static const String otpVerificationFailed = 'OTP verification failed';
  static const String failedToSendOtp = 'Failed to send OTP';
  static const String documents = 'Documents';
  static const String noPropertiesFound = 'No properties found.';
  static const String noDocumentsFound = 'No documents found for this property';
  static const String previewNotAvailable = 'Document preview is not available.';
  static const String fileTypeDefault = 'FILE';
  static const String openDownload = 'Open / Download';
  static const String close = 'Close';
  static String landlordLabel(String name) => 'Landlord: $name';
  static String tenantLabel(String name) => 'Tenant: $name';
  static const String noData = 'No data';
  static const String totalRevenue = 'Total Revenue';
  static const String allLandlordsCombined = 'All landlords combined';
  static const String rentedProperties = 'Rented Properties';
  static const String paid = 'Paid';
  static const String overdue = 'Overdue';
  static const String revenueTrend = 'Revenue Trend — Last 12 Months';
  static const String clickPropertyHint =
      'Click on a property to view monthly rent payments';
  static const String noRentedPropertiesFound = 'No rented properties found';
  static const String perMonth = '/ month';
  static const String cashInHand = 'Cash in Hand';
  static const String cashPaymentProof = 'Cash Payment Proof';
  static const String noProof = 'No proof';
  static const String noReceiptAttached = 'No receipt attached for this payment.';
  static const String amountReceived = 'Amount Received';
  static const String paymentDate = 'Payment Date';
  static const String month = 'Month';
  static const String villaName = 'Villa Name';
  static const String amount = 'Amount';
  static const String transactionId = 'Transaction ID';
  static const String status = 'Status';
  static const String dueDate = 'Due Date';
  static const String paidDate = 'Paid Date';
  static const String delay = 'Delay';
  static String joinedOn(String date) => 'Joined: $date';
  static String totalCollected(String amount) => 'Total collected: $amount';
  static String rentPerMonth(String amount) => '$amount / month';
  static const String invalidFinanceResponse = 'Invalid finance response';
  static const String failedToLoadFinanceOverview = 'Failed to load finance overview';
  static const String invalidPropertyResponse = 'Invalid property response';
  static const String failedToLoadPropertyPayments = 'Failed to load property payments';
  static const String dashboardOverview = 'Dashboard Overview';
  static const String dashboardSubtitle =
      'Real-time analytics and performance metrics.';
  static const String recentActivity = 'Recent Activity';
  static const String searchResults = 'Search Results';
  static const String totalRentCollections = 'Total Rent Collections';
  static const String pendingPayments = 'Pending Payments';
  static const String totalSubscriptions = 'Total Subscriptions';
  static const String subscriptionExpired = 'Subscription Expired';
  static const String recentRentCollections = 'Recent Rent Collections';
  static const String recentSubscriptions = 'Recent Subscriptions';
  static const String recentServiceRequests = 'Recent Service Requests';
  static const String property = 'Property';
  static const String document = 'Document';
  static const String support = 'Support';
  static const String noRecentServiceRequests = 'No recent service requests found.';
  static const String noRecentRentCollections = 'No recent rent collections found.';
  static const String noRecordsFound = 'No records found.';
  static const String location = 'Location';
  static const String issue = 'Issue';
  static const String raisedDate = 'Raised Date';
  static const String resolvedDate = 'Resolved Date';
  static const String activity = 'Activity';
  static const String category = 'Category';
  static const String message = 'Message';
  static const String uploaded = 'Uploaded';
  static const String statusSolved = 'Solved';
  static const String statusPending = 'Pending';
  static const String statusInProgress = 'In Progress';
  static const String statusRented = 'Rented';
  static const String statusAvailable = 'Available';
  static String raisedOn(String d) => 'Raised: $d';
  static String solvedOn(String d) => 'Solved: $d';
  static String paidOn(String d) => 'Paid: $d';
  static String addedOn(String d) => 'Added: $d';
  static String createdOn(String d) => 'Created: $d';
  static String requestedOn(String d) => 'Requested: $d';
  static String advance(String v) => 'Advance: $v';
  static String rent(String v) => 'Rent: $v';
  static String usedProperties(int n) => '$n Used Properties';
  static String slotsFilled(int n) => '$n Slots filled';
  static String documentType(String type) => '${type.toUpperCase()} Document';
  static String tenantReported(String issue, String date) =>
      'Tenant reported: $issue. Request raised on $date.';
  static const String unknownLocation = 'Unknown Location';
  static const String unknownProperty = 'Unknown Property';
  static const String noTenant = 'No Tenant';
  static const String noLandlord = 'No Landlord';
  static const String noDescription = 'No Description';
  static const String serviceRequestDetails = 'Service Request Details';
  static const String propertyDetails = 'Property Details';
  static const String documentPreview = 'Document Preview';
  static const String downloadFile = 'Download File';
  static const String previewUnavailable = 'Preview not available';
  static const String imageLoadFailed = 'Image load failed';
  static const String imageNotFound = 'Image not found';
  static const String couldNotLaunchDownload = 'Could not launch download link.';
  static const String noValidDownloadLink = 'No valid download link found.';
  static const String noMessagesYet = 'No messages yet';
  static const String noMessagesSubtitle =
      "The tenant and landlord haven't\nchatted about this issue yet.";
  static const String chatReadOnly =
      'Chat is read-only. Admin can view conversation history.';
}