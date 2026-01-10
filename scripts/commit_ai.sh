#!/bin/bash
set -e

# --- Configuration ---
COMMITS_TO_SUGGEST=10                       # Required quantity per final example
AICHAT_MODEL="groq:llama-3.3-70b-versatile" # Your chosen model
SCRIPT_NAME=$(basename "$0" .sh)

# --- Logging Function ---
# Use a unique log file name in /tmp to avoid collisions if script runs multiple times
# or if other scripts also use /tmp/commit_ai.log
LOG_FILE="/tmp/${SCRIPT_NAME}_$(date +%Y%m%d_%H%M%S)_$$.log"
# Clear log file on start (or rather, create it fresh)
# If using a unique name per run, clearing isn't strictly necessary but doesn't hurt.
>"$LOG_FILE"

log_message() {
	echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >>"$LOG_FILE"
}

log_debug() {
	if [[ -n "${DEBUG_COMMIT_AI}" ]]; then               # Enable with DEBUG_COMMIT_AI=true ./commit_ai.sh
		echo "$(date '+%Y-%m-%d %H:%M:%S') - DEBUG: $1" >&2 # Debug to stderr
	fi
}

log_message "Script started (lazygit context)."
log_message "Log file: $LOG_FILE"
log_message "COMMITS_TO_SUGGEST: $COMMITS_TO_SUGGEST"
log_message "AICHAT_MODEL: $AICHAT_MODEL"

# --- Script Logic ---

log_message "Checking for staged changes..."
diff_output=$(git diff --cached)
if [ -z "$diff_output" ]; then
	log_message "No changes in staging. Exiting."
	echo "No changes in staging. Add changes first." # This output goes to lazygit menu
	exit 1
fi
log_message "Staged changes detected (length: ${#diff_output})."
log_debug "Staged changes (first 500 chars): ${diff_output:0:500}..."

log_message "Getting recent commit history..."
previous_commits=$(git log -n 10)
log_message "Previous commits obtained (length: ${#previous_commits})."
log_debug "Previous commits (first 500 chars): ${previous_commits:0:500}..."

log_message "Constructing aichat prompt content..."

prompt_template=$(
	cat <<EOM
You are an expert at writing Git commits. Your job is to write a short clear commit message that summarizes the changes using conventional commits format.
this is the spec for commit lint

formatter: "@commitlint/format"
extends:
  - "@commitlint/config-conventional"
rules:
  # commitlint interprets special characters as whitespace for some reason - make this a warning to
  # avoid
  header-trim:
    - 1
    - always
  scope-enum:
    - 2
    - always
    - - alchemist
      - authorizer
      - bbg-bpipe
      - brainy
      - burrow
      - chronicler
      - ci
      - cleaner-shrimp
      - codex
      - coral
      - coral-binance-futures
      - coral-bybit
      - coral-ib
      - coral-okx
      - courier
      - crucible
      - datacat
      - discover-region
      - eco
      - exchanges
      - glyph
      - http-proxy
      - ib-jester
      - louvre
      - match-point
      - mni
      - nerve
      - news
      - news-feed-handler-velo
      - news-feed-handlers
      - order-management
      - order-monitor
      - order-monitor-binance-futures
      - order-monitor-ib
      - order-poller
      - order-poller-binance-futures
      - order-poller-core
      - order-poller-spot
      - pensieve
      - portfolio-analyzer
      - proto
      - query-manager
      - s3-proxy
      - samurai
      - sashimi
      - scepter
      - scheduler
      - scoop
      - scribe
      - secretary
      - tracing-preset
      - trade-exit-engine
      - ui
      - venue-ingester
      - view-stream
      - webscrapers
      - webserver
  type-enum:
    - 2
    - always
    - - build
      - chore
      - ci
      - docs
      - feat
      - fix
      - perf
      - refactor
      - release
      - revert
      - style
      - test

Follow these guidelines for conventional commits:
- Always use one of these types: feat, fix, docs, style, refactor, perf, test, build, ci, chore
- Structure: <type>(<scope>): <description>
  Example: feat(auth): add OAuth login support
- Scope is optional but encouraged (put component or area affected)
- Use ! after type/scope for breaking changes: feat(api)!: change API response format

For the commit message body:
- Add a detailed body when the change is complex or requires explanation
- Always add a body for breaking changes with "BREAKING CHANGE:" prefix
- Separate body from subject with a blank line
- Explain "what" and "why" in the body, not "how"
- Wrap body text at 72 characters
- Example body format:
  
  This commit introduces X to solve Y problem.
  
  BREAKING CHANGE: API endpoint Z now returns JSON instead of XML.

General Git style rules:
- Try to limit the subject line to 50 characters
- Capitalize the subject line
- Do not end the subject line with any punctuation
- Use the imperative mood in the subject line

Only return the commit message(s) in your response. Do not include any additional meta-commentary.
Generate $COMMITS_TO_SUGGEST different commit suggestions.

IMPORTANT: Do not wrap your response in markdown code blocks. Do not use \`\`\` in your response at all.
Just list each commit message directly, one per line.

Here is an example of previous commit messages in this repository:

${previous_commits}

Here is the diff:

${diff_output}
EOM
)

log_message "Heredoc read and variable assignment complete."
log_message "Size of final prompt_template: ${#prompt_template} characters."

# For debugging: save the exact prompt being sent to aichat to a temporary file in /tmp
PROMPT_DEBUG_FILE="/tmp/${SCRIPT_NAME}_prompt_content_$(date +%Y%m%d_%H%M%S)_$$.txt"
echo "$prompt_template" >"$PROMPT_DEBUG_FILE"
log_message "Full prompt content saved to $PROMPT_DEBUG_FILE for inspection."
# Ensure the debug file is cleaned up on exit, even if the script fails
trap "rm -f '$PROMPT_DEBUG_FILE'" EXIT

# Call aichat, piping the prompt to its stdin.
log_message "Executing aichat command, piping prompt to stdin..."
aichat_output=$(echo "$prompt_template" | aichat --model "$AICHAT_MODEL" 2>>"$LOG_FILE")
aichat_exit_code=$?

log_message "aichat exited with code: $aichat_exit_code"

if [ $aichat_exit_code -eq 0 ]; then
	log_message "aichat raw output (for log):\n$aichat_output"
	# This output goes to lazygit's menuFromCommand
	echo "$aichat_output"
else
	log_message "aichat failed."
	# This output goes to lazygit's menuFromCommand to indicate failure
	echo "Error: Failed to generate commit messages. Check log: $LOG_FILE and prompt debug file: $PROMPT_DEBUG_FILE for details."
	exit 1
fi

log_message "Script finished."
