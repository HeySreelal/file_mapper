# File Mapper - Directory Visualization Tool

A simple yet powerful CLI tool built with Dart that visualizes the directory structure of your project with colorized output. File Mapper helps you quickly understand your project's file organization with customizable filtering, sorting, and depth options.

## Features

- 🌲 **Beautiful Tree Visualization**: Displays your directories and files in a colorized tree structure
- 📊 **Size Information**: Optional display of file and directory sizes
- 🔍 **Customizable Depth**: Control how deep the directory traversal goes
- 🔄 **Flexible Sorting**: Sort by name or size, in ascending or descending order
- ⛔ **Filtering**: Skip irrelevant directories like node_modules, .git, etc.
- ⚙️ **Persistent Configuration**: Save your preferred ignore patterns

## Installation

### From Pub.dev

```bash
dart pub global activate file_mapper
```

### From Source

```bash
# Clone the repository
git clone https://github.com/HeySreelal/file_mapper.git

# Navigate to the project directory
cd file_mapper

# Install dependencies
dart pub get

# Activate globally
dart pub global activate --source path .
```

## Usage

```bash
file_mapper [options]
```

### Options

- `-s, --size`: Show file and directory sizes
- `-h, --help`: Show help information
- `-i, --ignore <pattern>`: Patterns to ignore (can be used multiple times)
- `--sort-by <criteria>`: Sort entries by (name, size)
- `--sort-direction <direction>`: Sort direction (asc, desc)
- `-l, --level <n>`: Maximum directory depth to display

### Examples

Display directory tree with file sizes:
```bash
file_mapper --size
```

Show directory tree with maximum depth of 2:
```bash
file_mapper --level 2
```

Ignore specific directories:
```bash
file_mapper --ignore node_modules --ignore .git
```

Sort files by size in descending order:
```bash
file_mapper --size --sort-by size --sort-direction desc
```

## Configuration

File Mapper creates a configuration file at `~/.file_mapper_config.json` that stores default ignore patterns. By default, the following patterns are ignored:

- .git
- .idea
- .vscode
- node_modules
- build
- out
- dist
- .dart_tool
- .packages
- .pub-cache
- .flutter-plugins
- .flutter-plugins-dependencies

You can edit this file to customize your default ignore patterns.

## Output Example

```
Directory: /Users/username/projects/my_project

├── lib/
│   ├── src/
│   │   ├── models/
│   │   │   └── user.dart 3.2 KB
│   │   └── utils/
│   │       └── helpers.dart 1.5 KB
│   └── main.dart 1.1 KB
├── test/
│   └── widget_test.dart 2.8 KB
└── pubspec.yaml 1.7 KB

Summary:
Total files: 4
Total directories: 4
Total size: 10.3 KB
```

## Development

### Project Structure

- `cli_parser.dart`: Handles command line argument parsing
- `config_manager.dart`: Manages configuration storage and retrieval
- `console_colors.dart`: Handles colored console output
- `tree_printer.dart`: Core logic for traversing and rendering the directory tree
- `file_mapper.dart`: Main file and entry point

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

Made with ❤️ by @HeySreelal