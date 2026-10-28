#!/bin/bash
set -e
# Wait for the data volume, and format it the first time only
while [ ! -b /dev/vdb ]; do sleep 2; done
blkid /dev/vdb || mkfs.ext4 -L db-data /dev/vdb
mkdir -p /srv/db-data
echo 'LABEL=db-data /srv/db-data ext4 defaults,nofail 0 2' >> /etc/fstab
mount /srv/db-data

# Install PostgreSQL without its default cluster
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y postgresql-common
sed -i 's/^#*create_main_cluster.*/create_main_cluster = false/' /etc/postgresql-common/createcluster.conf
apt-get install -y postgresql
VERSION=$(ls /usr/lib/postgresql)

# The first time, create the cluster on the volume and move its configuration there too
if [ ! -d /srv/db-data/etc ]; then
  pg_createcluster -d /srv/db-data/"$VERSION"/main "$VERSION" main
  echo "listen_addresses = '*'" >> /etc/postgresql/"$VERSION"/main/postgresql.conf
  echo "host shop shop ${subnet_cidr} scram-sha-256" >> /etc/postgresql/"$VERSION"/main/pg_hba.conf
  mv /etc/postgresql /srv/db-data/etc
  sync
fi

# Every time, including on a rebuilt instance, use the cluster on the volume
rm -rf /etc/postgresql
ln -s /srv/db-data/etc /etc/postgresql
pg_ctlcluster "$VERSION" main start

sudo -u postgres psql -tc "SELECT 1 FROM pg_roles WHERE rolname = 'shop'" | grep -q 1 || sudo -u postgres psql -c "CREATE ROLE shop LOGIN PASSWORD '${db_password}'"
sudo -u postgres psql -tc "SELECT 1 FROM pg_database WHERE datname = 'shop'" | grep -q 1 || sudo -u postgres createdb -O shop shop
