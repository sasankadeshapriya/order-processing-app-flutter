class printSettings {
  String organizationName;
  String addressLine01;
  String addressLine02;
  String softwareCompany;
  String companyPhoneNumber;

  printSettings({
    required this.organizationName,
    required this.addressLine01,
    required this.addressLine02,
    required this.softwareCompany,
    required this.companyPhoneNumber,
  });

  // Example method to fetch settings from a local source or API
  static Future<printSettings> fetchSettings() async {
    // This is a placeholder for fetching data, replace with actual data fetch
    return printSettings(
      organizationName: 'Genius Soft Pvt Ltd',
      addressLine01: '274 2/1, High level road',
      addressLine02: 'Maharagama',
      softwareCompany: 'Software by Genius Soft(Pvt)Ltd.',
      companyPhoneNumber: '071-368-2002',
    );
  }
}
