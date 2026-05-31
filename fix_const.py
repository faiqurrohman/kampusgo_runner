import os
import re

dirs = ['lib/screens', 'lib/widgets']
for d in dirs:
    if os.path.exists(d):
        for f in os.listdir(d):
            if f.endswith('.dart'):
                filepath = os.path.join(d, f)
                with open(filepath, 'r', encoding='utf-8') as file:
                    content = file.read()
                
                targets = [
                    r'const\s+EdgeInsets',
                    r'const\s+SizedBox',
                    r'const\s+Text\(',
                    r'const\s+TextStyle',
                    r'const\s+BorderRadius',
                    r'const\s+Padding',
                    r'const\s+Center',
                    r'const\s+Expanded',
                    r'const\s+Align',
                    r'const\s+BoxDecoration',
                    r'const\s+LinearGradient',
                    r'const\s+BoxShadow',
                    r'const\s+Icon\(',
                    r'const\s+CircleAvatar',
                    r'const\s+Column',
                    r'const\s+Row',
                    r'const\s+Container\(',
                    r'const\s+Positioned\(',
                    r'const\s+ListView\(',
                    r'const\s+BorderSide\(',
                    r'const\s+TextSpan\(',
                    r'const\s+\[',
                ]
                
                for t in targets:
                    replacement = t.replace(r'const\s+', '').replace(r'\(', '(').replace(r'\[', '[')
                    content = re.sub(t, replacement, content)

                with open(filepath, 'w', encoding='utf-8') as file:
                    file.write(content)
