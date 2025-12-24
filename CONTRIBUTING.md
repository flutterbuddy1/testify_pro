# Contributing to Testify Pro

First off, thank you for considering contributing to Testify Pro! It's people like you that make Testify Pro such a great tool.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Project Structure](#project-structure)
- [Testing Guidelines](#testing-guidelines)
- [Documentation Guidelines](#documentation-guidelines)

---

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please be respectful, inclusive, and collaborative.

### Our Standards

- Use welcoming and inclusive language
- Be respectful of differing viewpoints and experiences
- Gracefully accept constructive criticism
- Focus on what is best for the community
- Show empathy towards other community members

---

## Getting Started

### Prerequisites

Before you begin, ensure you have:

- **Flutter SDK** 3.8.1 or higher installed
- **Dart SDK** 3.0 or higher
- **Git** for version control
- **Windows** 10/11 for testing (primary platform)
- **Visual Studio Code** or **Android Studio** (recommended IDEs)

### Recommended VS Code Extensions

- Flutter
- Dart
- Error Lens
- Bracket Pair Colorizer
- GitLens

---

## Development Setup

### 1. Fork and Clone

```bash
# Fork the repository on GitHub, then clone your fork
git clone https://github.com/flutterbuddy1/testify_pro.git
cd testify_pro

# Add upstream remote
git remote add upstream https://github.com/flutterbuddy1/testify_pro.git
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Code

```bash
# Generate Freezed models and JSON serialization
flutter pub run build_runner build --delete-conflicting-outputs

# For continuous generation during development
flutter pub run build_runner watch
```

### 4. Run the App

```bash
# Run in debug mode
flutter run -d windows

# Run in release mode
flutter run -d windows --release
```

### 5. Keep Your Fork Updated

```bash
# Fetch upstream changes
git fetch upstream

# Merge upstream main into your branch
git checkout main
git merge upstream/main
```

---

## How to Contribute

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates.

When you create a bug report, include:

- **Clear title**: Describe the issue concisely
- **Steps to reproduce**: Numbered step-by-step instructions
- **Expected behavior**: What you expected to happen
- **Actual behavior**: What actually happened
- **Screenshots**: If applicable
- **Environment**:
  - OS version (e.g., Windows 11)
  - Flutter version (`flutter --version`)
  - Testify Pro version

**Example Bug Report**:

```markdown
**Title**: Load test crashes when setting >50,000 users

**Steps to Reproduce**:
1. Navigate to Load Testing
2. Set Virtual Users to 60,000
3. Click "Start Load Test"
4. Application crashes after 10 seconds

**Expected**: Test should run successfully
**Actual**: App crashes with "Out of Memory" error

**Environment**:
- Windows 11 Pro
- Flutter 3.8.1
- Testify Pro 1.0.0
```

### Suggesting Features

Feature requests are welcome! Please provide:

- **Clear title**: Describe the feature
- **Use case**: Why is this needed?
- **Proposed solution**: How should it work?
- **Alternatives**: Other approaches considered

### Contributing Code

1. **Find an issue** or create one
2. **Comment** on the issue to claim it
3. **Create a branch** from `main`
4. **Make your changes**
5. **Test thoroughly**
6. **Submit a pull request**

---

## Coding Standards

### Dart Style Guide

Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines.

#### Formatting

```bash
# Format all Dart files
dart format .

# Check for issues
flutter analyze
```

#### Naming Conventions

```dart
// Classes: PascalCase
class ApiTestScreen extends StatelessWidget {}

// Variables and functions: camelCase
final String apiEndpoint = 'https://api.example.com';
void executeRequest() {}

// Private members: prefix with underscore
String _privateVariable;
void _privateMethod() {}

// Constants: lowerCamelCase or SCREAMING_SNAKE_CASE
const int defaultTimeout = 5000;
const String API_KEY = 'your_key_here';
```

### Code Organization

#### File Structure

```dart
// 1. Imports (organized by category)
// Dart SDK
import 'dart:async';
import 'dart:io';

// Flutter framework
import 'package:flutter/material.dart';

// Third-party packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

// Internal imports (relative paths)
import '../../domain/entities/api_request.dart';
import '../../core/providers/global_providers.dart';

// 2. Constants (if any)
const int _kMaxRetries = 3;

// 3. Main class/widget
class MyWidget extends StatelessWidget {
  // 4. Properties (public first, then private)
  final String title;
  final VoidCallback? onTap;
  
  final String? _privateData;
  
  // 5. Constructor
  const MyWidget({
    Key? key,
    required this.title,
    this.onTap,
  }) : super(key: key);
  
  // 6. Build/Methods (public first, then private)
  @override
  Widget build(BuildContext context) {
    return Container();
  }
  
  void _privateMethod() {}
}
```

#### Widget Guidelines

```dart
// GOOD: Extract complex widgets
Widget _buildHeader() {
  return Container(
    child: Text('Header'),
  );
}

// AVOID: Nesting too deeply
Widget build(BuildContext context) {
  return Container(
    child: Column(
      children: [
        Container(
          child: Row(
            children: [
              Container(
                // Too deep! Extract this
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// GOOD: Use const constructors when possible
const SizedBox(height: 16)

// GOOD: Use named parameters
TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: Colors.blue,
)
```

### State Management (Riverpod)

```dart
// Provider definition
final counterProvider = StateProvider<int>((ref) => 0);

// In widgets - use ConsumerWidget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    
    return Text('Count: $count');
  }
}

// In StatefulWidget - use ConsumerStatefulWidget
class MyStatefulWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends ConsumerState<MyStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    final count = ref.watch(counterProvider);
    return Text('$count');
  }
}
```

### Error Handling

```dart
// GOOD: Handle errors gracefully
try {
  final response = await httpService.execute(request);
  return ApiResponse.fromResponse(response);
} catch (e) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
  return ApiResponse.error(e.toString());
}

// GOOD: Use specific exception types
try {
  // code
} on DioException catch (e) {
  // Handle Dio-specific errors
} on FormatException catch (e) {
  // Handle format errors
} catch (e) {
  // Handle any other error
}
```

### Comments and Documentation

```dart
// GOOD: Document public APIs
/// Executes an HTTP request and returns the response.
///
/// [request] The API request configuration.
/// Returns an [ApiResponse] containing status, headers, and body.
///
/// Throws [DioException] if the network request fails.
Future<ApiResponse> execute(ApiRequest request) async {
  // Implementation
}

// GOOD: Explain complex logic
// Calculate percentiles using the nearest-rank method.
// Sort response times and find values at p50, p95, p99 positions.
final sortedTimes = responseTimes..sort();
final p50Index = (sortedTimes.length * 0.5).ceil() - 1;

// AVOID: Obvious comments
final count = 0; // Initialize count to zero (redundant!)
```

---

## Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

#### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code formatting (no logic change)
- `refactor`: Code refactoring
- `perf`: Performance improvement
- `test`: Adding tests
- `chore`: Build process or tooling changes

#### Examples

```bash
# Simple commit
git commit -m "feat: Add WebSocket support to API testing"

# Detailed commit
git commit -m "fix(load-testing): Prevent memory leak in metrics aggregator

The metrics aggregator was keeping all response times in memory,
causing OOM errors during long-running tests. Now we:
- Keep only the last 10,000 response times
- Calculate percentiles incrementally
- Clear old data after each aggregation

Fixes #123"

# Breaking change
git commit -m "feat!: Change Flow entity structure

BREAKING CHANGE: Flow.steps is now a List<FlowStep> instead of Map.
Migration required for existing flow data."
```

---

## Pull Request Process

### Before Submitting

1. **Run tests** (if applicable)
2. **Format code**: `dart format .`
3. **Analyze code**: `flutter analyze`
4. **Test manually**: Run the app and verify changes
5. **Update docs**: If you changed APIs or added features
6. **Commit with clear messages**

### PR Template

```markdown
## Description
Brief description of what this PR does.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
How did you test this?
- [ ] Tested manually on Windows
- [ ] Added unit tests
- [ ] Tested with existing flows

## Screenshots (if applicable)
Add screenshots or GIFs showing the changes.

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-reviewed the code
- [ ] Commented complex areas
- [ ] Updated documentation
- [ ] No new warnings from `flutter analyze`
- [ ] Tested thoroughly

## Related Issues
Fixes #123
Closes #456
```

### Review Process

1. **Automated checks** will run
2. **Maintainer review** within 3-5 days
3. **Address feedback** if requested
4. **Approval** and merge

---

## Project Structure

Understanding the architecture helps you contribute effectively.

```
lib/
├── core/                      # Shared utilities
│   ├── constants/            # App-wide constants
│   ├── providers/            # Global Riverpod providers
│   ├── theme/                # Material theme definitions
│   └── utils/                # Helper functions
│
├── domain/                    # Business logic (pure Dart)
│   └── entities/             # Business entities (Freezed)
│
├── data/                      # Data access layer
│   ├── services/             # External services (HTTP)
│   └── repositories/         # Data persistence (Hive)
│
├── infrastructure/            # External tools & engines
│   ├── load_engine/          # Load testing implementation
│   └── flow_engine/          # Flow execution implementation
│
└── presentation/              # UI layer
    └── screens/              # App screens
```

### Adding a New Feature

**Example: Add support for SOAP requests**

1. **Domain**: Define `SoapRequest` entity
   ```dart
   // lib/domain/entities/soap_request.dart
   @freezed
   class SoapRequest with _$SoapRequest {
     factory SoapRequest({
       required String endpoint,
       required String soapAction,
       required String xmlBody,
     }) = _SoapRequest;
   }
   ```

2. **Data**: Create `SoapService`
   ```dart
   // lib/data/services/soap_service.dart
   class SoapService {
     Future<SoapResponse> execute(SoapRequest request) async {
       // Implementation
     }
   }
   ```

3. **Presentation**: Add UI screen
   ```dart
   // lib/presentation/screens/soap_test_screen.dart
   class SoapTestScreen extends ConsumerWidget {
     // UI implementation
   }
   ```

4. **Integration**: Register in navigation
   ```dart
   // lib/presentation/screens/home_screen.dart
   _NavigationItem(
     icon: Icons.soap,
     label: 'SOAP Testing',
     screen: const SoapTestScreen(),
   ),
   ```

---

## Testing Guidelines

### Manual Testing

Always test on Windows:

1. **Fresh start**: Delete Hive boxes in `%USERPROFILE%\AppData\Local\testify_pro`
2. **Basic flow**: Test all main features
3. **Edge cases**: Empty inputs, extreme values, network errors
4. **Performance**: Test with realistic workloads

### Future: Unit Tests

We plan to add unit tests. Contributions welcome!

```dart
// Example test structure
void main() {
  group('HttpService', () {
    test('should return successful response', () async {
      // Arrange
      final service = HttpService();
      final request = ApiRequest(
        url: 'https://jsonplaceholder.typicode.com/posts/1',
        method: HttpMethod.get,
      );
      
      // Act
      final response = await service.execute(request);
      
      // Assert
      expect(response.statusCode, equals(200));
    });
  });
}
```

---

## Documentation Guidelines

### Code Comments

- **What**: Document public APIs with `///` doc comments
- **Why**: Explain complex algorithms or business decisions
- **Not what**: Avoid stating the obvious

### README Updates

If you add a feature:
1. Update the **Features** section
2. Add **Usage** example
3. Update **Architecture** if structure changed

### Inline Examples

```dart
/// Executes a multi-step flow with variable injection.
///
/// Example:
/// ```dart
/// final flow = Flow(
///   steps: [
///     FlowStep(
///       name: 'Login',
///       request: ApiRequest(url: '/auth/login'),
///       extractors: {'token': '$.access_token'},
///     ),
///     FlowStep(
///       name: 'Get Profile',
///       request: ApiRequest(
///         url: '/profile',
///         headers: {'Authorization': 'Bearer {{token}}'},
///       ),
///     ),
///   ],
/// );
/// 
/// final executor = FlowExecutor(httpService);
/// final result = await executor.execute(flow);
/// ```
Future<FlowExecutionResult> execute(Flow flow) async {
  // Implementation
}
```

---

## Questions?

- **General questions**: Open a [Discussion](https://github.com/flutterbuddy1/testify_pro/discussions)
- **Bug reports**: Create an [Issue](https://github.com/flutterbuddy1/testify_pro/issues)
- **Feature requests**: Start a [Discussion](https://github.com/flutterbuddy1/testify_pro/discussions)

---

## Recognition

Contributors will be recognized in:
- **README.md**: Contributors section
- **Release notes**: Mention in changelogs
- **GitHub**: Shown on contributors page

---

**Thank you for contributing to Testify Pro!** 🎉

Your efforts help make this tool better for everyone in the developer community.
