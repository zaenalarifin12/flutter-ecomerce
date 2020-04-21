class NetworkUrl {
  static String baseUrl            =  "http://192.168.42.45/ecom_flutter/";
  static String baseApi            =  baseUrl + "api/";
  static String getProduct         =  baseApi + "getProduct.php";
  static String addProduct         =  baseApi + "addProduct.php";
  static String getProductCategory =  baseApi + "getCategoryProduct.php";
  static String addFavoriteWithoutLogin = baseApi + "/addFavoriteWithoutLogin.php";

  static String getFavoriteWithoutLogin(String text){
    return baseApi + "getFavoriteWithoutLogin.php?deviceInfo=${text}";
  }
}