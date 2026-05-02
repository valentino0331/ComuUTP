// lib/widgets/course_card.dart

import 'package:flutter/material.dart';
import '../models/study_models.dart';

class CourseCard extends StatelessWidget {
  final StudyCourse course;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const CourseCard({
    Key? key,
    required this.course,
    required this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                Color(0xFF2563EB).withOpacity(0.1),
                const Color(0xFFB21132).withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        course.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFB21132),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (onDelete != null)
                      IconButton(
                        icon: Icon(Icons.more_vert),
                        onPressed: () {
                          showMenu(
                            context: context,
                            position: RelativeRect.fromLTRB(100, 0, 0, 100),
                            items: [
                              PopupMenuItem(
                                child: Text('Eliminar'),
                                value: 'delete',
                              ),
                            ],
                          ).then((value) {
                            if (value == 'delete') {
                              onDelete!();
                            }
                          });
                        },
                      ),
                  ],
                ),
                SizedBox(height: 8),
                if (course.courseCode != null)
                  Text(
                    'Código: ${course.courseCode}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                if (course.professorName != null)
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Prof. ${course.professorName}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                if (course.description != null && course.description!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      course.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF2563EB).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'S${course.semester ?? '?'} - ${course.year ?? '2024'}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
