# QIT CLI Complete Command Reference

## Test Execution Commands

### run:e2e
Run E2E (End-to-End) tests using Playwright.

```bash
qit run:e2e [options] [--] [<sut> [<passthrough>...]]
```

**Arguments:**
- `sut` - Extension identifier: plugin/theme slug or WooCommerce.com ID
- `passthrough` - Arguments passed after `--` to test runner

**Options:**
- `--config=<path>` - Path to qit.json configuration file
- `--profile=<name>` - Test profile to use (default: "default")
- `-e, --environment=<name>` - Environment block from qit.json (default: "default")
- `--zip=<path>` - Custom source (local ZIP, directory, or URL)
- `--async` - Enqueue test and return immediately
- `--test-package=<pkg>` - Test packages to include (repeatable)
- `--php=<version>` - PHP version (default: 8.2)
- `--wp=<version>` - WordPress version (default: stable)
- `--woo=<version>` - WooCommerce version
- `-p, --plugin=<slug>` - Additional plugins (repeatable)
- `-t, --theme=<slug>` - Additional themes (repeatable)
- `--volume=<host:container>` - Volume mounts (repeatable)
- `-x, --php_extension=<ext>` - PHP extensions (repeatable)
- `-o, --object_cache` - Enable Redis object cache
- `--tunnel=<provider>` - Enable tunneling (cloudflare, ngrok)
- `--offline` / `--online` - Force network mode
- `--env=<KEY=VAL>` - Environment variables (repeatable)
- `--env_file=<path>` - Load env vars from file (repeatable)
- `-j, --json` - Machine-readable JSON output
- `-s, --skip_activating_plugins` - Skip plugin activation
- `-st, --skip_activating_themes` - Skip theme activation
- `--ui` - Run in Playwright UI mode

### run:activation
Run activation tests (validates plugin activates without PHP errors).

```bash
qit run:activation [options] [--] [<sut>]
```

Same options as `run:e2e`.

### run:security
Run security vulnerability scans.

```bash
qit run:security [options] [--] [<sut>]
```

**Options:**
- `--config=<path>` - Path to qit.json
- `--profile=<name>` - Test profile (default: "default")
- `--zip=<path>` - Custom source
- `-j, --json` - JSON output
- `--async` - Enqueue without waiting
- `--print-report-url` - Show report URL
- `-t, --timeout=<seconds>` - Wait timeout
- `-g, --group` - Register into a group

### run:phpstan
Run PHPStan static analysis.

```bash
qit run:phpstan [options] [--] [<sut>]
```

**Options (in addition to standard):**
- `--phpstan_level=<0-10>` - PHPStan strictness level (default: 2)
- `--wp=<version>` - WordPress version
- `--woo=<version>` - WooCommerce version
- `--additional_plugins=<slugs>` - Comma-separated additional plugins

### run:malware
Run malware scanning.

```bash
qit run:malware [options] [--] [<sut>]
```

Same options as `run:security`.

### run:phpcompatibility
Run PHP compatibility checks.

```bash
qit run:phpcompatibility [options] [--] [<sut>]
```

Same options as `run:security`.

### run:performance
Run k6 performance tests.

```bash
qit run:performance [options] [--] [<woo_extension>]
```

**Additional Options:**
- `--local` - Run tests locally instead of QIT infrastructure
- `--no_baseline` - Skip baseline performance tests
- `--up_only` - Start environment only, keep running
- `--no_upload_report` - Don't upload report to QIT Manager
- `--optional_features=<features>` - WooCommerce features (hpos, new_product_editor)
- `--extension_set=<set>` - Predefined extension set (compatibility, minimal)

### run:group
Run a group of tests defined in qit.json.

```bash
qit run:group <group-name> [--only=<test-types>]
```

**Options:**
- `--only=<types>` - Run only specific test types from group

## Environment Commands

### env:up / env:start
Create a temporary local test environment.

```bash
qit env:up [options]
```

**Options:**
- `--config=<path>` - Path to qit.json
- `-e, --environment=<name>` - Environment block from qit.json (default: "default")
- `--environment_type=<type>` - Type: "e2e" or "performance" (default: e2e)
- `--php=<version>` - PHP version (default: 8.2)
- `--wp=<version>` - WordPress version (default: stable)
- `--woo=<version>` - WooCommerce version
- `-p, --plugin=<slug>` - Additional plugins (repeatable)
- `-t, --theme=<slug>` - Additional themes (repeatable)
- `-x, --php_extension=<ext>` - PHP extensions (repeatable)
- `-o, --object_cache` - Enable Redis
- `--volume=<host:container>` - Volume mounts (repeatable)
- `--env=<KEY=VAL>` - Environment variables (repeatable)
- `--env_file=<path>` - Load env vars from file
- `--tunnel=<provider>` - Enable tunneling (cloudflare, ngrok)
- `--test-package=<pkg>` - Test packages for setup (repeatable)
- `--utility=<pkg>` - Utility packages (repeatable)
- `--global-setup` - Run setup phases without tests
- `--skip-setup` - Skip setup phases
- `--skip_activating_plugins` - Skip plugin activation
- `--skip_activating_themes` - Skip theme activation
- `-j, --json` - JSON output
- `--offline` / `--online` - Force network mode

### env:down / env:stop
Stop a local test environment.

```bash
qit env:down [<environment>]
```

**Arguments:**
- `environment` - Environment ID, or "all" to stop all

### env:list
List running environments.

```bash
qit env:list [<env_id>]
```

**Options:**
- `-f, --field=<name>` - Show specific field only

### env:enter
Enter (SSH into) a running environment.

```bash
qit env:enter [options]
```

**Options:**
- `-u, --user=<user>` - User to enter as
- `-d, --dev` - Enter with developer tools (bash, less, etc.)

### env:exec
Execute command in a running environment.

```bash
qit env:exec [options] <command_to_run>
```

**Options:**
- `--env_var=<KEY=VAL>` - Environment variables (repeatable)
- `--env_id=<id>` - Target environment ID
- `--user=<user>` - User to run command as
- `--timeout=<seconds>` - Command timeout (default: 300)
- `--image=<name>` - Docker image (default: php)

### env:reset
Reset environment database to post-setup state.

```bash
qit env:reset
```

### env:source
Configure shell to run tests against QIT environment.

```bash
qit env:source
```

## Test Results Commands

### list-tests
List test runs with filtering.

```bash
qit list-tests [options]
```

**Options:**
- `-e, --extensions=<slugs>` - Filter by extensions (comma-separated)
- `-s, --test_status=<status>` - Filter by status
- `-t, --test_types=<types>` - Filter by test types (comma-separated)
- `-p, --page=<num>` - Page number (default: 1)
- `-pp, --per_page=<num>` - Results per page (default: 10)

### get
Get a single test run result.

```bash
qit get [options] <test_run_id>
```

**Options:**
- `-o, --open` - Open in browser
- `-j, --json` - JSON output
- `--check_finished` - Return success if finished, failure if not

**Exit Codes:**
- 0: Success
- 1: Failed
- 3: Warning

### get-multiple
Get multiple test run results.

```bash
qit get-multiple [options] <test_run_ids>
```

### open
Open test run in browser.

```bash
qit open <test_run_id>
```

### report
Show or open a test report.

```bash
qit report <test_run_id>
```

## Package Commands

### package:list
List available test packages.

```bash
qit package:list [options]
```

**Options:**
- `--format=<format>` - Output format: table, json (default: table)
- `-j, --json` - JSON output
- `-t, --test-type=<type>` - Filter by test type
- `--namespace=<ns>` - Filter by namespace
- `--type=<type>` - Filter by package type (utility, test, all)
- `-o, --owned-only` - Show only packages you own
- `-l, --limit=<num>` - Packages per page (default: 20)
- `-p, --page=<num>` - Page number (default: 1)
- `--no-pagination` - Show all packages

### package:show
Show details of a test package.

```bash
qit package:show <namespace/package>
```

### package:download
Download test packages from QIT registry.

```bash
qit package:download <namespace/package>
```

### package:scaffold
Scaffold a new test package.

```bash
qit package:scaffold <path> --package=<namespace/name:version>
```

### package:publish
Publish a test package to QIT.

```bash
qit package:publish <path> <version>
```

### package:delete
Delete a test package from registry.

```bash
qit package:delete <namespace/package>
```

## Partner/Connection Commands

### connect
Connect to QIT (authenticate with WooCommerce.com).

```bash
qit connect
```

### partner:add
Add a new Partner account.

```bash
qit partner:add --user=<email> --qit_token=<token>
```

### partner:switch
Switch between Partner accounts.

```bash
qit partner:switch
```

### partner:remove
Remove a Partner account.

```bash
qit partner:remove
```

## Utility Commands

### sync
Re-sync with QIT Manager server.

```bash
qit sync
```

### extensions
List WooCommerce extensions you have access to test.

```bash
qit extensions [options]
```

**Options:**
- `-r, --refresh` - Manually refresh the list
- `-d, --deps` - Include dependencies

### qit:dir
Show QIT configuration directory path.

```bash
qit qit:dir
```

### woo:validate-zip
Validate a local ZIP file's content.

```bash
qit woo:validate-zip <path-to-zip>
```

### cache
Manage QIT cache (dev mode only).

```bash
qit cache
```

### proxy
Set proxy settings.

```bash
qit proxy <url>
```

## Tunnel Commands

### tunnel:setup
Configure tunneling methods.

```bash
qit tunnel:setup
```

### tunnel:set-default
Set default tunneling method.

```bash
qit tunnel:set-default <provider>
```

**Providers:** cloudflare, ngrok

## Global Options

All commands support these options:

- `-h, --help` - Display help
- `-q, --quiet` - No output
- `-V, --version` - Display version
- `--ansi` / `--no-ansi` - Force/disable ANSI output
- `-n, --no-interaction` - No interactive prompts
- `-v` / `-vv` / `-vvv` - Verbosity levels
