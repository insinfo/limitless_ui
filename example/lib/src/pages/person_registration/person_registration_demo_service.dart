import 'dart:async';
import 'dart:html' as html;

import 'package:ngdart/angular.dart';

class PersonRegistrationMockRequest {
  const PersonRegistrationMockRequest({
    required this.fullName,
    required this.preferredName,
    required this.cpf,
    required this.email,
    required this.phone,
    required this.password,
    required this.notes,
    required this.birthDate,
    required this.preferredContactTime,
    required this.availabilityStart,
    required this.availabilityEnd,
    required this.personType,
    required this.departmentId,
    required this.skillIds,
    required this.reviewerIds,
    required this.primaryReviewerId,
    required this.workflowNode,
    required this.workflowNodeIds,
    required this.expectedCompensationMinorUnits,
    required this.contactChannel,
    required this.remoteEnabled,
    required this.accessibilityNeeded,
    required this.notificationsEnabled,
    required this.publicProfile,
    required this.acceptTerms,
    required this.acceptPrivacy,
    required this.attachments,
  });

  final String fullName;
  final String preferredName;
  final String cpf;
  final String email;
  final String phone;
  final String password;
  final String notes;
  final DateTime? birthDate;
  final Duration? preferredContactTime;
  final DateTime? availabilityStart;
  final DateTime? availabilityEnd;
  final String personType;
  final String departmentId;
  final List<String> skillIds;
  final List<String> reviewerIds;
  final String primaryReviewerId;
  final String workflowNode;
  final List<String> workflowNodeIds;
  final int? expectedCompensationMinorUnits;
  final String contactChannel;
  final bool remoteEnabled;
  final bool accessibilityNeeded;
  final bool notificationsEnabled;
  final bool publicProfile;
  final bool acceptTerms;
  final bool acceptPrivacy;
  final List<html.File> attachments;
}

class PersonRegistrationMockResult {
  const PersonRegistrationMockResult._({
    required this.success,
    required this.fieldErrors,
    required this.generalErrors,
    this.personId,
    this.protocol,
    this.normalizedPayload = const <String, dynamic>{},
  });

  factory PersonRegistrationMockResult.success({
    required int personId,
    required String protocol,
    required Map<String, dynamic> normalizedPayload,
  }) {
    return PersonRegistrationMockResult._(
      success: true,
      fieldErrors: const <String, String>{},
      generalErrors: const <String>[],
      personId: personId,
      protocol: protocol,
      normalizedPayload: normalizedPayload,
    );
  }

  factory PersonRegistrationMockResult.failure({
    required Map<String, String> fieldErrors,
    List<String> generalErrors = const <String>[],
  }) {
    return PersonRegistrationMockResult._(
      success: false,
      fieldErrors: Map<String, String>.unmodifiable(fieldErrors),
      generalErrors: List<String>.unmodifiable(generalErrors),
    );
  }

  final bool success;
  final int? personId;
  final String? protocol;
  final Map<String, String> fieldErrors;
  final List<String> generalErrors;
  final Map<String, dynamic> normalizedPayload;
}

@Injectable()
class PersonRegistrationDemoService {
  static const Set<String> _blockedEmails = <String>{
    'duplicado@limitless.dev',
    'taken@limitless.dev',
    'used@company.dev',
  };

  static const Set<String> _blockedCpfs = <String>{
    '11111111111',
    '12345678909',
  };

  int _nextPersonId = 4100;

  Future<PersonRegistrationMockResult> submit(
    PersonRegistrationMockRequest request,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 850));

    final fieldErrors = <String, String>{};
    final generalErrors = <String>[];

    final normalizedEmail = request.email.trim().toLowerCase();
    final normalizedCpf = request.cpf.replaceAll(RegExp(r'\D'), '');
    final normalizedPhone = request.phone.replaceAll(RegExp(r'\D'), '');
    final attachmentNames = request.attachments
        .map((file) => file.name.trim())
        .where((name) => name.isNotEmpty)
        .toList(growable: false);
    final hasPdf = request.attachments.any((file) {
      final name = file.name.toLowerCase();
      final type = file.type.toLowerCase();
      return name.endsWith('.pdf') || type.contains('pdf');
    });
    final hasImage = request.attachments.any((file) {
      final type = file.type.toLowerCase();
      final name = file.name.toLowerCase();
      return type.startsWith('image/') ||
          name.endsWith('.png') ||
          name.endsWith('.jpg') ||
          name.endsWith('.jpeg') ||
          name.endsWith('.webp');
    });

    if (_blockedEmails.contains(normalizedEmail)) {
      fieldErrors['email'] =
          'Este e-mail já existe na base simulada do backend.';
    }

    if (_blockedCpfs.contains(normalizedCpf)) {
      fieldErrors['cpf'] =
          'O backend bloqueou este CPF para demonstrar validação server-side.';
    }

    if (request.personType == 'contractor' &&
        request.skillIds.contains('sensitive-data')) {
      fieldErrors['skills'] =
          'Prestadores não podem receber a skill "Dados sensíveis".';
    }

    if (request.departmentId == 'finance' && !hasPdf) {
      fieldErrors['attachments'] =
          'Financeiro exige ao menos um anexo PDF no backend simulado.';
    }

    if (request.publicProfile && !hasImage) {
      fieldErrors['attachments'] = fieldErrors['attachments']
                  ?.trim()
                  .isNotEmpty ==
              true
          ? '${fieldErrors['attachments']} Perfis públicos também exigem uma imagem.'
          : 'Perfil público exige pelo menos uma imagem.';
    }

    if (request.contactChannel == 'sms' &&
        normalizedPhone.length >= 4 &&
        normalizedPhone.endsWith('0000')) {
      fieldErrors['phone'] =
          'O backend recusou telefones SMS terminados em 0000.';
    }

    final availabilityDays = _differenceInDays(
      request.availabilityStart,
      request.availabilityEnd,
    );
    if (availabilityDays != null && availabilityDays > 60) {
      fieldErrors['availability'] =
          'A janela de disponibilidade não pode passar de 60 dias.';
    }

    final normalizedNotes = request.notes.trim().toLowerCase();
    if (normalizedNotes.contains('hack') ||
        normalizedNotes.contains('exploit') ||
        normalizedNotes.contains('script malicioso')) {
      fieldErrors['notes'] =
          'O backend marcou a observação como conteúdo suspeito.';
    }

    final hasForbiddenFileName = attachmentNames.any((name) {
      final lower = name.toLowerCase();
      return lower.contains('virus') ||
          lower.contains('malware') ||
          lower.contains('script');
    });
    if (hasForbiddenFileName) {
      fieldErrors['attachments'] =
          fieldErrors['attachments']?.trim().isNotEmpty == true
              ? '${fieldErrors['attachments']} Há um arquivo com nome proibido.'
              : 'Há um arquivo com nome proibido para o backend simulado.';
    }

    if (request.fullName.trim().toLowerCase().contains('teste')) {
      generalErrors.add(
        'O backend marcou este cadastro como dado sintético. Use um nome realista para aprovar.',
      );
    }

    if (!request.acceptTerms || !request.acceptPrivacy) {
      generalErrors.add(
        'O backend exige os dois consentimentos ativos antes de persistir o cadastro.',
      );
    }

    if (fieldErrors.isNotEmpty || generalErrors.isNotEmpty) {
      return PersonRegistrationMockResult.failure(
        fieldErrors: fieldErrors,
        generalErrors: generalErrors,
      );
    }

    final personId = _nextPersonId++;
    final protocol = 'PES-${DateTime.now().year}-$personId';
    return PersonRegistrationMockResult.success(
      personId: personId,
      protocol: protocol,
      normalizedPayload: <String, dynamic>{
        'person_id': personId,
        'protocol': protocol,
        'normalized_email': normalizedEmail,
        'normalized_cpf': normalizedCpf,
        'normalized_phone': normalizedPhone,
        'person_type': request.personType,
        'department_id': request.departmentId,
        'skill_ids': request.skillIds,
        'reviewer_ids': request.reviewerIds,
        'primary_reviewer_id': request.primaryReviewerId,
        'workflow_node': request.workflowNode,
        'workflow_node_ids': request.workflowNodeIds,
        'expected_compensation_minor_units':
            request.expectedCompensationMinorUnits,
        'remote_enabled': request.remoteEnabled,
        'notifications_enabled': request.notificationsEnabled,
        'public_profile': request.publicProfile,
        'attachment_names': attachmentNames,
      },
    );
  }

  int? _differenceInDays(DateTime? start, DateTime? end) {
    if (start == null || end == null) {
      return null;
    }
    return end.difference(start).inDays;
  }
}
