import 'package:flutter/material.dart';

class AlertsTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String message;

  const AlertsTile({
    required this.title,
    required this.icon,
    required this.message,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Ink(
              decoration: ShapeDecoration(
                color: Colors.grey[200],
                shape: const CircleBorder(),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(icon, color: Colors.black, size: 30),
              ),
            ),

            const SizedBox(width: 10),

            // ✅ Expanded must wrap the column directly
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
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
