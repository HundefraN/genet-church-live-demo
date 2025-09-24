// import 'dart:convert';
//
// class Communication {
//   final String id;
//   final List<String> recipients;
//   final String subject;
//   final String message;
//   final DateTime timestamp;
//   final bool isDraft;
//
//   Communication({
//     required this.id,
//     required this.recipients,
//     required this.subject,
//     required this.message,
//     required this.timestamp,
//     this.isDraft = false,
//   });
//
//   factory Communication.fromJson(Map<String, dynamic> json) {
//     return Communication(
//       id: json['id'],
//       recipients: List<String>.from(json['recipients']),
//       subject: json['subject'],
//       message: json['message'],
//       timestamp: DateTime.parse(json['timestamp']),
//       isDraft: json['isDraft'] ?? false,
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'recipients': recipients,
//     'subject': subject,
//     'message': message,
//     'timestamp': timestamp.toIso8601String(),
//     'isDraft': isDraft,
//   };
// }