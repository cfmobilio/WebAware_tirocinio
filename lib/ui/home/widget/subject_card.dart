import 'package:flutter/material.dart';
import '../../../models/subject_model.dart';

class SubjectCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback onTap;

  const SubjectCard({required this.subject, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.asset(subject.iconaAsset, width: 40, height: 40),
        title: Text(subject.titolo),
        onTap: onTap,
      ),
    );
  }
}
