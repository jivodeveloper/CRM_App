

import 'package:crm_flutter/Model/MenuList.dart';

class User {

  late List<MenuList> menuList;
  late int empid;
  late String empNm;

  User({required this.menuList,required this.empid, required this.empNm});

  User.fromJson(Map<String, dynamic> json) {
    if (json['menu_list'] != null) {
      menuList = <MenuList>[];
      json['menu_list'].forEach((v) {
        menuList.add(new MenuList.fromJson(v));
      });
    }
    empid = json['empid'];
    empNm = json['empNm'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.menuList != null) {
      data['menu_list'] = this.menuList.map((v) => v.toJson()).toList();
    }
    data['empid'] = this.empid;
    data['empNm'] = this.empNm;
    return data;
  }
}