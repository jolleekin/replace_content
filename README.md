# replace_content

`replace_content` is a pub transformer that replaces the contents of some
target files with the contents of matching source files based on the
transformation mode.

Given a target file `path/to/file.ext`, its content will be replaced with
the content of `path/to/file.{mode}.ext` where `{mode}` is the
transformation mode passed to `pub serve` and `pub build`.
`path/to/file.{mode}.ext` and other files of the same path format will be
excluded from the rest of the build process.

The transformer has two parameters
- `targets`: a list of target files or a single target file.
- `keep_source`: whether source files should be kept. Default is `false`.

### Usage
Suppose that your project supports two transformation modes `debug` and
`release`, and you want to change the contents of two target files based on
the transformation mode. Those files are
- `lib/config.dart`
- `web/sample.jpg`

Your project should have these files
- `lib/config.dart`: target file (text based)
- `lib/config.debug.dart`: source file to use if mode is `debug`
- `lib/config.release.dart`: source file to use if mode is `release`
- `web/sample.jpg`: target file (binary)
- `web/sample.debug.jpg`: source file to use if mode is `debug`
- `web/sample.release.jpg`: source file to use if mode is `release`

In `pubspec.yaml`, add the transformer and specify the target files
```yaml
transformers:
- replace_content:
    targets:
    - lib/config.dart
    - web/sample.jpg
```

After this transformer runs, the output will contain
- `lib/config.dart`: contains the content of `lib/config.debug.dart`
- `web/sample.jpg`: contains the content of `web/sample.debug.jpg`

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/jolleekin/replace_content/issues
