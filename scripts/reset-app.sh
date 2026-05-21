#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "Resetting src/App.js and src/App.css to the blank workshop starter…"

cat > "$ROOT/src/App.js" <<'EOF'
import './App.css';

function App() {
  return (
    <div className="App">
      <h1>Everything works!</h1>
      <p>Wait for instructions from the workshop leaders.</p>
      <p>If there have been any changes, refresh this browser window.</p>

    </div>
  );
}

export default App;
EOF

cat > "$ROOT/src/App.css" <<'EOF'
* {
  box-sizing: border-box;
}

html, body, #root {
  height: 100%;
  margin: 0;
}

body {
  background: #f3f4f6;
  color: #111827;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen,
    Ubuntu, Cantarell, "Fira Sans", "Droid Sans", "Helvetica Neue", Arial, sans-serif;
}

.App {
  padding: 48px 24px;
  max-width: 720px;
  margin: 0 auto;
  text-align: center;
}

.App h1 {
  font-size: 2rem;
  margin: 0 0 16px;
}

.App p {
  color: #4b5563;
}
EOF

# Wipe any files Cline wrote during the previous round that we don't want
# carried into the next exercise. Keep CRA's scaffolding intact.
if [[ -d "$ROOT/cline_plan" ]]; then
  rm -rf "$ROOT/cline_plan"
  echo "  removed cline_plan/"
fi
for f in architecture.md todo.md TODO.md ARCHITECTURE.md; do
  if [[ -f "$ROOT/$f" ]]; then
    rm -f "$ROOT/$f"
    echo "  removed $f"
  fi
done

bash "$ROOT/scripts/set-title.sh"

echo "Done. Refresh your browser tab to see the fresh starter page."
