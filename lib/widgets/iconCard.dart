import 'package:flutter/material.dart';

class IconCard extends StatelessWidget {
  const IconCard(this.icon);
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: IconButton(
          onPressed: () {},
          icon: Icon(
            icon,
            color: Color.fromRGBO(42, 156, 164, 1),
          )),
      height: 62,
      width: 62,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
                offset: const Offset(0, 10),
                blurRadius: 22,
                color: Colors.blue.withOpacity(0.22)),
            const BoxShadow(
                offset: Offset(-15, -15), blurRadius: 20, color: Colors.white)
          ]),
    );
  }
}
