import 'package:http/http.dart' as http;
import 'package:wx_styleloft_project_flutter/model/clothing.dart';
import 'dart:convert';

class HttpService {
  // static const String _url = 'https://api.escuelajs.co/api/v1/products'; // Replace with the correct API URL
  //   static const String _baseurl = 'https://api.escuelajs.co/api/v1/products'; // Replace with the correct API URL
    static const String _url = 'https://fakestoreapi.com/products/'; // Replace with the correct API URL
    static const String _baseurl = 'https://fakestoreapi.com/products'; // Replace with the correct API URL

  static Future<List<Clothing>?> getClothing(String filterString) async {
    var uri = Uri.parse(_url);
    try {
      final response = await http.get(uri, headers: {
        // 'AccountKey': 'your-api-key-here',
        'accept': 'application/json',
      });
      
      if (response.statusCode == 200) {
        List<Clothing> clothingList = clothingFromJson(response.body);

        // Apply filter to the list of clothing
        return filterList(clothingList, filterString);
      } else {
        return null;
      }
    } catch (e) {
      print('Error: ${e.toString()}');
      return null;
    }
  }

    /// Fetch a single product by ID (NEW FUNCTION)
  static Future<Clothing?> getProductById(String productId) async {
    final url = Uri.parse('$_baseurl/$productId'); // Assuming API supports GET /products/{id}
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Clothing.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  }

  static List<Clothing> filterList(List<Clothing> clothingList, String filterString) {
    return clothingList.where((clothing) {
      return clothing.title.toLowerCase().contains(filterString.toLowerCase()) ||
             clothing.description.toLowerCase().contains(filterString.toLowerCase()) ||
             clothing.category.name.toString().toLowerCase().contains(filterString.toLowerCase());
    }).toList();
  }
}
