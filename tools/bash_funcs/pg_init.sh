pg_init() {
  pg_ctl stop -D ~/pg/server >/dev/null 2>&1
  rm -rf ~/pg/server >/dev/null 2>&1
  mkdir -p ~/pg/server >/dev/null 2>&1
  initdb --nosync -D ~/pg/server -E UNICODE -A trust >~/pg/init.out 2>&1
  rm -f ~/pg/server/postgresql.conf
  cat <<-EOF >>~/pg/server/postgresql.conf
listen_addresses='localhost'
port=45000
max_connections=100
unix_socket_directories='/home/atp/pg/server'
dynamic_shared_memory_type=posix
fsync=off
synchronous_commit=off
full_page_writes=off
max_wal_size=48GB
min_wal_size=4GB
log_timezone='UTC'
datestyle='iso,mdy'
timezone='UTC'
lc_messages='en_US.UTF-8'
lc_monetary='en_US.UTF-8'
lc_numeric='en_US.UTF-8'
lc_time='en_US.UTF-8'
default_text_search_config='pg_catalog.english'
shared_buffers = 1GB
temp_buffers = 32MB
work_mem = 16MB
maintenance_work_mem = 256MB
vacuum_buffer_usage_limit = 256MB
log_destination = 'stderr'
logging_collector = on
# Store logs in the 'log' subdirectory of the data directory
log_directory = 'log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_statement = 'all'
checkpoint_timeout=1h
effective_cache_size = 3GB
wal_buffers = 16MB
max_worker_processes = 8
max_parallel_maintenance_workers = 2

# Debugging & Logging optimizations
log_min_duration_statement = 0
log_line_prefix = '%m [%p] %d %u '

# NVMe SSD optimizations
random_page_cost = 1.1
effective_io_concurrency = 200

# JIT optimizations
jit = off

# Parallelism tuning
max_parallel_workers_per_gather = 2
max_parallel_workers = 4
EOF
  pg_start
}
