import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final Function(String) onSearch;
  final String hint;
  const CustomSearchBar({super.key, required this.onSearch, required this.hint});

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      hintText: hint,
      leading: const Icon(
        Icons.search,
        color: Color.fromRGBO(153, 161, 175, 1),
      ),
      onChanged: (value) {},
      onSubmitted: (value) {
        onSearch(value);
      },
    );
  }
}
