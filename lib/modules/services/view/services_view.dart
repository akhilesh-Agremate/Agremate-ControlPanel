import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/core/constants/constants.dart';
import 'package:agremate_admin/modules/services/controller/services_controller.dart';
import 'package:agremate_admin/modules/layout/controller/navigation_controller.dart';
import 'package:agremate_admin/core/widgets/glass_card.dart';
import 'package:agremate_admin/core/widgets/status_badge.dart';

class ServicesView extends StatelessWidget {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    final sc = Get.find<ServicesController>();
    final nav = Get.find<NavigationController>();

    return Obx(() {
      if (nav.searchQuery.value.isNotEmpty) {
        sc.search(nav.searchQuery.value);
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service Categories', style: AppTheme.heading2),
            const SizedBox(height: 4),
            Text('Click on a service to view property requests', style: AppTheme.caption),
            const SizedBox(height: 24),
            // Service cards grid
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: AppConstants.serviceTypes.map((type) {
                final color = AppConstants.serviceColors[type] ?? AppTheme.accentCyan;
                final icon = AppConstants.serviceIcons[type] ?? Icons.build;
                final count = sc.serviceCounts[type] ?? 0;
                final pending = sc.pendingCounts[type] ?? 0;
                final isSelected = sc.selectedServiceType.value == type;

                return SizedBox(
                  width: 220,
                  child: GlassCard(
                    color: Colors.white,
                    borderColor: isSelected ? AppTheme.accentBlue : AppTheme.border,
                    glowColor: isSelected ? color : color.withValues(alpha: 0.5),
                    onTap: () => sc.selectServiceType(type),
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(icon, color: color, size: 24),
                            ),
                            if (isSelected)
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check_circle, color: AppTheme.accentGreen, size: 18),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          type, 
                          style: AppTheme.heading3.copyWith(color: AppTheme.textPrimary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$count requests', 
                          style: AppTheme.bodyText.copyWith(color: AppTheme.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        if (pending > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            '$pending pending', 
                            style: TextStyle(color: AppTheme.brandRed, fontSize: 12, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            ),
            const SizedBox(height: 32),
            // Inline request list
            if (sc.selectedServiceType.value.isNotEmpty) ...[
              Row(
                children: [
                  Text('${sc.selectedServiceType.value} Requests', style: AppTheme.heading2),
                  const Spacer(),
                  StatusBadge(
                    label: '${sc.filteredRequests.length} total',
                    color: AppConstants.serviceColors[sc.selectedServiceType.value] ?? AppTheme.accentCyan,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (sc.filteredRequests.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text('No requests found', style: TextStyle(color: AppTheme.textMuted)),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sc.filteredRequests.length,
                  itemBuilder: (context, index) {
                    final req = sc.filteredRequests[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () => _showServiceChatDialog(context, req),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.border, width: 1),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 5,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2083D5), // Uniform Agremate Blue
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(req.propertyName, style: AppTheme.heading3),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.person_outline_rounded, size: 14, color: AppTheme.textMuted),
                                          const SizedBox(width: 4),
                                          Text('By ${req.tenantName}', style: AppTheme.caption.copyWith(fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                          width: 140,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.5), width: 1),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              req.description,
                                              style: const TextStyle(
                                                color: AppTheme.accentCyan,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        SizedBox(
                                          width: 170,
                                          child: Row(
                                            children: [
                                              const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.black),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  'Requested: ${req.requestDate.day}/${req.requestDate.month}/${req.requestDate.year}',
                                                  style: AppTheme.caption.copyWith(fontSize: 10.5, color: Colors.black),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                          width: 140,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: (req.status == 'pending' 
                                                  ? AppTheme.brandRed 
                                                  : (req.status == 'in_progress' 
                                                      ? AppTheme.accentGreen 
                                                      : (req.status == 'completed' 
                                                          ? AppTheme.accentBlue 
                                                          : AppTheme.accentCyan))).withValues(alpha: 0.5),
                                                width: 1,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              req.status.replaceAll('_', ' ').toUpperCase(),
                                              style: TextStyle(
                                                color: req.status == 'pending' 
                                                  ? AppTheme.brandRed 
                                                  : (req.status == 'in_progress' 
                                                      ? AppTheme.accentGreen 
                                                      : (req.status == 'completed' 
                                                          ? AppTheme.accentBlue 
                                                          : AppTheme.accentCyan)),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        SizedBox(
                                          width: 170,
                                          child: req.status == 'completed' ? Row(
                                            children: [
                                              const Icon(Icons.check_circle_outline, size: 14, color: Colors.black),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  'Completed: ${req.requestDate.add(const Duration(days: 2)).day}/${req.requestDate.add(const Duration(days: 2)).month}/${req.requestDate.year}',
                                                  style: AppTheme.caption.copyWith(fontSize: 10.5, color: Colors.black),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ) : const SizedBox.shrink(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ] else
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    children: [
                      Icon(Icons.touch_app_rounded, size: 48, color: AppTheme.textMuted.withValues(alpha: 0.2)),
                      const SizedBox(height: 16),
                      Text('Select a category to view requests', style: AppTheme.bodyText.copyWith(color: AppTheme.textMuted)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  void _showServiceChatDialog(BuildContext context, dynamic req) {
    final List<Map<String, dynamic>> messages = req.chatMessages;
    final String propertyName = req.propertyName;
    final String issue = req.description;
    final String status = req.status == 'completed' ? 'Solved' : 'Pending';
    final String tenantName = req.tenantName;
    final String landlordName = req.landlordName;
    final String location = req.location;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
        child: Container(
          width: 520,
          constraints: const BoxConstraints(maxHeight: 680),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9FC),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Chat Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.home_work_outlined, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(propertyName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                          const SizedBox(height: 2),
                          Text(issue, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: status == 'Solved' ? const Color(0xFF43A047) : const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(height: 4),
                        Text(location, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 10)),
                      ],
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),

              // Participants Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                color: Colors.white,
                child: Row(
                  children: [
                    _chatParticipantChip(Icons.person_outlined, 'Tenant', tenantName, const Color(0xFF1E88E5)),
                    const SizedBox(width: 12),
                    _chatParticipantChip(Icons.business_center_outlined, 'Landlord', landlordName, const Color(0xFF43A047)),
                  ],
                ),
              ),

              Container(height: 1, color: const Color(0xFFE0E0E0)),

              // Chat Messages
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(color: const Color(0xFF1E88E5).withValues(alpha: 0.08), shape: BoxShape.circle),
                              child: const Icon(Icons.chat_bubble_outline_rounded, size: 40, color: Color(0xFF1E88E5)),
                            ),
                            const SizedBox(height: 16),
                            const Text('No messages yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF212121))),
                            const SizedBox(height: 6),
                            const Text('The tenant and landlord haven\'t\nchatted about this issue yet.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: Color(0xFF757575), height: 1.6)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        itemCount: messages.length,
                        itemBuilder: (ctx, idx) {
                          final msg = messages[idx];
                          final isTenant = msg['sender'] == 'tenant';
                          return _buildChatBubble(
                            message: msg['message'] as String,
                            senderName: msg['senderName'] as String,
                            time: msg['time'] as String,
                            isTenant: isTenant,
                            isRead: msg['isRead'] as bool? ?? true,
                          );
                        },
                      ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 14, color: Color(0xFF9E9E9E)),
                    const SizedBox(width: 6),
                    const Expanded(child: Text('Chat is read-only. Admin can view conversation history.', style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)))),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        backgroundColor: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Close', style: TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chatParticipantChip(IconData icon, String role, String name, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 14, backgroundColor: color.withValues(alpha: 0.15), child: Icon(icon, size: 14, color: color)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(role, style: TextStyle(fontSize: 9.5, color: color, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                  Text(name, style: const TextStyle(fontSize: 12, color: Color(0xFF212121), fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble({required String message, required String senderName, required String time, required bool isTenant, required bool isRead}) {
    final Color bubbleColor = isTenant ? const Color(0xFFE3F2FD) : const Color(0xFFE8F5E9);
    final Color nameColor = isTenant ? const Color(0xFF1565C0) : const Color(0xFF2E7D32);
    final CrossAxisAlignment crossAlign = isTenant ? CrossAxisAlignment.start : CrossAxisAlignment.end;
    final MainAxisAlignment rowAlign = isTenant ? MainAxisAlignment.start : MainAxisAlignment.end;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: rowAlign,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isTenant) ...[_avatarCircle(isTenant), const SizedBox(width: 8)],
          Flexible(
            child: Column(
              crossAxisAlignment: crossAlign,
              children: [
                Text(senderName, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: nameColor)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  constraints: const BoxConstraints(maxWidth: 320),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isTenant ? 4 : 16),
                      bottomRight: Radius.circular(isTenant ? 16 : 4),
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: Text(message, style: const TextStyle(fontSize: 13, color: Color(0xFF212121), height: 1.45)),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(time, style: const TextStyle(fontSize: 9.5, color: Color(0xFF9E9E9E))),
                    if (!isTenant) ...[
                      const SizedBox(width: 4),
                      Icon(isRead ? Icons.done_all : Icons.done, size: 12, color: isRead ? const Color(0xFF1E88E5) : const Color(0xFF9E9E9E)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (!isTenant) ...[const SizedBox(width: 8), _avatarCircle(isTenant)],
        ],
      ),
    );
  }

  Widget _avatarCircle(bool isTenant) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: isTenant ? const Color(0xFF1E88E5).withValues(alpha: 0.15) : const Color(0xFF43A047).withValues(alpha: 0.15),
      child: Icon(isTenant ? Icons.person : Icons.business_center, size: 16, color: isTenant ? const Color(0xFF1E88E5) : const Color(0xFF43A047)),
    );
  }
}
