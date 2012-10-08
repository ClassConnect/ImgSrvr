# make executing job a singleton instance

Delayed::Worker.read_ahead = 1

$stdout.sync = true
