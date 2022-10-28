import 'package:flutter/material.dart';

class CardModel extends StatelessWidget {

  final String title;
  final String subtitle;
  final String image;
  final bool? private;
  final Icon icon;
  final bool dark;
  final void Function()? onTapImage;
  final void Function()? onTapIcon;
  final bool updated;
  final bool privateIcon;
  final Color? color;

  const CardModel({Key? key,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.icon,
    this.private,
    required this.dark,
    required this.onTapImage,
    required this.onTapIcon,
    required this.updated,
    required this.privateIcon,
    required this.color
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {

    double w = MediaQuery.of(context).size.width - 4;

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        height: w * 0.375,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: dark ? Colors.grey[800] : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            InkWell(
              onTap: onTapImage,
              child: SizedBox(
                width: w * 0.375,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          image.isNotEmpty ? Image.network(image) : Image.asset('assets/placeholder_1440.jpg'),
                          privateIcon == true ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.lock_outline,
                              color: color,
                              size: 15,
                            ),
                          ) : Container(),
                        ],
                      )
                  ),
                ),
              ),
            ),

            SizedBox(
              width: w * 0.5,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title,
                      style: TextStyle(
                        color: dark ? Colors.grey[300] : Colors.grey[800],
                        fontSize: 20,
                      ),
                      overflow: TextOverflow.fade,
                    ),
                    //SizedBox(height: 5,),
                    Text(subtitle,
                      style: TextStyle(
                        color: dark ? Colors.grey[500] : Colors.grey[700],
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.fade,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(
              width: w * 0.125,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  updated == true ? Icon(
                    Icons.notification_important, color: color, size: 20,
                  ) : Container(),
                  IconButton(
                    icon: icon,
                    onPressed: onTapIcon,
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
