#!/bin/sh

if [ ! -d ./feeds/homeassistant ]; then
  echo "error: change the directory" && exit 1
fi

PACKAGES_FEED="./feeds/packages"
PATCH_DIR="./feeds/homeassistant/_patches"
PATCH_PACKAGES="\
$PATCH_DIR/lang-python-Jinja2-bump-to-3.1.2.patch
$PATCH_DIR/lang-python-numpy-downgrade.patch
$PATCH_DIR/lang-python-python-aiohttp-bump-to-3.8.1.patch
$PATCH_DIR/lang-python-python-async-timeout-bump-to-4.0.2.patch
$PATCH_DIR/lang-python-python-awesomeversion-bump-to-22.9.0.patch
$PATCH_DIR/lang-python-python-boto3-bump-to-1.16.52.patch
$PATCH_DIR/lang-python-python-botocore-bump-to-1.19.52.patch
$PATCH_DIR/lang-python-python-ciso8601-bump-to-2.2.0.patch
$PATCH_DIR/lang-python-python-multidict-bump-to-6.0.2.patch
$PATCH_DIR/lang-python-python-netdisco-bump-to-3.0.0.patch
$PATCH_DIR/lang-python-python-psutil-bump-to-5.9.4.patch
$PATCH_DIR/lang-python-python-pyotp-bump-to-2.7.0.patch
$PATCH_DIR/lang-python-python-pyserial-bump-to-3.5.patch
$PATCH_DIR/lang-python-python-s3transfer-bump-to-0.3.3.patch
$PATCH_DIR/lang-python-python-sqlalchemy-bump-to-1.4.44.patch
$PATCH_DIR/lang-python-python-typing-extensions-bump-to-4.4.0.patch
$PATCH_DIR/lang-python-python-urllib3-bump-to-1.26.5.patch
$PATCH_DIR/lang-python-python-voluptuous-bump-to-0.13.1.patch
$PATCH_DIR/lang-python-python-yarl-bump-to-1.8.1.patch
$PATCH_DIR/lang-python-python-zeroconf-bump-to-0.39.4.patch
$PATCH_DIR/lang-python-python3-netifaces-bump-to-0.11.0.patch
$PATCH_DIR/lang-python-python3-pyroute2-bump-to-0.6.13.patch
$PATCH_DIR/lang-python-xmltodict-bump-to-0.13.0.patch
$PATCH_DIR/libs-libjpeg-turbo-add-libturbojpeg.patch
$PATCH_DIR/libs-libre2-add-as-dependency.patch
"
STAMP_PACKAGES="$PATCH_DIR/.packages-patched"

backup()
{
if [ ! -f $STAMP_PACKAGES ]; then
  for PATCH in $PATCH_PACKAGES; do patch -p1 -b -d $PACKAGES_FEED < "$PATCH"; done
  touch $STAMP_PACKAGES
fi
}

check()
{
for PATCH in $PATCH_PACKAGES; do patch -p1 --dry-run -d $PACKAGES_FEED < "$PATCH"; done
}

recovery()
{
if [ -f $STAMP_PACKAGES ]; then
  for PATCH in $PATCH_PACKAGES; do patch -p1 -R -d $PACKAGES_FEED < "$PATCH"; done
  rm $STAMP_PACKAGES
  find $PACKAGES_FEED/lang/python $PACKAGES_FEED/libs -type f -name "*.orig" -delete
fi
}

case "$1" in
    backup)
	backup
	[ $? -eq 0 ] && echo "Done"
    ;;
    check)
	check
    ;;
    recovery)
	recovery
	[ $? -eq 0 ] && echo "Done"
    ;;
    *)
	echo "Usage: $0 {backup|check|recovery}"
	exit 1
    ;;
esac

exit 0