## Examples

### Basic Usage
```bash
# Basic tree view of current directory
file_mapper

# Show with file sizes
file_mapper --size

# Limit directory depth to 2 levels
file_mapper --level 2
```

### Filtering and Sorting
```bash
# Ignore specific directories
file_mapper --ignore node_modules --ignore .git

# Sort by size in descending order (largest files first)
file_mapper --size --sort-by size --sort-direction desc
```

### Sample Output
```
Directory: /project

├── lib/
│   ├── models/
│   │   └── user.dart 3.2 KB
│   └── main.dart 1.1 KB
├── test/
│   └── widget_test.dart 2.8 KB
└── pubspec.yaml 1.7 KB

Summary:
Total files: 3
Total directories: 3
Total size: 8.8 KB
```