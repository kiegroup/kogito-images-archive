#!/usr/bin/env bash
#
# S2I run script for the 'kogito-runtime-jvm' images.
# The run script executes the server that runs your application.
#
# For more information see the documentation:
#	https://github.com/openshift/source-to-image/blob/master/docs/builder_image.md
#
# Image help.
if [[ "$1" == "-h" ]]; then
    exec /usr/local/s2i/usage
    exit 0
fi
set -e

# Configuration scripts
# Any configuration script that needs to run on image startup must be added here.
CONFIGURE_SCRIPTS=(
    "${KOGITO_HOME}"/launch/configure-custom-truststore.sh
)
source ${S2I_MODULE_LOCATION}/s2i-core
source "${KOGITO_HOME}"/launch/configure.sh

runtime_type=$(get_runtime_type)

#############################################

DYNAMIC_RESOURCES_OPTS="$(${JBOSS_CONTAINER_JAVA_JVM_MODULE}/java-default-options) $(${JBOSS_CONTAINER_JAVA_JVM_MODULE}/debug-options)"

# shellcheck disable=SC2086
case ${runtime_type} in 
    "quarkus") 
        exec java ${DYNAMIC_RESOURCES_OPTS} ${JAVA_OPTIONS} ${KOGITO_QUARKUS_JVM_PROPS} ${CUSTOM_TRUSTSTORE_ARGS} \
            -Dquarkus.http.host=0.0.0.0 \
            -Dquarkus.http.port=8080 \
            -jar "${KOGITO_HOME}"/bin/*.jar
    ;;
    "springboot") 
        exec java ${DYNAMIC_RESOURCES_OPTS} ${JAVA_OPTIONS} ${KOGITO_SPRINGBOOT_PROPS} ${CUSTOM_TRUSTSTORE_ARGS} \
            -Dserver.address=0.0.0.0 -Dserver.port=8080 -jar "${KOGITO_HOME}"/bin/*.jar
    ;;
    *)
        log_error "${runtime_type} is not supported."
        exit 1
esac