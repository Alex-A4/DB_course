import 'package:db_course_mobile/src/models/subcategory.dart';
import 'package:flutter/material.dart';

class MasterCategoryItem extends StatelessWidget {
  final double priceCoef;
  final String categoryName;
  final List<Subcategory> subcategories;

  MasterCategoryItem({
    Key key,
    @required this.categoryName,
    @required this.subcategories,
    @required this.priceCoef,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 5, bottom: 5),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                categoryName,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ...subcategories
                  .map((s) => SubcategoryWidget(
                        subcategory: s,
                        priceCoef: priceCoef,
                      ))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }
}

class SubcategoryWidget extends StatelessWidget {
  final double priceCoef;
  final Subcategory subcategory;

  SubcategoryWidget(
      {Key key, @required this.subcategory, @required this.priceCoef})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: ListTile(
        onTap: () {},
        title: Text(subcategory.name),
        trailing: Text('${subcategory.executionTime} мин.'),
        subtitle: Text('${(subcategory.price * priceCoef).toInt()} руб.'),
      ),
    );
  }
}
