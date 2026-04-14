# LYRD (Layered) - A Complete Development Environment for Neovim

<!-- toc -->

- [What is LYRD?](#what-is-lyrd)
- [Why Use LYRD?](#why-use-lyrd)
- [How LYRD Works: The Layer Architecture](#how-lyrd-works-the-layer-architecture)
- [Core Features That Improve Your Workflow](#core-features-that-improve-your-workflow)
  - [Smart Editor Basics](#smart-editor-basics)
  - [Beautiful and Informative Interface](#beautiful-and-informative-interface)
  - [Intelligent Code Assistance](#intelligent-code-assistance)
  - [Powerful Search and Navigation](#powerful-search-and-navigation)
  - [Git Integration](#git-integration)
  - [Testing Made Easy](#testing-made-easy)
  - [Debugging](#debugging)
  - [Task Automation](#task-automation)
  - [AI-Powered Development](#ai-powered-development)
  - [Code Snippets and Templates](#code-snippets-and-templates)
  - [Container and Cloud Development](#container-and-cloud-development)
  - [CI/CD Pipeline Support](#cicd-pipeline-support)
  - [Interactive Programming (REPL)](#interactive-programming-repl)
  - [REST API Testing](#rest-api-testing)
  - [Database Management](#database-management)
  - [Grammar Checking](#grammar-checking)
  - [Static Website Development](#static-website-development)
  - [Internationalization (i18n)](#internationalization-i18n)
  - [Development Server](#development-server)
  - [Secret Scanning](#secret-scanning)
  - [Tmux Integration](#tmux-integration)
  - [Media and Images](#media-and-images)
  - [Neovide Support](#neovide-support)
  - [VSCode Compatibility](#vscode-compatibility)
- [TUI Panels and Sidebars](#tui-panels-and-sidebars)
  - [File Tree](#file-tree)
  - [File Explorer](#file-explorer)
  - [Git UI](#git-ui)
  - [Git Graph](#git-graph)
  - [Test Sidebar](#test-sidebar)
  - [Tasks Panel (Overseer)](#tasks-panel-overseer)
  - [Debugging UI](#debugging-ui)
  - [Database Sidebar](#database-sidebar)
  - [Code Outline](#code-outline)
  - [Search and Replace in Files](#search-and-replace-in-files)
  - [Diagnostics Panel](#diagnostics-panel)
  - [Quickfix List](#quickfix-list)
  - [Integrated Terminal](#integrated-terminal)
  - [AI Chat Panel](#ai-chat-panel)
  - [REPL Panel](#repl-panel)
  - [REST Client](#rest-client)
  - [Containers and Kubernetes](#containers-and-kubernetes)
  - [Focus Mode](#focus-mode)
  - [Local Configuration](#local-configuration)
- [Keyboard-Driven Workflow](#keyboard-driven-workflow)
- [Language Support](#language-support)
  - [Python](#python)
  - [JavaScript/TypeScript and Web Development](#javascripttypescript-and-web-development)
  - [Java](#java)
  - [.NET (C Sharp, F Sharp, VB.NET)](#net-c-sharp-f-sharp-vbnet)
  - [Go](#go)
  - [Rust](#rust)
  - [C and C++](#c-and-c)
  - [Kotlin](#kotlin)
  - [Bash](#bash)
  - [Pascal](#pascal)
  - [LaTeX](#latex)
  - [Other Languages](#other-languages)
- [Installation](#installation)
  - [Prerequisites](#prerequisites)
  - [Basic Installation](#basic-installation)
  - [Post-Installation](#post-installation)
- [Configuration](#configuration)
  - [Local Configuration File](#local-configuration-file)
  - [Skipping Layers](#skipping-layers)
  - [Customizing Keybindings](#customizing-keybindings)
  - [AI Provider Configuration](#ai-provider-configuration)
  - [Theme Customization](#theme-customization)
  - [Project-Specific Settings](#project-specific-settings)
  - [Updating LYRD](#updating-lyrd)
  - [Troubleshooting](#troubleshooting)
  - [Getting Help](#getting-help)
  - [Learning Resources](#learning-resources)
- [Contributing](#contributing)
- [License](#license)

<!-- tocstop -->

## What is LYRD?

LYRD (Layered Neovim) transforms Neovim into a complete, modern development
environment that rivals popular IDEs like VS Code, IntelliJ, or PyCharm. It's
designed for developers who want the speed and efficiency of Neovim combined
with the features of a full-featured IDE.

Think of LYRD as a carefully curated collection of the best tools and features
for software development, all working together seamlessly. Whether you're
writing Python, JavaScript, Java, Rust, or any other language, LYRD provides the
tools you need without the bloat.

## Why Use LYRD?

**For Beginners**: LYRD provides a ready-to-use development environment. You
don't need to spend weeks researching and configuring plugins - everything is
set up and working out of the box.

**For Experienced Developers**: LYRD offers a modular architecture that's easy
to customize. You can enable or disable specific features, add your own
configurations, and maintain your workflow without fighting against the system.

**Key Benefits**:

- **Save Time**: No need to configure everything from scratch
- **Stay Focused**: All your development tools in one place
- **Work Faster**: Keyboard-driven workflow means less mouse usage
- **Code Smarter**: AI assistance, intelligent completions, and refactoring
  tools
- **Debug Easier**: Integrated debugging for multiple languages
- **Test Confidently**: Built-in test runners and coverage reports
- **Version Control**: Powerful Git integration right in your editor
- **Work Anywhere**: Since Neovim runs in the terminal, every LYRD feature —
  code intelligence, debugging, testing, AI assistance, Git — works seamlessly
  over SSH. Access your full development environment on remote machines, cloud
  servers, or containers with no extra setup

## How LYRD Works: The Layer Architecture

LYRD is built using a **layer system** - think of it like building blocks that
you can stack together. Each layer adds a specific feature or capability to your
editor.

**What makes this powerful?**

1. **Modular Design**: Each feature (like Python support, Git integration, or AI
   assistance) lives in its own layer. This means:
   - Features don't interfere with each other
   - You can disable features you don't need
   - Adding new features is straightforward

2. **Smart Loading**: LYRD only loads the features you're actually using. For
   example:
   - Python tools only load when you open a Python file
   - Database tools only load when you need them
   - This keeps Neovim fast and responsive

3. **Consistent Experience**: All features work the same way across different
   languages. For example:
   - `LYRDCodeRun` runs your code regardless of the language
   - `LYRDTest` runs tests whether you're writing Python, Java, or JavaScript
   - `LYRDDebug` starts debugging in any supported language

4. **Easy Customization**: Don't like a feature? You can:
   - Skip specific layers in a simple configuration file
   - Override settings without modifying the core files
   - Add your own layers for custom functionality

## Core Features That Improve Your Workflow

### Smart Editor Basics

**What it does**: Sets up Neovim with sensible defaults that professional
developers expect.

**How it helps you**:

- **Remember where you were**: Automatically returns to the last position when
  you reopen a file
- **See what you're doing**: Highlights the current line so you never lose your
  place
- **Undo forever**: Keeps undo history even after closing files
- **Smart indentation**: Automatically matches the indentation style of your
  project
- **No distractions**: Hides unnecessary UI elements but shows important
  information
- **Clipboard integration**: Copy and paste between Neovim and other
  applications seamlessly

**Real-world benefit**: You spend less time on manual setup and more time
writing code. The editor "just works" the way you expect it to.

### Beautiful and Informative Interface

**What it does**: Provides a modern, clean interface with helpful visual
feedback.

**Components**:

- **Status Line**: Shows important information at a glance (current file, Git
  branch, language server status, errors/warnings)
- **Startup Screen**: Quick access to recent files and common actions when you
  open Neovim
- **Notification System**: Clean, non-intrusive notifications for operations
  (saves, builds, errors)
- **Command Palette**: Beautiful command interface that shows what commands are
  available as you type
- **Floating Terminals**: Pop-up terminals that don't disturb your layout
- **Focus Mode**: Dims everything except the current code block for
  distraction-free coding
- **Inline Color Preview**: Displays color swatches next to hex, RGB, and other
  color values in your code

**How it helps you**:

- **Stay informed**: See Git status, errors, and file information without
  running commands
- **Look professional**: A polished interface makes your work environment more
  enjoyable
- **Reduce cognitive load**: Visual indicators help you understand what's
  happening without reading text
- **Quick access**: The startup screen gets you to your work faster

**Real-world benefit**: You know what's happening in your project at all times
without cluttering your screen. The interface gets out of your way but provides
information when you need it.

### Intelligent Code Assistance

**What it does**: Provides smart code completions, error detection, and code
navigation for all supported languages.

**Features**:

- **Auto-completion**: Suggests functions, variables, and methods as you type
- **Error detection**: Highlights problems in your code as you write
- **Go to definition**: Jump to where a function or variable is defined with one
  keystroke
- **Find references**: See everywhere a function is used in your project
- **Hover documentation**: View function signatures and documentation without
  leaving your editor
- **Code actions**: Get suggestions for fixing problems or improving code
- **Auto-formatting**: Automatically format your code to follow style guidelines
- **Refactoring**: Safely rename variables, extract functions, and reorganize
  code

**How it helps you**:

- **Write code faster**: Completions save typing and reduce typos
- **Catch bugs early**: See errors as you type, not when you run the code
- **Understand code better**: Jump to definitions and see documentation
  instantly
- **Maintain code quality**: Automatic formatting keeps your code clean and
  consistent
- **Refactor confidently**: Change code structure without breaking things

**Real-world benefit**: You write better code faster. The editor acts like a
pair programming partner, catching mistakes and suggesting improvements as you
work.

### Powerful Search and Navigation

**What it does**: Helps you find files, code, and information quickly in large
projects.

**Capabilities**:

- **Fuzzy file finder**: Type part of a filename and instantly see matches
- **Project-wide search**: Find text across all files in your project
- **Code outline**: See the structure of your current file (functions, classes,
  etc.)
- **Symbol search**: Find any function or class in your project by name
- **Recent files**: Quickly reopen files you were just working on
- **Bookmarks**: Mark important locations in your code and jump back to them,
  with visual indicators in the sign column for marks
- **TODO Search**: Find and navigate all TODO, FIXME, HACK, and NOTE comments
  across your project with highlighted annotations
- **Saved Macros**: Save and search recorded macros via Telescope for reuse
  across sessions
- **File browser**: Visual tree of your project structure

**How it helps you**:

- **Navigate large projects**: Find what you need in seconds, not minutes
- **No more memorizing paths**: Fuzzy search means you don't need to remember
  exact filenames
- **Understand structure**: See how your project is organized at a glance
- **Context switching**: Quickly jump between related files
- **Work faster**: Less time searching means more time coding

**Real-world benefit**: In a project with thousands of files, you can find
anything you need in 2-3 keystrokes. No more hunting through directories or
using grep commands.

### Git Integration

**What it does**: Brings Git version control directly into your editor.

**Features**:

- **Visual Git interface**: See and manage your Git repository in a beautiful
  interface
- **Line-by-line change indicators**: See which lines you've modified, added, or
  deleted
- **Blame annotations**: See who wrote each line of code and when
- **Diff viewing**: Compare different versions of your files side-by-side
- **Commit from editor**: Stage changes and create commits without leaving
  Neovim
- **Branch management**: Create, switch, and merge branches visually
- **Conflict resolution**: Resolve merge conflicts with clear visual indicators

**How it helps you**:

- **Stay in flow**: No need to switch to terminal for Git operations
- **Understand changes**: Immediately see what you've modified
- **Track history**: Quickly see who made changes and why
- **Resolve conflicts easily**: Visual tools make merge conflicts less scary
- **Commit more often**: Easy commits encourage better version control habits

**Real-world benefit**: You maintain better version control because it's
effortless. You can review changes, create meaningful commits, and manage
branches without breaking your concentration.

### Testing Made Easy

**What it does**: Runs your tests and shows results directly in your editor.

**Capabilities**:

- **Run individual tests**: Test just the function you're working on
- **Run test files**: Test an entire file with one command
- **Run test suites**: Run all tests in your project
- **Visual test results**: See which tests passed or failed with clear
  indicators
- **Test coverage**: See which parts of your code are tested
- **Watch mode**: Automatically rerun tests when you save files
- **Debug tests**: Step through failing tests to understand why they fail

**Supported test frameworks**:

- Python: pytest, unittest
- JavaScript/TypeScript: Jest, Vitest
- Java: JUnit, TestNG
- Go: go test
- Rust: cargo test
- .NET: VSTest (xUnit, NUnit, MSTest)
- C/C++: CTest/CMake

**How it helps you**:

- **Faster feedback**: See test results immediately after changes
- **Confidence in changes**: Know if your code works before pushing
- **Find bugs faster**: Visual indicators show exactly which tests fail
- **Better coverage**: See untested code and write tests for it
- **TDD workflow**: Write tests and code together seamlessly

**Real-world benefit**: Testing becomes part of your normal workflow instead of
a separate step. You catch bugs earlier and ship more reliable code.

### Debugging

**What it does**: Lets you pause your code, inspect variables, and step through
execution line by line.

**Features**:

- **Breakpoints**: Pause code execution at specific lines
- **Step through code**: Execute one line at a time to understand flow
- **Variable inspection**: See the value of any variable at any point
- **Call stack**: Understand how your code got to the current point
- **Conditional breakpoints**: Pause only when specific conditions are met
- **Debug console**: Run code and commands while debugging
- **Visual debugging**: All debugging tools in a clear, organized interface

**Supported languages**:

- Python (debugpy)
- JavaScript/TypeScript (Node.js debugger)
- Java (java-debug-adapter)
- .NET (netcoredbg)
- Go (delve)
- Kotlin (kotlin-debug-adapter)
- Rust (lldb/codelldb)
- C/C++ (lldb/codelldb)

**How it helps you**:

- **Understand bugs**: See exactly what your code is doing when it fails
- **Fix issues faster**: No more adding print statements everywhere
- **Learn code**: Step through unfamiliar code to understand how it works
- **Catch edge cases**: Use conditional breakpoints to debug rare scenarios
- **Complex debugging**: Handle multi-threaded and asynchronous code

**Real-world benefit**: Debugging that would take hours with print statements
takes minutes with a proper debugger. You understand your code better and fix
bugs with confidence.

### Task Automation

**What it does**: Manages and runs all your project's build, test, and
deployment tasks.

**Capabilities**:

- **VSCode tasks**: Import and run tasks from VS Code's tasks.json
- **Build systems**: Support for Make, Maven, Gradle, Cargo, npm scripts, and
  more
- **Custom tasks**: Define your own tasks for any project-specific needs
- **Task monitoring**: See task output in real-time
- **Task history**: Rerun recent tasks with one command
- **Parallel execution**: Run multiple tasks simultaneously
- **Task templates**: Pre-configured tasks for common operations

**Examples of tasks**:

- Build your project
- Run development servers
- Execute database migrations
- Deploy to staging/production
- Generate documentation
- Run code quality checks
- Clean build artifacts

**How it helps you**:

- **Consistent workflows**: Same task system across all projects
- **No memorizing commands**: Run complex commands with simple shortcuts
- **Automation**: Set up automated workflows for common operations
- **Visibility**: See what's running and monitor progress
- **Efficiency**: Run multiple tasks without opening multiple terminals

**Real-world benefit**: Complex projects with many build steps become
manageable. You can build, test, and deploy with a few keystrokes instead of
typing long commands.

### AI-Powered Development

**What it does**: Integrates AI assistants to help you write, understand, and
improve code.

**AI Provider Options**:

- GitHub Copilot
- Codeium
- TabNine

**AI Chat and Editing** (Avante):

- **Ask questions**: Get explanations about code directly in your editor
- **Smart editing**: AI-powered code edits with visual diff review
- **Generate documentation**: Auto-create comments and documentation
- **Code explanations**: Understand complex code with AI explanations
- **Refactoring suggestions**: Get AI recommendations for improving code
- **Bug fixes**: AI suggests fixes for errors and issues

**CLI AI Tools** (Sidekick):

- **CLI integration**: Use external AI CLI tools (Claude Code, GitHub Copilot
  CLI, etc.) directly from within Neovim
- **Tmux backend**: Runs CLI tools in a Tmux pane alongside your editor
- **Tool selection**: Switch between different CLI AI tools on the fly
- **Send prompts**: Send prompts to CLI AI tools with project context

**Inline Completions**:

- **Code suggestions**: Get AI-powered completions as you type
- **Smart context**: AI understands your project and suggests relevant code
- **Multiple providers**: Switch between Copilot, Codeium, or TabNine

**How it helps you**:

- **Learn faster**: AI explains unfamiliar code and concepts
- **Write faster**: AI suggests entire code blocks, not just completions
- **Better documentation**: Auto-generated docs save time and improve code
  quality
- **Fewer bugs**: AI catches potential issues before they become problems
- **Stay in flow**: Get help without searching documentation or Stack Overflow
- **Use your preferred AI CLI**: Leverage powerful CLI tools like Claude Code
  without leaving Neovim

**Real-world benefit**: Multiple AI integration points — inline completions for
fast coding, Avante for chat-based editing and questions, and Sidekick for full
CLI AI tools — give you the right level of AI assistance for each task.

### Code Snippets and Templates

**What it does**: Provides reusable code templates and file scaffolding.

**Features**:

- **Code snippets**: Quick templates for common code patterns
- **Language-specific snippets**: Optimized snippets for each programming
  language
- **File templates**: Start new files with proper structure
- **Custom snippets**: Create your own templates for repeated code
- **Smart placeholders**: Jump between fillable parts of a template
- **Template browser**: Search and preview available snippets

**Available templates**:

- Python: Classes, Pydantic models, SQLAlchemy models, FastAPI endpoints
- Java: Classes, Records, Interfaces, Enums
- C#: Classes, Interfaces, MediatR handlers
- Go: Structs, Interfaces, Test files
- Vue: Component templates
- Lua: LYRD module templates, LSP settings

**How it helps you**:

- **Consistent code**: Templates ensure you follow patterns correctly
- **Save typing**: Generate boilerplate code instantly
- **Reduce errors**: Templates include correct structure and imports
- **Learn patterns**: Templates show the right way to structure code
- **Custom workflows**: Create templates for your team's patterns

**Real-world benefit**: You spend less time writing repetitive boilerplate and
more time on the unique parts of your application. New files start with the
right structure automatically.

### Container and Cloud Development

**What it does**: Integrates with Docker, Docker Compose, and Kubernetes for
container-based development.

**Docker Features**:

- **Dockerfile support**: Syntax highlighting and language server for
  Dockerfiles
- **Docker Compose**: Full support for compose files with service visualization
  and automatic filetype detection
- **Run services from compose files**: Place your cursor on a service in a
  Docker Compose file and run commands (up, down, start, stop, restart, build,
  pull, logs) directly on that service or the entire compose file
- **Service indicators**: Visual signs in the gutter mark each service defined
  in your compose file
- **Linting**: Catch Dockerfile problems with hadolint (Linux)
- **LazyDocker integration**: Visual Docker management in a terminal UI
- **Quick actions**: Start, stop, and manage containers from your editor

**Kubernetes Features**:

- **Run manifests from the editor**: Apply, delete, describe, create, or diff
  Kubernetes manifests directly from the current file — either the whole file or
  the individual YAML document under the cursor
- **Dry-run support**: Test manifests with client-side or server-side dry-run
  before applying
- **k9s integration**: Full-featured Kubernetes cluster management
- **Helm support**: Work with Helm charts and templates with dedicated filetype
  detection and language server
- **YAML validation**: Ensure your Kubernetes configs are correct
- **Smart filetype detection**: Automatically recognizes manifests in common
  directory patterns (k8s/, kubernetes/, manifests/, deploy/)

**How it helps you**:

- **Faster development**: Manage containers and deployments without leaving your
  editor
- **Run services in place**: Execute Docker Compose commands or apply Kubernetes
  manifests from the file you are editing
- **Catch issues early**: Linting and dry-run prevent deployment problems
- **Visual management**: See your containers and clusters clearly
- **Simplified workflows**: Common Docker/K8s operations are just keystrokes
  away
- **DevOps integration**: Bridge development and deployment seamlessly

**Real-world benefit**: Container-based development becomes as smooth as local
development. You can develop, test, and deploy containerized apps efficiently.
Running a Docker Compose service or applying a Kubernetes manifest is as simple
as triggering the run command on the file you are editing.

### CI/CD Pipeline Support

**What it does**: Provides language server support and linting for CI/CD
pipeline configuration files across major platforms.

**Features**:

- **GitHub Actions**: Language server for workflow files with completions,
  validation, and diagnostics
- **GitLab CI**: Language server for `.gitlab-ci.yml` with schema validation and
  autocompletion
- **Azure Pipelines**: Language server for Azure DevOps pipeline YAML files
- **Actionlint**: Linting for GitHub Actions workflow files to catch common
  mistakes
- **Custom filetype detection**: Automatic recognition of `.gitlab-ci.yml` as a
  GitLab CI file

**How it helps you**:

- **Catch errors early**: Validate pipeline configs before pushing
- **Faster authoring**: Autocompletion for pipeline-specific syntax and keywords
- **Multi-platform**: Work with GitHub, GitLab, and Azure pipelines in the same
  editor
- **Less context switching**: No need to check documentation for correct syntax

**Real-world benefit**: Writing and maintaining CI/CD pipelines becomes much
faster and less error-prone. You get instant feedback on syntax issues and
schema violations without waiting for a pipeline run to fail.

### Interactive Programming (REPL)

**What it does**: Lets you run code interactively and see results immediately.

**Features**:

- **Language REPLs**: Interactive shells for supported languages
- **Code execution**: Send code from your editor to the REPL
- **Jupyter notebooks**: Work with notebooks directly in Neovim
- **Cell-based execution**: Run code in chunks like Jupyter
- **Variable inspection**: See values of variables after execution
- **Plot visualization**: View charts and graphs from your code

**Supported**:

- Python (IPython, Jupyter)
- JavaScript/Node.js
- And more...

**How it helps you**:

- **Rapid experimentation**: Try ideas instantly without full program runs
- **Interactive debugging**: Test functions and see results immediately
- **Data science**: Work with data and visualizations interactively
- **Learning**: Experiment with new libraries and features
- **Prototyping**: Build and test ideas quickly

**Real-world benefit**: Perfect for data science, scientific computing, and
learning new technologies. You get instant feedback on your code without context
switching.

### REST API Testing

**What it does**: Test HTTP APIs directly from your editor without external
tools.

**Features**:

- **HTTP client**: Send requests to APIs and see responses
- **Request builder**: Define requests in simple text format
- **Variable support**: Use variables for API keys, endpoints, etc.
- **Response viewing**: See formatted JSON, XML, and other responses
- **Save requests**: Keep a library of API requests in your project
- **Environment support**: Switch between dev, staging, and production

**How it helps you**:

- **No Postman needed**: Test APIs without leaving your editor
- **Version control**: Save API requests in Git with your code
- **Faster testing**: Quick iterations when developing APIs
- **Documentation**: API requests serve as examples in your codebase
- **Team sharing**: Share API requests with your team

**Real-world benefit**: API development becomes faster because you can write
code and test it immediately in the same window. Your API requests become
documentation.

### Database Management

**What it does**: Connect to databases, run queries, and manage data from your
editor.

**Features**:

- **Database connections**: Connect to PostgreSQL, MySQL, SQLite, MongoDB, and
  more
- **Query execution**: Run SQL queries and see results
- **Table browsing**: View database structure and data
- **Result formatting**: See query results in easy-to-read tables
- **Query history**: Review and rerun previous queries
- **Multiple connections**: Switch between different databases

**How it helps you**:

- **No separate tools**: Manage databases without leaving your editor
- **Faster development**: Write code and test database queries together
- **Query prototyping**: Test queries before putting them in code
- **Data inspection**: Quickly check database state while debugging
- **Learning SQL**: Experiment with queries and see results immediately

**Real-world benefit**: Database work integrates into your normal workflow. You
can develop features that touch the database without constantly switching
between tools.

### Grammar Checking

**What it does**: Checks your writing for grammar and style issues directly in
the editor.

**Features**:

- **Harper LS**: Fast, privacy-focused grammar checker that runs locally
- **Inline diagnostics**: See grammar issues highlighted as you write
- **Code actions**: Quick fixes for common grammar mistakes
- **Works everywhere**: Checks comments, strings, markdown, and documentation

**How it helps you**:

- **Better documentation**: Catch grammar issues in comments and docs
- **Professional communication**: Write cleaner commit messages and README files
- **No external services**: Everything runs locally for privacy and speed

**Real-world benefit**: Your documentation, comments, and written content are
polished without needing to copy text into an external grammar tool.

### Static Website Development

**What it does**: Integrates with Hugo for static site generation workflows.

**Features**:

- **Hugo integration**: Build, serve, and manage Hugo sites from your editor
- **Task templates**: Pre-configured Overseer tasks for common Hugo operations
- **Live preview**: Start the Hugo development server and preview changes

**How it helps you**:

- **Streamlined workflow**: Manage your static site without leaving the editor
- **Quick iterations**: Build and preview changes with keyboard shortcuts
- **Content creation**: Write and publish blog posts efficiently

**Real-world benefit**: Static site development becomes as smooth as any other
project type, with all Hugo commands accessible from your editor.

### Internationalization (i18n)

**What it does**: Provides inline translation status and diagnostics for
internationalized web applications.

**Features**:

- **Inline translation preview**: See translated text directly in your code as
  virtual text annotations
- **Primary language display**: Shows the primary language value next to
  translation keys
- **Auto-hover**: Automatically displays translation details when your cursor
  rests on a key
- **Translation diagnostics**: Compare translations against the primary language
  to find missing or outdated entries

**How it helps you**:

- **Stay in context**: See translations without switching to JSON files or
  external tools
- **Catch missing translations**: Identify gaps in your translation coverage
  early
- **Faster development**: No need to cross-reference translation files manually
- **Better quality**: Ensure all languages are complete before shipping

**Real-world benefit**: Managing translations in multi-language web applications
becomes much less error-prone. You see the actual translated text right next to
the keys in your code, catching issues before they reach users.

### Development Server

**What it does**: Starts a local development server for previewing web projects
directly from your editor.

**Features**:

- **Live reload**: Uses live-server for automatic browser refresh on file
  changes
- **Configurable port**: Choose which port to serve on (defaults to 3000)
- **Custom folder**: Serve any directory, not just the project root
- **Task integration**: Runs as an Overseer task with real-time output
- **Server exposure**: Expose local servers to the internet via ngrok tunnels
  for sharing or testing on other devices
- **Environment variables**: Load and inspect `.env` files directly from the
  editor

**How it helps you**:

- **Quick previews**: Launch a dev server without leaving Neovim
- **Flexible setup**: Serve any folder on any port
- **Live feedback**: See changes in your browser instantly as you edit
- **Share instantly**: Expose your local server for external access with one
  command

**Real-world benefit**: Frontend and static site development becomes faster.
Start a live-reloading server with a single keybinding and iterate on your HTML,
CSS, and JavaScript with immediate visual feedback.

### Secret Scanning

**What it does**: Scans your project for accidentally committed secrets,
credentials, and API keys using TruffleHog.

**Features**:

- **Filesystem scanning**: Scans the current working directory for secrets using
  TruffleHog's filesystem mode
- **Diagnostics integration**: Results appear as Neovim diagnostics, allowing
  you to jump between findings with quickfix navigation
- **Verified vs unverified**: Each finding indicates whether the secret was
  verified as active or just a potential match
- **Detector details**: Shows which type of secret was detected (e.g., AWS keys,
  GitHub tokens, private keys) along with a redacted preview
- **Task integration**: Runs as an Overseer task with real-time output and
  auto-closes when the scan completes

**How it helps you**:

- **Catch leaks early**: Find secrets before they reach a public repository
- **Quick navigation**: Jump directly to the file and line containing the secret
- **Non-blocking**: The scan runs in the background so you can keep working

**Real-world benefit**: Prevent credential leaks by scanning your codebase from
within your editor. One keybinding triggers a full scan, and results land in
your diagnostics list so you can fix them immediately.

### Tmux Integration

**What it does**: Seamless navigation and window management between Neovim and
Tmux.

**Features**:

- **Unified navigation**: Move between Neovim splits and Tmux panes with the
  same keys
- **Smart resizing**: Resize Neovim and Tmux panes consistently
- **Terminal workflow**: Combine Neovim with terminal-based tools naturally

**How it helps you**:

- **No context switching**: Navigate between editor and terminal seamlessly
- **Muscle memory**: Same key bindings work in both Neovim and Tmux
- **Efficient layout**: Use Tmux panes alongside Neovim splits naturally

**Real-world benefit**: If you use Tmux, the boundary between your editor and
terminal disappears. Navigation feels like one unified environment.

### Media and Images

**What it does**: Embed and manage images directly from your editor.

**Features**:

- **Image embedding**: Paste images from clipboard into your documents
- **Format support**: Works with PNG, JPG, and other common formats
- **Markdown integration**: Automatically creates proper image references

**How it helps you**:

- **Quick documentation**: Add screenshots to docs without leaving the editor
- **Streamlined workflow**: Paste images directly instead of manual file
  management

**Real-world benefit**: Adding visual content to documentation becomes as simple
as taking a screenshot and pasting it.

### Neovide Support

**What it does**: Optimizes the experience when running Neovim inside the
Neovide GUI client.

**Features**:

- **Font configuration**: Proper font settings for the GUI environment
- **Smooth animations**: Cursor and scroll animations tuned for Neovide
- **GUI-specific settings**: Transparency, padding, and visual polish

**Real-world benefit**: If you prefer a graphical Neovim experience, LYRD
automatically detects Neovide and applies appropriate settings.

### VSCode Compatibility

**What it does**: Provides a compatibility mode for running LYRD layers inside
VSCode's Neovim extension.

**Features**:

- **Selective layer loading**: Only loads layers marked as `vscode_compatible`
- **Shared keybindings**: Keep your muscle memory across both environments
- **Lightweight mode**: Skips plugins that conflict with VSCode features

**Real-world benefit**: Use your familiar Neovim keybindings and motions inside
VSCode when needed, without breaking either environment.

## TUI Panels and Sidebars

LYRD provides a set of integrated TUI panels that give you an IDE-like layout
entirely within the terminal. Each panel can be toggled independently and
coexists with your editing buffers.

### File Tree

![File Tree Panel](docs/images/file-tree-panel.png)

**Plugin**: nvim-tree.lua **Layer**: `layers/filetree.lua`

A sidebar file tree that shows your project structure with Git status
indicators, diagnostics, and bookmarks in the sign column.

- Positioned on the right side with 60-character default width
- Git status glyphs (unstaged, staged, unmerged, renamed, untracked, deleted,
  ignored) shown inline next to each file
- Diagnostics icons (error, warning, info, hint) in the sign column
- Indent guides with tree-line characters
- Filters out `.git`, `node_modules`, `bin`, `obj` by default
- Opens the file and closes the tree on selection

### File Explorer

![File Explorer](docs/images/file-explorer.png)

**Plugins**: tfm.nvim (yazi backend), oil.nvim **Layer**: `layers/filetree.lua`

Two alternative file browsing modes that complement the file tree.

**yazi** opens as a floating terminal with full file management capabilities —
rename, move, copy, delete — using the yazi TUI. Selected files open in the
current window, a split, or a new tab.

**oil.nvim** opens the current directory as an editable buffer. Rename files by
editing their names, delete by removing lines, and create new files by typing
new entries. Changes are applied when you save the buffer.

### Git UI

![LazyGit](docs/images/lazy-git.png)
![Git Status Panel](docs/images/git-status-panel.png)

**Plugins**: lazygit.nvim, neogit, diffview.nvim, gitsigns.nvim, blame.nvim,
git-conflict.nvim, octo.nvim, worktrees.nvim **Layer**: `layers/git.lua`

A comprehensive Git interface combining multiple tools:

- **LazyGit** — full-featured Git TUI in a floating terminal for staging,
  committing, branching, rebasing, and more
- **Neogit** — a Magit-inspired status buffer for staging hunks, committing, and
  pushing without leaving Neovim
- **Diffview** — side-by-side diff viewer for file history, merge conflicts, and
  commit comparisons
- **Gitsigns** — gutter indicators showing added, changed, and deleted lines
- **Blame** — toggle line-by-line Git blame annotations
- **Git Conflict** — visual merge conflict resolution with choose-ours,
  choose-theirs, and choose-both actions
- **Octo** — GitHub issues and pull request management
- **Worktrees** — Git worktree creation and switching

Also includes Git Flow commands for feature, release, and hotfix branch
workflows.

### Git Graph

![Git Graph](docs/images/git-chart.png)

**Plugin**: External `tig` TUI **Layer**: `layers/git.lua`

A text-based Git history graph viewer. Opens `tig` — a ncurses-based Git
repository browser — in a floating terminal window. Provides a scrollable commit
graph with branch topology, commit details, and diff viewing.

LazyGit also includes an integrated commit graph accessible from its own UI.

**Requires**: `tig` installed on the system.

### Test Sidebar

![Test Sidebar](docs/images/tests-panel.png)

**Plugin**: neotest **Layer**: `layers/test.lua`

A sidebar panel that displays test results in a hierarchical tree — organized by
file, suite, and individual test. Shows pass/fail status with icons and allows
jumping to failing tests.

- Run individual tests, files, or the entire suite from the sidebar
- Debug failing tests with DAP integration
- View test output in a dedicated panel
- Toggle coverage display with nvim-coverage
- Adapters for Python, Go, Rust, Java, .NET, C++, Lua, JavaScript (Jest, Vitest)

### Tasks Panel (Overseer)

![Overseer Panel](docs/images/overseer-panel.png)

**Plugin**: overseer.nvim **Layer**: `layers/tasks.lua`

A bottom dock panel that shows running and completed tasks — builds, test runs,
dev servers, and custom commands. Each task displays its status, output, and
elapsed time.

- Docked at the bottom with configurable height (default 25 lines)
- Imports tasks from `.vscode/tasks.json`
- Integrates with neotest (test runs appear as tasks) and DAP (debug sessions)
- Task output viewable inline or in a quickfix list
- Custom task templates for Python, Java (Maven, Gradle), and .NET (Cake)

### Debugging UI

![Debugging Panels](docs/images/debug-panels.png)

**Plugin**: nvim-dap-ui **Layer**: `layers/debug.lua`

A multi-panel debugging interface that opens automatically when a debug session
starts and closes when it ends. Organizes debugging information into two layout
groups:

- **Bottom panels**: Scopes (local/global variables and their values) and
  Watches (user-defined watch expressions)
- **Right panels**: Stack traces, breakpoints list, debug REPL (interactive
  evaluation), and console output

The UI includes playback controls (continue, step over, step into, step out,
terminate) displayed in the REPL element. Variables can be expanded to inspect
nested structures, and the REPL accepts arbitrary expressions for evaluation
during a paused session. Virtual text annotations from nvim-dap-virtual-text
show variable values inline next to the source code.

### Database Sidebar

![Database Panel](docs/images/database-panel.png)

**Plugin**: db-cli-adapter.nvim **Layer**: `layers/lang/sql.lua`

A sidebar for browsing database connections, schemas, tables, views, and their
fields. Query results are displayed in a separate output panel with CSV
formatting and Excel-like navigation.

- Browse connections, schemas, tables, views, and columns in a tree sidebar
- Execute queries from the buffer or at cursor position
- CSV-formatted output with field-level navigation (Tab/Shift-Tab between
  fields, Enter/Shift-Enter between rows)
- Connection switching and management
- Current database connection shown in the status line

### Code Outline

![Code Outline](docs/images/outline-panel.png)

**Plugin**: aerial.nvim **Layer**: `layers/telescope.lua`

A sidebar that displays the structure of the current file — functions, classes,
methods, variables, and other symbols — in a navigable tree. Selecting an entry
jumps to its location in the source. The outline updates as you edit and closes
on selection by default. Positioned on the right side of the editor. Also
integrates with Telescope for fuzzy symbol search across the document.

### Search and Replace in Files

![Search and Replace](docs/images/replace-in-files-panel.png)

**Plugin**: grug-far.nvim **Layer**: `layers/lyrd-ui.lua`

A search-and-replace panel that opens as a split with live preview of matches
and replacements across your project or within the current file.

- Live preview of all matches and replacements before applying
- Regex support
- Scope to current file or entire project
- Path filtering

### Diagnostics Panel

**Plugin**: trouble.nvim **Layer**: `layers/lsp.lua`

A structured list of all diagnostics (errors, warnings, info, hints) for the
current buffer or the entire workspace. Replaces the default location list with
a filterable, navigable panel.

- Filter by current buffer or entire workspace
- Sorted by severity (errors first)
- Jump to diagnostic location on selection
- Virtual diagnostic lines toggle for inline multi-line diagnostic display
- Telescope integration for fuzzy searching diagnostics

### Quickfix List

**Plugin**: trouble.nvim **Layer**: `layers/lsp.lua`

An enhanced quickfix list powered by Trouble, providing a structured and
navigable view of quickfix entries. Auto-populated by LSP diagnostics, build
errors, search results, and task output.

### Integrated Terminal

**Plugin**: toggleterm.nvim **Layer**: `layers/lyrd-ui.lua`

A terminal emulator embedded in Neovim that can be toggled open and closed
without losing session state. Supports multiple terminal instances that can be
listed and switched between. Also serves as the backend for floating terminal
applications like LazyGit, lazydocker, k9s, and tig.

### AI Chat Panel

![AI Chat Panel](docs/images/ai-panel.png)

**Plugin**: avante.nvim **Layer**: `layers/ai-dev.lua`

A toggleable sidebar for AI-assisted development. Supports asking questions
about code, requesting edits with visual diff review, generating documentation,
and getting refactoring suggestions. Works with GitHub Copilot, and other AI
providers. The panel shows a conversation history and can apply suggested
changes directly to your buffers.

### REPL Panel

**Plugins**: iron.nvim, NotebookNavigator.nvim, molten-nvim **Layer**:
`layers/repl.lua`

A horizontal split panel that hosts an interactive REPL session. Supports
sending code from the editor to the REPL for immediate execution. Includes
notebook-style cell navigation and execution — define cells with comment
markers, run them individually or in sequence, and move cells up or down.
Currently supports Python (IPython/Python) with Jupyter notebook integration via
jupytext.

### REST Client

**Plugin**: kulala.nvim **Layer**: `layers/rest.lua`

A response viewer panel for HTTP requests. Write requests in `.http` or `.rest`
files and execute them to see formatted responses including headers, body, and
statistics. Supports environment variables via `http-client.env.json` files,
request inspection, curl import/export, and a scratchpad for quick one-off
requests.

### Containers and Kubernetes

**Plugins**: lazydocker (external), k9s (external) **Layers**:
`layers/docker.lua`, `layers/kubernetes.lua`

Floating terminal panels that launch external TUI tools for container and
cluster management:

- **lazydocker** — visual Docker container, image, volume, and compose
  management with logs, stats, and lifecycle controls
- **k9s** — full-featured Kubernetes cluster browser for pods, deployments,
  services, and logs

Both tools run inside Neovim's floating terminal and can be toggled without
losing state.

**Requires**: `lazydocker` and/or `k9s` installed on the system.

### Focus Mode

**Plugin**: twilight.nvim **Layer**: `layers/lyrd-ui.lua`

A toggle that dims all code outside the current context (function, block, or
paragraph), drawing attention to the section you are actively editing. Useful
for reducing visual noise when working in large files.

### Local Configuration

![Local Configuration](docs/images/local-settings-dialog.png)

**Module**: `shared/ui/local_config.lua`

A floating window for toggling which LYRD layers are active. Opens a checklist
of all skippable layers — toggle a layer on or off, then save to apply. Changes
are written to `~/.local/share/nvim/lyrd/lyrd-local.lua` and take effect after
restarting Neovim.

- Centered floating window (50% width) listing all skippable layers
- Visual toggle indicators
- Excludes core unskippable layers (LSP, Debug, Test, UI, Commands, Keyboard)

## Keyboard-Driven Workflow

LYRD is designed for developers who want to keep their hands on the keyboard.
Mouse usage is optional - everything can be done with keyboard shortcuts.

**Why keyboard shortcuts matter**:

- **Speed**: Keyboard shortcuts are faster than reaching for the mouse
- **Flow**: Stay focused on your code without breaking concentration
- **Ergonomics**: Less mouse usage means less wrist strain
- **Productivity**: Professional developers using keyboard shortcuts are
  measurably faster

**How LYRD makes shortcuts easy**:

1. **Two Main Leaders**:
   - **`,` (comma)** - Main leader for quick actions and panels
   - **`<Space>`** - Secondary leader for organized feature menus

2. **Logical Grouping**: Shortcuts are organized by purpose under `<Space>`:
   - `<Space>b` - **B**uffer operations (save, close, split)
   - `<Space>c` - **C**ode actions (run, build, format, generate)
   - `<Space>d` - **D**ebugging (start, breakpoints, step through)
   - `<Space>g` - **G**it operations (status, commit, diff, blame)
   - `<Space>s` - **S**earch (files, text, symbols, commands)
   - `<Space>t` - **T**esting (run tests, coverage, debug tests)
   - `<Space>r` - **R**un tasks and REPL

3. **Quick Access with `,`**: Common operations without menu navigation:
   - `,f` - Format current buffer
   - `,x` - Run code selection
   - `,X` - Run entire file
   - `,c` - Close buffer
   - `,[` and `,]` - Navigate between buffers
   - `,<Space>` - Clear search highlights

4. **Function Keys**: Standard IDE-style shortcuts:
   - `F2` - Toggle file tree
   - `F3` - Show test summary
   - `F4` - View code outline
   - `F5` - Start/continue debugging
   - `F9` - Toggle breakpoint
   - `F10` - Debug step over
   - `F11` - Debug step into
   - `F12` - Debug step out

5. **Quick Search**: Direct shortcuts for common searches:
   - `<Ctrl-p>` - Find files (fuzzy search)
   - `<Ctrl-t>` - Search in files (live grep)
   - `<Ctrl-f>` - Resume last search

6. **LSP Navigation**: Quick code intelligence shortcuts:
   - `gd` - Go to definition
   - `gr` - Find references
   - `gi` - Go to implementation
   - `gt` - Go to type definition
   - `K` - Show hover documentation
   - `<Alt-Enter>` or `<Ctrl-.>` - Code actions
   - `<Ctrl-r><Ctrl-r>` - Rename symbol

7. **Discoverable**: Built-in helper shows available shortcuts
   - Press leader key (`,` or `<Space>`) and wait a moment
   - A popup shows all available shortcuts and what they do
   - No need to memorize everything at once
   - Learn gradually as you use features

8. **Consistent Across Languages**: Same shortcuts work in all languages
   - `<Space>cx` always runs your code
   - `<Space>tt` always runs tests
   - `<Space>bf` always formats code
   - Learn once, use everywhere

**Example workflow** (finding and editing a function):

1. `<Ctrl-p>` - Open file finder (or `<Space>s.`)
2. Type part of filename
3. `Enter` - Open file
4. `<Space>so` - Find symbol in file
5. Type function name
6. `Enter` - Jump to function
7. Make your edits
8. `,f` - Format code
9. `<Space>tt` - Run tests
10. `<Space>gs` - Check Git status

All of this takes seconds and never requires moving your hands from the
keyboard.

For a detailed list of commands with their corresponding keybindings see
[LYRD Commands Reference](/docs/commands.md).

**Learning curve**: Don't worry about memorizing everything at once. The
built-in helper (which-key) shows you what shortcuts are available. Start with
the basics:

- `<Ctrl-p>` or `<Space>s.` - Find files
- `<Ctrl-t>` or `<Space>s/` - Search in files
- `<Space>cx` - Run code
- `<Space>tt` - Run tests
- `<Space>gs` - Git status

As you work, you'll naturally discover and learn more shortcuts. Press `<Space>`
or `,` and pause to see what's available!

## Language Support

LYRD provides comprehensive support for many programming languages. Each
language layer includes everything you need: syntax highlighting, code
completion, error detection, formatting, debugging, and testing.

### Python

**What you get**:

- **Language Servers**: Basedpyright/Pyright (type checking) and Ruff (fast
  linting and formatting)
- **Virtual Environments**: Automatic detection and switching between Python
  environments
- **Testing**: Run pytest and unittest tests with visual results
- **Debugging**: Full debugging support with breakpoints and variable inspection
- **Jupyter Notebooks**: Work with notebooks directly in Neovim
- **REPL**: Interactive Python/IPython shell for experimentation
- **Package Management**: Integration with uv for fast package management
- **Code Quality**: Pylint integration with customizable rules

**How it helps you**:

- Develop Django, Flask, FastAPI applications with full IDE support
- Data science work with Jupyter integration
- Catch type errors before running code
- Fast, accurate code completions
- Instant feedback on code quality

**Perfect for**: Web development, data science, scripting, automation, machine
learning

### JavaScript/TypeScript and Web Development

**What you get**:

- **Language Servers**: VTSLS for TypeScript/JavaScript, Vue Language Server,
  Angular LS
- **Frameworks**: First-class support for React, Vue, Angular, and Svelte
- **Testing**: Jest and Vitest test runners with visual results
- **Debugging**: Debug Node.js and browser code
- **Formatting**: Prettier integration for consistent code style
- **Package Management**: npm, yarn, pnpm support
- **HTML/CSS**: Emmet support for rapid HTML writing
- **Auto-tags**: Automatic closing tags for HTML/JSX
- **Internationalization**: Inline translation previews and diagnostics via
  i18n-status
- **Development Server**: Start a live-reloading local server for previewing web
  projects

**How it helps you**:

- Build modern web applications with full TypeScript support
- Instant error detection catches bugs as you type
- Component-based development with framework-specific tools
- Fast refactoring across multiple files
- Test-driven development with visual test runners
- See translations inline and catch missing i18n keys early
- Preview web projects with live reload without leaving Neovim

**Perfect for**: Frontend development, full-stack JavaScript, Node.js
applications, modern web frameworks (React, Vue, Angular, Svelte)

### Java

**What you get**:

- **Language Server**: Eclipse JDT.LS (the same engine as VS Code)
- **Testing**: JUnit and TestNG support with visual test runner
- **Debugging**: Full debugging with Java Debug Adapter
- **Build Tools**: Maven and Gradle integration
- **Code Generation**: Generate getters, setters, constructors, and more
- **Code Scaffolding**: Java class, record, enum, and interface templates
- **Refactoring**: Rename, extract method, extract variable, and more
- **Spring Boot**: Spring Boot integration with boot-specific tooling
- **Project Management**: Automatic classpath detection and management

**How it helps you**:

- Enterprise Java development with IDE-quality support
- Spring Boot development with all the tools you need
- Automatic import management
- Quick fixes for common problems
- Seamless Maven/Gradle builds

**Perfect for**: Enterprise applications, Spring Boot, Android development,
backend services

### .NET (C Sharp, F Sharp, VB.NET)

**What you get**:

- **Language Server**: Roslyn (Microsoft's official language server) via
  easy-dotnet
- **Testing**: VSTest integration with visual results
- **Debugging**: netcoredbg for full debugging support
- **Code Generation**: Create classes, interfaces, MediatR patterns (commands,
  requests, events, handlers)
- **Code Scaffolding**: C# class, interface, enum, record, and exception
  templates
- **Formatting**: CSharpier for consistent code style
- **Project Management**: Solution and project file support
- **NuGet**: Package management integration

**How it helps you**:

- ASP.NET Core development with full IntelliSense
- CQRS patterns with MediatR templates
- Entity Framework integration
- Quick navigation in large solutions
- Cross-platform .NET development

**Perfect for**: Web APIs, microservices, desktop applications, game development
with Unity

### Go

**What you get**:

- **Language Server**: gopls (official Go language server)
- **Testing**: go test integration with visual results
- **Debugging**: delve debugger integration
- **Code Generation**: struct tags, interface implementation, test files
- **Code Scaffolding**: Go struct, interface, and test file templates
- **Formatting**: gofmt/goimports automatic formatting
- **Build Tools**: go build, go mod support
- **Refactoring**: gorename, goimpl for safe refactoring

**How it helps you**:

- Fast, efficient Go development
- Automatic imports management
- Generate boilerplate code (tags, tests, etc.)
- Concurrent code debugging
- Microservices development

**Perfect for**: Microservices, command-line tools, cloud applications,
concurrent systems

### Rust

**What you get**:

- **Language Server**: rust-analyzer (best-in-class Rust tooling)
- **Testing**: cargo test integration
- **Debugging**: lldb/codelldb for debugging
- **Crate Management**: crates.nvim for dependency management
- **Build Tools**: Cargo integration with visual feedback
- **Compiler Errors**: Clear, actionable error messages
- **Bacon**: Continuous compilation in the background

**How it helps you**:

- Write safe, fast Rust code with excellent tooling
- Understand complex compiler errors
- Manage dependencies easily
- Test-driven development
- Systems programming with confidence

**Perfect for**: Systems programming, WebAssembly, CLI tools,
performance-critical applications

### C and C++

**What you get**:

- **Language Server**: clangd for C/C++ intelligence
- **Debugging**: lldb/codelldb integration
- **Testing**: CTest integration
- **Formatting**: clang-format for consistent style
- **Build Systems**: CMake, Make support
- **Header/Source**: Quick switching between headers and source files

**How it helps you**:

- Modern C++ development with C++20 support
- Navigate large C/C++ codebases
- Understand complex types and templates
- Debug memory issues
- Cross-platform development

**Perfect for**: Systems programming, game development, embedded systems,
performance-critical code

### Kotlin

**What you get**:

- **Language Server**: kotlin-language-server for code intelligence
- **Linting**: ktlint for code style enforcement
- **Debugging**: kotlin-debug-adapter for full debugging support
- **Build Tools**: Gradle and Maven integration

**Perfect for**: Android development, Spring Boot with Kotlin, multiplatform
projects

### Bash

**What you get**:

- **Language Server**: bash-language-server for script intelligence
- **Syntax highlighting**: Full Treesitter-based highlighting
- **ShellCheck integration**: Linting for common shell scripting issues

**Perfect for**: Shell scripting, automation, DevOps workflows

### Pascal

**What you get**:

- **Language Server**: pascal-language-server (custom Mason registry)
- **Syntax highlighting**: Treesitter-based highlighting

**Perfect for**: Legacy Pascal projects, Free Pascal development

### LaTeX

**What you get**:

- **Language Server**: texlab for completions, references, and diagnostics
- **Syntax highlighting**: Treesitter-based highlighting for LaTeX and BibTeX
- **Formatting**: latexindent for consistent document formatting
- **Compilation**: VimTeX integration with continuous compilation via `latexmk`
- **PDF Viewing**: Zathura PDF viewer with forward/inverse search
- **Error Reporting**: Quick access to compilation errors

**How it helps you**:

- Compile and preview documents without leaving the editor
- Navigate compilation errors quickly
- Format your LaTeX source consistently
- Get intelligent completions for commands, environments, and citations

**Perfect for**: Academic papers, theses, technical documentation, scientific
publishing

### SQL

**What you get**:

- **Language Server**: sqls for completions and database introspection
- **Diagnostics and Formatting**: sqlfluff with per-buffer dialect awareness
- **Dialect Selection**: 28 SQL dialects (PostgreSQL, MySQL, SQLite, T-SQL,
  BigQuery, Snowflake, DuckDB, Oracle, and more) configurable per buffer,
  dynamically adjusting diagnostics and formatting rules
- **Automatic Dialect Detection**: Changing the active database connection
  automatically sets the matching SQL dialect
- **Database Connections**: db-cli-adapter integration for managing and switching
  between multiple database connections
- **Query Execution**: Run the entire buffer or individual queries against the
  active connection
- **Recursive Query Selection**: When running a selection, Tree-sitter walks
  upward from the cursor to find all enclosing SQL statements (subqueries,
  statements, full program), letting you choose which level to execute
- **CSV Output**: Query results in CSV format with in-editor column-based
  viewing via csvview

**How it helps you**:

- Work with multiple databases and dialects without leaving the editor
- Get accurate linting and formatting tuned to each dialect
- Execute queries at any nesting level with a single action
- Browse query results as formatted tables inside Neovim

**Perfect for**: Database development, data analysis, query authoring across
multiple SQL engines

### Other Languages

**Lua**:

- Neovim plugin development
- Game development (Love2D, etc.)
- Embedded scripting

**Markdown**:

- Beautiful rendering in the editor
- Table of contents generation
- Mermaid diagrams
- Live preview

**Data Formats** (JSON, YAML, TOML, XML):

- Schema validation
- Formatting and linting
- Quick navigation in large files

**CMake**:

- Build system support
- Syntax highlighting and completion

**gRPC/Protocol Buffers**:

- .proto file support
- Code generation integration

**CSV/TSV**:

- Column-based viewing
- Easy navigation in data files

## Installation

### Prerequisites

- **Neovim 0.11.0 or higher**: LYRD requires a recent version of Neovim (uses
  native LSP config via `vim.lsp.enable()`)
- **Git**: For cloning the repository and managing plugins
- **A Nerd Font**: For icons to display correctly (recommended: JetBrains Mono
  Nerd Font, FiraCode Nerd Font, or Hack Nerd Font)
- **ripgrep**: For fast text searching
- **fd**: For fast file finding (optional but recommended)
- **Node.js**: Required for many language servers
- **Python 3**: Required for Python development and some plugins

### Basic Installation

1. **Backup your existing Neovim configuration** (if you have one):

   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   mv ~/.local/share/nvim ~/.local/share/nvim.backup
   mv ~/.local/state/nvim ~/.local/state/nvim.backup
   mv ~/.cache/nvim ~/.cache/nvim.backup
   ```

2. **Clone LYRD into your Neovim config folder**:

   ```bash
   git clone https://github.com/diegoortizmatajira/LYRD-lua.git ~/.config/nvim/lua/LYRD
   ```

3. **Create a symbolic link to the init script**:

   ```bash
   ln -s ~/.config/nvim/lua/LYRD/root-init.lua ~/.config/nvim/init.lua
   ```

4. **Launch Neovim**:

   ```bash
   nvim
   ```

5. **Wait for plugins to install**: On first launch, LYRD will automatically:
   - Install the Lazy.nvim plugin manager
   - Download and install all configured plugins
   - This may take a few minutes depending on your internet connection

6. **Restart Neovim**: After the initial installation completes, restart Neovim
   to ensure everything is loaded correctly.

### Post-Installation

**Install Language Tools**:

LYRD will prompt you to install language servers and tools as needed. You can
also manually install tools:

1. Open Neovim
2. Run the `LYRDToolManager` command to open Mason (the tool manager)
3. Browse and install the tools you need

**Common tools to install**:

- Python: `basedpyright`, `ruff`, `debugpy`
- JavaScript/TypeScript: `typescript-language-server`, `prettier`
- Java: `jdtls`, `java-debug-adapter`
- Go: `gopls`, `delve`
- Rust: `rust-analyzer`, `codelldb`
- C/C++: `clangd`, `clang-format`

**Verify Installation**:

Run the health check to see if everything is working:

```vim
:checkhealth LYRD
```

This will show you:

- Which features are working correctly
- Missing dependencies
- Recommended installations

## Configuration

### Local Configuration File

LYRD allows you to customize settings without modifying the core files. Your
personal configuration is stored in:

```bash
~/.local/share/nvim/lyrd/lyrd-local.lua
```

To edit your local configuration:

1. Run the `LYRDEditLocalConfig` command in Neovim
2. Or manually create/edit the file

### Skipping Layers

If you don't need certain features, you can skip loading specific layers. In
your local config file:

```lua
return {
    skip_layers = {
        "LYRD.layers.ai-dev",      -- Skip AI features
        "LYRD.layers.docker",      -- Skip Docker integration
        "LYRD.layers.kubernetes",  -- Skip Kubernetes features
    }
}
```

**Common layers you might want to skip**:

- `LYRD.layers.ai-dev` - AI-powered coding assistance
- `LYRD.layers.docker` - Docker integration
- `LYRD.layers.kubernetes` - Kubernetes tools
- `LYRD.layers.repl` - Interactive REPL/Jupyter support
- `LYRD.layers.grammar` - Grammar checking
- `LYRD.layers.static-website` - Hugo integration
- `LYRD.layers.lang.java` - Java support
- `LYRD.layers.lang.dotnet` - .NET support
- `LYRD.layers.lang.rust` - Rust support

Skipping unused layers reduces startup time and memory usage.

### Customizing Keybindings

While LYRD's default keybindings are well thought out, you can override them in
your local config or add your own mappings directly in Neovim:

```lua
-- In your local config or in Neovim
vim.keymap.set('n', '<your-key>', '<your-command>', { desc = 'Your description' })
```

### AI Provider Configuration

LYRD supports multiple AI providers. By default, it's configured for GitHub
Copilot, but you can switch providers or disable AI features entirely.

To configure AI settings, you can modify the AI layer settings in your local
configuration or check the `ai-dev.lua` layer for provider options (Copilot,
Codeium, TabNine).

### Theme Customization

LYRD comes with multiple themes. Use the `LYRDApplyNextTheme` command to cycle
through themes, and `LYRDApplyCurrentTheme` to apply the current theme
permanently.

### Project-Specific Settings

For project-specific configurations, you can create a `.nvim.lua` file in your
project root with custom settings. This is useful for:

- Project-specific tasks
- Custom commands
- Environment variables
- Build configurations

### Updating LYRD

To update LYRD to the latest version:

```bash
cd ~/.config/nvim/lua/LYRD
git pull
```

Then in Neovim, update plugins:

1. Run the `LYRDPluginsUpdate` command to update all plugins
2. Restart Neovim

### Troubleshooting

**Plugins not loading?**

- Run `:Lazy sync` to reinstall plugins
- Check `:checkhealth lazy`

**Language features not working?**

- Install the language server via Mason using the `LYRDToolManager` command
- Check `:LspInfo` to see if the server is running
- Run `:checkhealth lsp`

**Performance issues?**

- Skip unused layers (see Configuration above)
- Disable AI features if not needed
- Check for large files (LYRD disables some features for files >5MB)

**Icons not showing?**

- Install a Nerd Font and configure your terminal to use it
- Check `:checkhealth` for icon-related issues

### Getting Help

- **In-editor help**: Run `LYRDSearchKeyMappings` to see buffer-specific keymaps
- **Command palette**: Run `LYRDSearchCommands` to search all available commands
- **Mason tools**: Run `LYRDToolManager` to manage language servers and tools
- **Health check**: Run `:checkhealth LYRD` to diagnose issues

### Learning Resources

**Start small**: Focus on learning a few commands at a time:

1. **Week 1**: File navigation and search
2. **Week 2**: Code navigation (go to definition, find references, hover docs)
3. **Week 3**: Running and testing
4. **Week 4**: Git integration
5. **Week 5**: Debugging

**Explore gradually**: Press a leader key and pause to see what commands are
available. The which-key popup will show you all options with descriptions. See
the [Keyboard-Driven Workflow](#keyboard-driven-workflow) section for detailed
shortcut mappings.

**Customize to your needs**: Don't be afraid to skip features you don't use and
add your own customizations.

---

## Contributing

LYRD is open for contributions! If you:

- Find bugs
- Want to add features
- Have suggestions for improvements
- Want to add support for new languages

Feel free to open issues or pull requests on the GitHub repository.

## License

LYRD is released under the MIT License. See the LICENSE file in the repository
for details.

---

LYRD® Neovim by Diego Ortiz. 2023-2026

Transform your Neovim into a complete development environment. Code faster,
debug smarter, and stay in your flow.
