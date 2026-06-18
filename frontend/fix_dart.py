import os
import re

lib_dir = 'lib'

def fix_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Replacements
    content = content.replace('ObsidianTheme.onPrimary', 'ObsidianTheme.onSurface')
    content = content.replace('ObsidianTheme.secondary', 'ObsidianTheme.tertiary')
    
    # regex for withOpacity
    content = re.sub(r'\.withOpacity\(([^)]+)\)', r'.withValues(alpha: \1)', content)
    
    # activeColor -> activeThumbColor in Switch/Checkbox
    content = content.replace('activeColor:', 'activeThumbColor:')

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            fix_file(os.path.join(root, file))

# Remove unused import in app_router.dart
router_file = os.path.join(lib_dir, 'router', 'app_router.dart')
if os.path.exists(router_file):
    with open(router_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    with open(router_file, 'w', encoding='utf-8') as f:
        for line in lines:
            if "import 'package:flutter/material.dart';" in line:
                continue
            f.write(line)

print("Done fixing dart files.")
