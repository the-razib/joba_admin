import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/app_toast.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
import 'package:joba_admin/features/admin_management/controllers/admin_profile_controller.dart';
import 'package:joba_admin/features/admin_management/models/admin_user.dart';
import 'package:joba_admin/features/admin_management/views/widgets/admin_role_badge.dart';

/// Minimal, high-end administrative profile dialog.
class AdminProfileDialog extends StatefulWidget {
  const AdminProfileDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const AdminProfileDialog(),
    );
  }

  @override
  State<AdminProfileDialog> createState() => _AdminProfileDialogState();
}

class _AdminProfileDialogState extends State<AdminProfileDialog>
    with SingleTickerProviderStateMixin {
  late final AdminProfileController _controller;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(AdminProfileController());
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    Get.delete<AdminProfileController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final width = MediaQuery.of(context).size.width;
    final dialogWidth = width > 620 ? 580.0 : width * 0.94;

    return Dialog(
      backgroundColor: palette.card,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: palette.border, width: 1),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTopBar(context),
              _buildProfileSummary(context),
              _buildTabBar(context),
              Flexible(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGeneralTab(context),
                    _buildSecurityTab(context),
                    _buildPrivilegesTab(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Minimal clean top bar
  Widget _buildTopBar(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: palette.card,
        border: Border(bottom: BorderSide(color: palette.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Profile',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Manage your account credentials, security and role access',
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close',
            splashRadius: 18,
            icon: Icon(Icons.close, size: 18, color: palette.textSecondary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// Modern, minimal profile summary card
  Widget _buildProfileSummary(BuildContext context) {
    final palette = context.palette;

    return Obx(() {
      final user = _controller.user;
      final isUploading = _controller.isUploadingPhoto.value;
      final hasPhoto = user?.photoUrl != null && user!.photoUrl!.isNotEmpty;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: palette.inputFill.withValues(alpha: 0.35),
          border: Border(bottom: BorderSide(color: palette.border)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Minimal Avatar with loading state
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: palette.border, width: 1.5),
                  ),
                  child: AvatarCircle(
                    name: user?.name ?? 'Admin',
                    url: user?.photoUrl,
                    size: 58,
                  ),
                ),
                if (isUploading)
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.45),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // User details and direct minimal action buttons
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user?.name ?? 'Admin User',
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (user != null) AdminRoleBadge(role: user.role),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 12.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          side: BorderSide(color: palette.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: isUploading
                            ? null
                            : () => _controller.pickAndUploadPhoto(),
                        icon: const Icon(Icons.upload_outlined, size: 14),
                        label: Text(
                          hasPhoto ? 'Change photo' : 'Upload photo',
                          style: const TextStyle(fontSize: 11.5),
                        ),
                      ),
                      if (hasPhoto)
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            foregroundColor: AppColors.danger,
                          ),
                          onPressed: isUploading
                              ? null
                              : () => _controller.deletePhoto(),
                          icon: const Icon(Icons.delete_outline, size: 14),
                          label: const Text(
                            'Remove',
                            style: TextStyle(fontSize: 11.5),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Minimal, clean Tab Bar
  Widget _buildTabBar(BuildContext context) {
    final palette = context.palette;

    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        border: Border(bottom: BorderSide(color: palette.border)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: palette.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 2,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
        tabs: const [
          Tab(text: 'Profile Info'),
          Tab(text: 'Security & Password'),
          Tab(text: 'Role & Privileges'),
        ],
      ),
    );
  }

  /// Tab 1: Profile Info (Minimal)
  Widget _buildGeneralTab(BuildContext context) {
    final palette = context.palette;
    final user = _controller.user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _controller.nameFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Display Name',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Your public name across activity logs and administrative operations.',
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 11.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller.nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter your full name',
                      prefixIcon: const Icon(Icons.person_outline, size: 18),
                      isDense: true,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Display name cannot be empty';
                      }
                      if (val.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Obx(
                  () => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _controller.isSavingName.value
                        ? null
                        : () => _controller.saveName(),
                    child: _controller.isSavingName.value
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save Name', style: TextStyle(fontSize: 12.5)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Account Details List
            Text(
              'Account Information',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: palette.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: palette.border),
              ),
              child: Column(
                children: [
                  _buildMinimalInfoRow(
                    context,
                    label: 'Email Address',
                    value: user?.email ?? 'Unknown',
                    badge: 'Verified Login',
                  ),
                  Divider(height: 1, color: palette.border),
                  _buildMinimalInfoRow(
                    context,
                    label: 'Admin UID',
                    value: user?.uid ?? 'Unknown',
                    copyable: true,
                  ),
                  Divider(height: 1, color: palette.border),
                  _buildMinimalInfoRow(
                    context,
                    label: 'Status',
                    value: (user?.active ?? true) ? 'Active Admin' : 'Suspended',
                    statusIndicator: true,
                    isActive: user?.active ?? true,
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tab 2: Security & Password (Minimal)
  Widget _buildSecurityTab(BuildContext context) {
    final palette = context.palette;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _controller.passwordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Change Password',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Confirm your current password to establish a new password of at least 8 characters.',
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 11.5,
              ),
            ),
            const SizedBox(height: 16),

            // Current Password
            Text(
              'Current Password',
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Obx(
              () => TextFormField(
                controller: _controller.currentPasswordController,
                obscureText: _controller.obscureCurrent.value,
                decoration: InputDecoration(
                  hintText: 'Enter current password',
                  prefixIcon: const Icon(Icons.lock_outline, size: 18),
                  isDense: true,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _controller.obscureCurrent.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                    ),
                    onPressed: () => _controller.obscureCurrent.toggle(),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 12),

            // New Password
            Text(
              'New Password',
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Obx(
              () => TextFormField(
                controller: _controller.newPasswordController,
                obscureText: _controller.obscureNew.value,
                decoration: InputDecoration(
                  hintText: 'Minimum 8 characters',
                  prefixIcon: const Icon(Icons.lock_reset, size: 18),
                  isDense: true,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _controller.obscureNew.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                    ),
                    onPressed: () => _controller.obscureNew.toggle(),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 12),

            // Confirm Password
            Text(
              'Confirm New Password',
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Obx(
              () => TextFormField(
                controller: _controller.confirmPasswordController,
                obscureText: _controller.obscureConfirm.value,
                decoration: InputDecoration(
                  hintText: 'Re-enter new password',
                  prefixIcon: const Icon(Icons.lock_clock_outlined, size: 18),
                  isDense: true,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _controller.obscureConfirm.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                    ),
                    onPressed: () => _controller.obscureConfirm.toggle(),
                  ),
                ),
                validator: (val) {
                  if (val != _controller.newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),

            // Action Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _controller.isChangingPassword.value
                      ? null
                      : () => _controller.changePassword(),
                  child: _controller.isChangingPassword.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Update Password',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tab 3: Role & Privileges (Minimal List)
  Widget _buildPrivilegesTab(BuildContext context) {
    final palette = context.palette;
    final user = _controller.user;
    final role = user?.role ?? AdminRole.viewer;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Assigned Role:',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              AdminRoleBadge(role: role),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Permissions are governed strictly by your administrator role tier.',
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              children: [
                _buildMinimalPrivilegeRow(
                  context,
                  title: 'Manage Content & Articles',
                  description: 'Publish, edit, and remove health articles, disease screeners, and media.',
                  hasAccess: role == AdminRole.superAdmin || role == AdminRole.editor,
                ),
                Divider(height: 1, color: palette.border),
                _buildMinimalPrivilegeRow(
                  context,
                  title: 'Push Notification Broadcasts',
                  description: 'Compose and dispatch push campaigns to registered devices.',
                  hasAccess: role == AdminRole.superAdmin || role == AdminRole.editor,
                ),
                Divider(height: 1, color: palette.border),
                _buildMinimalPrivilegeRow(
                  context,
                  title: 'Administrator Management',
                  description: 'Invite administrators, modify staff roles, or suspend access.',
                  hasAccess: role == AdminRole.superAdmin,
                ),
                Divider(height: 1, color: palette.border),
                _buildMinimalPrivilegeRow(
                  context,
                  title: 'Audit Logs & Security Trail',
                  description: 'Inspect full audit trails of administrative events and logins.',
                  hasAccess: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    String? badge,
    bool copyable = false,
    bool statusIndicator = false,
    bool isActive = true,
  }) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (copyable)
            IconButton(
              icon: const Icon(Icons.copy, size: 14),
              splashRadius: 14,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Copy UID',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                AppToast.info('Copied', 'UID copied to clipboard.');
              },
            ),
          if (statusIndicator)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? AppColors.success : AppColors.danger,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  isActive ? 'Active' : 'Suspended',
                  style: TextStyle(
                    color: isActive ? AppColors.success : AppColors.danger,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMinimalPrivilegeRow(
    BuildContext context, {
    required String title,
    required String description,
    required bool hasAccess,
  }) {
    final palette = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            hasAccess ? Icons.check_circle_outline : Icons.remove_circle_outline,
            size: 18,
            color: hasAccess ? AppColors.success : palette.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: hasAccess
                  ? AppColors.success.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              hasAccess ? 'Allowed' : 'Restricted',
              style: TextStyle(
                color: hasAccess ? AppColors.success : palette.textSecondary,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
