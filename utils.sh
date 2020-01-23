set -ex

# escape_package <package>
# replaces / with __
# replaces @ with -AT-
# per docker spec, / and @ are invalid characters for docker tags
# per unix, / cannot be part of a filename (treats as directory)
escape_package() {
  node -e "console.log('$1'.replace(/\//g, '__').replace(/@/g, '-AT-'))"
}

# s3_download <s3 uri> <file>
s3_download() {
  local S3_URI=$1
  local FILE=$2

  AWS_ACCESS_KEY_ID="${WEB_CODE_AWS_KEY_ID}" \
  AWS_SECRET_ACCESS_KEY="${WEB_CODE_AWS_ACCESS_KEY}" \
  aws --region=us-west-1 \
  s3 cp $S3_URI $FILE
}

util_install_yarn_cache_tarball() {
  local PACKAGE="${1}"

  # replace slashes with __, to prevent s3 directory shenanagins
  local TARBALL_FILE="$(escape_package $PACKAGE).tar.gz"

  # download tarball from s3
  local S3_URI="s3://uber-web-monorepo/yarn-cache-tarballs/${TARBALL_FILE}"

  # if tarball does not exist, return
  local RESPONSE=$(AWS_ACCESS_KEY_ID="${WEB_CODE_AWS_KEY_ID}" \
                   AWS_SECRET_ACCESS_KEY="${WEB_CODE_AWS_ACCESS_KEY}" \
                   aws --region=us-west-1 s3 ls "$S3_URI" || true)
  if [ -z "$RESPONSE" ]; then
    echo "yarn cache tarball not found at ${S3_URI}"
    return
  fi

  # get the tarball, and unpack
  s3_download "${S3_URI}" "${TARBALL_FILE}"
  local YARN_CACHE_DIR=.yarn_cache
  mkdir -p "${YARN_CACHE_DIR}"
  tar -xf "${TARBALL_FILE}" -C "${YARN_CACHE_DIR}"
  echo "# Cached Libs: $(ls -al "${YARN_CACHE_DIR}" | wc -l)" "Total size: $(du -h -d1 "${YARN_CACHE_DIR}/..")"

  # ensures that the docker container can read/write these files as well (treat it like a shared directory)
  chmod -R 777 $YARN_CACHE_DIR

  rm "${TARBALL_FILE}"
}