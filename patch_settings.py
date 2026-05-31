import re

with open('lib/screens/settings_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

if "import '../services/auth_service.dart';" not in content:
    content = content.replace("import '../services/app_data.dart';", "import '../services/auth_service.dart';\nimport '../services/app_data.dart';")

switch_method = """
  void _showSwitchAccountModal(BuildContext context) async {
    final accounts = await AuthService.instance.getSavedAccounts();
    if (!context.mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, MediaQuery.of(ctx).padding.bottom + 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2.r))),
            SizedBox(height: 20.h),
            Text('Beralih Akun', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            Text('Pilih akun yang pernah login sebelumnya', style: TextStyle(fontSize: 13.sp, color: Colors.grey)),
            SizedBox(height: 24.h),
            ...accounts.map((acc) {
              final isCurrent = acc['email'] == data.userEmail;
              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                leading: CircleAvatar(
                  backgroundColor: isCurrent ? AppTheme.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  child: Text(acc['name']![0].toUpperCase(), style: TextStyle(color: isCurrent ? AppTheme.primary : Colors.grey)),
                ),
                title: Text(acc['name']!, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(acc['email']!),
                trailing: isCurrent ? Icon(Icons.check_circle_rounded, color: AppTheme.primary) : null,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                tileColor: isCurrent ? AppTheme.primary.withOpacity(0.05) : null,
                onTap: () async {
                  if (isCurrent) {
                    Navigator.pop(ctx);
                    return;
                  }
                  await AuthService.instance.switchAccount(acc['email']!, acc['name']!);
                  await AppData.instance.loadUserData(acc['email']!);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              );
            }).toList(),
            SizedBox(height: 16.h),
            Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
            SizedBox(height: 16.h),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              leading: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Icon(Icons.add_rounded, color: AppTheme.primary),
              ),
              title: Text('Tambah Akun KampusGo Baru', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
              onTap: () {
                Navigator.pop(ctx);
                widget.onLogout();
              },
            ),
          ],
        ),
      ),
    );
  }
"""

if "void _showSwitchAccountModal" not in content:
    content = content.replace("  Widget _sectionTitle(String title) {", switch_method + "\n  Widget _sectionTitle(String title) {")

switch_button = """
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                onPressed: () => _showSwitchAccountModal(context),
                icon: Icon(Icons.people_alt_rounded, color: AppTheme.primary),
                label: Text('Beralih Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: AppTheme.primary)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  foregroundColor: AppTheme.primary,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                  elevation: 0,
                ),
              ),
              SizedBox(height: 16.h),
"""

content = content.replace("              SizedBox(height: 36.h);\n              // Tombol Keluar Akun", switch_button + "              // Tombol Keluar Akun")

with open('lib/screens/settings_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
