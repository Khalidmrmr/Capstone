#!/bin/bash
# Rebuilds D0, D1, D2 PDFs from their HTML and merges the consolidated Assignment #4 PDF:
# User_Stories, D0, D1, D2 (D2 ends with the peer review notes).
set -e
cd "$(dirname "$0")"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
for doc in D0_High_Level_Design D1_Detailed_Design D2_Detailed_Design; do
  "$CHROME" --headless --no-pdf-header-footer --print-to-pdf="$PWD/$doc.pdf" "file://$PWD/$doc.html" 2>/dev/null
done
MERGE="$(mktemp -d)/merge.swift"
cat > "$MERGE" <<'SWIFT'
import PDFKit
let args = Array(CommandLine.arguments.dropFirst())
let out = PDFDocument()
for path in args.dropLast() {
  guard let d = PDFDocument(url: URL(fileURLWithPath: path)) else { print("cannot read \(path)"); exit(1) }
  for i in 0..<d.pageCount { out.insert(d.page(at: i)!, at: out.pageCount) }
}
out.write(to: URL(fileURLWithPath: args.last!))
print("wrote \(args.last!) (\(out.pageCount) pages)")
SWIFT
swift "$MERGE" ../User_Stories.pdf D0_High_Level_Design.pdf D1_Detailed_Design.pdf D2_Detailed_Design.pdf ../Assignment4_Design_Diagrams.pdf
