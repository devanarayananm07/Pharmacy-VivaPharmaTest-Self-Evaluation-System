import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class ProfileAvatar extends ConsumerWidget {
  final double radius;

  const ProfileAvatar({
    super.key,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarUrl = ref.watch(profileAvatarProvider);
    final authState = ref.watch(authProvider);

    return CircleAvatar(
      radius: radius,
      backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
      child: avatarUrl.isEmpty
          ? Text(
              (authState.employeeName ?? 'P')
                  .split(' ')
                  .map((s) => s.isNotEmpty ? s[0] : '')
                  .take(2)
                  .join()
                  .toUpperCase(),
              style: TextStyle(
                fontSize: radius * 0.625,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }
}
