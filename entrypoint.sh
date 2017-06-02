#!/bin/sh

if [ "${1}" == "mysqld" ]; then
  if [ ! -d "${MYSQL_DIR}"/mysql ]; then
    if [ -z "${MYSQL_ROOT_PASSWORD}" -a -z "${MYSQL_ALLOW_EMPTY_PASSWORD}" ]; then
      echo >&2 'error: database is uninitialized and MYSQL_ROOT_PASSWORD not set'
      echo >&2 '  Did you forget to add -e MYSQL_ROOT_PASSWORD=... ?'
      exit 1
    fi

    echo 'Initializing database'
    mysql_install_db --ldata=${MYSQL_DIR} --basedir=/usr/ --user=mysql
    echo 'Database initialized'

    tempSqlFile='/tmp/mysql-first-time.sql'
    cat > ${tempSqlFile} << EOSQL
      DELETE FROM mysql.user ;
      CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' ;
      GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
      DROP DATABASE IF EXISTS test ;
EOSQL

    if [ ! -z "${MYSQL_DATABASE}" ]; then
      echo "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` ;" >> ${tempSqlFile}
    fi

    if [ ! -z "${MYSQL_USER}" -a ! -z ${MYSQL_PASSWORD} ]; then
      echo "CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}' ;" >> ${tempSqlFile}

      if [ ! -z "${MYSQL_DATABASE}" ]; then
        echo "GRANT ALL ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%' ;" >> ${tempSqlFile}
      fi
    fi

    echo 'FLUSH PRIVILEGES ;' >> ${tempSqlFile}

    set -- "$@" --init-file=${tempSqlFile}
  fi

  chown -R mysql:mysql ${MYSQL_DIR}
  sed -i "s|^socket.*|socket=${MYSQL_DIR}/mysql.sock|" /etc/mysql/my.cnf
fi

exec "$@"
