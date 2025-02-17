# CPMAD WeiXuan StyleLoft Project 
Name: Wei Xuan <br>
Module Group: L1
<br> 
## Project Title
**TheStyleLoft** <br>
## Background
**A New Era of Fashion**

In today's fast-paced world, online shopping has transformed the way we shop for clothes. The convenience of browsing and purchasing from the comfort of our homes has revolutionized the retail industry.

**StyleLoft** is born from this digital revolution. Our mission is to bring you a curated selection of stylish and affordable clothing, delivered right to your doorstep. We believe that fashion should be accessible to everyone, without compromising on quality or style.

By leveraging the power of e-commerce, we aim to create a seamless shopping experience. Our user-friendly platform allows you to effortlessly explore our collections, discover the latest trends, and make informed purchasing decisions.
<br>

## Setting Up
-  Go to pubspec.yaml and ctrl save or do a pub get , if not will have error and program can't be start

## Key Functional Features
-  **Login/Logout/Registration**
-  **View And Edit Profile**
-  **View About Us**
    - Comes with a google map with two markers to showcase the shop location<br>
-  **Dsiplay Produt**
    -  Display Prodcut From Api json dataset<br>
    -  Allow user to add product to favourite<br>
-  **Search For Clothing**
    - Search By Name<br>
-  **Filter Function**
    -  By Category<br>
    -  By Price <br>
-  **Shopping Cart:**
    - Users can add products to their shopping cart.
    - Allow use to add or remove product
    - Show the total price of product in the cart
    - Allow user to do a dummy payment.
-  **OrderHistoryDetails & OrderHistory**
    - OrderHistory shall show all orders made by the current user.
    - OrderHistoryDetails shall show all details of the order like the total price and date ordered.
    - OrderHistroyDetails shall allow user to readd the purchased item back to the cart.
-  **Authentication and Authorization:**
    - Users must be logged in to add products to their cart or modify quantities.



## External API(s)
- FakeStore Api 
  - Use to retrieve the product<br>
https://fakestoreapi.com/
<br> 
## All Additional Dependencies used (excluding firebase,google map , location & badges)

```
- `uuid` // for generating random cart id
- `intl` // for date formating using in orderhistory and detail page.
- `flutter_staggered_grid_view` // for use of massonagry grid view builder to create dynamic height for product home 
```

## Data Source, Storage & State Management Methods <br>
• Source
- JSON API dataset
Authentication
- Firebase Authentication
Stat Management
- Provider 


