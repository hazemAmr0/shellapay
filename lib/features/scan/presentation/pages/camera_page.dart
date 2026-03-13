import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/scan_bloc.dart';
import '../widgets/camera_overlay.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    
    if (image != null && context.mounted) {
      context.read<ScanBloc>().add(ProcessImageEvent(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ScanBloc>(),
      child: BlocConsumer<ScanBloc, ScanState>(
        listener: (context, state) {
          if (state is ScanSuccess) {
            // Navigate to Review Page
            context.push('/review', extra: state.items);
          } else if (state is ScanError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(title: const Text('Scan Receipt')),
            body: Stack(
              children: [
                const CameraOverlay(),
                
                if (state is ScanProcessing)
                  Container(
                    color: Colors.black.withOpacity(0.8),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: AppColors.primaryLight),
                          const SizedBox(height: 24),
                          Text(
                            state.message, 
                            style: const TextStyle(
                              color: Colors.white, 
                              fontSize: 18, 
                              fontWeight: FontWeight.w600,
                            )
                          ),
                        ],
                      ),
                    ),
                  ),

                // Controls
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        heroTag: 'gallery',
                        backgroundColor: AppColors.surfaceElevated,
                        onPressed: () => _pickImage(context, ImageSource.gallery),
                        child: const Icon(Icons.photo_library, color: AppColors.primaryLight),
                      ),
                      FloatingActionButton.large(
                        heroTag: 'camera',
                        backgroundColor: AppColors.primary,
                        onPressed: () => _pickImage(context, ImageSource.camera),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 36),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
