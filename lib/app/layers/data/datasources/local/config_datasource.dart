abstract class IConfigDatasource {
  Future<Map<String, String>?> loadAddresses();
  Future<void> saveAddresses(Map<String, String> strings);
  Future<String?> loadLastLoggedEmail();
  Future<void> saveLastLoggedEmail(String email);
  Future<String?> loadLastLoggedPassword();
  Future<void> saveLastLoggedPassword(String password);
  Future<String> version();
  Future<void> company(String value);
  Future<String> loadCompany();
  Future<void> saveConfig(String value);
  Future<String> loadConfig();
}
