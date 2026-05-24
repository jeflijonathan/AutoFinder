import 'package:flutter/material.dart';

class Header extends StatefulWidget {
  final String title;
  final String? subtitle;
  const Header({super.key, required this.title, this.subtitle});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        if (widget.subtitle != null && widget.subtitle!.isNotEmpty)
          Text(
            widget.subtitle ?? '',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
      ],
    );
  }
}
