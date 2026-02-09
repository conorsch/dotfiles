Update the "gaming-vids" utility such that:

1. the hostname lookup is not even the command "hostname" but rather the env var "HOSTNAME";
2. the logic for determining whether the current host is in WSL is refactored into a discrete function, and reused;
3. when run under WSL, the "gaming-vids ls" command checks the windows media dirs, and lists files there.
4. similarly, the "gaming-vids upload" should accept a "--dry-run" flag, that essentially just runs the "gaming-vids ls" logic
