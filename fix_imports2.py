import os
import re

directory = 'lib/views/components'

for root, _, files in os.walk(directory):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                content = f.read()

            new_content = content
            
            # fix core imports
            new_content = new_content.replace("import '../../core/", "import '../../../core/")
            
            # fix atoms, molecules, organisms imports
            new_content = new_content.replace("import '../components/atoms/", "import '../atoms/")
            new_content = new_content.replace("import '../components/molecules/", "import '../molecules/")
            new_content = new_content.replace("import '../components/organisms/", "import '../organisms/")
            
            # organism to pages was changed to '../../pages/' which is correct because views/components/organisms -> views/components -> views -> pages
            
            if new_content != content:
                with open(filepath, 'w') as f:
                    f.write(new_content)
                print(f"Updated {filepath}")
