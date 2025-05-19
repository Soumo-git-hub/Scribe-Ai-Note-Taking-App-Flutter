import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:convert';

class MindMapWidget extends StatelessWidget {
  final Map<String, dynamic>? mindMapData;

  const MindMapWidget({super.key, required this.mindMapData});

  @override
  Widget build(BuildContext context) {
    if (mindMapData == null) {
      return const Center(child: Text('No mind map data available'));
    }

    // Parse mind map data if it's a string
    Map<String, dynamic> data = mindMapData!;
    if (mindMapData is String) {
      try {
        data = json.decode(mindMapData as String);
      } catch (e) {
        return const Center(child: Text('Invalid mind map data'));
      }
    }

    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildMindMap(data),
          ),
        ),
      ),
    );
  }

  Widget _buildMindMap(Map<String, dynamic> data) {
    final centralTopic = data['central_topic'] ?? 'Main Topic';
    final branches = data['branches'] as List? ?? [];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Central Topic
        _buildCentralTopic(centralTopic),
        const SizedBox(height: 40),
        // Branches
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < branches.length; i++)
              _buildBranch(branches[i], i, branches.length),
          ],
        ),
      ],
    );
  }

  Widget _buildCentralTopic(String topic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        topic,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBranch(Map<String, dynamic> branch, int index, int totalBranches) {
    final topic = branch['topic'] ?? 'Branch';
    final subtopics = branch['subtopics'] as List? ?? [];
    final colors = [
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    final color = colors[index % colors.length];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Branch Topic
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color, width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              topic,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Connection Line
          Container(
            width: 2,
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withOpacity(0.5),
                  color.withOpacity(0.3),
                ],
              ),
            ),
          ),
          // Subtopics
          ...subtopics.map((subtopic) {
            final text = subtopic is String ? subtopic : subtopic['text'] ?? '';
            final details = subtopic is Map ? (subtopic['details'] as List? ?? []) : [];
            
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: color.withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: color,
                        ),
                      ),
                      if (details.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        ...details.map((detail) => Padding(
                          padding: const EdgeInsets.only(left: 12, top: 3),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 6,
                                color: color.withOpacity(0.8),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  detail.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: color.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ],
                    ],
                  ),
                ),
                // Connection Line
                if (subtopic != subtopics.last) // Only show connection line if not the last subtopic
                  Container(
                    width: 2,
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          color.withOpacity(0.3),
                          color.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
} 