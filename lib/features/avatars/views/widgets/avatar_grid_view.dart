import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:joba_admin/core/theme/responsive.dart';
import 'package:joba_admin/core/widgets/empty_state.dart';
import 'package:joba_admin/features/avatars/controllers/avatars_controller.dart';
import 'package:joba_admin/features/avatars/views/widgets/avatar_item_card.dart';

/// Responsive grid displaying avatar cards for the currently selected category.
class AvatarGridView extends GetView<AvatarsController> {
  const AvatarGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.avatarsFor(controller.selectedCategoryId.value);

      if (list.isEmpty) {
        return const Card(
          child: EmptyState(
            icon: Icons.face_outlined,
            title: 'No avatars in this category',
            subtitle: 'Use Upload Avatars to add the first one.',
          ),
        );
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Responsive.pick(
            context,
            mobile: 3,
            tablet: 5,
            desktop: 6,
          ),
          mainAxisExtent: 168,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: list.length,
        itemBuilder: (_, i) => AvatarItemCard(avatar: list[i]),
      );
    });
  }
}
