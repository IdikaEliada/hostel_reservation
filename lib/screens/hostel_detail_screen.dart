import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hostel_reservation/widgets/app_footer.dart';

class HostelDetailScreen extends StatefulWidget {
  final String hostelId;
  final Map<String, dynamic>? hostelData;

  const HostelDetailScreen({
    super.key,
    required this.hostelId,
    this.hostelData,
  });

  @override
  State<HostelDetailScreen> createState() => _HostelDetailScreenState();
}

class _HostelDetailScreenState extends State<HostelDetailScreen> {
  int _currentImageIndex = 0;
  List<String> _images = [];

  @override
  void initState() {
    super.initState();
    _parseImages();
  }

  void _parseImages() {
    final urls = widget.hostelData?['imageUrls'];
    if (urls is List) {
      _images = urls.map((e) => e.toString()).toList();
    } else {
      final singleUrl = widget.hostelData?['imageUrl'];
      if (singleUrl is String) {
        _images = [singleUrl];
      }
    }

    // Fallback if no images found
    if (_images.isEmpty) {
      _images = ['https://via.placeholder.com/600x400?text=No+Image'];
    }
  }

  void _prevImage() {
    setState(() {
      if (_currentImageIndex > 0) {
        _currentImageIndex--;
      } else {
        _currentImageIndex = _images.length - 1;
      }
    });
  }

  void _nextImage() {
    setState(() {
      if (_currentImageIndex < _images.length - 1) {
        _currentImageIndex++;
      } else {
        _currentImageIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.hostelData?['name'] ?? 'Hostel Details';
    final totalRooms = widget.hostelData?['totalRooms'];
    final availableRooms = widget.hostelData?['availableRooms'];

    return Scaffold(
      bottomNavigationBar: const AppFooter(),
      appBar: AppBar(
        title: const Text('Hostel Info'),
        backgroundColor: Colors.white,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        foregroundColor: Colors.black,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.push('/hostels');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Image Display
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Stack(
                  children: [
                    Image.network(
                      _images[_currentImageIndex],
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 250,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                    ),
                    if (_images.length > 1)
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_currentImageIndex + 1}/${_images.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Carousel Controls
              if (_images.length > 1)
                SizedBox(
                  height: 80,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _prevImage,
                        icon: const Icon(Icons.arrow_back_ios, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      Expanded(
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _images.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final isSelected = index == _currentImageIndex;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _currentImageIndex = index),
                              child: Container(
                                width: 100,
                                decoration: BoxDecoration(
                                  border: isSelected
                                      ? Border.all(
                                          color: Theme.of(context).primaryColor,
                                          width: 2,
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    _images[index],
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Center(
                                              child: Icon(
                                                Icons.error,
                                                size: 16,
                                              ),
                                            ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: _nextImage,
                        icon: const Icon(Icons.arrow_forward_ios, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              Text(name, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              if (totalRooms != null)
                Text(
                  'Total Rooms: $totalRooms',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontSize: 20),
                ),
              if (availableRooms != null)
                Text(
                  'Available Rooms: $availableRooms',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontSize: 20),
                ),
              const SizedBox(height: 54),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green[800],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    context.push('/hostel/${widget.hostelId}/rooms');
                  },
                  child: const Text(
                    'View Rooms',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
