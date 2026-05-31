import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_data.dart';
import '../utils/app_theme.dart';
import '../widgets/section_title.dart';

class ResourceScreen extends StatefulWidget {
  const ResourceScreen({super.key});

  @override
  State<ResourceScreen> createState() => _ResourceScreenState();
}

class _ResourceScreenState extends State<ResourceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedTag = 'Semua';

  final List<String> _tags = ['Semua', 'Kuliah', 'Organisasi', 'Lomba'];

  Color _getTagColor(String tag) {
    switch (tag) {
      case 'Kuliah':
        return AppTheme.primary;
      case 'Organisasi':
        return AppTheme.secondary;
      case 'Lomba':
        return AppTheme.accent;
      default:
        return Colors.teal;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = AppData.instance;
    return AnimatedBuilder(
      animation: data,
      builder: (_, __) {
        // Filter resources based on Search Query and Selected Tag
        final filteredResources = data.resources.where((res) {
          final matchesTag = _selectedTag == 'Semua' || res.tag == _selectedTag;
          final matchesSearch = _searchQuery.isEmpty ||
              res.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              res.course.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              res.link.toLowerCase().contains(_searchQuery.toLowerCase());
          return matchesTag && matchesSearch;
        }).toList();

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddSheet(context),
            backgroundColor: AppTheme.primary,
            elevation: 4,
            child: Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
          body: SafeArea(
          child: Column(
            children: [
              // Header & Section Title with padding
              Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(
                      title: 'Community Resource Hub',
                      subtitle: 'Simpan link materi, Zoom/Meet, dan arsip penting kuliah.',
                    ),
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Cari judul, matkul, atau link...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 16.w, right: 12.w),
                          child: Icon(Icons.search_rounded),
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.only(right: 8.w),
                                child: IconButton(
                                  icon: Icon(Icons.clear_rounded),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                ),
                              )
                            : null,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Categories / Tagging horizontal scroll
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _tags.map((tag) {
                          final isSelected = _selectedTag == tag;
                          final tagColor = tag == 'Semua' ? AppTheme.primary : _getTagColor(tag);
                          return Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: FilterChip(
                              label: Text(tag),
                              selected: isSelected,
                              selectedColor: tagColor.withOpacity(0.2),
                              checkmarkColor: tagColor,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? tagColor
                                    : Theme.of(context).textTheme.bodyMedium?.color,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                                side: BorderSide(
                                  color: isSelected ? tagColor : Theme.of(context).dividerColor.withOpacity(0.1),
                                ),
                              ),
                              onSelected: (_) => setState(() => _selectedTag = tag),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Add Resource Button
                    // Elevated button dihapus




                    SizedBox(height: 16.h),
                  ],
                ),
              ),
              // Resources List
              Expanded(
                child: filteredResources.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_off_rounded,
                              size: 64,
                              color: Theme.of(context).dividerColor.withOpacity(0.2),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'Tidak ada resource ditemukan',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Coba gunakan kata kunci atau kategori lain.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 80),
                        itemCount: filteredResources.length,
                        itemBuilder: (context, index) {
                          final res = filteredResources[index];
                          final tagColor = _getTagColor(res.tag);
                          return Dismissible(
                            key: ValueKey(res.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => data.deleteResource(res.id),
                            background: Container(
                              margin: EdgeInsets.only(bottom: 12.h),
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 20.w),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(32.r),
                              ),
                              child: Icon(Icons.delete_rounded, color: Colors.white),
                            ),
                            child: _ExpandableResourceCard(
                              res: res,
                              tagColor: tagColor,
                              onCopy: () async {
                                await Clipboard.setData(ClipboardData(text: res.link));
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Link berhasil disalin!'),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16.r),
                                      ),
                                    ),
                                  );
                                }
                              },
                              onOpen: () async {
                                final uri = Uri.tryParse(res.link);
                                if (uri != null) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      );
      },
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddResourceSheet(),
    );
  }
}

class _AddResourceSheet extends StatefulWidget {
  const _AddResourceSheet();

  @override
  State<_AddResourceSheet> createState() => _AddResourceSheetState();
}

class _AddResourceSheetState extends State<_AddResourceSheet> {
  final _courseController = TextEditingController();
  final _titleController = TextEditingController();
  final _linkController = TextEditingController(text: 'https://');
  String _selectedTag = 'Kuliah';

  final List<String> _tags = ['Kuliah', 'Organisasi', 'Lomba'];

  @override
  void dispose() {
    _courseController.dispose();
    _titleController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 24.h, bottom: bottomInset + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Tambah Resource Baru',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20.h),
          TextField(
            controller: _courseController,
            decoration: const InputDecoration(labelText: 'Mata Kuliah / Topik'),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Judul Resource'),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: _linkController,
            decoration: const InputDecoration(labelText: 'Link URL'),
          ),
          SizedBox(height: 16.h),
          Text(
            'Kategori Tag',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Row(
            children: _tags.map((tag) {
              final isSelected = _selectedTag == tag;
              Color tagColor;
              if (tag == 'Kuliah') tagColor = AppTheme.primary;
              else if (tag == 'Organisasi') tagColor = AppTheme.secondary;
              else tagColor = AppTheme.accent;

              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: ChoiceChip(
                  label: Text(tag),
                  selected: isSelected,
                  selectedColor: tagColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? tagColor : Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    side: BorderSide(
                      color: isSelected ? tagColor : Theme.of(context).dividerColor.withOpacity(0.1),
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedTag = tag);
                  },
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              final course = _courseController.text.trim();
              final title = _titleController.text.trim();
              final link = _linkController.text.trim();
              if (course.isNotEmpty && title.isNotEmpty && link.startsWith('http')) {
                AppData.instance.addResource(course, title, link, _selectedTag);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Harap lengkapi semua kolom dengan benar.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text('Simpan Resource'),
          ),
        ],
      ),
    );
  }
}

class _ExpandableResourceCard extends StatefulWidget {
  final dynamic res;
  final Color tagColor;
  final VoidCallback onCopy;
  final VoidCallback onOpen;

  const _ExpandableResourceCard({
    required this.res,
    required this.tagColor,
    required this.onCopy,
    required this.onOpen,
  });

  @override
  State<_ExpandableResourceCard> createState() => _ExpandableResourceCardState();
}

class _ExpandableResourceCardState extends State<_ExpandableResourceCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: _isExpanded ? _buildExpanded() : _buildCollapsed(),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsed() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildIcon(),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.res.title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  _buildTagBadge(),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                '${widget.res.course}\n${widget.res.link}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 20),
              onPressed: widget.onCopy,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            IconButton(
              icon: const Icon(Icons.open_in_new_rounded, size: 20),
              onPressed: widget.onOpen,
              color: AppTheme.primary,
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
          ],
        ),
      ],
    );
  }

  Widget _buildExpanded() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildIcon(),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                widget.res.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
            ),
            SizedBox(width: 8.w),
            _buildTagBadge(),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          widget.res.course,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        SelectableText(
          widget.res.link,
          style: TextStyle(fontSize: 13.sp, color: Colors.blueAccent),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('Salin'),
                  onPressed: widget.onCopy,
                ),
                SizedBox(width: 8.w),
                ElevatedButton.icon(
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('Buka Link'),
                  onPressed: widget.onOpen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            Icon(Icons.keyboard_arrow_up_rounded, color: Colors.grey),
          ],
        ),
      ],
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: widget.tagColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Icon(Icons.link_rounded, color: widget.tagColor),
    );
  }

  Widget _buildTagBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: widget.tagColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: widget.tagColor.withOpacity(0.3)),
      ),
      child: Text(
        widget.res.tag,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: widget.tagColor,
        ),
      ),
    );
  }
}
