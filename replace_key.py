#!/usr/bin/env python3
"""Replace the Supabase key in index.html"""
with open('index.html', 'r') as f:
    content = f.read()

# Replace the entire key in the return statement
# Old: service key ending with 2YA2FvX0bmShS8rwAan64mKrrUdirRoy1QOU12ZUyy4
# New: anon key ending with K1_niR4ZylqzbDPFnmTs5HRo2aEbObkGw3V9clM1czo
old_suffix = '2YA2FvX0bmShS8rwAan64mKrrUdirRoy1QOU12ZUyy4'
new_suffix = 'K1_niR4ZylqzbDPFnmTs5HRo2aEbObkGw3V9clM1czo'

if old_suffix in content:
    content = content.replace(old_suffix, new_suffix)
    print('Key suffix replaced successfully')
else:
    print('Old suffix not found, trying full key replacement...')
    # Just replace the whole key string
    content = content.replace(
        "return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBreG1zZnl6Y3BoenZ1YW5ncnpzIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3OTA0OTE3NywiZXhwIjoyMDk0NjI1MTc3fQ.2YA2FvX0bmShS8rwAan64mKrrUdirRoy1QOU12ZUyy4'",
        "return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBreG1zZnl6Y3BoenZ1YW5ncnpzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkwNDkxNzcsImV4cCI6MjA5NDYyNTE3N30.K1_niR4ZylqzbDPFnmTs5HRo2aEbObkGw3V9clM1czo'"
    )
    print('Full key replacement done')

with open('index.html', 'w') as f:
    f.write(content)

# Verify
with open('index.html', 'r') as f:
    for i, line in enumerate(f, 1):
        if 'return' in line and 'eyJ' in line:
            print(f'Line {i}: {line.strip()[:70]}...')
            if 'anon' in line:
                print('✅ Anon key confirmed!')
            else:
                print('❌ Still has wrong role')
