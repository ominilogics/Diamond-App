import 'dart:io';

void main() {
  final dir = Directory('lib/features');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    if (!content.contains('backgroundColor: const Color(0xFFE7FFEC),') &&
        !content.contains('backgroundColor: AppColors.gradientStart,')) {
      continue;
    }

    int index = 0;
    bool modified = false;
    while (true) {
      index = content.indexOf('SliverAppBar(', index);
      if (index == -1) break;

      int newlineIndex = content.lastIndexOf('\n', index);
      String indentation = content.substring(newlineIndex + 1, index);

      int openParens = 0;
      int closeIndex = -1;
      for (int i = index + 'SliverAppBar'.length; i < content.length; i++) {
        if (content[i] == '(') openParens++;
        if (content[i] == ')') {
          openParens--;
          if (openParens == 0) {
            closeIndex = i;
            break;
          }
        }
      }

      if (closeIndex != -1) {
        String sliverAppBarContent = content.substring(index, closeIndex + 1);
        if (sliverAppBarContent.contains('backgroundColor: const Color(0xFFE7FFEC),') ||
            sliverAppBarContent.contains('backgroundColor: AppColors.gradientStart,')) {
          
          String newSliverAppBarContent = sliverAppBarContent
              .replaceAll('backgroundColor: const Color(0xFFE7FFEC),', 'backgroundColor: isScrolled ? const Color(0xFFE7FFEC) : Colors.transparent,')
              .replaceAll('backgroundColor: AppColors.gradientStart,', 'backgroundColor: isScrolled ? AppColors.gradientStart : Colors.transparent,');

          newSliverAppBarContent = newSliverAppBarContent.replaceAll('\n', '\n  ');

          String wrapper = 'SliverLayoutBuilder(\n' +
              indentation + '  builder: (context, constraints) {\n' +
              indentation + '    final isScrolled = constraints.scrollOffset > 0;\n' +
              indentation + '    return ' + newSliverAppBarContent + ';\n' +
              indentation + '  },\n' +
              indentation + ')';

          content = content.substring(0, index) + wrapper + content.substring(closeIndex + 1);
          modified = true;
          index += wrapper.length;
        } else {
          index = closeIndex + 1;
        }
      } else {
        index += 'SliverAppBar('.length;
      }
    }
    
    if (modified) {
      file.writeAsStringSync(content);
      print('Updated ${file.path}');
    }
  }
}
