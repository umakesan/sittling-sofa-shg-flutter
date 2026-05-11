#!/usr/bin/env python3
"""
Pre-commit hook: detect cp1252-corrupted Unicode in staged Dart files.

Symptoms: UTF-8 multi-byte sequences misread as Windows-1252, then re-saved.
Common victims: ₹ → â‚¹, 📅 → ðŸ"…, · → Â·, ─ → â"€, — → â€"
"""
import subprocess, sys

# Known corruption patterns: (corrupted_utf8_bytes, original_char_description)
# Each tuple: UTF-8 encoding of the cp1252 misreading of the original UTF-8 bytes.
PATTERNS = [
    (b'\xc3\xa2\xe2\x80\x9a\xc2\xb9',   '₹  (rupee)'),        # E2 82 B9
    (b'\xc3\xb0\xc5\xb8\xe2\x80\x9c\xe2\x80\xa6', '📅 (calendar)'),  # F0 9F 93 85
    (b'\xc3\x82\xc2\xb7',               '·  (middle dot)'),    # C2 B7
    (b'\xc3\xa2\xe2\x80\x9d\xe2\x82\xac', '─  (box-draw)'),    # E2 94 80
    (b'\xc3\xa2\xe2\x82\xac\xe2\x80\x9d', '—  (em dash)'),     # E2 80 94
    (b'\xc3\xa2\xe2\x80\xa0\xe2\x80\x99', '→  (arrow)'),       # E2 86 92
]

# Get list of staged .dart files
result = subprocess.run(
    ['git', 'diff', '--cached', '--name-only', '--diff-filter=ACM'],
    capture_output=True, text=True
)
staged = [f for f in result.stdout.splitlines() if f.endswith('.dart')]

errors = []
for filepath in staged:
    try:
        with open(filepath, 'rb') as f:
            data = f.read()
    except FileNotFoundError:
        continue
    for pattern, description in PATTERNS:
        if pattern in data:
            errors.append(f"  {filepath}: contains corrupted {description}")

if errors:
    print("COMMIT BLOCKED — cp1252-corrupted Unicode detected:")
    for e in errors:
        print(e)
    print()
    print("Fix: your editor saved this file as Windows-1252 instead of UTF-8.")
    print("In VS Code: click the encoding in the status bar → 'Reopen with Encoding'")
    print("→ UTF-8, then save. Or run the repair script in docs/fix-encoding.py.")
    sys.exit(1)

sys.exit(0)
