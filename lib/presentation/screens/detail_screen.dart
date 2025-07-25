import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskium/domain/task.dart';
import 'package:taskium/presentation/viewmodels/notifiers/detail_notifier.dart';
import 'package:taskium/presentation/viewmodels/states/detail_state.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class DetailScreen extends ConsumerStatefulWidget {
  const DetailScreen({
    super.key,
    required this.task,
  });

  final Task task;

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(detailNotifierProvider.notifier).initialize(widget.task);
    });
  }

  @override
  void didUpdateWidget(DetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task != widget.task) {
      ref.read(detailNotifierProvider.notifier).initialize(widget.task);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(detailNotifierProvider);
    final detailNotifier = ref.read(detailNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (detailNotifier.shouldPreventNavigation()) {
              return;
            }
            context.pop(detailNotifier.shouldNavigateBack());
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Upload file',
            onPressed: detailState.task == null || detailState.screenState.isLoading || detailState.screenState.isDeleting
                ? null
                : () async {
                    await detailNotifier.uploadFile();
                  },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: detailState.task == null || detailState.screenState.isLoading || detailState.screenState.isDeleting
                ? null
                : () async {
                    final updatedTask = await context.push('/edit', extra: {
                      'task': detailState.task,
                      'userId': detailState.task!.userId
                    });
                    if (updatedTask != null) {
                      detailNotifier.updateTask(updatedTask as Task);
                    }
                  },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: detailState.task == null || detailState.screenState.isLoading || detailState.screenState.isDeleting
                ? null
                : () async {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Delete Task'),
                          content: const Text('Are you sure you want to delete this task?'),
                          actions: [
                            TextButton(
                              onPressed: () => context.pop(),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () async {
                                context.pop();
                                await detailNotifier.deleteTask();
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
          ),
        ],
      ),
      body: detailState.screenState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        idle: () => detailState.task == null
            ? TaskDetailView(
                task: widget.task,
                detailState: detailState,
                detailNotifier: detailNotifier,
              )
            : TaskDetailView(
                task: detailState.task!,
                detailState: detailState,
                detailNotifier: detailNotifier,
              ),
        error: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${detailState.errorMessage}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => detailNotifier.clearError(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        deleting: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Deleting task...'),
            ],
          ),
        ),
        deleted: () {
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted && context.canPop()) {
              context.pop(true);
            }
          });
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 64),
                SizedBox(height: 16),
                Text('Task deleted successfully'),
              ],
            ),
          );
        },
      ),
    );
  }
}

class TaskDetailView extends StatelessWidget {
  const TaskDetailView({
    super.key,
    required this.task,
    required this.detailState,
    required this.detailNotifier,
  });

  final Task task;
  final DetailState detailState;
  final DetailNotifier detailNotifier;

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: [
        SlideFirstView(
          task: task,
          detailState: detailState,
          detailNotifier: detailNotifier,
        ),
        SlideSecondView(task: task),
      ],
    );
  }
}

class SlideFirstView extends ConsumerWidget {
  const SlideFirstView({
    super.key,
    required this.task,
    required this.detailState,
    required this.detailNotifier,
  });

  final Task task;
  final DetailState detailState;
  final DetailNotifier detailNotifier;

  void _showImageGallery(BuildContext context, List<String> images, int initialIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: GalleryView(images: images, initialIndex: initialIndex),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const Divider(),
              const SizedBox(height: 10),
              if(task.description.isNotEmpty) ...[
                // Text(
                //   'Description:',
                //   style: Theme.of(context).textTheme.displayMedium,
                // ),
                Text(
                  task.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              if (task.files.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Text('Attachments:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                if (detailState.screenState == DetailScreenState.loading) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (int i = 0; i < task.files.length; i++)
                      Builder(builder: (context) {
                        final url = task.files[i];
                        final lowerUrl = url.toLowerCase();
                        final isImage = RegExp(r'\.(png|jpe?g|gif|webp)(\?|$)').hasMatch(lowerUrl);
                        final isPdf = lowerUrl.contains('.pdf');
                        Widget preview;
                        if (isImage) {
                          final imageFiles = task.files.where((u) =>
                            RegExp(r'\.(png|jpe?g|gif|webp)(\?|$)').hasMatch(u.toLowerCase())
                          ).toList();
                          final imageIndex = imageFiles.indexOf(url);
                          preview = GestureDetector(
                            onTap: () => _showImageGallery(context, imageFiles, imageIndex),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: SizedBox(
                                width: 150,
                                height: 150,
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Image.network(
                                        url,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(
                                            color: Colors.grey[200],
                                            child: const Center(
                                              child: SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(),
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else if (isPdf) {
                          preview = GestureDetector(
                            onTap: detailState.isLoadingPdf ? null : () async {
                              try {
                                final filePath = await detailNotifier.getPdfFile(url);
                                if (filePath != null && context.mounted) {
                                  showDialog(
                                    context: context,
                                    builder: (dialogContext) {
                                      return Dialog(
                                        backgroundColor: Colors.black,
                                        insetPadding: EdgeInsets.zero,
                                        child: Stack(
                                          children: [
                                            PDFViewDialog(filePath: filePath),
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: IconButton(
                                                icon: const Icon(Icons.close, color: Colors.black, size: 28),
                                                onPressed: () => context.pop(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                } else if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Error loading PDF')),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error loading PDF: $e')),
                                  );
                                }
                              }
                            },
                            child: Stack(
                              children: [
                                Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.picture_as_pdf, size: 36, color: Colors.red),
                                ),
                                // PDF filename overlay
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(6),
                                        bottomRight: Radius.circular(6),
                                      ),
                                    ),
                                    child: Text(
                                      _extractPdfName(url),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                if (detailState.isLoadingPdf)
                                  Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator()
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        } else {
                          preview = const SizedBox.shrink();
                        }
                        return Stack(
                          children: [
                            preview,
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Material(
                                color: Colors.transparent,
                                child: IconButton(
                                  icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  tooltip: 'Remove attachment',
                                  onPressed: detailState.screenState == DetailScreenState.loading
                                      ? null
                                      : () async {
                                          final confirmed = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text('Remove Attachment'),
                                              content: const Text('Remove this attachment from the task? (File will remain in storage)'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(ctx).pop(false),
                                                  child: const Text('Cancel'),
                                                ),
                                                FilledButton(
                                                  onPressed: () => Navigator.of(ctx).pop(true),
                                                  child: const Text('Remove'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirmed == true) {
                                            await detailNotifier.removeAttachment(url);
                                          }
                                        },
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Add this helper function inside SlideFirstView (below the class fields, above build)
  String _extractPdfName(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
      // path is like: tasks%2FlfK5zIDfluaEEbsCzGnA%2F1751940583840_LM2575-D%20(1).PDF
      final decoded = Uri.decodeComponent(path);
      // decoded: tasks/lfK5zIDfluaEEbsCzGnA/1751940583840_LM2575-D (1).PDF
      final parts = decoded.split('/');
      final fileName = parts.isNotEmpty ? parts.last : decoded;
      // fileName: 1751940583840_LM2575-D (1).PDF
      final nameMatch = RegExp(r'^\d+_(.+)$').firstMatch(fileName);
      String name = nameMatch != null ? nameMatch.group(1)! : fileName;
      // Normalize extension to .pdf
      name = name.replaceAllMapped(RegExp(r'\.PDF$', caseSensitive: false), (m) => '.pdf');
      // Remove spaces before extension
      name = name.replaceAll(RegExp(r'\s+\.'), '.');
      return name;
    } catch (_) {
      return 'PDF';
    }
  }
}

class SlideSecondView extends StatelessWidget {
  const SlideSecondView({
    super.key,
    required this.task,
  });

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            ListTile(
              title: const Text('Category'),
              subtitle: Text(task.category),
              leading: const Icon(Icons.category),
            ),
            const Divider(),
            ListTile(
              title: const Text('Priority'),
              subtitle: Text(task.priority.toString()),
              leading: const Icon(Icons.priority_high),
            ),
            const Divider(),
            ListTile(
              title: const Text('Progress'),
              subtitle: Text('${task.progress}%'),
              leading: const Icon(Icons.timeline),
            ),
            const Divider(),
            ListTile(
              title: const Text('Created At'),
              subtitle: Text(task.createdAt?.substring(0, 10) ?? 'N/A'),
              leading: const Icon(Icons.date_range),
            ),
            const Divider(),
            ListTile(
              title: const Text('Due Date'),
              subtitle: Text(task.dueDate ?? 'N/A'),
              leading: const Icon(Icons.calendar_today),
            ),
            if (task.isCompleted) ...[
              const Divider(),
              ListTile(
                title: const Text('Completed At'),
                subtitle: Text(task.completedAt?.substring(0, 10) ?? 'N/A'),
                leading: const Icon(Icons.check_circle),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class GalleryView extends ConsumerWidget {
  final List<String> images;
  final int initialIndex;
  const GalleryView({super.key, required this.images, required this.initialIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailNotifier = ref.read(detailNotifierProvider.notifier);
    final detailState = ref.watch(detailNotifierProvider);

    // Initialize gallery index if not set
    if (detailState.galleryIndex == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        detailNotifier.setGalleryIndex(initialIndex);
      });
    }

    final currentIndex = detailState.galleryIndex ?? initialIndex;

    return Stack(
      children: [
        PageView.builder(
          controller: PageController(initialPage: currentIndex),
          itemCount: images.length,
          onPageChanged: (i) => detailNotifier.setGalleryIndex(i),
          itemBuilder: (context, i) {
            return Center(
              child: InteractiveViewer(
                child: Image.network(images[i]),
              ),
            );
          },
        ),
        Positioned(
          top: 30,
          right: 20,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 32),
            onPressed: () => context.pop(),
          ),
        ),
      ],
    );
  }
}

class PDFViewDialog extends StatefulWidget {
  final String filePath;

  const PDFViewDialog({super.key, required this.filePath});

  @override
  _PDFViewDialogState createState() => _PDFViewDialogState();
}

class _PDFViewDialogState extends State<PDFViewDialog> {
  @override
  Widget build(BuildContext context) {
    return PDFView(
      filePath: widget.filePath,
      enableSwipe: true,
      swipeHorizontal: true,
      autoSpacing: false,
      pageFling: false,
      onError: (error) {
        // print('PDF Error: $error');
      },
      onPageError: (page, error) {
        // print('PDF Page Error: $error');
      },
    );
  }
}