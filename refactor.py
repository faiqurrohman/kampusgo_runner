import os
import re

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Only process if not already processed extensively
    if 'flutter_screenutil' not in content:
        content = "import 'package:flutter_screenutil/flutter_screenutil.dart';\n" + content

    # Regex patterns
    # height: 20 -> height: 20.h
    content = re.sub(r'(height:\s*)(\d+\.?\d*)(?![\w\.])', r'\1\2.h', content)
    
    # width: 20 -> width: 20.w
    content = re.sub(r'(width:\s*)(\d+\.?\d*)(?![\w\.])', r'\1\2.w', content)

    # fontSize: 20 -> fontSize: 20.sp
    content = re.sub(r'(fontSize:\s*)(\d+\.?\d*)(?![\w\.])', r'\1\2.sp', content)

    # radius: 20 -> radius: 20.r
    content = re.sub(r'(radius:\s*)(\d+\.?\d*)(?![\w\.])', r'\1\2.r', content)
    
    # blurRadius: 20 -> blurRadius: 20.r
    content = re.sub(r'(blurRadius:\s*)(\d+\.?\d*)(?![\w\.])', r'\1\2.r', content)

    # spreadRadius: 20 -> spreadRadius: 20.r
    content = re.sub(r'(spreadRadius:\s*)(\d+\.?\d*)(?![\w\.])', r'\1\2.r', content)

    # EdgeInsets.all(20) -> EdgeInsets.all(20.w)
    content = re.sub(r'(EdgeInsets\.all\(\s*)(\d+\.?\d*)(?![\w\.])', r'\1\2.w', content)

    # EdgeInsets.symmetric(horizontal: 20, vertical: 20) -> ...
    def sym_repl(match):
        res = match.group(0)
        res = re.sub(r'(horizontal:\s*)(\d+\.?\d*)(?![\w\.])', r'\1\2.w', res)
        res = re.sub(r'(vertical:\s*)(\d+\.?\d*)(?![\w\.])', r'\1\2.h', res)
        return res
    content = re.sub(r'EdgeInsets\.symmetric\([^)]+\)', sym_repl, content)

    # EdgeInsets.only(...)
    def only_repl(match):
        res = match.group(0)
        res = re.sub(r'(left:\s*)(\d+\.?\d*)(?![\w\.])', r'\1\2.w', res)
        res = re.sub(r'(right:\s*)(\d+\.?\d*)(?![\w\.])', r'\1\2.w', res)
        res = re.sub(r'(top:\s*)(\d+\.?\d*)(?![\w\.])', r'\1\2.h', res)
        res = re.sub(r'(bottom:\s*)(\d+\.?\d*)(?![\w\.])', r'\1\2.h', res)
        return res
    content = re.sub(r'EdgeInsets\.(?:fromLTRB|only)\([^)]+\)', only_repl, content)

    # BorderRadius.circular(20)
    content = re.sub(r'(BorderRadius\.circular\(\s*)(\d+\.?\d*)(?![\w\.])', r'\1\2.r', content)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

dirs = ['lib/screens', 'lib/widgets']
for d in dirs:
    if os.path.exists(d):
        for f in os.listdir(d):
            if f.endswith('.dart'):
                process_file(os.path.join(d, f))
