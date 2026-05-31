import os
import re

def fix_file(filepath):
    if not os.path.exists(filepath): return
    with open(filepath, 'r') as f:
        code = f.read()

    # Generic replace for jsonDecode(response.body)
    code = re.sub(
        r'final response = await _client\.([a-z]+)\((.*?)\);\s*final body = jsonDecode\(response\.body\) as Map<String, dynamic>;\s*if \(body\[\'success\'\] != true\) \{\s*throw ApiErrorException\([^\)]+\);\s*\}\s*final data = body\[\'data\'\] as List\? \?\? \[\];\s*return data\.map\((.*?)\)\.toList\(\);',
        r'final data = await _client.\1(\2) as List? ?? [];\n    return data.map(\3).toList();',
        code, flags=re.DOTALL
    )

    code = re.sub(
        r'final response = await _client\.([a-z]+)\((.*?)\);\s*final body = jsonDecode\(response\.body\) as Map<String, dynamic>;\s*if \(body\[\'success\'\] != true\) \{\s*throw ApiErrorException\([^\)]+\);\s*\}\s*return ([A-Za-z0-9_]+)\.fromJson\(body\[\'data\'\] as Map<String, dynamic>\);',
        r'final data = await _client.\1(\2) as Map<String, dynamic>;\n    return \3.fromJson(data);',
        code, flags=re.DOTALL
    )

    code = re.sub(
        r'final response = await _client\.([a-z]+)\((.*?)\);\s*final body = jsonDecode\(response\.body\) as Map<String, dynamic>;\s*if \(body\[\'success\'\] != true\) \{\s*throw ApiErrorException\([^\)]+\);\s*\}',
        r'await _client.\1(\2);',
        code, flags=re.DOTALL
    )
    
    # Specific OCR replace
    code = re.sub(
        r'final resBody = jsonDecode\(response\.body\) as Map<String, dynamic>;\s*if \(resBody\[\'success\'\] != true\) \{[^\}]+\}',
        r'final resBody = response;',
        code, flags=re.DOTALL
    )

    with open(filepath, 'w') as f:
        f.write(code)

files = [
    'lib/repositories/data_sources/remote/category_remote_data_source.dart',
    'lib/repositories/data_sources/remote/notification_remote_data_source.dart',
    'lib/repositories/data_sources/remote/analytics_remote_data_source.dart',
    'lib/repositories/data_sources/ocr_data_source.dart'
]

for f in files:
    fix_file(f)
