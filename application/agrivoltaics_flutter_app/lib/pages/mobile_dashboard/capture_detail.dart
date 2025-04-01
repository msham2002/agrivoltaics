import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CaptureDetailPage extends StatelessWidget {
  final DocumentSnapshot document;

  const CaptureDetailPage({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    final data = document.data() as Map<String, dynamic>;
    final imagePaths = List<String>.from(data['url'] ?? []);

    final timestamp = DateTime.fromMillisecondsSinceEpoch(data['timestamp'].seconds * 1000,).toLocal();

    final dateStr = "${timestamp.month}/${timestamp.day}/${timestamp.year}";
    final timeStr = "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === TOP ROW: Date/Time (left), View Button (right) ===
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Date & Time
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.access_time, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          timeStr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // === DISEASE STATUS CHIP ===
                Chip(
                  label: Text(
                    data['detected_disesase'] == true
                        ? 'Disease Detected'
                        : 'No Disease Detected',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  backgroundColor:
                      data['detected_disesase'] == true ? Colors.red : Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide.none,
                  ),
                  side: BorderSide.none,
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    const Icon(Icons.insights, size: 24),
                    const SizedBox(width: 6),
                    Text(
                      "AI Analysis: ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      data['analysis_summary'],
                    ),
                  ],
                )

              ],
            )
          ),
        ),
        
        const SizedBox(height: 16),

          /// Image Cards
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: imagePaths.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              final path = imagePaths[index];
              final label = path
                  .split('/')
                  .last
                  .split('.')
                  .first
                  .replaceAll('_', ' ')
                  .toUpperCase();
          
              return FutureBuilder<String>(
                future: FirebaseStorage.instance.ref(path).getDownloadURL(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Card(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
              
                  final imageUrl = snapshot.data!;
              
                  final label = Uri.decodeFull(path)
                      .split('/')
                      .last
                      .split('.')
                      .first
                      .replaceAll('_', ' ')
                      .toUpperCase();
              
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          child: InteractiveViewer(
                            child: Image.network(imageUrl),
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              label,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            /*maybe change AspectRatio widget with this
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: 200, // Max height cap
                                maxWidth: double.infinity, // Allow full width but don't stretch
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.contain, // 👈 don't stretch, preserve size
                                  alignment: Alignment.center,
                                ),
                              ),
                            ),
                            */
                            AspectRatio(
                              aspectRatio: 1, // Square-ish thumbnail
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
