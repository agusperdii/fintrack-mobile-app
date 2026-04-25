import os
import re

directory = 'lib'

for root, _, files in os.walk(directory):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                content = f.read()

            new_content = content
            
            # models
            new_content = re.sub(r"import\s+'(.*?)data/models/", r"import '\1models/entities/", new_content)
            new_content = re.sub(r"import\s+'(.*?)data/repositories/", r"import '\1models/repositories/", new_content)
            new_content = re.sub(r"import\s+'(.*?)data/data_sources/", r"import '\1models/data_sources/", new_content)
            
            # controllers
            new_content = re.sub(r"import\s+'(.*?)presentation/providers/finance_provider.dart'", r"import '\1controllers/finance_controller.dart'", new_content)
            new_content = new_content.replace('FinanceProvider', 'FinanceController')
            
            # from main.dart
            new_content = re.sub(r"import\s+'presentation/pages/", r"import 'views/pages/", new_content)
            
            # components
            new_content = re.sub(r"import\s+'\.\./atoms/", r"import '../components/atoms/", new_content)
            new_content = re.sub(r"import\s+'\.\./molecules/", r"import '../components/molecules/", new_content)
            new_content = re.sub(r"import\s+'\.\./organisms/", r"import '../components/organisms/", new_content)
            
            # organism to pages
            new_content = re.sub(r"import\s+'\.\./pages/", r"import '../../pages/", new_content)
            
            if new_content != content:
                with open(filepath, 'w') as f:
                    f.write(new_content)
                print(f"Updated {filepath}")
