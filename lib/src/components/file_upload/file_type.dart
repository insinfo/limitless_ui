import 'dart:html' as html;

class LiFileType {
  static const List<String> _mimeDoc = <String>[
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.template',
    'application/vnd.ms-word.document.macroEnabled.12',
    'application/vnd.ms-word.template.macroEnabled.12',
  ];

  static const List<String> _mimeXls = <String>[
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.template',
    'application/vnd.ms-excel.sheet.macroEnabled.12',
    'application/vnd.ms-excel.template.macroEnabled.12',
    'application/vnd.ms-excel.addin.macroEnabled.12',
    'application/vnd.ms-excel.sheet.binary.macroEnabled.12',
  ];

  static const List<String> _mimePpt = <String>[
    'application/vnd.ms-powerpoint',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'application/vnd.openxmlformats-officedocument.presentationml.template',
    'application/vnd.openxmlformats-officedocument.presentationml.slideshow',
    'application/vnd.ms-powerpoint.addin.macroEnabled.12',
    'application/vnd.ms-powerpoint.presentation.macroEnabled.12',
    'application/vnd.ms-powerpoint.slideshow.macroEnabled.12',
  ];

  static const List<String> _mimePsd = <String>[
    'image/photoshop',
    'image/x-photoshop',
    'image/psd',
    'application/photoshop',
    'application/psd',
    'zz-application/zz-winassoc-psd',
  ];

  static const List<String> _mimeCompress = <String>[
    'application/x-gtar',
    'application/x-gcompress',
    'application/compress',
    'application/x-tar',
    'application/x-rar-compressed',
    'application/octet-stream',
    'application/zip',
    'application/x-7z-compressed',
  ];

  static String getMimeClass(html.File file) {
    final type = file.type.toLowerCase();
    if (_mimePsd.contains(type) || type.startsWith('image/')) {
      return 'image';
    }
    if (type.startsWith('video/')) {
      return 'video';
    }
    if (type.startsWith('audio/')) {
      return 'audio';
    }
    if (type == 'application/pdf') {
      return 'pdf';
    }
    if (_mimeCompress.contains(type)) {
      return 'compress';
    }
    if (_mimeDoc.contains(type)) {
      return 'doc';
    }
    if (_mimeXls.contains(type)) {
      return 'xls';
    }
    if (_mimePpt.contains(type)) {
      return 'ppt';
    }

    return fileTypeDetection(file.name);
  }

  static String fileTypeDetection(String inputFilename) {
    const types = <String, String>{
      'jpg': 'image',
      'jpeg': 'image',
      'tif': 'image',
      'psd': 'image',
      'bmp': 'image',
      'png': 'image',
      'nef': 'image',
      'tiff': 'image',
      'cr2': 'image',
      'dwg': 'image',
      'cdr': 'image',
      'ai': 'image',
      'indd': 'image',
      'pin': 'image',
      'cdp': 'image',
      'skp': 'image',
      'stp': 'image',
      '3dm': 'image',
      'mp3': 'audio',
      'wav': 'audio',
      'wma': 'audio',
      'mod': 'audio',
      'm4a': 'audio',
      'rar': 'compress',
      '7z': 'compress',
      'lz': 'compress',
      'z01': 'compress',
      'zip': 'compress',
      'pdf': 'pdf',
      'xls': 'xls',
      'xlsx': 'xls',
      'ods': 'xls',
      'mp4': 'video',
      'avi': 'video',
      'wmv': 'video',
      'mpg': 'video',
      'mts': 'video',
      'flv': 'video',
      '3gp': 'video',
      'vob': 'video',
      'm4v': 'video',
      'mpeg': 'video',
      'm2ts': 'video',
      'mov': 'video',
      'doc': 'doc',
      'docx': 'doc',
      'eps': 'doc',
      'txt': 'doc',
      'odt': 'doc',
      'rtf': 'doc',
      'ppt': 'ppt',
      'pptx': 'ppt',
      'pps': 'ppt',
      'ppsx': 'ppt',
      'odp': 'ppt',
    };

    final chunks = inputFilename.split('.');
    if (chunks.length < 2) {
      return 'application';
    }

    return types[chunks.last.toLowerCase()] ?? 'application';
  }
}
