---
name: qit
description: QIT (Quality Insights Toolkit) CLI for WooCommerce extension testing. This skill should be used when running tests (E2E, activation, security, PHPStan, malware, performance), managing local test environments, or working with QIT test packages. Use for testing WooCommerce plugins/themes, spinning up test environments, or analyzing test results.
allowed-tools: Read, Write, Edit, Bash(qit:*), Grep, Glob, Task
---

# QIT CLI Skill

## Overview

QIT (Quality Insights Toolkit) is a testing platform for WooCommerce plugins and themes. This skill enables running managed tests, creating local test environments, and managing test packages through the `qit` CLI.

**Important:** Plugins and themes must be registered with QIT before testing. The following extensions are pre-registered and available for use:
- **Plugins:** `automatewoo`, `woocommerce-bookings`
- **Themes:** `bistro`

## Quick Reference

### Most Common Commands

```bash
# List running environments
qit env:list

# Create a test environment
qit env:up --php=8.2 --wp=stable --woo=stable

# Stop environment
qit env:down

# Run E2E tests
qit run:e2e <extension-slug>

# Run activation tests
qit run:activation <extension-slug>

# Run security scan
qit run:security <extension-slug>

# List test results
qit list-tests

# Get specific test result
qit get <test-run-id>
```

## Core Workflows

### 1. Running Tests

To run tests against a registered extension:

#### E2E Tests (End-to-End)
```bash
# Basic E2E test
qit run:e2e automatewoo

# E2E with specific versions
qit run:e2e automatewoo --php=8.3 --wp=6.7 --woo=9.0

# E2E with additional plugins
qit run:e2e automatewoo -p woocommerce-bookings

# E2E with custom theme
qit run:e2e automatewoo -t bistro

# E2E with tunneling for external access
qit run:e2e automatewoo --tunnel=cloudflare

# E2E in Playwright UI mode (for debugging)
qit run:e2e automatewoo --ui
```

#### Activation Tests
Validates plugin activates without PHP errors:
```bash
qit run:activation automatewoo
qit run:activation woocommerce-bookings --php=8.2
```

#### Security Tests
```bash
qit run:security automatewoo
qit run:security automatewoo --json  # Machine-readable output
```

#### PHPStan Analysis
```bash
# Default level (2)
qit run:phpstan automatewoo

# Custom strictness level (0-10)
qit run:phpstan automatewoo --phpstan_level=5
```

#### Other Test Types
```bash
qit run:malware <extension>           # Malware scanning
qit run:phpcompatibility <extension>  # PHP compatibility
qit run:api <extension>               # API tests
qit run:validation <extension>        # Validation tests
qit run:plugin-check <extension>      # Plugin check
qit run:performance <extension>       # Performance tests (k6)
```

### 2. Managing Local Environments

To create disposable test environments:

#### Starting an Environment
```bash
# Basic environment with defaults
qit env:up

# Custom PHP/WP/WooCommerce versions
qit env:up --php=8.3 --wp=6.7 --woo=10.0

# With additional plugins and themes
qit env:up -p automatewoo -p woocommerce-bookings -t bistro

# With Redis object cache
qit env:up -o

# With volume mounting for development
qit env:up --volume=/local/path:/container/path

# With environment variables
qit env:up --env=DEBUG=true --env=WP_DEBUG_LOG=true

# With tunneling for external access
qit env:up --tunnel=cloudflare
```

#### Managing Running Environments
```bash
# List all running environments
qit env:list

# Get specific environment info
qit env:list <env_id>

# Enter an environment (SSH)
qit env:enter

# Enter as developer (with bash, less, etc.)
qit env:enter --dev

# Execute command in environment
qit env:exec "wp plugin list"
qit env:exec "wp user create test test@test.com --role=administrator"

# Reset environment database
qit env:reset

# Stop environment
qit env:down

# Stop all environments
qit env:down all
```

### 3. Viewing Test Results

```bash
# List recent tests
qit list-tests

# Filter by extension
qit list-tests --extensions=automatewoo,woocommerce-bookings

# Filter by status
qit list-tests --test_status=failed

# Filter by test type
qit list-tests --test_types=security,e2e

# Get specific test details
qit get <test-run-id>

# Get test as JSON
qit get <test-run-id> --json

# Open test in browser
qit get <test-run-id> --open

# View test report
qit report <test-run-id>
```

### 4. Test Packages

To manage custom test packages:

```bash
# List available packages
qit package:list

# Filter by test type
qit package:list --test-type=e2e

# Show package details
qit package:show <namespace/package>

# Download a package
qit package:download <namespace/package>

# Scaffold new package
qit package:scaffold ./my-tests --package=myco/custom-tests:1.0.0

# Publish package
qit package:publish ./my-tests 1.0.0
```

### 5. Running Test Groups

When `qit.json` defines test groups:

```bash
# Run entire group
qit run:group ci-pipeline

# Run only specific test types from group
qit run:group ci-pipeline --only=e2e
```

## Configuration

### qit.json Structure

Projects can define a `qit.json` for configuration:

```json
{
  "sut": {
    "type": "plugin",
    "slug": "automatewoo"
  },
  "environments": {
    "default": {
      "php": "8.2",
      "wp": "stable",
      "woo": "stable"
    },
    "legacy": {
      "php": "7.4",
      "wp": "6.4",
      "woo": "8.0"
    }
  },
  "test_types": {
    "e2e": {
      "default": {
        "environment": "default",
        "test_packages": ["woocommerce/e2e-tests:latest"]
      }
    }
  },
  "groups": {
    "ci": {
      "activation": ["default"],
      "security": ["default"],
      "e2e": ["default"]
    }
  }
}
```

### Using Configuration
```bash
# Use specific environment from qit.json
qit env:up --environment=legacy

# Use specific test profile
qit run:e2e automatewoo --profile=smoke

# Use custom config file
qit run:e2e automatewoo --config=./custom-qit.json
```

## Common Options Reference

### Version Aliases
- `--php` or `--php_version` - PHP version (8.2, 8.3)
- `--wp` or `--wordpress_version` - WordPress version (stable, rc, 6.7)
- `--woo` or `--woocommerce_version` - WooCommerce version (stable, rc, 10.0)

### Test Execution Options
- `--async` - Enqueue test without waiting for completion
- `--json` / `-j` - Output in JSON format
- `--print-report-url` - Show report URL in output
- `--timeout=<seconds>` - Wait timeout

### Environment Options
- `-p, --plugin` - Add plugin (repeatable)
- `-t, --theme` - Add theme (repeatable)
- `-x, --php_extension` - Add PHP extension (repeatable)
- `-o, --object_cache` - Enable Redis
- `--volume` - Mount volume (repeatable)
- `--env` - Set environment variable (repeatable)
- `--tunnel` - Enable tunneling (cloudflare, ngrok)

## Troubleshooting

### Check Connection Status
```bash
qit connect  # Re-authenticate if needed
qit sync     # Re-sync with QIT Manager
```

### List Available Extensions
```bash
qit extensions         # List extensions you can test
qit extensions --deps  # Include dependencies
```

### Environment Issues
```bash
# List all environments to find stuck ones
qit env:list

# Force stop all environments
qit env:down all

# Check QIT config directory
qit qit:dir
```

### Verbose Output
Add `-v`, `-vv`, or `-vvv` for increasing verbosity:
```bash
qit run:e2e automatewoo -vvv
```

## Resources

### references/
- `command-reference.md` - Complete command documentation and examples

**Note:** The qit CLI binary is installed globally and available in the environment. Extensions must be registered with QIT before they can be tested.
