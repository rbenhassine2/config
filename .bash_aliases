

#generic aliases
alias acpy='source .venv/bin/activate'
alias vacpy='source venv/bin/activate'

#ssh aliases
alias srv_odoo='ssh -i ~/docs/sshkeys/stg_hq ubuntu@$IP_ODOO_SRV'
alias rbh_srv_odoo='ssh -i ~/.ssh/odoo_srv_raouf_key raouf@$IP_ODOO_SRV'
alias ec2_sf_utils='ssh -i ~/.ssh/id_ed25519 ubuntu@$IP_SF_UTILS'

#git aliases
alias gst='git status'
alias gl='git pull'
alias gp='git push'
alias gpsup='git push --set-upstream origin `git branch --show-current`'
alias gsw='git switch'
alias gswc='git switch -c'
alias gco='git checkout'
alias gba='git branch -a'
alias grv='git remote -v'
alias gra='git remote -a'

#systemctl aliases
alias sc-start='sudo systemctl start'
alias sc-status='sudo systemctl status'
alias sc-restart='sudo systemctl restart'
alias sc-reload='sudo systemctl reload'
alias sc-stop='sudo systemctl stop'
alias sc-enable='sudo systemctl enable'
alias sc-disable='sudo systemctl disable'
alias sc-daemon-reload='sudo systemctl daemon-reload'

#postgresql aliases
alias pg_start='pg_ctl start -D ~/pg/server -l ~/pg/postgresql.log'
alias pg_stop='pg_ctl stop -D ~/pg/server -l ~/pg/postgresql.log'
alias pg_status='pg_ctl status -D ~/pg/server -l ~/pg/postgresql.log'

#odoo aliases
alias odoo-server='./odoo17/odoo-bin -c ./odoo17/odoo.conf --dev xml'
alias odoo-shell='./odoo17/odoo-bin shell -c ./odoo17/odoo.conf'
alias config='/usr/bin/git --git-dir=/home/rbenhassine/.cfg/ --work-tree=/home/rbenhassine'
