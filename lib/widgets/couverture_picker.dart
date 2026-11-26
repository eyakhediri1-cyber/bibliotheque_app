import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bibliotheque_app/database/sql_helper.dart';
import 'package:bibliotheque_app/services/book_cover_service.dart';

class CouverturePicker extends StatefulWidget {
  final String? initialImage;
  final ValueChanged<String?> onChanged;
  final String initialQuery;

  const CouverturePicker({
    super.key,
    this.initialImage,
    this.initialQuery = '',
    required this.onChanged,
  });

  @override
  State<CouverturePicker> createState() => _CouverturePickerState();
}

class _CouverturePickerState extends State<CouverturePicker> {
  String? image;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _searchController = TextEditingController();

  List<BookCover> results = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    image = widget.initialImage;
    _searchController.text = widget.initialQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 900,
    );

    if (file == null) return;

    final bytes = await file.readAsBytes();
    final encoded = SQLHelper.encoderCouverture(bytes);

    if (!mounted) return;

    setState(() => image = encoded);
    widget.onChanged(encoded);
  }

  Future<void> _searchBooks() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      loading = true;
      results = [];
    });

    final books = await BookCoverService.search(query);

    if (!mounted) return;

    setState(() {
      results = books;
      loading = false;
    });
  }

  void _selectOnlineCover(BookCover book) {
    setState(() => image = book.imageUrl);
    widget.onChanged(book.imageUrl);
  }

  Widget _buildPreview() {
    if (image == null || image!.isEmpty) {
      return const Icon(Icons.menu_book, size: 65, color: Colors.grey);
    }

    if (image!.startsWith('base64:')) {
      final bytes = SQLHelper.decoderCouverture(image);
      if (bytes == null) {
        return const Icon(Icons.broken_image, size: 50);
      }
      return Image.memory(bytes, fit: BoxFit.cover);
    }

    if (image!.startsWith('http://') || image!.startsWith('https://')) {
      return Image.network(
        image!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const Icon(Icons.broken_image, size: 50),
      );
    }

    return Image.file(
      File(image!),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const Icon(Icons.broken_image, size: 50),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Couverture du livre',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: 125,
            height: 165,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildPreview(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _selectGallery,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galerie'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    image = null;
                    results = [];
                  });
                  widget.onChanged(null);
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Supprimer'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Titre ou ISBN du livre',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              onPressed: loading ? null : _searchBooks,
              icon: const Icon(Icons.search),
            ),
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) => _searchBooks(),
        ),
        const SizedBox(height: 8),
        if (loading) const Center(child: CircularProgressIndicator()),
        if (!loading && results.isNotEmpty)
          SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: results.length,
              itemBuilder: (context, index) {
                final book = results[index];

                return GestureDetector(
                  onTap: () => _selectOnlineCover(book),
                  child: Container(
                    width: 105,
                    margin: const EdgeInsets.only(right: 10),
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.network(
                            book.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(Icons.book),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        if (!loading && results.isEmpty && _searchController.text.isNotEmpty)
          const Text(
            'Aucune couverture trouvée.',
            style: TextStyle(color: Colors.grey),
          ),
      ],
    );
  }
}
