# Agent Instructions

## Test Environment Setup
- Download the Godot 4.4.1 executable to run tests.
- Example commands for Linux x86_64:

```bash
curl -L -o Godot_v4.4.1-stable_linux.x86_64.zip \
  https://downloads.tuxfamily.org/godotengine/4.4.1/Godot_v4.4.1-stable_linux.x86_64.zip
unzip Godot_v4.4.1-stable_linux.x86_64.zip
chmod +x Godot_v4.4.1-stable_linux.x86_64
```

The executable must be available in the repository root when running tests.

## Running Tests
- Run the following commands from the repository root:

```bash
./Godot_v4.4.1-stable_linux.x86_64 --headless --path . -s res://tests/test_addition.gd
./Godot_v4.4.1-stable_linux.x86_64 --headless --path . -s res://tests/test_maze_data.gd
```
Alternatively, execute all test scripts using `tests/run_all_tests.sh`:

```bash
./tests/run_all_tests.sh
```

Make sure the commands exit with status code `0` to pass tests.

## Additional Notes
- Keep the Godot binary out of version control. Download it in each new environment when needed.
- Use the exact test file paths provided above.
