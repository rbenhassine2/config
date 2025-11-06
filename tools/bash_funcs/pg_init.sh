pg_init(){
    pg_ctl stop -D ~/pg/server > /dev/null 2>&1
    rm -rf ~/pg/server > /dev/null 2>&1
    mkdir -p ~/pg/server > /dev/null 2>&1
    initdb --nosync -D ~/pg/server -E UNICODE -A trust > ~/pg/init.out 2>&1
    rm -f ~/pg/server/postgresql.conf
    cat <<- EOF >> ~/pg/server/postgresql.conf
listen_addresses='localhost'
port=45000
max_connections=100
unix_socket_directories='/home/`whoami`/pg/server'
dynamic_shared_memory_type=posix
fsync=off
synchronous_commit=off
full_page_writes=off
max_wal_size=1GB
min_wal_size=80MB
log_timezone='UTC'
datestyle='iso,mdy'
timezone='UTC'
lc_messages='en_US.UTF-8'
lc_monetary='en_US.UTF-8'
lc_numeric='en_US.UTF-8'
lc_time='en_US.UTF-8'
default_text_search_config='pg_catalog.english'
shared_buffers = 6GB
temp_buffers = 256MB
work_mem = 6GB
maintenance_work_mem = 6GB
vacuum_buffer_usage_limit = 2GB
vacuum_buffer_usage_limit = 512MB
log_destination = 'stderr'
logging_collector = on
# Store logs in the 'log' subdirectory of the data directory
log_directory = 'log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_statement = 'all'
EOF
    pg_start
}