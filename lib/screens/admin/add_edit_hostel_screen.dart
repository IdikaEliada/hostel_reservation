import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class AddEditHostelScreen extends StatefulWidget {
  final String? hostelId;
  final Map<String, dynamic>? initialData;

  const AddEditHostelScreen({super.key, this.hostelId, this.initialData});

  @override
  State<AddEditHostelScreen> createState() => _AddEditHostelScreenState();
}

class _AddEditHostelScreenState extends State<AddEditHostelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _totalRoomsController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _nameController.text = widget.initialData!['name'] ?? '';
      _totalRoomsController.text =
          widget.initialData!['totalRooms']?.toString() ?? '0';
      _imageUrlController.text = widget.initialData!['imageUrl'] ?? '';
    } else if (widget.hostelId != null) {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('hostels')
          .doc(widget.hostelId)
          .get();
      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _totalRoomsController.text = data['totalRooms']?.toString() ?? '0';
          _imageUrlController.text = data['imageUrl'] ?? '';
        });
      }
    } catch (_) {}
  }

  Future<void> _deleteHostel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Hostel'),
        content: const Text(
          'Are you sure you want to delete this hostel? All associated rooms should be handled manually.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('hostels')
          .doc(widget.hostelId)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hostel deleted successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveHostel() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final totalRoomsParsed =
          int.tryParse(_totalRoomsController.text.trim()) ?? 0;

      final data = {
        'name': _nameController.text.trim(),
        'totalRooms': totalRoomsParsed,
        'imageUrl': _imageUrlController.text.trim(),
        if (widget.hostelId == null) 'createdAt': FieldValue.serverTimestamp(),
      };

      // Seed an empty imageUrls array or a standard image if it's new
      if (widget.hostelId == null) {
        data['imageUrls'] = [_imageUrlController.text.trim()];
        data['availableRooms'] = totalRoomsParsed; // Initial available is all
      }

      if (widget.hostelId != null) {
        await FirebaseFirestore.instance
            .collection('hostels')
            .doc(widget.hostelId)
            .update(data);
      } else {
        await FirebaseFirestore.instance.collection('hostels').add(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hostel saved successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.hostelId != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Hostel' : 'Add Hostel'),
        backgroundColor: const Color(0xFF008000),
        foregroundColor: Colors.white,
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isLoading ? null : _deleteHostel,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Hostel Name',
                  prefixIcon: const Icon(Icons.apartment),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required field' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _totalRoomsController,
                decoration: InputDecoration(
                  labelText: 'Total Room Capacity',
                  prefixIcon: const Icon(Icons.format_list_numbered),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required field' : null,
              ),

              const SizedBox(height: 32),
              if (isEdit)
                OutlinedButton.icon(
                  onPressed: () => context.push(
                    Uri(
                      path: '/admin/rooms',
                      queryParameters: {'hostelId': widget.hostelId},
                    ).toString(),
                  ),
                  icon: const Icon(Icons.meeting_room),
                  label: const Text('Manage All Rooms'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              if (isEdit) const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveHostel,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF008000),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isEdit ? 'Update Hostel' : 'Create Hostel',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
