// Copyright (c) 2017, Man Hoang. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// `replace_content` is a pub transformer that replaces the contents of some
/// target files with the contents of matching source files based on the
/// transformation mode.
///
/// Given a target file `path/to/file.ext`, its content will be replaced with
/// the content of `path/to/file.{mode}.ext` where `{mode}` is the
/// transformation mode passed to `pub serve` and `pub build`.
/// `path/to/file.{mode}.ext` and other files of the same path format will be
/// excluded from the rest of the build process.
///
/// The transformer has two parameters
/// - `targets`: a list of target files or a single target file.
/// - `keep_source`: whether source files should be kept. Default is `false`.
///
/// __Usage__:
/// Suppose that your project supports two transformation modes `debug` and
/// `release`, and you want to change the contents of two target files based on
/// the transformation mode. Those files are
/// - `lib/config.dart`
/// - `web/sample.jpg`
///
/// Your project should have these files
/// - `lib/config.dart`: target file (text based)
/// - `lib/config.debug.dart`: source file to use if mode is `debug`
/// - `lib/config.release.dart`: source file to use if mode is `release`
/// - `web/sample.jpg`: target file (binary)
/// - `web/sample.debug.jpg`: source file to use if mode is `debug`
/// - `web/sample.release.jpg`: source file to use if mode is `release`
///
/// In `pubspec.yaml`, add the transformer and specify the target files
///     transformers:
///     - replace_content:
///         targets:
///         - lib/config.dart
///         - web/sample.jpg
/// 
/// After this transformer runs, the output will contain
/// - `lib/config.dart`: contains the content of `lib/config.debug.dart`
/// - `web/sample.jpg`: contains the content of `web/sample.debug.jpg`
library replace_content;

import 'package:barback/barback.dart';

class ReplaceContent extends Transformer {
  bool _keepSource;
  String _mode;
  List<String> _targets;

  /// Given a target at `path/to/file.ext`, this method returns true if [id]'s
  /// path is of the form `path/to/file.{mode}.ext` where `{mode}` is any string
  /// that doesn't contain '.' and '/'.
  bool _isSource(AssetId id) {
    var parts = id.path.split('.');
    var n = parts.length;
    if (n >= 3 && !parts[n - 2].contains('/')) {
      parts.removeAt(n - 2);
      var path = parts.join('.');
      return _targets.contains(path);
    }
    return false;
  }

  ReplaceContent.asPlugin(BarbackSettings settings) {
    _keepSource = settings.configuration['keep_source'] ?? false;
    _mode = settings.mode.name;
    _targets = _toList(settings.configuration['targets']);
  }

  @override
  apply(Transform transform) async {
    var id = transform.primaryInput.id;
    if (_targets.contains(id.path)) {
      var srcId = id.changeExtension('.$_mode${id.extension}');
      transform.addOutput(new Asset.fromPath(id, srcId.path));
    } else if (!_keepSource && _isSource(id)) {
      transform.consumePrimary();
    }
  }
}

List<String> _toList(value) {
  var files = <String>[];
  bool error;
  if (value is List) {
    files = value as List<String>;
    error = value.any((e) => e is! String);
  } else if (value is String) {
    files = [value];
    error = false;
  } else {
    error = true;
  }
  if (error) {
    print('Invalid value for "targets" in the replace_content transformer.');
  }
  return files;
}
