class SupportFaq {
  final String id;
  final String question;
  final String answer;
  final String category;
  final int displayOrder;
  final bool isActive;

  SupportFaq({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    required this.displayOrder,
    required this.isActive,
  });

  factory SupportFaq.fromJson(Map<String, dynamic> json) {
    return SupportFaq(
      id: (json['id'] ?? '').toString(),
      question: (json['question'] ?? '').toString(),
      answer: (json['answer'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      displayOrder: json['displayOrder'] is num
          ? (json['displayOrder'] as num).toInt()
          : int.tryParse('${json['displayOrder']}') ?? 0,
      isActive: json['isActive'] != false,
    );
  }

  Map<String, dynamic> toBody({bool? active}) {
    return {
      'question': question,
      'answer': answer,
      'category': category,
      'displayOrder': displayOrder,
      'isActive': active ?? isActive,
    };
  }
}
