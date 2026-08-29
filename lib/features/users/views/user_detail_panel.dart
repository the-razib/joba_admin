import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/features/users/models/app_user.dart';
import 'package:joba_admin/core/theme/app_colors.dart';
import 'package:joba_admin/core/theme/app_theme.dart';
import 'package:joba_admin/core/utils/format.dart';
import 'package:joba_admin/core/widgets/avatar_circle.dart';
import 'package:joba_admin/core/widgets/badges.dart';
import 'package:joba_admin/core/widgets/detail_panel.dart';
import 'package:joba_admin/features/users/controllers/users_controller.dart';

/// Opens the user detail slide-over panel for the given user ID.
void openUserDetail(BuildContext context, String uid) {
  showDetailPanel(
    context,
    title: 'User Details',
    child: UserDetailBody(uid: uid),
    footer: UserDetailFooter(uid: uid),
  );
}

/// Body content of the user detail slide-over panel.
class UserDetailBody extends GetView<UsersController> {
  const UserDetailBody({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final u = controller.all.firstWhereOrNull((e) => e.uid == uid);
      if (u == null) return const SizedBox();
      final palette = context.palette;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AvatarCircle(name: u.name, url: u.photoUrl, size: 64),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        u.name,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        u.email,
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          userStatusBadge(u.status),
                          userPlanBadge(u.plan),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _sectionTitle(context, 'Profile'),
            _infoRow(context, 'User ID', u.uid),
            _infoRow(context, 'Country', '${u.flagEmoji} ${u.country}'),
            _infoRow(
              context,
              'Language',
              u.language == 'bn' ? 'বাংলা (Bengali)' : 'English',
            ),
            _infoRow(context, 'Joined', formatDateTime(u.joinedAt)),
            _infoRow(context, 'Last active', timeAgo(u.lastActive)),
            if (u.birthYear != null)
              _infoRow(context, 'Birth year', '${u.birthYear}'),
            const SizedBox(height: 22),
            _sectionTitle(context, 'Cycle Summary'),
            const SizedBox(height: 10),
            Row(
              children: [
                _cycleTile(
                  context,
                  'Avg. Cycle',
                  '${u.averageCycleLength} days',
                ),
                const SizedBox(width: 10),
                _cycleTile(
                  context,
                  'Period',
                  '${u.averagePeriodDuration} days',
                ),
                const SizedBox(width: 10),
                _cycleTile(context, 'Goal', u.cycleGoal),
              ],
            ),
            const SizedBox(height: 26),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.privacy_tip_outlined,
                    size: 18,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Cycle data is sensitive health information. Every admin view and action is strictly recorded in Audit Logs.',
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 11.5,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _sectionTitle(BuildContext context, String t) => Text(
        t,
        style: TextStyle(
          color: context.palette.textPrimary,
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
        ),
      );

  Widget _infoRow(BuildContext context, String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              child: Text(
                label,
                style: TextStyle(
                  color: context.palette.textSecondary,
                  fontSize: 12.5,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: context.palette.textPrimary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _cycleTile(BuildContext context, String label, String value) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: context.palette.textSecondary,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
      );
}

/// Footer controls for user status and subscription plan editing.
class UserDetailFooter extends StatefulWidget {
  const UserDetailFooter({super.key, required this.uid});

  final String uid;

  @override
  State<UserDetailFooter> createState() => _UserDetailFooterState();
}

class _UserDetailFooterState extends State<UserDetailFooter> {
  UserStatus? _status;
  UserPlan? _plan;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();
    final u = controller.all.firstWhereOrNull((e) => e.uid == widget.uid);
    if (u == null) return const SizedBox();
    final status = _status ?? u.status;
    final plan = _plan ?? u.plan;

    return Column(
      children: [
        Row(
          children: [
            for (final s in UserStatus.values)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  selected: status == s,
                  label: Text(
                    s.name.toUpperCase(),
                    style: const TextStyle(fontSize: 11),
                  ),
                  onSelected: (_) => setState(() => _status = s),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final p in UserPlan.values)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  selected: plan == p,
                  label: Text(p.name, style: const TextStyle(fontSize: 11)),
                  onSelected: (_) => setState(() => _plan = p),
                ),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (_status != null) controller.updateStatus(u.uid, _status!);
                if (_plan != null) controller.updatePlan(u.uid, _plan!);
                Navigator.of(context).pop();
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ],
    );
  }
}
