require "application_metrics"

# Starts a background thread that serves process metrics on a Unix domain socket under tmp/.
ApplicationMetrics.serve_process_metrics
