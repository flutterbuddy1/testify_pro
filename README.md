# Testify Pro

<div align="center">

![Testify Pro](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.8+-02569B?logo=flutter)
![Platform](https://img.shields.io/badge/platform-Windows-0078D6?logo=windows)
![License](https://img.shields.io/badge/license-MIT-green.svg)

**A Professional API Testing & Load Testing Desktop Application**

*Built with Flutter for developers who demand performance, precision, and productivity*

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Architecture](#-architecture) • [Contributing](#-contributing)

</div>

---

## 📖 Introduction

**Testify Pro** is a production-grade desktop application designed for API testing, load testing, and comprehensive API workflow automation. Whether you're testing a single endpoint or simulating thousands of concurrent users, Testify Pro delivers the performance and insights you need.

### Why Testify Pro?

- 🚀 **Blazing Fast**: Built with Flutter and Dart isolates for true concurrent load generation
- 💪 **Enterprise-Ready**: Handles 100,000+ virtual users with real-time metrics
- 🎯 **Developer-Focused**: Intuitive UI with powerful features like JSONPath extraction and variable injection
- 🔧 **Fully Featured**: API testing, load testing, multi-step flows, and comprehensive history tracking
- 🎨 **Modern UI**: Material Design 3 with dark mode support
- 💾 **Offline-First**: All data stored locally with Hive for lightning-fast access

### Who Is This For?

- **API Developers** testing their endpoints during development
- **QA Engineers** running comprehensive test suites
- **DevOps Teams** performing load tests before deployment
- **Performance Engineers** analyzing API behavior under stress

---

## ✨ Features

### 🔌 API Testing
- **Postman-like Interface**: Test individual API endpoints with ease
- **All HTTP Methods**: GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS
- **Request Configuration**: Headers, query parameters, request body
- **Authentication Support**: Bearer tokens, Basic Auth, API keys
- **Response Visualization**: JSON syntax highlighting, headers inspection
- **Request History**: Access previous requests instantly

### ⚡ Load Testing
- **Virtual User Simulation**: Simulate 1 to 100,000+ concurrent users
- **Intelligent Worker Pool**: Fixed isolate pool architecture prevents system overload
- **Configurable Ramp-Up**: Gradual user increase for realistic scenarios
- **Real-Time Metrics**: 
  - Requests per second (RPS)
  - Success/failure rates
  - Response time percentiles (p50, p95, p99)
  - Min/max/average response times
- **Live Monitoring**: Real-time charts and logs during test execution
- **Auto-Stop Conditions**: Automatic test termination on target completion

### 🔄 Flow Designer
- **Multi-Step Scenarios**: Chain multiple API calls into complex workflows
- **Variable Extraction**: Extract data from responses using JSONPath
- **Dynamic Injection**: Use extracted variables in subsequent steps with `{{variable}}`
- **Conditional Logic**: Build sophisticated test scenarios
- **Flow Execution**: Run flows individually or under load
- **Detailed Logging**: Step-by-step execution logs with request/response details

### 📊 Metrics Dashboard
- **Real-Time Visualization**: Live charts powered by FL Chart
- **Historical Analysis**: View past test runs with detailed metrics
- **Export Capabilities**: Save results as CSV, JSON, or HTML reports
- **Filtering & Search**: Find specific test runs quickly

### 🌍 Environment Management
- **Multiple Environments**: Dev, staging, production configurations
- **Variable Management**: Define environment-specific variables
- **Quick Switching**: Change active environment with one click
- **Variable Injection**: Use environment variables across all features

### ⚙️ Settings & Customization
- **Theme Control**: Light/dark mode with system sync
- **Data Export/Import**: Full backup and restore capabilities
- **Developer Information**: Credits and project links
- **Window Management**: Configurable window size and layout

---

## 🚀 Installation

### Prerequisites

- **Flutter SDK**: Version 3.8.1 or higher
- **Windows**: Windows 10/11 (64-bit)
- **Git**: For cloning the repository

### Step 1: Clone the Repository

```bash
git clone https://github.com/flutterbuddy1/testify_pro.git
cd testify_pro
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Generate Code

Testify Pro uses code generation for Freezed models and Riverpod providers:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 4: Run the Application

#### Development Mode
```bash
flutter run -d windows
```

#### Release Build
```bash
flutter build windows --release
```

The executable will be located at:
```
build\windows\x64\runner\Release\testify_pro.exe
```

---

## 📱 Usage

### Getting Started

1. **Launch Testify Pro**
2. Navigate using the left sidebar:
   - **API Testing**: Test individual endpoints
   - **Flow Designer**: Create multi-step scenarios
   - **Load Testing**: Run performance tests
   - **Metrics**: View performance analytics
   - **History**: Browse past test runs
   - **Environments**: Manage configurations

### API Testing Workflow

1. **Navigate to API Testing**
2. **Enter Request Details**:
   - URL: `https://api.example.com/users`
   - Method: `GET`, `POST`, etc.
3. **Add Headers** (optional):
   - `Authorization: Bearer token123`
   - `Content-Type: application/json`
4. **Add Body** (for POST/PUT):
   ```json
   {
     "name": "John Doe",
     "email": "john@example.com"
   }
   ```
5. **Click Send**
6. **View Response**:
   - Status code and message
   - Response time
   - Headers
   - Formatted JSON body

### Creating a Flow

1. **Navigate to Flow Designer**
2. **Click "Add Flow"**
3. **Add Steps**:
   - **Step 1**: Login
     - URL: `https://api.example.com/auth/login`
     - Method: `POST`
     - Body: `{"username": "admin", "password": "pass"}`
     - **Extractor**: `token` from `$.data.token`
   
   - **Step 2**: Get User Profile
     - URL: `https://api.example.com/profile`
     - Method: `GET`
     - Header: `Authorization: Bearer {{token}}`
   
4. **Run Flow**: Execute step-by-step with variable injection
5. **Use in Load Test**: Test the entire flow under load

### Running a Load Test

1. **Navigate to Load Testing**
2. **Choose Target**:
   - **Single Request**: Test one endpoint
   - **Flow**: Test a multi-step scenario
3. **Configure Parameters**:
   - Virtual Users: `1000`
   - Duration: `60` seconds
   - Ramp-Up: `10` seconds
4. **Start Test**
5. **Monitor Real-Time Metrics**:
   - Watch RPS, success rate, response times
   - View live request logs
6. **Stop When Complete**: Review final metrics

### Exporting Results

1. **Navigate to History**
2. **Select a Test Run**
3. **Click Export**
4. **Choose Format**: CSV, JSON, or HTML
5. **Save to Disk**

---

## 🏗️ Architecture

Testify Pro follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                      # Shared utilities
│   ├── constants/            # App constants
│   ├── providers/            # Global providers
│   ├── theme/                # Material theme
│   └── utils/                # Helper functions
│
├── domain/                    # Business Logic (Pure Dart)
│   └── entities/             # Core business entities
│       ├── api_request.dart
│       ├── api_response.dart
│       ├── flow.dart
│       ├── test_run.dart
│       ├── test_metrics.dart
│       └── environment.dart
│
├── data/                      # Data Layer
│   ├── services/             # External services
│   │   └── http_service.dart
│   └── repositories/         # Data persistence
│       ├── flow_repository.dart
│       ├── test_run_repository.dart
│       ├── environment_repository.dart
│       └── api_history_repository.dart
│
├── infrastructure/            # Framework & External Tools
│   ├── load_engine/          # Load Testing Engine
│   │   ├── load_coordinator.dart    # Orchestrates workers
│   │   ├── worker_isolate.dart      # Concurrent workers
│   │   └── metrics_aggregator.dart  # Real-time metrics
│   └── flow_engine/          # Flow Execution Engine
│       ├── flow_executor.dart       # Step execution
│       ├── json_extractor.dart      # JSONPath extraction
│       └── variable_injector.dart   # Variable substitution
│
└── presentation/              # UI layer
    └── screens/              # Application screens
        ├── home_screen.dart
        ├── api_test_screen.dart
        ├── flow_designer_screen.dart
        ├── load_test_screen.dart
        ├── history_screen.dart
        ├── metrics_dashboard_screen.dart
        └── settings_screen.dart
```

### Key Design Patterns

#### 1. Worker Pool for Load Testing

**Problem**: Spawning one isolate per virtual user (e.g., 100,000 isolates) would crash the system.

**Solution**: Fixed worker pool architecture
- Spawn 4-8 worker isolates (based on CPU cores)
- Each worker simulates thousands of users using async/await
- Example: 8 workers × 12,500 users each = 100,000 total users

**Benefits**:
- ✅ System stays responsive
- ✅ Scales to extreme loads
- ✅ Efficient CPU utilization
- ✅ Predictable memory usage

#### 2. Real-Time Metrics Aggregation

- Workers send results to coordinator via `SendPort`
- Metrics aggregator batches updates (1-second intervals)
- Calculates percentiles efficiently
- Emits to UI via `Stream<TestMetrics>`
- Keeps history bounded to prevent memory leaks

#### 3. Repository Pattern

All data access goes through repositories:
- **Abstraction**: UI doesn't know about Hive
- **Testability**: Easy to mock for unit tests
- **Flexibility**: Can swap storage without changing UI

---

## 🛠️ Technology Stack

| Category | Technology | Purpose |
|----------|-----------|---------|
| **Framework** | Flutter 3.8+ | Cross-platform UI |
| **Language** | Dart 3.0+ | Application logic |
| **State Management** | Riverpod 2.5+ | Reactive state |
| **HTTP Client** | Dio 5.4+ | Network requests |
| **Local Storage** | Hive 2.2+ | Fast NoSQL database |
| **Concurrency** | Dart Isolates | Parallel load generation |
| **Code Generation** | Freezed, JSON Serializable | Immutable models |
| **Data Extraction** | JSONPath | Response parsing |
| **Charting** | FL Chart | Real-time visualization |
| **File Operations** | File Picker, Path Provider | Export/import |
| **Window Management** | Window Manager | Desktop window control |
| **URL Launching** | URL Launcher | External links |

---

## 🤝 Contributing

We welcome contributions from the community! Whether you're fixing bugs, adding features, or improving documentation, your help is appreciated.

### How to Contribute

1. **Fork the Repository**
   ```bash
   # Click "Fork" on GitHub, then clone your fork
   git clone https://github.com/flutterbuddy1/testify_pro.git
   cd testify_pro
   ```

2. **Create a Feature Branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

3. **Make Your Changes**
   - Write clean, readable code
   - Follow the existing code style
   - Add comments for complex logic
   - Update documentation if needed

4. **Test Thoroughly**
   ```bash
   # Run the app and test your changes
   flutter run -d windows
   
   # Ensure code generates without errors
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "feat: Add amazing feature"
   ```

   **Commit Message Format**:
   - `feat:` New feature
   - `fix:` Bug fix
   - `docs:` Documentation changes
   - `style:` Code style/formatting
   - `refactor:` Code refactoring
   - `test:` Adding tests
   - `chore:` Maintenance tasks

6. **Push to Your Fork**
   ```bash
   git push origin feature/amazing-feature
   ```

7. **Open a Pull Request**
   - Go to the original repository
   - Click "New Pull Request"
   - Describe your changes clearly
   - Reference any related issues

### Development Guidelines

#### Code Style

- **Use Dart conventions**: Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) guide
- **Format code**: Run `dart format .` before committing
- **Lint**: Ensure no warnings with `flutter analyze`
- **Naming**:
  - Classes: `PascalCase`
  - Variables/Functions: `camelCase`
  - Constants: `lowerCamelCase` or `SCREAMING_SNAKE_CASE` for compile-time constants
  - Private members: Prefix with `_`

#### Architecture Rules

1. **Domain Layer**: Pure business logic, no Flutter imports
2. **Data Layer**: Only data access, no business logic
3. **Infrastructure**: External service wrappers
4. **Presentation**: UI only, delegate logic to providers

#### State Management

- Use **Riverpod** for all state
- Keep providers in appropriate directories
- Use `ConsumerWidget` or `ConsumerStatefulWidget` in UI
- Avoid direct repository access from UI (use providers)

#### File Organization

```dart
// Good: Clear imports organized by category
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/api_request.dart';
import '../../core/providers/global_providers.dart';

// Avoid: Messy imports
import '../../domain/entities/api_request.dart';
import 'package:flutter/material.dart';
```

### Areas Open for Contribution

#### 🎯 Priority Features

- [ ] **WebSocket Support**: Real-time API testing
- [ ] **gRPC Protocol**: Add gRPC request support
- [ ] **Request Chaining**: Advanced flow dependencies
- [ ] **Assertions**: Add validation rules to flows
- [ ] **Mock Server**: Built-in API mocking
- [ ] **GraphQL Support**: Query and mutation testing
- [ ] **Custom Plugins**: Plugin architecture for extensibility

#### 🐛 Bug Fixes

- Check [Issues](https://github.com/flutterbuddy1/testify_pro/issues) for reported bugs
- Look for `good first issue` labels for beginner-friendly tasks

#### 📚 Documentation

- Improve code comments
- Add tutorials and guides
- Create video walkthroughs
- Translate to other languages

#### 🎨 UI/UX Enhancements

- Improve responsiveness for smaller windows
- Add keyboard shortcuts
- Enhance accessibility
- Create custom themes

#### ⚡ Performance Optimizations

- Optimize large response rendering
- Improve chart performance with massive datasets
- Reduce memory footprint during extreme load tests

### Getting Help

- **Questions?** Open a [Discussion](https://github.com/flutterbuddy1/testify_pro/discussions)
- **Bug Report?** Create an [Issue](https://github.com/flutterbuddy1/testify_pro/issues)
- **Feature Request?** Start a [Discussion](https://github.com/flutterbuddy1/testify_pro/discussions)

---

## 📊 Performance Benchmarks

On a modern desktop (Intel i7, 16GB RAM):

| Metric | Value |
|--------|-------|
| **Max Virtual Users** | 100,000+ |
| **Peak RPS** | 10,000+ |
| **UI Response Time** | < 100ms (even under load) |
| **Metrics Update Rate** | 1 second |
| **Memory Usage** | ~200MB idle, ~500MB under max load |
| **CPU Usage** | Scales with worker count (4-8 cores) |

---

## 📝 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

You are free to:
- ✅ Use commercially
- ✅ Modify
- ✅ Distribute
- ✅ Use privately

---

## 👨‍💻 Developer

**Developed by [Mayank Diwakar](https://github.com/flutterbuddy1)**

- GitHub: [@flutterbuddy1](https://github.com/flutterbuddy1)
- LinkedIn: [Mayank Diwakar](https://www.linkedin.com/in/mayankdiwakar-innovator/)

---

## 🙏 Acknowledgments

- **Flutter Team** for the amazing framework
- **Riverpod** for elegant state management
- **Dio** for robust HTTP client
- **Hive** for blazing-fast local storage
- **All Contributors** who help improve Testify Pro

---

## 📞 Support

If you find Testify Pro useful, please consider:

- ⭐ **Star this repository** to show support
- 🐛 **Report bugs** to help us improve
- 💡 **Suggest features** for future versions
- 🤝 **Contribute** to make it better

---

<div align="center">

**Built with ❤️ for developers who demand excellence in API testing**

[⬆ Back to Top](#testify-pro)

</div>
