import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_modal.dart';

class AddEditRoomScreen extends StatefulWidget {
  final String? roomId;
  final Map<String, dynamic>? initialData;

  const AddEditRoomScreen({super.key, this.roomId, this.initialData});

  @override
  State<AddEditRoomScreen> createState() => _AddEditRoomScreenState();
}

class _AddEditRoomScreenState extends State<AddEditRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _customPriceController = TextEditingController();
  String? _selectedHostelId;
  String? _selectedRoomTypeId;
  bool _isAvailable = true;
  bool _isLoading = false;

  // Metadata
  List<Map<String, dynamic>> _hostels = [];
  List<Map<String, dynamic>> _roomTypes = [];

  List<String> _occupants = [];

  @override
  void initState() {
    super.initState();
    _fetchMetadata();
    if (widget.initialData != null) {
      _nameController.text = widget.initialData!['name'] ?? '';
      _selectedHostelId = widget.initialData!['hostelId'];
      _selectedRoomTypeId = widget.initialData!['roomTypeId'];
      _isAvailable = widget.initialData!['isAvailable'] ?? true;
      _occupants = List<String>.from(widget.initialData!['occupants'] ?? []);

      if (widget.initialData!['customPrice'] != null) {
        _customPriceController.text = widget.initialData!['customPrice']
            .toString();
      }
    } else if (widget.roomId != null) {
      // Fetch if initialData not passed (though we try to pass it)
      _fetchRoomData();
    }
  }

  Future<void> _fetchMetadata() async {
    try {
      final hostelsSnapshot = await FirebaseFirestore.instance
          .collection('hostels')
          .get();
      final roomTypesSnapshot = await FirebaseFirestore.instance
          .collection('room_types')
          .get();

      if (mounted) {
        setState(() {
          _hostels = hostelsSnapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
          _roomTypes = roomTypesSnapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading metadata: $e')));
      }
    }
  }

  Future<void> _fetchRoomData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(widget.roomId)
          .get();
      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _selectedHostelId = data['hostelId'];
          _selectedRoomTypeId = data['roomTypeId'];
          _isAvailable = data['isAvailable'] ?? true;
          _occupants = List<String>.from(data['occupants'] ?? []);

          if (data['customPrice'] != null) {
            _customPriceController.text = data['customPrice'].toString();
          }
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  int get _maxCapacity {
    if (_selectedRoomTypeId == null) return 0;
    final type = _roomTypes.firstWhere(
      (t) => t['id'] == _selectedRoomTypeId,
      orElse: () => {},
    );
    return type['capacity'] ?? 0;
  }

  void _addOccupant() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => CustomModal(
        title: 'Add Occupant',
        subtitle: 'Enter the student name or ID to assign to this room.',
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Student Name / ID',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
        paramActionText: 'Add',
        onAction: () {
          if (controller.text.isNotEmpty) {
            setState(() {
              _occupants.add(controller.text.trim());
            });
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Future<void> _saveRoom() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedHostelId == null || _selectedRoomTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select hostel and room type')),
      );
      return;
    }

    // Capacity check
    if (_occupants.length > _maxCapacity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Occupants exceed room capacity ($_maxCapacity)'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final customPriceParsed = double.tryParse(
        _customPriceController.text.trim(),
      );

      final roomData = {
        'hostelId': _selectedHostelId,
        'name': _nameController.text.trim(),
        'roomTypeId': _selectedRoomTypeId,
        'isAvailable': _isAvailable,
        'occupants': _occupants,
        'customPrice': customPriceParsed,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.roomId != null) {
        await FirebaseFirestore.instance
            .collection('rooms')
            .doc(widget.roomId)
            .update(roomData);
      } else {
        await FirebaseFirestore.instance.collection('rooms').add({
          ...roomData,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room saved successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving room: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.roomId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Room' : 'Add Room')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Room Details'),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration(
                          'Room Name / Number',
                          Icons.meeting_room,
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter a name'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedHostelId,
                        decoration: _inputDecoration('Hostel', Icons.apartment),
                        items: _hostels.map((hostel) {
                          return DropdownMenuItem<String>(
                            value: hostel['id'],
                            child: Text(
                              hostel['name'] ?? 'Unknown',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedHostelId = value),
                        validator: (value) =>
                            value == null ? 'Please select a hostel' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedRoomTypeId,
                        decoration: _inputDecoration(
                          'Room Type',
                          Icons.category,
                        ),
                        items: _roomTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type['id'],
                            child: Text(
                              '${type['name']} (Max: ${type['capacity']}, ₦${type['price']})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedRoomTypeId = value),
                        validator: (value) =>
                            value == null ? 'Please select a room type' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _customPriceController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: _inputDecoration(
                          'Custom Price (Overrides Room Type Default)',
                          Icons.attach_money,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Availability'),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Is Available?',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    _isAvailable
                        ? 'Room can be booked by students'
                        : 'Room is unavailable/under maintenance',
                  ),
                  activeThumbColor: Theme.of(context).primaryColor,
                  value: _isAvailable,
                  onChanged: (value) => setState(() => _isAvailable = value),
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle(
                    'Occupants (${_occupants.length} / $_maxCapacity)',
                  ),
                  TextButton.icon(
                    onPressed: (_occupants.length < _maxCapacity)
                        ? _addOccupant
                        : null,
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              if (_occupants.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    'No occupants assigned yet.',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _occupants.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade50,
                          child: Icon(
                            Icons.person,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        title: Text(
                          _occupants[index],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red,
                          ),
                          onPressed: () =>
                              setState(() => _occupants.removeAt(index)),
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveRoom,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isEdit ? 'Save Changes' : 'Create Room',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey[600]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _customPriceController.dispose();
    super.dispose();
  }
}
