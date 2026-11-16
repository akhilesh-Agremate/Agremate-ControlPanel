import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:agremate_admin/core/theme/theme.dart';
import 'package:agremate_admin/core/widgets/app_toast.dart';
import 'package:agremate_admin/modules/home/controller/home_controller.dart';
import 'package:agremate_admin/modules/home/model/support_ticket_model.dart';

import '../../../../core/theme/app_colors.dart';

Color _statusColor(String s) {
  switch (s) {
    case 'Open': return const Color(0xFFE53935);
    case 'Assigned':
    case 'InProgress': return const Color(0xFF2196F3);
    case 'WaitingOnUser': return const Color(0xFFFB8C00);
    case 'Escalated': return const Color(0xFF8E24AA);
    case 'Resolved': return const Color(0xFF43A047);
    case 'Closed': return const Color(0xFF757575);
    case 'Reopened': return const Color(0xFFF4511E);
    default: return const Color(0xFF2F6BFF);
  }
}

String _fmt(DateTime? d) =>
    d == null ? '' : DateFormat('dd MMM yyyy, hh:mm a').format(d);

Widget _chip(String label, Color color) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
  decoration: BoxDecoration(
    color: color.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: color.withValues(alpha: 0.6)),
  ),
  child: Text(label,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
);

class SupportTicketsDetailView extends StatelessWidget {
  const SupportTicketsDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeController>();
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return ColoredBox(
      color: const Color(0xFFF8FAFD),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 14 : 28),
        child: Obx(() {
          final s = c.supportSummary.value;
          final totalPages =
          (c.supportTotal.value / HomeController.supportPageSize).ceil();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                IconButton(
                  onPressed: c.closeSupportDetails,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 4),
                Text('Active Support', style: AppTheme.heading1),
              ]),
              const SizedBox(height: 16),

              if (s != null)
                Wrap(spacing: 12, runSpacing: 12, children: [
                  _kpi('Total', s.total, AppColors.primaryBlue),
                  _kpi('Open', s.open, AppColors.chatRed),
                  _kpi('In Progress', s.inProgress, AppColors.activeBlue),
                  _kpi('Escalated', s.escalated, AppColors.metricDarkBlue),
                  _kpi('Resolved', s.resolved, AppColors.success),
                  _kpi('SLA Breached', s.breached, AppColors.metricRed),
                ]),
              const SizedBox(height: 16),

              Row(children: [
                if (c.isSupportStaff)
                  SizedBox(
                    width: 280,
                    child: TextField(
                      onSubmitted: c.setSupportSearch,
                      decoration: InputDecoration(
                        hintText: 'Search ticket, user, phone...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppTheme.border),
                        ),
                      ),
                    ),
                  ),
              ]),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  _filterChip(c, 'All', null),
                  for (var i = 0; i < HomeController.ticketStatuses.length; i++)
                    _filterChip(c, HomeController.ticketStatuses[i], i),
                ]),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: c.isSupportLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : c.supportError.value.isNotEmpty
                    ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(c.supportError.value),
                      TextButton(
                        onPressed: c.fetchSupportTickets,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
                    : c.supportTickets.isEmpty
                    ? Center(
                    child: Text('No support tickets found.',
                        style: AppTheme.bodyText.copyWith(
                            color: AppTheme.textMuted,
                            fontStyle: FontStyle.italic)))
                    : ListView.builder(
                  itemCount: c.supportTickets.length,
                  itemBuilder: (_, i) =>
                      _TicketCard(ticket: c.supportTickets[i]),
                ),
              ),

              if (c.isSupportStaff && totalPages > 1)
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  IconButton(
                    onPressed: c.supportPage.value > 1
                        ? () => c.setSupportPage(c.supportPage.value - 1)
                        : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text('Page ${c.supportPage.value} of $totalPages'),
                  IconButton(
                    onPressed: c.supportPage.value < totalPages
                        ? () => c.setSupportPage(c.supportPage.value + 1)
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ]),
            ],
          );
        }),
      ),
    );
  }

  Widget _kpi(String label, int value, Color color) => Container(
    width: 150,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF1565C0).withValues(alpha: 0.09),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
      const SizedBox(height: 6),
      Text('$value',
          style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 24)),
    ]),
  );

  Widget _filterChip(HomeController c, String label, int? value) {
    final selected = c.supportStatusFilter.value == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) => c.setSupportStatus(value),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final SupportTicketModel ticket;
  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeController>();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          c.openTicket(ticket.id);
          showDialog(context: context, builder: (_) => const _TicketDialog());
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              width: 5,
              height: 64,
              decoration: BoxDecoration(
                color: _statusColor(ticket.status),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${ticket.ticketNumber}  •  ${ticket.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.heading3.copyWith(fontSize: 15)),
                const SizedBox(height: 6),
                Text(
                  '${ticket.raisedByName} (${ticket.raisedByRole})'
                      '${ticket.raisedByPhone.isNotEmpty ? ' • ${ticket.raisedByPhone}' : ''}',
                  style: AppTheme.caption,
                ),
                const SizedBox(height: 2),
                Text(_fmt(ticket.createdAt), style: AppTheme.caption),
              ]),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Wrap(spacing: 6, runSpacing: 6, children: [
                _chip(ticket.status, _statusColor(ticket.status)),
                _chip(ticket.priority, const Color(0xFF2F6BFF)),
                _chip(ticket.category, const Color(0xFF00ACC1)),
                if (ticket.breached) _chip('SLA Breached', const Color(0xFFE53935)),
              ]),
              const SizedBox(height: 8),
              Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.chat_bubble_outline, size: 14),
                const SizedBox(width: 4),
                Text('${ticket.messageCount}', style: AppTheme.caption),
              ]),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _TicketDialog extends StatefulWidget {
  const _TicketDialog();
  @override
  State<_TicketDialog> createState() => _TicketDialogState();
}

class _TicketDialogState extends State<_TicketDialog> {
  final _ctrl = TextEditingController();
  bool _internal = false;
  final c = Get.find<HomeController>();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send(SupportTicketDetail d) async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    final err = await c.sendTicketMessage(d.ticket.id, text, internal: _internal);
    if (err != null) {
      AppToast.error(err);
    } else {
      _ctrl.clear();
    }
  }

  Future<void> _changeStatus(SupportTicketDetail d, int status) async {
    String? note;
    if (status == 5 || status == 4) {
      final noteCtrl = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(status == 5 ? 'Resolution note (required)' : 'Escalation reason'),
          content: TextField(controller: noteCtrl, maxLines: 3),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Submit')),
          ],
        ),
      );
      if (ok != true) return;
      note = noteCtrl.text.trim();
      if (status == 5 && note.isEmpty) {
        AppToast.error('Resolution note is required.');
        return;
      }
    }
    final err = await c.changeTicketStatus(
      d.ticket.id,
      status,
      notes: status == 4 ? note : null,
      resolutionNote: status == 5 ? note : null,
    );
    if (err != null) AppToast.error(err);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 700),
        child: Obx(() {
          final d = c.selectedTicket.value;
          if (c.isTicketLoading.value || d == null) {
            return const SizedBox(
                height: 240, child: Center(child: CircularProgressIndicator()));
          }
          final t = d.ticket;
          final closed = t.status == 'Closed';

          return Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${t.ticketNumber} • ${t.title}', style: AppTheme.heading3),
                    const SizedBox(height: 4),
                    Text('${t.raisedByName} (${t.raisedByRole})', style: AppTheme.caption),
                  ]),
                ),
                _chip(t.status, _statusColor(t.status)),
                if (c.isSupportStaff)
                  PopupMenuButton<int>(
                    tooltip: 'Change status',
                    icon: const Icon(Icons.swap_horiz_rounded),
                    onSelected: (v) => _changeStatus(d, v),
                    itemBuilder: (_) => [
                      for (var i = 0; i < HomeController.ticketStatuses.length; i++)
                        PopupMenuItem(value: i, child: Text(HomeController.ticketStatuses[i])),
                    ],
                  ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ]),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(t.description, style: AppTheme.bodyText),
              ),
            ),
            Expanded(
              child: d.messages.isEmpty
                  ? Center(child: Text('No messages yet.', style: AppTheme.caption))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: d.messages.length,
                itemBuilder: (_, i) {
                  final m = d.messages[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: m.isInternal
                          ? const Color(0xFFFFF8E1)
                          : const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(m.senderName,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                        if (m.isInternal) ...[
                          const SizedBox(width: 8),
                          _chip('Internal', const Color(0xFFFB8C00)),
                        ],
                        const Spacer(),
                        Text(_fmt(m.sentAt), style: AppTheme.caption.copyWith(fontSize: 10)),
                      ]),
                      const SizedBox(height: 6),
                      Text(m.message),
                    ]),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: closed
                  ? Text('Ticket is closed. Reopen it to reply.', style: AppTheme.caption)
                  : Column(children: [
                if (c.isSupportStaff)
                  Row(children: [
                    Switch(
                      value: _internal,
                      onChanged: (v) => setState(() => _internal = v),
                    ),
                    const Text('Internal note'),
                  ]),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      minLines: 1,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: _internal ? 'Write internal note...' : 'Write a reply...',
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  c.isTicketSending.value
                      ? const SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2))
                      : IconButton(
                    onPressed: () => _send(d),
                    icon: const Icon(Icons.send_rounded, color: Color(0xFF2F6BFF)),
                  ),
                ]),
              ]),
            ),
          ]);
        }),
      ),
    );
  }
}