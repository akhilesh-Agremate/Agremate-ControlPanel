import 'package:flutter/material.dart';
import 'package:agremate_admin/core/widgets/app_toast.dart';
import 'add_property_panel.dart' show PickedFile;

class PropertyUpload {
  static const int maxBytes = 2 * 1024 * 1024;

  static List<PickedFile> withinLimit(List<PickedFile> files) {
    final ok = <PickedFile>[];
    var tooBig = false;
    for (final f in files) {
      if (f.bytes.length > maxBytes) {
        tooBig = true;
      } else {
        ok.add(f);
      }
    }
    if (tooBig) {
      AppToast.error('Maximum allowed file size is 2 MB.');
    }
    return ok;
  }

  static void listen(
    Map<String, dynamic> data,
    bool Function() mounted,
    BuildContext context,
  ) {
    data['onUploadProgress'] = (String message, double progress) {};
    data['onUploadRetry'] = (String name, String error) async {
      if (!mounted()) return false;
      final retry = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Upload failed'),
          content: Text(
            '$name could not be uploaded.\n\n$error\n\nDo you want to try again?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
      return retry == true;
    };
  }

  static Future<void> uploadNow(
    List<PickedFile> files,
    Future<Map<String, dynamic>> Function(PickedFile file) upload,
    bool Function() mounted,
    void Function(VoidCallback fn) setState,
    BuildContext context,
  ) async {
    for (final file in files) {
      file.uploading = true;
    }
    if (files.isNotEmpty && mounted()) setState(() {});
    for (final file in files) {
      while (file.uploaded == null && file.uploading) {
        try {
          file.uploaded = await upload(file);
          file.uploading = false;
          if (mounted()) setState(() {});
        } catch (e) {
          if (!mounted() || !context.mounted) return;
          final message = '$e'.replaceFirst('Exception: ', '');
          final retry = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text('Upload failed'),
              content: Text(
                '${file.name} could not be uploaded.\n\n$message\n\nDo you want to try again?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
          if (retry != true) {
            file.uploading = false;
            if (mounted()) setState(() {});
          }
        }
      }
    }
  }

  static Widget tileLoader(bool uploading) {
    if (!uploading) return const SizedBox.shrink();
    return Positioned.fill(
      child: Container(
        color: const Color(0x66000000),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  static Widget overlay({required bool visible}) {
    if (!visible) return const SizedBox.shrink();
    return const Stack(
      children: [
        ModalBarrier(dismissible: false, color: Color(0x33000000)),
        Center(
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }
}
