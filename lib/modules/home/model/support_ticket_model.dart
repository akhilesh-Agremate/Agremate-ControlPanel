class SupportSummary {
  final int total, open, assigned, inProgress, waitingOnUser,
      escalated, resolved, closed, reopened, breached;

  SupportSummary.fromJson(Map<String, dynamic> j)
      : total = j['totalCount'] ?? 0,
        open = j['openCount'] ?? 0,
        assigned = j['assignedCount'] ?? 0,
        inProgress = j['inProgressCount'] ?? 0,
        waitingOnUser = j['waitingOnUserCount'] ?? 0,
        escalated = j['escalatedCount'] ?? 0,
        resolved = j['resolvedCount'] ?? 0,
        closed = j['closedCount'] ?? 0,
        reopened = j['reopenedCount'] ?? 0,
        breached = j['breachedCount'] ?? 0;
}

class SupportTicketModel {
  final String id, ticketNumber, title, description, category, priority, status;
  final String raisedByName, raisedByEmail, raisedByPhone, raisedByRole;
  final String? assignedAgentName, resolutionNote;
  final bool firstResponseBreached, resolutionBreached;
  final DateTime? createdAt;
  final int messageCount;

  SupportTicketModel.fromJson(Map<String, dynamic> j)
      : id = (j['id'] ?? '').toString(),
        ticketNumber = (j['ticketNumber'] ?? '').toString(),
        title = (j['title'] ?? '').toString(),
        description = (j['description'] ?? '').toString(),
        category = (j['category'] ?? '').toString(),
        priority = (j['priority'] ?? '').toString(),
        status = (j['status'] ?? '').toString(),
        raisedByName = (j['raisedByName'] ?? 'N/A').toString(),
        raisedByEmail = (j['raisedByEmail'] ?? '').toString(),
        raisedByPhone = (j['raisedByPhone'] ?? '').toString(),
        raisedByRole = (j['raisedByRole'] ?? '').toString(),
        assignedAgentName = j['assignedAgentName']?.toString(),
        resolutionNote = j['resolutionNote']?.toString(),
        firstResponseBreached = j['isFirstResponseBreached'] == true,
        resolutionBreached = j['isResolutionBreached'] == true,
        createdAt = DateTime.tryParse((j['createdAt'] ?? '').toString())?.toLocal(),
        messageCount = j['messageCount'] ?? 0;

  bool get breached => firstResponseBreached || resolutionBreached;
}

class SupportListResult {
  final SupportSummary? summary;
  final List<SupportTicketModel> tickets;
  final int totalFiltered;

  SupportListResult(this.summary, this.tickets, this.totalFiltered);

  factory SupportListResult.fromJson(Map<String, dynamic> j) => SupportListResult(
    j['summary'] is Map
        ? SupportSummary.fromJson(Map<String, dynamic>.from(j['summary']))
        : null,
    (j['tickets'] as List? ?? [])
        .map((e) => SupportTicketModel.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    j['totalFilteredCount'] ?? 0,
  );
}

class TicketMessage {
  final String id, senderName, message;
  final bool isInternal, isSeen;
  final DateTime? sentAt;

  TicketMessage.fromJson(Map<String, dynamic> j)
      : id = (j['id'] ?? '').toString(),
        senderName = (j['senderName'] ?? '').toString(),
        message = (j['message'] ?? '').toString(),
        isInternal = j['isInternal'] == true,
        isSeen = j['isSeen'] == true,
        sentAt = DateTime.tryParse((j['sentAt'] ?? '').toString())?.toLocal();
}

class SupportTicketDetail {
  final SupportTicketModel ticket;
  final List<TicketMessage> messages;

  SupportTicketDetail(this.ticket, this.messages);

  factory SupportTicketDetail.fromJson(Map<String, dynamic> j) => SupportTicketDetail(
    SupportTicketModel.fromJson(j),
    (j['messages'] as List? ?? [])
        .map((e) => TicketMessage.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );
}