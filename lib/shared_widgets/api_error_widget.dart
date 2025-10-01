import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:iconsax/iconsax.dart';

class ApiErrorWidget extends StatelessWidget {
  final Object error;
  const ApiErrorWidget({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    String title = 'An Error Occurred';
    String message = 'Failed to load data. Please try again later.';
    IconData icon = Iconsax.warning_2;

    if (error is DioException) {
      final dioError = error as DioException;
      if (dioError.response?.statusCode == 403) {
        title = 'Access Denied';
        message =
        'Your user role does not have permission to view this content.';
        icon = Iconsax.lock;
      } else if (dioError.response?.statusCode == 404) {
        title = 'Not Found';
        message = 'The requested resource could not be found.';
        icon = Iconsax.search_zoom_out;
      } else if (dioError.response?.statusCode == 500) {
        title = 'Server Error';
        message =
        'There was a problem with the server. Please contact support.';
        icon = Iconsax.danger;
      }
    }

    return Center(
      heightFactor: 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: appColors.textSecondary, size: 32),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: appColors.textSecondary),
          ),
        ],
      ),
    );
  }
}