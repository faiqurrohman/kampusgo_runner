import os

filepath = 'lib/screens/resource_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

missing_code = """                ScaffoldMessenger.of(context).showSnackBar(
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

"""

# The file currently has `Navigator.pop(context);\n              } else {\n\n  @override\n  Widget build`
# We need to replace `} else {\n\n  @override\n  Widget build` with `} else {\n` + missing_code + `  @override\n  Widget build`

content = content.replace("              } else {\n\n  @override\n  Widget build(BuildContext context) {\n    return Card(", 
                          "              } else {\n" + missing_code + "  @override\n  Widget build(BuildContext context) {\n    return Card(")

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
