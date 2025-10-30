// import 'package:app/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:provider/provider.dart';

class MyTextBox extends StatelessWidget {
  final String text;
  final String sectionName;
  final void Function()? onPressed;
  const MyTextBox({
    super.key,
    required this.text,
    required this.sectionName,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // bool isDarkMode =
    //     Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //section name
            Text(
              sectionName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            //edit button
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                //text
                SizedBox(
                  width: 220,
                  child: Text(
                    maxLines: 1, // Giới hạn số dòng
                    overflow: TextOverflow.ellipsis, // Hiển thị dấu ...
                    text,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                FaIcon(
                  FontAwesomeIcons.angleRight,
                  size: 18,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
