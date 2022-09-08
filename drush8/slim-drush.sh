#!/usr/bin/env sh

DRUSH=drush.phar
BACKUP=$DRUSH.bak
PHAR=/usr/bin/phar81


_download() {
[ ! -e $DRUSH ] && curl -L https://github.com/drush-ops/drush/releases/download/8.4.8/drush.phar -o drush.phar
cp -n $DRUSH $BACKUP
php -dphar.readonly=0 $PHAR add -f $DRUSH files/
}

_cleanup() {
_dir=$1
_grep=$2
echo "processing dir: $_dir"
list=$($PHAR list -f $DRUSH | grep -e $DRUSH/$_grep | sed "s|.*$DRUSH/$_dir/||" )
for _file in $list; do

echo "deleting file: $_dir/$_file"

php -dphar.readonly=0 $PHAR delete -f $DRUSH -e $_dir/$_file
done
}

_download

# remove unused dirs
cleanup='
docs
examples
misc/windrush_build/assets
misc/windrush_build
'
for _dir in $cleanup; do _cleanup $_dir "$_dir/" ; done

# remove unused vendor
cleanup='
doctrine
phpdocumentor
phpspec
phpunit
sebastian
'
for _dir in $cleanup; do _cleanup vendor/$_dir "vendor/$_dir.*\.php$" ; done

#php -dphar.readonly=0 $PHAR compress -c auto -f $DRUSH
